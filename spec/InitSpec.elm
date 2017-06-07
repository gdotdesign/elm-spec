import Spec exposing (..)
import Spec.Expect as Expect

import Html.Events exposing (onClick, on, keyCode)
import Html.Attributes exposing (class, attribute)
import Html exposing (..)

import Json.Encode as JE
import Json.Decode as JD

import Task exposing (Task)

type alias Model = String

type Msg
  = SetValue String


init : () -> Model
init _ =
  ""


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    SetValue value ->
      ( value, Cmd.none )


view : Model -> Html.Html Msg
view model =
  node "test" []
    [ div [ class "value"] [ text model ]
   ]


specs : Node
specs =
  describe "Spec.Steps"
    [ describe ".setValue"
      [ it "should set value of element on init"
        [ assert.containsText { text = "new-value", selector = ".value" }
        ]
      ]
    ]

main =
  runWithProgram
    { init = init
    , update = update
    , view = view
    , subscriptions = \_ -> Sub.none
    , initCmd = fire (SetValue "new-value")
    } specs


fire : msg -> Cmd msg
fire msg =
    Task.perform identity (Task.succeed msg)

