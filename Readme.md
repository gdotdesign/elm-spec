# elm-spec
[![Build Status](https://travis-ci.org/gdotdesign/elm-spec.svg?branch=master)](https://travis-ci.org/gdotdesign/elm-spec)
[![Npm Version](https://badge.fury.io/js/elm-spec.svg)](https://badge.fury.io/js/elm-spec)
[![Documentation](https://img.shields.io/badge/documentation-elm--directory-brightgreen.svg)](http://elm-directory.herokuapp.com/package/gdotdesign/elm-spec)

End-to-end testing for your Elm apps and components.

## Features
* Can test apps or separate components
* `Task` based steps and assertions (allows createing custom ones easily)
* Create composite steps from other steps
* DOM steps and assertions (`click`, `containsText`, `valueEquals`, etc...)
* Mock HTTP requests and report not mocked requests
* `before` / `after` hooks
* Run tests in the console (via _jsdom_)
* Run tests with `elm-reactor` with console report
* Run files one at a time `elm-spec spec/SomeSpec.elm`
* Run tests one at a time `elm-spec spec/SomeSpec.elm:2`

## CLI
You can install the CLI with either of the following commands:

`npm install elm-spec -g` or `yarn global add elm-spec`

```
elm-spec [glob pattern or file:testID] -f format

Options:
  --format, -f  Reporting format
                [choices: "documentation", "progress"] [default: "documentation"]
  --help        Show help                                               [boolean]

```

## Adding the package
Add `gdotdesign/elm-spec` as a dependency to your `elm-package.json`.

```json
  "dependencies": {
    "gdotdesign/elm-spec": "1.0.0 <= v < 2.0.0"
  }
```

And then install with [elm-github-install](https://github.com/gdotdesign/elm-github-install) using the `elm-install` command.

## Quick Start
Here is an exmaple of testing a simple component:

```elm
import Spec exposing (..)

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
      , steps.click "div"
      , assert.containsText { text = "Something", selector = "div" }
      ]
    ]

main =
  runWithProgram
    { subscriptions = \_ -> Sub.none
    , update = update
    , view = view
    , init = init
    } specs
```

And open the file in `elm-reactor` or run it wit the `elm-spec` command:

```
$ elm-spec spec/ExampleSpec.elm
◎ spec/ExampleSpec.elm
  Example
    ✔ clicking on the div should change the text
      Element div contains text "Empty"
      Clicked: div
      Element div contains text "Something"

1 files 1 tests:
 3 steps: 3 successfull, 0 failed, 0 errored
 0 requests: 0 called, 0 not called, 0 unhandled
```

## Defining tests
You can define tests with the `it` or `test` functions:

```elm
it "does something"
  [ step1
  , assertion1
  , step2
  , assertion2
  ]
```

Each test can have an unlimited number of steps (`Task Never Outcome`) which
are executed in sequence.

Before every test the given application is reset and a fresh DOM is created.

## Defining Groups
You can define groups that can have an tests, hooks and groups. There are three
functions that do the same thing: `group`, `context`, `describe`.

```elm
context "Something"
  [ describe "Something else"
    [ it "does something"
      [ step1
      , assertion1
      ]
    ]
  ]
```

## Hooks
Elm-spec allows you to append and prepend steps and assertions before each test
with the `before` and `after` functions.

These functions can be defined in a group and it will add it's steps to each
test in that group and it's descendant groups tests (recursively).

```elm
context "Something"
  [ describe "Something else"
    [ before
      [ preparationStep1
      ]
    , after
      [ cleanupStep1
      ]
    , it "does something"
      [ step1
      , assertion1
      ]
    ]
  ]
```

## Steps and Assertions
The following steps are available in the `steps` record:

```elm
{ dispatchEvent : String -> Json.Value -> String -> Step
, getAttribute : String -> String -> Task Never String
, setValue : String -> String -> Step
, getTitle : Task Never String
, clearValue : String -> Step
, getUrl : Task Never String
, click : String -> Step
}
```

And the following assertions are available in the `assert` and `assert.not`
records:

```elm
{ attributeContains : AttributeData -> Assertion
, attributeEquals : AttributeData -> Assertion
, inlineStyleEquals : StyleData -> Assertion
, valueContains : TextData -> Assertion
, classPresent : ClassData -> Assertion
, containsText : TextData -> Assertion
, styleEquals : StyleData -> Assertion
, elementPresent : String -> Assertion
, elementVisible : String -> Assertion
, titleContains : String -> Assertion
, valueEquals : TextData -> Assertion
, titleEquals : String -> Assertion
, urlContains : String -> Assertion
, urlEquals : String -> Assertion
}
```

## Step groups
You can define a new step that is composed of many other steps but appear as
one step in the results with the `stepGroup` function. If any of the defined
steps fails the new step fails as well.

```elm
myStep =
  stepGroup "Descripiton of the step"
    [ step1
    , assertion1
    ]

spec =
  it "does something"
    [ myStep
    , step2
    ]
```

## Examples
You can see examples of tests written in elm-spec in here:
* https://github.com/gdotdesign/elm-ui/tree/master/spec
* https://github.com/gdotdesign/elm-dom/tree/master/spec
* https://github.com/gdotdesign/elm-storage/tree/master/spec
