module Spec exposing
  ( Test
  , Node
  , flatten
  , group
  , context
  , describe
  , it
  , test
  )

{-| This module provides a way to test Elm apps end-to-end in the browser.
-}
import Spec.Types exposing (Assertion, Outcome)
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

{-| Representation of a node.
-}
type Node
  = GroupNode Group
  | TestNode Test

flatten : List String -> List Test -> Node -> List Test
flatten path tests node =
  case node of
    GroupNode node ->
      List.map (flatten (path ++ [node.name]) []) node.nodes
      |> List.foldr (++) tests

    TestNode node ->
      tests ++
        [ { node
          | name = (String.join " " (path ++ [node.name]))
          , indentation = List.length path
          }
        ]

group : String -> List Node -> Node
group name nodes =
  GroupNode { name = name, nodes = nodes }

context : String -> List Node -> Node
context =
  group

describe : String -> List Node -> Node
describe =
  group

test : String -> List Assertion -> Node
test =
  it

it : String -> List Assertion -> Node
it name steps =
  TestNode
    { steps = steps
    , name = name
    , results = []
    , indentation = 0
    }
