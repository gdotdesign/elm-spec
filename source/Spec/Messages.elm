module Spec.Messages exposing (..)

import Spec.CoreTypes exposing (..)

{-| Messages for a test program.
-}
type Msg msg
  = Next (Maybe Outcome)
  | NoOp ()
  | App msg
