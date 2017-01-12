module Spec.Expect exposing (..)

import Spec.Assertions exposing (fail, pass)
import Spec.Types exposing (..)
import Task exposing (Task)

equals : a -> String -> Task Never a -> Assertion
equals expected message  =
  Task.map (\actual ->
    if actual == expected then
      pass message
    else
      fail (message ++ "\n" ++ (toString actual) ++ " <=> " ++ (toString expected))
  )
