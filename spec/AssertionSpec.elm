import Spec.Assertions exposing (..)
import Spec.Runner exposing (..)
import Spec.Steps exposing (..)
import Spec exposing (..)

import Html.Attributes exposing (attribute, class)
import Html exposing (..)

type alias Model =
  {}


type Msg
  = NoOp


init : Model
init =
  {}


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  ( model, Cmd.none )


view : Model -> Html.Html Msg
view model =
  div
    [ attribute "test" "test"
    , class "test"
    ]
    [ text "Lorem ipsum dolor sit amet, consectetur adipiscing elit. " ]


specs : Node
specs =
  describe "Spec.Assertions"
    [ describe ".containsText"
      [ it "should check if element contains text"
        [ assert.containsText { text = "Lorem", selector = "div" }
        , assert.containsText { text = "amet,", selector = "div" }
        , assert.not.containsText { text = "blah", selector = "div" }
        ]
      ]
    , describe ".classPresent"
      [ it "should check if element have the given class"
        [ assert.classPresent { class = "test", selector = "div" }
        , assert.not.classPresent { class = "amet,", selector = "div" }
        ]
      ]
    , describe ".styleEquals"
      [ it "should check it element has the given style with the given value "
        [ assert.styleEquals
          { style = "display", value = "block", selector = "div" }
        , assert.not.styleEquals
          { style = "display", value = "inline-block", selector = "div" }
        ]
      ]
    , describe ".attributeEquals"
      [ it "should check if attributes value equals text"
        [ assert.attributeEquals
          { text = "test", selector = "div", attribute = "test" }
        , assert.not.attributeEquals
          { text = "blah", selector = "div", attribute = "test" }
        ]
      ]
    , describe ".attributeContains"
      [ it "should check if attributes value contains text"
        [ assert.attributeContains
          { text = "te", selector = "div", attribute = "test" }
        , assert.attributeContains
          { text = "st", selector = "div", attribute = "test" }
        , assert.not.attributeContains
          { text = "blah", selector = "div", attribute = "test" }
        ]
      ]
    ]

main =
  runWithProgram
    { init = init
    , update = update
    , view = view
    } specs
