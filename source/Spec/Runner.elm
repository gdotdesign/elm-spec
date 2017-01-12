module Spec.Runner exposing (run, runWithProgram)

{-| This module runs the tests with or without an app.

@docs run, runWithProgram
-}
import Spec.Types exposing (Outcome(..), Assertion)
import Spec exposing (Test, Node)
import Spec.Reporter
import Spec.Steps

import Json.Encode as Json
import Task
import Html


{-| Represents the state of a test program.
-}
type alias State model msg =
  { update : msg -> model -> ( model, Cmd msg )
  , view : model -> Html.Html msg
  , finishedTests : List Test
  , tests : List Test
  , app : model
  }


{-| Messages for a test program.
-}
type Msg msg
  = Next (Maybe Outcome)
  | NoOp ()
  | App msg


{-| Representation of an app.
-}
type alias Prog model msg =
  { update : msg -> model -> ( model, Cmd msg )
  , subscriptions : model -> Sub msg
  , view : model -> Html.Html msg
  , init : model
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
            case test.steps of
              -- Take the nex step
              step :: remainingSteps ->
                let
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
  if List.isEmpty model.tests then
    Spec.Reporter.render model.finishedTests
  else
    Html.map App (model.view model.app)


{-| Runs the given tests without an app / component.
-}
run : Node -> Program Never (State String msg) (Msg msg)
run tests =
  runWithProgram
    { update = (\_ _ -> ( "", Cmd.none ))
    , subscriptions = (\_ -> Sub.none)
    , view = (\_ -> Html.text "")
    , init = ""
    }
    tests


{-| Runs the given tests with the given app / component.
-}
runWithProgram : Prog model msg -> Node -> Program Never (State model msg) (Msg msg)
runWithProgram data tests =
  Html.program
    { subscriptions = (\model -> Sub.map App (data.subscriptions model.app))
    , update = update
    , view = view
    , init =
      ( { tests = (Spec.flatten [] [] tests)
        , update = data.update
        , finishedTests = []
        , view = data.view
        , app = data.init
        }
      , perform (Next Nothing)
      )
    }


{-| Sends the report to the CLI when running tests in a terminal.
-}
report : List Test -> Cmd (Msg msg)
report tests =
  let
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
        , ( "results", Json.list (List.map encodeResult test.results) )
        ]

    data =
      Json.list (List.map encodeTest tests)
  in
    Task.perform NoOp (Native.Spec.report data)
