module Spec.Steps exposing (..)

{-| Common steps for testing web applications (click, fill, etc..)

# Interaction
@docs click

# Querying
@docs getAttribute, getUrl, getTitle
-}
import Spec.Types exposing (..)

import Task exposing (Task)


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
getAttribute : String -> String -> Step
getAttribute attribute selector =
  Native.Spec.getAttribute attribute selector
