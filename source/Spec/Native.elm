module Spec.Native exposing (..)

{-| Functions for native modules containing assertions.

# Assertions
@docs containsText, attributeContains, attributeEquals, classPresent
@docs styleEquals, elementPresent, elementVisible, titleContains
@docs titleEquals, urlContains, urlEquals, valueContains, valueEquals
-}
import Spec.Types exposing (..)
import Task exposing (Task)
import Native.HttpMock
import Native.Spec


{-| Checks if the given element contains the specified text.
-}
containsText : TextData -> Assertion
containsText { text, selector } =
  Native.Spec.containsText text selector


{-| Checks if the given attribute of an element contains the expected value.
-}
attributeContains : AttributeData -> Assertion
attributeContains { text, selector, attribute } =
  Native.Spec.attributeContains attribute text selector


{-| Checks if the given attribute of an element has the expected value.
-}
attributeEquals : AttributeData -> Assertion
attributeEquals { text, selector, attribute} =
  Native.Spec.attributeEquals attribute text selector


{-| Checks if the given element has the specified class.
-}
classPresent : ClassData -> Assertion
classPresent { class, selector } =
  Native.Spec.classPresent class selector


{-| Checks if the given element given attribute equals the expected value.
-}
styleEquals : StyleData -> Assertion
styleEquals { style, value, selector } =
  Native.Spec.styleEquals style value selector


{-| Checks if the given element exists in the DOM.
-}
elementPresent : String -> Assertion
elementPresent =
  Native.Spec.elementPresent


{-| Checks if the given element is visible on the page.
-}
elementVisible : String -> Assertion
elementVisible =
  Native.Spec.elementVisible


{-| Checks if the page title contains the given value.
-}
titleContains : String -> Assertion
titleContains =
  Native.Spec.titleContains


{-| Checks if the page title contains the given value.
-}
titleEquals : String -> Assertion
titleEquals =
  Native.Spec.titleEquals


{-| Checks if the current URL contains the given value.
-}
urlContains : String -> Assertion
urlContains =
  Native.Spec.urlContains


{-| Checks if the current url equals the given value.
-}
urlEquals : String -> Assertion
urlEquals =
  Native.Spec.urlEquals


{-| Checks if the given form element's value contains the expected value.
-}
valueContains : TextData -> Assertion
valueContains { text, selector } =
  Native.Spec.valueContains text selector


{-| Checks if the given form element's value equals the expected value.
-}
valueEquals : TextData -> Assertion
valueEquals { text, selector } =
  Native.Spec.valueEquals text selector
