# elm-spec
[![Build Status](https://travis-ci.org/gdotdesign/elm-spec.svg?branch=master)](https://travis-ci.org/gdotdesign/elm-spec)

End-to-end testing for your Elm apps and components.

## CLI
You can install the CLI with either of the following commands:

`npm install elm-spec -g` or `yarn global add elm-spec`

## Adding the package
Add `gdotdesign/elm-spec` as a dependency to your `elm-package.json`.

```json
  "dependencies": {
    "gdotdesign/elm-spec": "1.0.0 <= v 2.0.0"
  }
```

And then install with [elm-github-install](https://github.com/gdotdesign/elm-github-install) using the `elm-install` command.

## Quick Start
Here is an exmaple of testing a simple component:

```elm
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
    [ describe "clicking on the div should change the text"
      [ it "wait for the event to finish"
        [ assert.containsText { text = "Empty", selector = "div" }
        , click "div"
        , assert.containsText { text = "Something", selector = "div" }
        ]
      ]
    ]

main =
  Spec.Runner.runWithProgram
    { subscriptions = \_ -> Sub.none
    , update = update
    , view = view
    , init = init
    } specs
```

And open the file in `elm-reactor` or run it wit the `elm-spec` command:

```
 Example / clicking on the div should change the text / wait for the event to finish
   Element div contains text "Empty"
   Clicked: div
   Element div contains text "Something"
```
