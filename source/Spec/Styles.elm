module Spec.Styles exposing (..)

{-| Styles for the Html reporter.

@docs Class, embed, stylesheet, beforeStyles
-}
import Html

{- Styles for the before elements.

beforeStyles : List Property
beforeStyles =
  [ property "display" "inline-block"
  , textAlign alignCenter
  , width (px 25)
  ]
-}

container : List (String, String)
container =
  [ ( "font", "sans" )
  , ( "padding", "20px" )
  , ( "margin-bottom", "20px" )
  ]

subTitle : List (String, String)
subTitle =
  [ ( "padding-left", "20px" )
  , ( "text-transform", "uppercase" )
  , ( "margin-top", "5p" )
  , ( "font-weight", "bold" )
  ]

row : List (String, String)
row =
  [ ( "line-height", "1.5" )
  ]


calledRequest =
  [ ( "color", "green")
  , ( "padding-left", "25px" )
  ]


notCalledRequest =
  [ ( "color", "red")
  , ( "padding-left", "25px" )
  ]

unhandledRequest =
  [ ( "color", "white")
  , ( "background-color", "red" )
  , ( "padding-left", "25px" )
  ]

test =
  [ ( "padding-left", "20px" )
  ]
