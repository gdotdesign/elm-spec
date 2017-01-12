import Spec exposing (describe, it, Node)
import Spec.Assertions exposing (assert)
import Spec.Steps exposing (click)
import Spec.Runner

import Html.Events exposing (onClick)
import Html exposing (div, text)

type alias Model
  = String

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
  div [ onClick Set ] [ text model ]

specs : Node
specs =
  describe "Example"
    [ it "clicking on the div should change the text"
      [ assert.containsText { text = "Empty", selector = "div" }
      , click "div"
      , assert.containsText { text = "Something", selector = "div" }
      ]
    ]

main =
  Spec.Runner.runWithProgram
    { subscriptions = \_ -> Sub.none
    , update = update
    , view = view
    , init = init
    } specs
