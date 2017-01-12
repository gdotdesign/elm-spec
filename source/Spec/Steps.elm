module Spec.Steps exposing (..)

{-| Common steps for testing web applications (click, fill, etc..)

# Interaction
@docs click

# Querying
@docs getAttribute, getUrl, getTitle

# Actions
@docs click, clearValue, setValue, dispatchEvent
-}
import Spec.Types exposing (..)

import Task exposing (Task)
import Json.Decode as Json
import Native.Spec


{-| Clears the value of the element with the given selector.
-}
clearValue : String -> Step
clearValue selector =
  Native.Spec.clearValue selector


{-| Sets the value of the element with the given selector.
-}
setValue : ValueData -> Step
setValue { value, selector } =
  Native.Spec.setValue value selector


{-| Dispatches an event with the given data for the element with the given
selector.
-}
dispatchEvent : String -> Json.Value -> String -> Step
dispatchEvent event data selector =
  Native.Spec.dispatchEvent event data selector


{-| Triggers a click on the given selector.
-}
click : String -> Step
click selector =
  Native.Spec.click selector


{-| Gets the current URL.
-}
getUrl : Task Never String
getUrl =
  Native.Spec.getUrl


{-| Gets the current title.
-}
getTitle : Task Never String
getTitle =
  Native.Spec.getTitle


{-| Gets the given attribute of the element with the given selector.
-}
getAttribute : String -> String -> Task Never String
getAttribute attribute selector =
  Native.Spec.getAttribute attribute selector
