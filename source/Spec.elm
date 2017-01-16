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

# Http
@docs http
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
  , requests : List Request
  , id : Int
  }


{-| Representation of a test group.
-}
type alias Group =
  { nodes : List Node
  , name : String
  }


type alias Request =
  { url : String
  , method : String
  , response :
    { status : Int
    , body : String
    }
  }

{-| Representation of a test tree (Node).
-}
type Node
  = GroupNode Group
  | TestNode Test
  | Before (List Assertion)
  | After (List Assertion)
  | Http (List Request)


{-| Turns a tree into a flat list of tests.
-}
flatten : List String -> List Test -> Node -> List Test
flatten path tests node =
  case node of
    Before steps ->
      tests

    After steps ->
      tests

    Http mocks ->
      tests

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
        List.map (flatten (path ++ [node.name]) []) filteredNodes
          |> List.foldr (++) tests
          |> List.map (\test ->
            { test
            | steps = beforeSteps ++ test.steps ++ afterSteps
            , requests = test.requests ++ requests
            })

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
    , requests = []
    , results = []
    , name = name
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
