module Spec.Reporter exposing (render)

{-| Renders test results in Html.

@docs render
-}
import Spec.Styles as Styles exposing (stylesheet)
import Spec.Types exposing (..)
import Spec.CoreTypes exposing (Outcome)
import Spec.CoreTypes exposing (Outcome(..))

import Json.Encode

import Html.Attributes exposing (style, property)
import Html exposing (div, strong, text)


{-| Renders an outcome.
-}
renderOutcome : Outcome -> Html.Html msg
renderOutcome outcome =
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


{-| Renders a test.
-}
renderTest : Test msg -> Html.Html msg
renderTest model =
  let
    requests =
      Native.Spec.getMockResults model

    notCalled =
      List.filter
        (\item -> not (List.member item requests.called))
        model.requests

    title =
      [ strong [] [ text model.name ] ]

    results =
      List.map renderOutcome model.results

    renderRequest class request =
      div
        [ stylesheet.class class ]
        [ text (request.method ++ " - " ++ request.url) ]

    requestResults =
      if List.isEmpty requests.called
      && List.isEmpty requests.unhandled
      && List.isEmpty notCalled
      then
        []
      else
        [ div [ stylesheet.class Styles.SubTitle ] [ text "Requets:" ]]
        ++ (List.map (renderRequest Styles.CalledRequest) requests.called)
        ++ (List.map (renderRequest Styles.NotCalledRequest) notCalled)
        ++ (List.map (renderRequest Styles.UnhandledRequest) requests.unhandled)

  in
    div
      [ stylesheet.class Styles.Row ] (title ++ results ++ requestResults)


{-| Renders the test results.
-}
render : List (Test msg) -> Html.Html msg
render tests =
  let
    styles =
      [ Styles.embed ]

    rows =
      List.map renderTest tests
  in
    Html.div [ stylesheet.class Styles.Container ] (styles ++ rows)
