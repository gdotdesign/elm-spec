module Spec.Types exposing (..)

{-| This module contains the types for specs.
-}
import Task exposing (Task)


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
