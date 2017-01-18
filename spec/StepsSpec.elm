import Spec.Assertions exposing (..)
import Spec.Expect as Expect
import Spec.Runner exposing (..)
import Spec.Steps exposing (..)
import Spec exposing (..)

import Html.Events exposing (onClick, on, keyCode)
import Html.Attributes exposing (attribute)
import Html exposing (..)

import Json.Encode as JE
import Json.Decode as JD

type alias Model = String

type Msg
  = SetValue Int
  | Set


init : () -> Model
init _ =
  "Empty"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    SetValue value ->
      ( toString value, Cmd.none )

    Set ->
      ( "Something", Cmd.none )


view : Model -> Html.Html Msg
view model =
  node "test" []
    [ div
      [ attribute "test" "test", onClick Set ]
      [ text model ]
    , input [ on "keydown" (JD.map SetValue keyCode) ] []
    ]


specs : Node
specs =
  describe "Spec.Steps"
    [ before [ assert.elementPresent "body" ]
    , after [ assert.elementPresent "body" ]
    , describe ".click"
      [ it "wait for the event to finish"
        [ assert.containsText { text = "Empty", selector = "div" }
        , click "div"
        , assert.containsText { text = "Something", selector = "div" }
        ]
      ]
    , describe ".getAttribute"
      [ it "should return attribute"
        [ getAttribute "test" "div"
          |> Expect.equals "test"
            "Testing if attribute equals with getAttribute"
        ]
      ]
    , describe ".setValue"
      [ it "should set value of element"
        [ assert.valueEquals { text = "", selector = "input" }
        , setValue { value = "test", selector = "input" }
        , assert.valueEquals { text = "test", selector = "input" }
        ]
      ]
    , describe ".clearValue"
      [ it "should clear value of element"
        [ setValue { value = "test", selector = "input" }
        , assert.valueEquals { text = "test", selector = "input" }
        , clearValue "input"
        , assert.valueEquals { text = "", selector = "input" }
        ]
      ]
    , describe ".dispatchEvent"
      [ it "should dispatch the given event"
        [ assert.containsText { text = "Empty", selector = "div" }
        , dispatchEvent "click" (JE.object []) "div"
        , assert.containsText { text = "Something", selector = "div" }
        ]
      , it "should dispatch event with data"
        [ assert.containsText { text = "Empty", selector = "div" }
        , dispatchEvent "keydown" (JE.object [("keyCode", JE.int 13)]) "input"
        , assert.containsText { text = "13", selector = "div" }
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
