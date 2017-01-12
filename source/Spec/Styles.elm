module Spec.Styles exposing (..)

{-| Styles for the Html reporter.

@docs Class, embed, stylesheet
-}
import Style exposing (..)
import Html


{-| Classes for the styles.
-}
type Class
  = Container
  | Test
  | Row


{-| Renders the stylesheet.
-}
embed : Html.Html msg
embed =
  Style.embed stylesheet


{-| The stylesheet to use.
-}
stylesheet : StyleSheet Class msg
stylesheet =
  Style.render
    [ class Container
      [ font "sans"
      , padding (all 20)
      , spacing (bottom 20)
      ]
    , class Row
      [ lineHeight 1.5
      ]
    , class Test
      [ padding (left 20) ]
    ]
