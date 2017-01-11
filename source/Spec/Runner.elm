port module Spec.Runner exposing
  ( run
  , runWithProgram
  )

{-| This module runs the tests with or without an app.

@docs run, runWithProgram
-}
import Spec.Types exposing (Outcome(..), Assertion)
import Spec exposing (Test, Node)
import Spec.Reporter
import Spec.Steps

import Task

import Html

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

{-| Runs the given tests without an app / component.
-}
run : Node -> Program Never (State String msg) (Msg msg)
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
          Spec.Reporter.render model.finishedTests
        else
          Html.map App (model.view model.app)
      }

{-| Runs the given tests with the given app / component.
-}
runWithProgram : { init : model, update : msg -> model -> (model, Cmd msg), subscriptions : model -> Sub msg, view : model -> Html.Html msg } -> Node -> Program Never (State model msg) (Msg msg)
runWithProgram data tests =
  let
    tests_ =
      Spec.flatten [] [] tests
  in
    Html.program
      { init = ({ app = data.init, update = data.update, view = data.view, tests = tests_, finishedTests = [] }, runCmd tests_)
      , update = update
      , subscriptions = (\model -> Sub.map App (data.subscriptions model.app))
      , view = \model ->
        if List.isEmpty model.tests then
          Spec.Reporter.render model.finishedTests
        else
          Html.map App (model.view model.app)
      }

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
