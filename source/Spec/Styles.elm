module Spec.Styles exposing (..)

{-| Styles for the Html reporter.

@docs Class, embed, stylesheet, beforeStyles
-}
import Style exposing (..)
import Html


{-| Classes for the styles.
-}
type Class
  = NotCalledRequest
  | UnhandledRequest
  | CalledRequest
  | Container
  | SubTitle
  | Test
  | Row


{-| Renders the stylesheet.
-}
embed : Html.Html msg
embed =
  Style.embed stylesheet


{-| Styles for the before elements.
-}
beforeStyles : List Property
beforeStyles =
  [ property "display" "inline-block"
  , textAlign alignCenter
  , width (px 25)
  ]

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
    , class SubTitle
      [ padding (left 20)
      , property "text-transform" "uppercase"
      , property "margin-top" "5px"
      , bold
      ]
    , class CalledRequest
      [ property "color" "green"
      , padding (left 25)
      , before "\"✔\"" beforeStyles
      ]
    , class NotCalledRequest
      [ property "color" "red"
      , padding (left 25)
      , before "\"✘\"" beforeStyles
      ]
    , class UnhandledRequest
      [ property "color" "white"
      , property "background-color" "red"
      , padding (left 25)
      , before "\"?\"" beforeStyles
      ]
    , class Row
      [ lineHeight 1.5
      ]
    , class Test
      [ padding (left 20) ]
    ]
