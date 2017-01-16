# elm-spec
[![Build Status](https://travis-ci.org/gdotdesign/elm-spec.svg?branch=master)](https://travis-ci.org/gdotdesign/elm-spec)

End-to-end testing for your Elm apps and components.

## Features
* Can test apps or separate components
* `Task` based steps and assertions (allows createing custom ones easily) 
* Create composite steps from other steps
* DOM steps and assertions (`click`, `containsText`, `valueEquals`, etc...)
* Mock HTTP requests and report not mocked requests
* `before` / `after` hooks
* Run tests in the console (via _jsdom_)
* Run tests with `elm-reactor` with HTML Report 
* Run files one at a time `elm-spec spec/SomeSpec.elm`
* Run tests one at a time `elm-spec spec/SomeSpec.elm:2`

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
```

And open the file in `elm-reactor` or run it wit the `elm-spec` command:

```
$ elm-spec spec/ExampleSpec.elm
spec/ExampleSpec.elm
 Example / clicking on the div should change the text
   Element div contains text "Empty"
   Clicked: div
   Element div contains text "Something"

1 files 1 tests:
  3 steps 3 successfull 0 failed 0 errored
  0 requests 0 called 0 not called 0 unhandled
```
