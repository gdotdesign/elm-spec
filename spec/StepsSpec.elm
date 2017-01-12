import Spec.Assertions exposing (..)
import Spec.Expect as Expect
import Spec.Runner exposing (..)
import Spec.Steps exposing (..)
import Spec exposing (..)

import Html.Attributes exposing (attribute)
import Html.Events exposing (onClick)
import Html exposing (..)

type alias Model = String

type Msg
  = Set


init : () -> Model
init _ =
  "Empty"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Set ->
      ( "Something", Cmd.none )


view : Model -> Html.Html Msg
view model =
  div
    [ attribute "test" "test", onClick Set ]
    [ text model ]


specs : Node
specs =
  describe "Spec.Steps"
    [ describe ".click"
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
    ]

main =
  runWithProgram
    { init = init
    , update = update
    , view = view
    , subscriptions = \_ -> Sub.none
    } specs
