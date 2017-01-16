import Spec exposing (http, describe, it)
import Spec.Steps exposing (click)
import Spec.Runner

tests =
  describe "Http Mocking"
    [ http
      [ { method = "POST"
        , url = "/test"
        , response = { status = 200, body = "" }
        }
      , { method = "GET"
        , url = "/blah"
        , response = { status = 400, body = "" }
        }
      ]
    , it "should mock http requests"
      [ click "body"
      ]
    ]

main =
  Spec.Runner.run tests
