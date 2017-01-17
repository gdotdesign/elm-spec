module Spec exposing
  ( Node
  , Test
  , flatten
  , group
  , context
  , describe
  , it
  , test
  , before
  , after
  , http
  , stepGroup
  )

{-| This module provides a way to test Elm apps end-to-end in the browser.

# Types
@docs Test, Node, flatten

# Grouping
@docs group, context, describe

# Grouping steps / assertions
@docs stepGroup

# Defining Tests
@docs it, test

# Hooks
@docs before, after

# Http
@docs http
-}
import Spec.Assertions exposing (pass, fail, error)
import Spec.Types exposing (..)
import Spec.Steps

import Task exposing (Task)


{-| Representation of a test.
-}
type alias Test =
  { requests : List Request
  , results : List Outcome
  , steps : List Assertion
  , path : List String
  , name : String
  , id : Int
  }


{-| Representation of a test group.
-}
type alias Group =
  { nodes : List Node
  , name : String
  }


{-| Representatio of a mocked request.
-}
type alias Request =
  { method : String
  , url : String
  , response :
    { status : Int
    , body : String
    }
  }


{-| Representation of a test tree (Node).
-}
type Node
  = Before (List Assertion)
  | After (List Assertion)
  | Http (List Request)
  | GroupNode Group
  | TestNode Test


{-| Turns a tree into a flat list of tests.
-}
flatten : List Test -> Node -> List Test
flatten tests node =
  case node of
    -- There branches are processed in the group below
    Before steps ->
      tests

    After steps ->
      tests

    Http mocks ->
      tests

    {- Process a group node:
       * add before and after hooks to test
       * add requests to tests
    -}
    GroupNode node ->
      let
        getRequests nd =
          case nd of
            Http requests -> requests
            _ -> []

        getBefores nd =
          case nd of
            Before steps -> steps
            _ -> []

        getAfters nd =
          case nd of
            After steps -> steps
            _ -> []

        filterNodes nd =
          case nd of
            After _ -> False
            Before _ -> False
            _ -> True

        beforeSteps =
          List.map getBefores node.nodes
            |> List.foldr (++) []

        afterSteps =
          List.map getAfters node.nodes
            |> List.foldr (++) []

        filteredNodes =
          List.filter filterNodes node.nodes

        requests =
          List.map getRequests node.nodes
            |> List.foldr (++) []
      in
        List.map (flatten []) filteredNodes
          |> List.foldr (++) tests
          |> List.map (\test ->
            { test
            | steps = beforeSteps ++ test.steps ++ afterSteps
            , requests = test.requests ++ requests
            , path = [node.name] ++ test.path
            })

    TestNode node ->
      tests ++ [ node ]

{-| Groups the given tests and groups into a new group.

    group "description"
      [ it "should do something" []
      , group "sub group"
        [ it "should do something else" []
        ]
      ]
-}
group : String -> List Node -> Node
group name nodes =
  GroupNode { name = name, nodes = nodes }


{-| Alias for `group`.
-}
context : String -> List Node -> Node
context =
  group


{-| Alias for `group`.
-}
describe : String -> List Node -> Node
describe =
  group


{-| Creates a test from the given steps / assertions.

    test "description"
-}
test : String -> List Assertion -> Node
test name steps =
  TestNode
    { steps = steps
    , requests = []
    , results = []
    , name = name
    , path = []
    , id = -1
    }


{-| Alias for `it`.
-}
it : String -> List Assertion -> Node
it =
  test


{-|-}
before : List Assertion -> Node
before =
  Before


{-|-}
after : List Assertion -> Node
after =
  After


{-|-}
http : List Request -> Node
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
          Task.succeed (error (message ++ ": " ++ errorMessage))
      else if List.any isFail results then
        let
          failureMessage =
            List.filter isFail results
              |> List.head
              |> Maybe.map outcomeToString
              |> Maybe.withDefault ""
        in
          Task.succeed (fail (message ++ ": " ++ failureMessage))
      else
        Task.succeed (pass message)
  in
    List.map mapTask steps
      |> Task.sequence
      |> Task.andThen handleResults
