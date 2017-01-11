port module Spec.Runner exposing (..)

import Spec.Types exposing (Outcome(..), Assertion)
import Spec.Steps
import Spec exposing (Test)
import Spec.Styles as Styles exposing (stylesheet)

import Task
import Json.Encode

import Html.Attributes exposing (style, property)
import Html exposing (div, strong, text)

type alias State a msg =
  { tests : List Test
  , finishedTests : List Test
  , app : a
  , update : msg -> a -> (a, Cmd msg)
  , view : a -> Html.Html msg
  }

type Msg msg
  = Next (Maybe Outcome)
  | App msg

perform : Msg msg -> Cmd (Msg msg)
perform msg =
  Task.perform (\_ -> msg) (Task.succeed "")

update : Msg msg -> State app msg -> (State app msg, Cmd (Msg msg))
update msg model =
  case msg of
    App appMsg ->
      let
        (app, cmd) = model.update appMsg model.app
      in
        { model | app = app } ! [Cmd.map App cmd]

    Next maybeResult ->
      case model.tests of
        test :: remainingTests ->
          let
            updatedTest =
              case maybeResult of
                Just result ->
                  { test | results = test.results ++ [result] }
                Nothing -> test
          in
            case test.steps of
              step :: remainingSteps ->
                { model
                | tests = { updatedTest | steps = remainingSteps } :: remainingTests
                } !
                [ Native.Spec.raf
                  |> Task.andThen (\_ -> step)
                  |> Task.perform (Next << Just)
                ]

              [] ->
                { model
                | tests = remainingTests
                , finishedTests = model.finishedTests ++ [updatedTest]
                } ! [perform (Next Nothing)]
        [] ->
          model ! [elmSpecReport (List.map transformTest model.finishedTests)]

runCmd : List Test -> Cmd (Msg msg)
runCmd tests =
  case tests of
    test :: tail ->
      perform (Next Nothing)
    [] -> elmSpecReport []

run tests =
  let
    tests_ =
      Spec.flatten [] [] tests
  in
    Html.program
      { init = ({ app = "", update = (\_ _ -> ("", Cmd.none)), view = (\_ -> Html.text ""), tests = tests_, finishedTests = [] }, runCmd tests_)
      , update = update
      , subscriptions = (\_ -> Sub.none)
      , view = \model ->
        if List.isEmpty model.tests then
          Html.div [ stylesheet.class Styles.Container ]
            (renderResults model.finishedTests)
        else
          Html.text ""
      }

runWithProgram data tests =
  let
    tests_ =
      Spec.flatten [] [] tests
  in
    Html.program
      { init = ({ app = data.init, update = data.update, view = data.view, tests = tests_, finishedTests = [] }, runCmd tests_)
      , update = update
      , subscriptions = (\_ -> Sub.none)
      , view = \model ->
        if List.isEmpty model.tests then
          Html.div [ stylesheet.class Styles.Container ]
            ([ Styles.embed] ++ (renderResults model.finishedTests))
        else
          Html.map App (model.view model.app)
      }

renderTest model =
  let
    renderLine result =
      let
        teststyle =
          case result of
            Pass _ -> style [("color", "green")]
            Error _ -> style [("color", "white"), ("background-color", "red")]
            Fail _ -> style [("color", "red")]
      in
        div
        [ teststyle
        , stylesheet.class Styles.Test
        , property "innerHTML" (Json.Encode.string (Native.Spec.ansiToHtml (stepToString result)))
        ] []
  in
    div [ stylesheet.class Styles.Row ]
      ([ strong [] [ text model.name ]
      ] ++ (List.map renderLine model.results ))

stepToString result =
  case result of
    Pass message -> message
    Fail message -> message
    Error message -> message

renderResults tests =
  List.map renderTest tests


type alias TestResult =
  { results : List { outcome : String, message : String }
  , name : String
  }

transformResult result =
  case result of
    Pass message -> { outcome = "pass", message = message }
    Fail message -> { outcome = "fail", message = message }
    Error message -> { outcome = "error", message = message }

transformTest test =
  { results = List.map transformResult test.results
  , name = test.name
  }

port elmSpecReport : List TestResult -> Cmd msg
