import Spec exposing (..)

import Html.Attributes exposing (class)
import Html exposing (div, text, span, button)
import Html.Events exposing (onClick)

import Json.Decode as Json

import Http

type alias Model
  = String

type Msg
  = Request
  | RequestPost
  | Loaded (Result Http.Error String)

init : () -> Model
init _ =
  "Empty"

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Loaded result ->
      case result of
        Ok data ->
          ( data, Cmd.none )
        Err error ->
          ( "ERROR", Cmd.none )

    RequestPost ->
      ( ""
      , Http.post "/blah" Http.emptyBody Json.string
        |> Http.send Loaded
      )

    Request ->
      ( ""
      , Http.get "/test" Json.string
        |> Http.send Loaded
      )

view : Model -> Html.Html Msg
view model =
  div [ ]
    [ button [ class "get-test", onClick Request ] []
    , button [ class "post-blah", onClick RequestPost ] []
    , span [ ] [ text model ]
    ]

tests =
  describe "Http Mocking"
    [ http
      [ { method = "GET"
        , url = "/test"
        , response = { status = 200, body = "\"OK /test\"" }
        }
      , { method = "POST"
        , url = "/blah"
        , response = { status = 500, body = "" }
        }
      ]
    , it "should mock http requests"
      [ assert.containsText { selector = "span", text = "" }
      , steps.click "button.get-test"
      , assert.containsText { selector = "span", text = "OK /test" }
      , steps.click "button.post-blah"
      , assert.containsText { selector = "span", text = "ERROR" }
      ]
    ]

main =
  runWithProgram
    { subscriptions = \_ -> Sub.none
    , update = update
    , view = view
    , init = init
    , initCmd = Cmd.none
    } tests
