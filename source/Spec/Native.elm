module Spec.Native exposing (..)

import Spec.Types exposing (..)
import Task exposing (Task)
import Native.Spec

containsText : TextData -> Assertion
containsText { text, selector } =
  Native.Spec.containsText text selector

attributeContains : AttributeData -> Assertion
attributeContains { text, selector, attribute } =
  Native.Spec.attributeContains attribute text selector

attributeEquals : AttributeData -> Assertion
attributeEquals { text, selector, attribute} =
  Native.Spec.attributeEquals attribute text selector

classPresent : ClassData -> Assertion
classPresent { class, selector } =
  Native.Spec.classPresent class selector

styleEquals : StyleData -> Assertion
styleEquals { style, value, selector } =
  Native.Spec.styleEquals style value selector
