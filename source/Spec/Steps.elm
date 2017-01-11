module Spec.Steps exposing (..)

import Task exposing (Task)

click : String -> Task String String
click selector =
  Native.Spec.click selector

getAttribute : String -> String -> Task String String
getAttribute attribute selector =
  Native.Spec.getAttribute attribute selector
