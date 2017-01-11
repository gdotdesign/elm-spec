module Spec.Reporter exposing (..)

import Spec.Styles as Styles exposing (stylesheet)
import Spec.Types exposing (..)
import Spec exposing (Test)

import Json.Encode

import Html.Attributes exposing (style, property)
import Html exposing (div, strong, text)


renderStep : Outcome -> Html.Html msg
renderStep outcome =
  let
    html =
      outcome
        |> outcomeToString
        |> Native.Spec.ansiToHtml
        |> Json.Encode.string

    styles =
      case outcome of
        Pass _ ->
          style [ ( "color", "green" ) ]

        Error _ ->
          style
            [ ( "color", "white" )
            , ( "background-color", "red" )
            ]

        Fail _ ->
          style [ ( "color", "red" ) ]
  in
    div
      [ stylesheet.class Styles.Test
      , property "innerHTML" html
      , styles
      ]
      []


renderTest : Test -> Html.Html msg
renderTest model =
  let
    title =
      [ strong [] [ text model.name ] ]

    results =
      List.map renderStep model.results
  in
  div
    [ stylesheet.class Styles.Row ] (title ++ results)


outcomeToString : Outcome -> String
outcomeToString outcome =
  case outcome of
    Error message -> message
    Pass message -> message
    Fail message -> message


render : List Test -> Html.Html msg
render tests =
  let
    styles =
      [ Styles.embed ]

    rows =
      List.map renderTest tests
  in
    Html.div [ stylesheet.class Styles.Container ] (styles ++ rows)
