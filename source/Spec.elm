module Spec exposing
  ( Node
  , Test
  , flatten
  , group
  , context
  , describe
  , it
  , test
  )

{-| This module provides a way to test Elm apps end-to-end in the browser.

# Types
@docs Test, Node, flatten

# Grouping
@docs group, context, describe

# Defining Tests
@docs it, test
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


{-| Turns a tree into a flat list of tests.
-}
flatten : List String -> List Test -> Node -> List Test
flatten path tests node =
  case node of
    GroupNode node ->
      List.map (flatten (path ++ [node.name]) []) node.nodes
        |> List.foldr (++) tests

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
