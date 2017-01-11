module Spec.Assertions exposing
  ( fail
  , pass
  , error
  , assert
  )

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
  { attributeContains : AttributeData -> Assertion
  , attributeEquals : AttributeData -> Assertion
  , classPresent : ClassData -> Assertion
  , containsText : TextData -> Assertion
  , styleEquals : StyleData -> Assertion
  , not :
    { attributeContains : AttributeData -> Assertion
    , attributeEquals : AttributeData -> Assertion
    , classPresent : ClassData -> Assertion
    , containsText : TextData -> Assertion
    , styleEquals : StyleData -> Assertion
    }
  }
assert =
  { attributeContains = Spec.Native.attributeContains
  , attributeEquals = Spec.Native.attributeEquals
  , containsText = Spec.Native.containsText
  , classPresent = Spec.Native.classPresent
  , styleEquals = Spec.Native.styleEquals
  , not =
    { attributeContains = Spec.Native.attributeContains >> switch
    , attributeEquals = Spec.Native.attributeEquals >> switch
    , containsText = Spec.Native.containsText >> switch
    , classPresent = Spec.Native.classPresent >> switch
    , styleEquals = Spec.Native.styleEquals >> switch
    }
  }
