module Spec.Styles exposing (..)

import Style exposing (..)

type Class
  = Container
  | Test
  | Row

embed =
  Style.embed stylesheet

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
