module Spec.CoreTypes exposing (..)


{-| Represents an outcome for a step:
  * Error - if there was an error during the step (element not found for example)
  * Fail - represents failure
  * Pass - represents success
-}
type Outcome
  = Error String
  | Fail String
  | Pass String
