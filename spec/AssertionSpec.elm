import Spec exposing (..)

import Html.Attributes exposing (attribute, class, style, value)
import Html exposing (..)

import Task

type alias Model =
  {}


type Msg
  = NoOp


init : () -> Model
init _ =
  {}


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  ( model, Cmd.none )


view : Model -> Html.Html Msg
view model =
  node "test"
    []
    [ div
      [ attribute "test" "test"
      , class "test"
      , style
        [("cursor", "pointer")]
      ]
      [ text "Lorem ipsum dolor sit amet, consectetur adipiscing elit. " ]
    , div [ class "hidden-by-none", style [ ( "display", "none" ) ] ] []
    , div [ class "hidden-by-opacity", style [ ( "opacity", "0" ) ] ] []
    , div [ class "hidden-by-visiblity", style [ ( "visibility", "hidden" ) ] ] []
    , div [ class "hidden-by-z-index", style [ ( "position", "relative"), ("z-index", "-1" ) ] ]
      [ span [] [ i [] [] ] ]
    , input [ value "value of input" ] []
    ]


specs : Node
specs =
  describe "Spec.Assertions"
    [ describe ".containsText"
      [ it "should check if element contains text"
        [ assert.containsText { text = "Lorem", selector = "div" }
        , assert.containsText { text = "amet,", selector = "div" }
        , assert.not.containsText { text = "blah", selector = "div" }
        ]
      , it "should check if element contains text"
        [ stepGroup "Contains text..."
          [ assert.containsText { text = "Lorem", selector = "div" }
          , assert.containsText { text = "amet,", selector = "div" }
          , assert.not.containsText { text = "blah", selector = "div" }
          ]
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
    , describe ".inlineStyleEquals"
      [ it "should check it element has the given style with the given value "
        [ assert.inlineStyleEquals
          { style = "cursor", value = "pointer", selector = "div" }
        , assert.not.inlineStyleEquals
          { style = "cursor", value = "not-allowed", selector = "div" }
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
    , describe ".elementPresent"
      [ it "should check if element is in the DOM"
        [ assert.elementPresent "div"
        , assert.not.elementPresent "blah"
        ]
      ]
    , describe ".elementVisible"
      [ it "should check if element is visible"
        [ assert.elementVisible "div"
        ]
      , it "should check display: none"
        [ assert.not.elementVisible "div.hidden-by-none" ]
      , it "should check opacity: 0"
        [ assert.not.elementVisible "div.hidden-by-opacity" ]
      , it "should check visibility: hidden"
        [ assert.not.elementVisible "div.hidden-by-visiblity" ]
      , it "should check z-index"
        [ assert.not.elementVisible "div.hidden-by-z-index" ]
      , it "should check parent elements"
        [ assert.not.elementVisible "div.hidden-by-z-index span i" ]
      ]
    , describe ".titleContains"
      [ it "should check if title contains text"
        [ Task.andThen
            (\title -> assert.titleContains (String.slice 0 4 title))
            steps.getTitle
        , assert.not.titleContains "Blah"
        ]
      ]
    , describe ".titleEquals"
      [ it "should check if title equals text"
        [ Task.andThen assert.titleEquals steps.getTitle
        , assert.not.titleEquals "Blah"
        ]
      ]
    , describe ".urlContains"
      [ it "should check if the current urls contains text"
        [ Task.andThen
            (\url -> assert.urlContains (String.slice 0 4 url))
            steps.getUrl
        , assert.not.urlContains "Blah"
        ]
      ]
    , describe ".urlEquals"
      [ it "should check if title equals text"
        [ Task.andThen assert.urlEquals steps.getUrl
        , assert.not.urlEquals "Blah"
        ]
      ]
    , describe ".valueContains"
      [ it "should check if elements value contains text"
        [ assert.valueContains { text = "value", selector = "input" }
        , assert.not.valueContains { text = "asd", selector = "input" }
        ]
      ]
    , describe ".valueEquals"
      [ it "should check if elements value equals text"
        [ assert.valueEquals { text = "value of input", selector = "input" }
        , assert.not.valueEquals { text = "asd", selector = "input" }
        ]
      ]
    ]

main =
  runWithProgram
    { init = init
    , update = update
    , view = view
    , subscriptions = \_ -> Sub.none
    } specs
