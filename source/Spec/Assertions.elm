module Spec.Assertions exposing (..)

{-| Utility functions for assertions.

# Outcome
@docs Outcome, fail, pass, error, flip
-}

import Spec.Types exposing (..)
import Task exposing (Task)
import Spec.CoreTypes exposing (Outcome(..))

{-| The outcome of an assertion or step.
-}
type alias Outcome
  = Spec.CoreTypes.Outcome

{-| Creates a failed outcome with the given message.
-}
fail : String -> Outcome
fail message =
  Fail message


{-| Creates a passing outcome with the given message.
-}
pass : String -> Outcome
pass message =
  Pass message


{-| Creates an error outcome with the given message.
-}
error : String -> Outcome
error message =
  Error message


{-| Filps the meaning of an assertion: faliures become passes, passes
become failures and errors remain errors.
-}
flip : Assertion -> Assertion
flip =
  Task.map (\result ->
    case result of
      Fail message -> Pass message
      Pass message -> Fail message
      _ -> result
  )

