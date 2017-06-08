module Spec exposing
  ( Outcome
  , Node
  , Step
  , Test
  , group
  , context
  , describe
  , it
  , test
  , before
  , after
  , http
  , layout
  , stepGroup
  , assert
  , steps
  , run
  , runWithProgram
  )

{-| This module provides a way to test Elm apps end-to-end in the browser.

# Types
@docs Test, Node, Step

# Grouping
@docs group, context, describe

# Grouping steps / assertions
@docs stepGroup

# Assertions
@docs Outcome, assert

# Steps
@docs steps

# Defining Tests
@docs it, test

# Hooks
@docs before, after

# Http
@docs http

# Layout
@docs layout

# Running
@docs run, runWithProgram
-}
import Spec.Assertions exposing (pass, fail, error)
import Spec.Runner exposing (Prog, State)
import Spec.Messages exposing (Msg)
import Spec.Types exposing (..)
import Spec.CoreTypes exposing (..)
import Spec.Native

import Task exposing (Task)
import Json.Decode as Json

{-| Representation of a step.
-}
type alias Step =
  Spec.Types.Step

{-| Representation of a test.
-}
type alias Test msg =
  Spec.Types.Test msg


{-| The outcome of an assertion or step.
-}
type alias Outcome
  = Spec.CoreTypes.Outcome


{-| Representation of a test tree (Node).
-}
type alias Node msg =
  Spec.Types.Node msg


flip =
  Spec.Assertions.flip

{-| Groups the given tests and groups into a new group.

    group "description"
      [ it "should do something" []
      , group "sub group"
        [ it "should do something else" []
        ]
      ]
-}
group : String -> List (Node msg) -> Node msg
group name nodes =
  GroupNode { name = name, nodes = nodes }


{-| Alias for `group`.
-}
context : String -> List (Node msg) -> Node msg
context =
  group


{-| Alias for `group`.
-}
describe : String -> List (Node msg) -> Node msg
describe =
  group


{-| Creates a test from the given steps / assertions.

    test "description"
-}
test : String -> List Assertion -> Node msg
test name steps =
  TestNode
    { steps = steps
    , requests = []
    , results = []
    , layout = []
    , name = name
    , path = []
    , id = -1
    , initCmd = Nothing
    }


{-| Alias for `it`.
-}
it : String -> List Assertion -> Node msg
it =
  test


{-|-}
before : List Assertion -> Node msg
before =
  Before

{-|-}
layout : List (String, Rect) -> Node msg
layout =
  Layout

{-|-}
after : List Assertion -> Node msg
after =
  After


{-|-}
http : List Request -> Node msg
http =
  Http


{-| Groups the given steps into a step group. Step groups makes it easy to
run multiple steps under one message.
-}
stepGroup : String -> List Assertion -> Assertion
stepGroup message steps =
  let
    isError outcome =
      case outcome of
        Error _ -> True
        _ -> False

    isFail outcome =
      case outcome of
        Fail _ -> True
        _ -> False

    mapTask task =
      Task.andThen (\_ -> task) Native.Spec.raf

    handleResults results =
      if List.any isError results then
        let
          errorMessage =
            List.filter isError results
              |> List.head
              |> Maybe.map outcomeToString
              |> Maybe.withDefault ""
        in
          Task.succeed (error (message ++ ":\n  " ++ errorMessage))
      else if List.any isFail results then
        let
          failureMessage =
            List.filter isFail results
              |> List.head
              |> Maybe.map outcomeToString
              |> Maybe.withDefault ""
        in
          Task.succeed (fail (message ++ ":\n  " ++ failureMessage))
      else
        Task.succeed (pass message)
  in
    List.map mapTask steps
      |> Task.sequence
      |> Task.andThen handleResults


{-| A record for quickly accessing assertions and giving it a readable format.

    it "should do something"
      [ assert.not.containsText { text = "something", selector = "div" }
      , assert.styleEquals
        { style = "display", value = "block", selector = "div" }
      ]
-}
assert :
  { attributeContains : AttributeData -> Assertion
  , attributeEquals : AttributeData -> Assertion
  , inlineStyleEquals : StyleData -> Assertion
  , valueContains : TextData -> Assertion
  , classPresent : ClassData -> Assertion
  , containsText : TextData -> Assertion
  , styleEquals : StyleData -> Assertion
  , elementPresent : String -> Assertion
  , elementVisible : String -> Assertion
  , titleContains : String -> Assertion
  , valueEquals : TextData -> Assertion
  , titleEquals : String -> Assertion
  , urlContains : String -> Assertion
  , urlEquals : String -> Assertion
  , not :
    { attributeContains : AttributeData -> Assertion
    , attributeEquals : AttributeData -> Assertion
    , inlineStyleEquals : StyleData -> Assertion
    , valueContains : TextData -> Assertion
    , classPresent : ClassData -> Assertion
    , containsText : TextData -> Assertion
    , styleEquals : StyleData -> Assertion
    , elementPresent : String -> Assertion
    , elementVisible : String -> Assertion
    , titleContains : String -> Assertion
    , valueEquals : TextData -> Assertion
    , titleEquals : String -> Assertion
    , urlContains : String -> Assertion
    , urlEquals : String -> Assertion
    }
  }
assert =
  { attributeContains = Spec.Native.attributeContains
  , inlineStyleEquals = Spec.Native.inlineStyleEquals
  , attributeEquals = Spec.Native.attributeEquals
  , elementPresent = Spec.Native.elementPresent
  , elementVisible = Spec.Native.elementVisible
  , valueContains = Spec.Native.valueContains
  , titleContains = Spec.Native.titleContains
  , containsText = Spec.Native.containsText
  , classPresent = Spec.Native.classPresent
  , styleEquals = Spec.Native.styleEquals
  , titleEquals = Spec.Native.titleEquals
  , valueEquals = Spec.Native.valueEquals
  , urlContains = Spec.Native.urlContains
  , urlEquals = Spec.Native.urlEquals
  , not =
    { attributeContains = Spec.Native.attributeContains >> flip
    , inlineStyleEquals = Spec.Native.inlineStyleEquals >> flip
    , attributeEquals = Spec.Native.attributeEquals >> flip
    , elementPresent = Spec.Native.elementPresent >> flip
    , elementVisible = Spec.Native.elementVisible >> flip
    , valueContains = Spec.Native.valueContains >> flip
    , titleContains = Spec.Native.titleContains >> flip
    , containsText = Spec.Native.containsText >> flip
    , classPresent = Spec.Native.classPresent >> flip
    , styleEquals = Spec.Native.styleEquals >> flip
    , titleEquals = Spec.Native.titleEquals >> flip
    , valueEquals = Spec.Native.valueEquals >> flip
    , urlContains = Spec.Native.urlContains >> flip
    , urlEquals = Spec.Native.urlEquals >> flip
    }
  }


{-| Common steps for testing web applications (click, fill, etc..)
-}
steps :
  { dispatchEvent : String -> Json.Value -> String -> Step
  , getAttribute : String -> String -> Task Never String
  , setValue : String -> String -> Step
  , getTitle : Task Never String
  , clearValue : String -> Step
  , getUrl : Task Never String
  , click : String -> Step
  }
steps =
  { dispatchEvent = Native.Spec.dispatchEvent
  , getAttribute =Native.Spec.getAttribute
  , clearValue = Native.Spec.clearValue
  , getTitle = Native.Spec.getTitle
  , setValue = Native.Spec.setValue
  , getUrl = Native.Spec.getUrl
  , click = Native.Spec.click
  }


{-| Runs the given tests without an app / component.
-}
run : Node msg -> Program Never (State String msg) (Msg msg)
run =
  Spec.Runner.run


{-| Runs the given tests with the given app / component.
-}
runWithProgram : Prog model msg -> Node msg -> Program Never (State model msg) (Msg msg)
runWithProgram =
  Spec.Runner.runWithProgram
