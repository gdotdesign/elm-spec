import Spec exposing (..)

import Spec exposing (..)
import Spec.Expect as Expect

import Html.Events exposing (onClick, on, keyCode)
import Html.Attributes exposing (attribute)
import Html exposing (..)

import Json.Encode as JE
import Json.Decode as JD

type alias Model =
  { rect : String
  , element : Maybe String
  }

type Msg
  = GetRect String
  | GetElement Int Int

init : () -> Model
init _ =
  { rect = "{}"
  , element = Nothing
  }

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    GetElement x y ->
      ( { model | element = Native.Spec.elementFromPoint x y }
      , Cmd.none
      )

    GetRect value ->
      ( { model | rect = toString (Native.Spec.getBoundingClientRect value) }
      , Cmd.none
      )

view : Model -> Html.Html Msg
view model =
  node "test" []
    [ div
      [ onClick (GetRect "test") ]
      [ text model.rect ]
    , span
      [ onClick (GetElement 10 10) ]
      [ text (toString model.element) ]
    ]

specs : Node
specs =
  describe "Layout mocking"
    [ context "getBoundingClientRect"
      [ before
        [ assert.containsText { text = "{}", selector = "div" }
        , steps.click "div"
        ]
      , context "without layout"
        [ it "wait for the event to finish"
          [ assert.containsText
            { text = "{ top = 0, left = 0, right = 0, bottom = 0, width = 0, height = 0 }"
            , selector = "div"
            }
          ]
        ]
      , context "with layout"
        [ layout
          [ ( "test", { top = 10, left = 20, right = 30, bottom = 40, width = 100, height = 200, zIndex = 1 })
          ]
        , it "returnes mocked dimensions"
          [ assert.containsText
            { text = "{ top = 10, left = 20, right = 30, bottom = 40, width = 100, height = 200, zIndex = 1 }"
            , selector = "div"
            }
          ]
        ]
      ]
    , context "elementFromPoint"
      [  layout
        [ ( "test", { top = 0, left = 0, right = 0, bottom = 0, width = 20, height = 20, zIndex = 1 })
        ]
      , it "get element"
        [ assert.containsText { text = "Nothing", selector = "span" }
        , steps.click "span"
        , assert.containsText { text = "Just \"TEST\"", selector = "span" }
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
