module Spec.Types exposing (..)

import Task exposing (Task)

type alias Assertion
  = Task Never Outcome

type alias Step = Assertion

type Outcome
  = Error String
  | Fail String
  | Pass String

type alias TextData =
  { text : String, selector : String }

type alias AttributeData =
  { text : String, selector : String, attribute : String }

type alias ClassData =
  { class : String, selector : String }

type alias StyleData =
  { style : String, value : String, selector : String }
