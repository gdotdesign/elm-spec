module Spec.Assertions exposing (..)

import Task exposing (Task)

import Spec.Types exposing (..)
import Spec.Native

fail : String -> Outcome
fail message =
  Fail message

pass : String -> Outcome
pass message =
  Pass message

error : String -> Outcome
error message =
  Error message

switch : Assertion -> Assertion
switch =
  Task.map (\result ->
    case result of
      Fail message -> Pass message
      Pass message -> Fail message
      _ -> result
  )

assert :
  { containsText : TextData -> Assertion
  , attributeContains : AttributeData -> Assertion
  , attributeEquals : AttributeData -> Assertion
  , classPresent : ClassData -> Assertion
  , styleEquals : StyleData -> Assertion
  , not :
    { containsText : TextData -> Assertion
    , attributeContains : AttributeData -> Assertion
    , attributeEquals : AttributeData -> Assertion
    , classPresent : ClassData -> Assertion
    , styleEquals : StyleData -> Assertion
    }
  }
assert =
  { containsText = Spec.Native.containsText
  , attributeContains = Spec.Native.attributeContains
  , attributeEquals = Spec.Native.attributeEquals
  , classPresent = Spec.Native.classPresent
  , styleEquals = Spec.Native.styleEquals
  , not =
    { containsText = Spec.Native.containsText >> switch
    , attributeContains = Spec.Native.attributeContains >> switch
    , attributeEquals = Spec.Native.attributeEquals >> switch
    , classPresent = Spec.Native.classPresent >> switch
    , styleEquals = Spec.Native.styleEquals >> switch
    }
  }
