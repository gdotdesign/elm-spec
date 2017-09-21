import Spec exposing (..)

import Html exposing (node, div, text)

type alias Model
  = String

type Msg
  = NoOp

init : () -> Model
init _ =
  "Initial"

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  ( model, Cmd.none )

keys : List String
keys =
  [ "animation"
  , "animation-delay"
  , "animation-duration"
  , "animation-direction"
  , "animation-iteration-count"
  , "animation-fill-mode"
  , "animation-name"
  , "animation-play-state"
  , "animation-timing-function"
  , "transition"
  , "transition-delay"
  , "transition-duration"
  , "transition-property"
  , "transition-timing-function"
  , "justify-content"
  , "flex-direction"
  , "align-content"
  , "align-items"
  , "align-selft"
  , "flex-shrink"
  , "flex-basis"
  , "flex-grow"
  , "flex-wrap"
  , "flex-flow"
  , "flex"
  , "order"
  ]

style : String
style =
  """
  div {
    animation: none;
    animation-delay: none;
    animation-duration: none;
    animation-direction: none;
    animation-iteration-count: none;
    animation-fill-mode: none;
    animation-name: none;
    animation-play-state: none;
    animation-timing-function: none;
    transition: none;
    transition-delay: none;
    transition-duration: none;
    transition-property: none;
    transition-timing-function: none;
    justify-content: none;
    flex-direction: none;
    align-content: none;
    align-items: none;
    align-selft: none;
    flex-shrink: none;
    flex-basis: none;
    flex-grow: none;
    flex-wrap: none;
    flex-flow: none;
    order: none;
    flex: none;
  }
  """

view : Model -> Html.Html Msg
view model =
  div [] [ node "style" [] [ text style ] ]

specs : Node
specs =
  let
    map key =
      it ("handles property: " ++ key)
        [ assert.styleEquals
          { selector = "div"
          , value = "none"
          , style = key
          }
        ]
  in
    describe "Flex Properties" (List.map map keys)

main =
  runWithProgram
    { subscriptions = \_ -> Sub.none
    , update = update
    , view = view
    , init = init
    } specs
