module Spec.Assertions exposing (..)

{-| Assertions and utility functions for them.

# Assert
@docs assert

# Utilities
@docs fail, pass, error, flip
-}
import Task exposing (Task)

import Spec.Types exposing (..)
import Spec.Native


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


{-| A record for quickly accessing assertions and giving it a readable format.

    it "should do something"
      [ assert.not.containsText { text = "something", selector = "div" }
      , assert.styleEquals
        { style = "display", value = "block", selector = "div" }
      ]
-}
assert :
  { attributeContains : AttributeData -> Assertion
  , attributeEquals : AttributeData -> Assertion
  , classPresent : ClassData -> Assertion
  , containsText : TextData -> Assertion
  , styleEquals : StyleData -> Assertion
  , elementPresent : String -> Assertion
  , elementVisible : String -> Assertion
  , titleContains : String -> Assertion
  , titleEquals : String -> Assertion
  , urlContains : String -> Assertion
  , urlEquals : String -> Assertion
  , not :
    { attributeContains : AttributeData -> Assertion
    , attributeEquals : AttributeData -> Assertion
    , classPresent : ClassData -> Assertion
    , containsText : TextData -> Assertion
    , styleEquals : StyleData -> Assertion
    , elementPresent : String -> Assertion
    , elementVisible : String -> Assertion
    , titleContains : String -> Assertion
    , titleEquals : String -> Assertion
    , urlContains : String -> Assertion
    , urlEquals : String -> Assertion
    }
  }
assert =
  { attributeContains = Spec.Native.attributeContains
  , attributeEquals = Spec.Native.attributeEquals
  , elementPresent = Spec.Native.elementPresent
  , elementVisible = Spec.Native.elementVisible
  , titleContains = Spec.Native.titleContains
  , containsText = Spec.Native.containsText
  , classPresent = Spec.Native.classPresent
  , styleEquals = Spec.Native.styleEquals
  , titleEquals = Spec.Native.titleEquals
  , urlContains = Spec.Native.urlContains
  , urlEquals = Spec.Native.urlEquals
  , not =
    { attributeContains = Spec.Native.attributeContains >> flip
    , attributeEquals = Spec.Native.attributeEquals >> flip
    , elementPresent = Spec.Native.elementPresent >> flip
    , elementVisible = Spec.Native.elementVisible >> flip
    , titleContains = Spec.Native.titleContains >> flip
    , containsText = Spec.Native.containsText >> flip
    , classPresent = Spec.Native.classPresent >> flip
    , styleEquals = Spec.Native.styleEquals >> flip
    , titleEquals = Spec.Native.titleEquals >> flip
    , urlContains = Spec.Native.urlContains >> flip
    , urlEquals = Spec.Native.urlEquals >> flip
    }
  }
