module Spec.Reporter exposing (render)

{-| Renders test results in Html.

@docs render
-}
import Json.Encode

import Html.Attributes exposing (style, property)
import Html exposing (div, strong, text)

import Spec.Types exposing (..)
import Spec.Styles as Styles


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
      [ style Styles.test
      , property "innerHTML" html
      , styles
      ]
      []


{-| Renders a test.
-}
renderTest : Test -> Html.Html msg
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

    renderRequest prefix styles request =
      div
        [ style styles ]
        [ text (prefix ++ " " ++ request.method ++ " - " ++ request.url) ]

    requestResults =
      if List.isEmpty requests.called
      && List.isEmpty requests.unhandled
      && List.isEmpty notCalled
      then
        []
      else
        [ div [ style Styles.subTitle ] [ text "Requests:" ]]
        ++ (List.map (renderRequest "✔" Styles.calledRequest) requests.called)
        ++ (List.map (renderRequest "✘" Styles.notCalledRequest) notCalled)
        ++ (List.map (renderRequest "?" Styles.unhandledRequest) requests.unhandled)

  in
    div
      [ style Styles.row ] (title ++ results ++ requestResults)


{-| Renders the test results.
-}
render : List Test -> Html.Html msg
render tests =
  Html.div [ style Styles.container ] (List.map renderTest tests)
