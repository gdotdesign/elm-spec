module Spec.Types exposing (..)

{-| This module contains the types for specs.
-}
import Task exposing (Task)

{-| Representation of a test.
-}
type alias Test =
  { layout : List (String, Rect)
  , requests : List Request
  , results : List Outcome
  , steps : List Assertion
  , path : List String
  , name : String
  , id : Int
  }


{-| Representation of a mocked request.
-}
type alias Request =
  { method : String
  , url : String
  , response :
    { status : Int
    , body : String
    }
  }

type alias Rect =
  { top : Int
  , left : Int
  , bottom : Int
  , right : Int
  , width : Int
  , height : Int
  , zIndex : Int
  }

{-| Representation of a test tree (Node).
-}
type Node
  = Layout (List (String, Rect))
  | Before (List Assertion)
  | After (List Assertion)
  | Http (List Request)
  | GroupNode Group
  | TestNode Test


{-| Representation of a test group.
-}
type alias Group =
  { nodes : List Node
  , name : String
  }


{-| Assertion is just a task that produces an outcome.
-}
type alias Assertion
  = Task Never Outcome


{-| Step is just an alias for assertion.
-}
type alias Step = Assertion


{-| Represents an outcome for a step:
  * Error - if there was an error during the step (element not found for example)
  * Fail - represents failure
  * Pass - represents success
-}
type Outcome
  = Error String
  | Fail String
  | Pass String


{-| Text data for assertions.
-}
type alias TextData =
  { text : String, selector : String }


{-| Text data for assertions.
-}
type alias ValueData =
  { value : String, selector : String }


{-| Attribute data for assertions.
-}
type alias AttributeData =
  { text : String, selector : String, attribute : String }


{-| Class data for assertions.
-}
type alias ClassData =
  { class : String, selector : String }


{-| Style data for assertions.
-}
type alias StyleData =
  { style : String, value : String, selector : String }


{-| Gets the message from an outcome.
-}
outcomeToString : Outcome -> String
outcomeToString outcome =
  case outcome of
    Error message -> message
    Pass message -> message
    Fail message -> message


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

    Layout layout ->
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

        getLayouts nd =
          case nd of
            Layout layouts -> layouts
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

        layout =
          List.map getLayouts node.nodes
            |> List.foldr (++) []
      in
        List.map (flatten []) filteredNodes
          |> List.foldr (++) tests
          |> List.map (\test ->
            { test
            | steps = beforeSteps ++ test.steps ++ afterSteps
            , requests = test.requests ++ requests
            , path = [node.name] ++ test.path
            , layout = test.layout ++ layout
            })

    TestNode node ->
      tests ++ [ node ]
