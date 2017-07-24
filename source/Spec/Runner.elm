module Spec.Runner exposing (..)

{-| This module runs the tests with or without an app.

@docs run, runWithProgram
-}
import Spec.Types exposing (Assertion, Test, Node)
import Spec.CoreTypes exposing (Outcome(..))
import Spec.Messages exposing (Msg(..))
import Spec.Reporter

import Json.Encode as Json
import Task

import Html.Keyed
import Html


{-| Represents the state of a test program.
-}
type alias State model msg =
  { update : msg -> model -> ( model, Cmd msg )
  , view : model -> Html.Html msg
  , finishedTests : List (Test msg)
  , appInit : () -> model
  , tests : List (Test msg)
  , counter : Int
  , app : model
  }

{-| Representation of an app.
-}
type alias Prog model msg =
  { update : msg -> model -> ( model, Cmd msg )
  , subscriptions : model -> Sub msg
  , view : model -> Html.Html msg
  , init : () -> model
  , initCmd : Cmd msg
  }


{-| Perform a message as a task.
-}
perform : Msg msg -> Cmd (Msg msg)
perform msg =
  Task.perform (\_ -> msg) (Task.succeed "")


{-| Updates the state of the test, running a step at a time.
-}
update : Msg msg -> State app msg -> ( State app msg, Cmd (Msg msg) )
update msg model =
  case msg of
    NoOp _ ->
      ( model, Cmd.none )

    App appMsg ->
      let
        (app, cmd) = model.update appMsg model.app
      in
        { model | app = app } ! [Cmd.map App cmd]

    Next maybeResult ->
      case model.tests of
        -- Take the next test
        test :: remainingTests ->
          let
            -- If we got a result add it to the test
            updatedTest =
              case maybeResult of
                Just result ->
                  { test | results = test.results ++ [result] }

                Nothing -> test
          in
            case test.initCmd of
                Just cmd ->
                    -- if there is app init Cmd to run, run it
                    let
                        _ =
                            Native.Spec.mockHttpRequests test

                        _ =
                            Native.Spec.setLayout test.layout

                        testWithoutCmd = { test | initCmd = Nothing }
                    in
                        ({ model | tests = testWithoutCmd :: remainingTests }, Cmd.batch [ cmd, perform (Next Nothing) ] )
                Nothing ->
                    case test.steps of
                      -- Take the next step
                      step :: remainingSteps ->
                        let
                          _ =
                            Native.Spec.mockHttpRequests test

                          _ =
                            Native.Spec.setLayout test.layout

                          -- Remove that step from the test
                          testWithoutStep =
                            { updatedTest | steps = remainingSteps }

                          -- Create a task from that step
                          stepTask =
                            Native.Spec.raf
                              |> Task.andThen (\_ -> step)
                              |> Task.perform (Next << Just)
                        in
                          -- Execute
                          ( { model | tests = testWithoutStep :: remainingTests }
                          , stepTask
                          )

                      -- If there is no other steps go for the next test
                      [] ->
                        ( { model
                          | finishedTests = model.finishedTests ++ [updatedTest]
                          , counter = model.counter + 1
                          , app = model.appInit ()
                          , tests = remainingTests
                          }
                        , perform (Next Nothing)
                        )

        -- When everything is finished report
        [] ->
          ( model, report model.finishedTests )


{-| Renders the app and the report when finished.
-}
view : State model msg -> Html.Html (Msg msg)
view model =
  let
    app : (String, Html.Html (Msg msg))
    app =
      ( toString model.counter, Html.map App (model.view model.app) )

    nodes =
      if List.isEmpty model.tests then
        [ app
        , ( "report", Html.map App (Spec.Reporter.render model.finishedTests) )
        ]
      else
        [ app ]

  in
    Html.Keyed.node "testing-node-123456" [] nodes


{-| Runs the given tests without an app / component.
-}
run : Node msg -> Program Never (State String msg) (Msg msg)
run tests =
  runWithProgram
    { update = (\_ _ -> ( "", Cmd.none ))
    , subscriptions = (\_ -> Sub.none)
    , view = (\_ -> Html.text "")
    , init = (\_ -> "")
    , initCmd = Cmd.none
    }
    tests


{-| Runs the given tests with the given app / component.
-}
runWithProgram : Prog model msg -> Node msg -> Program Never (State model msg) (Msg msg)
runWithProgram data tests =
  let
    processedTests : Cmd (Msg msg) -> List (Test msg)
    processedTests initCmd =
      tests
      |> Spec.Types.flatten []
      |> List.indexedMap (\index item -> { item | id = index, initCmd = Just initCmd })

    testToRun : Cmd (Msg msg) -> List (Test msg)
    testToRun initCmd =
      case Native.Spec.getTestId () of
        Just id -> List.filter (.id >> ((==) id)) (processedTests initCmd)
        Nothing -> processedTests initCmd
  in
    Html.program
      { subscriptions = (\model -> Sub.map App (data.subscriptions model.app))
      , update = update
      , view = view
      , init =
        ( { tests = testToRun (Cmd.map App data.initCmd)
          , update = data.update
          , appInit = data.init
          , finishedTests = []
          , app = data.init ()
          , view = data.view
          , counter = 0
          }
        , perform (Next Nothing)
        )
      }


{-| Sends the report to the CLI when running tests in a terminal.
-}
report : List (Test msg) -> Cmd (Msg msg)
report tests =
  let
    mockedRequests test =
      Native.Spec.getMockResults test

    notMockedRequests test =
      List.filter (\item -> not (List.member item (.called (mockedRequests test)))) test.requests

    encodeMock mock =
      Json.object
        [ ( "method", Json.string mock.method)
        , ( "url", Json.string mock.url )
        ]

    encodeResult result =
      case result of
        Pass message ->
          Json.object
            [ ( "outcome", Json.string "pass" )
            , ( "message", Json.string message )
            ]

        Fail message ->
          Json.object
            [ ( "outcome", Json.string "fail" )
            , ( "message", Json.string message )
            ]

        Error message ->
          Json.object
            [ ( "outcome", Json.string "error" )
            , ( "message", Json.string message )
            ]

    encodeTest test =
      Json.object
        [ ( "name", Json.string test.name )
        , ( "id", Json.int test.id )
        , ( "path", Json.list (List.map Json.string test.path))
        , ( "results", Json.list (List.map encodeResult test.results) )
        , ( "unhandledRequests"
          , mockedRequests test
            |> .unhandled
            |> List.map encodeMock
            |> Json.list
          )
        , ( "mockedRequests"
          , mockedRequests test
            |> .called
            |> List.map encodeMock
            |> Json.list
          )
        , ( "notMockedRequests", Json.list (List.map encodeMock (notMockedRequests test)))
        ]

    data =
      Json.list (List.map encodeTest tests)
  in
    Task.perform NoOp (Native.Spec.report data)
