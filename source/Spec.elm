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
  )

{-| This module provides a way to test Elm apps end-to-end in the browser.

# Types
@docs Test, Node, flatten

# Grouping
@docs group, context, describe

# Defining Tests
@docs it, test

# Hooks
@docs before, after
-}
import Spec.Types exposing (..)
import Spec.Steps

import Task exposing (Task)


{-| Representation of a test.
-}
type alias Test =
  { steps : List Assertion
  , results : List Outcome
  , indentation : Int
  , name : String
  }


{-| Representation of a test group.
-}
type alias Group =
  { nodes : List Node
  , name : String
  }


{-| Representation of a test tree (Node).
-}
type Node
  = GroupNode Group
  | TestNode Test
  | Before (List Assertion)
  | After (List Assertion)


{-| Turns a tree into a flat list of tests.
-}
flatten : List String -> List Test -> Node -> List Test
flatten path tests node =
  case node of
    Before steps ->
      tests

    After steps ->
      tests

    GroupNode node ->
      let
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
      in
        List.map (flatten (path ++ [node.name]) []) filteredNodes
          |> List.foldr (++) tests
          |> List.map (\test -> { test | steps = beforeSteps ++ test.steps ++ afterSteps })

    TestNode node ->
      tests ++
        [ { node
          | name = (String.join " / " (path ++ [node.name]))
          , indentation = List.length path
          }
        ]

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
    { indentation = 0
    , steps = steps
    , results = []
    , name = name
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
