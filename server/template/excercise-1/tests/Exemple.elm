module Exemple exposing (..)

import Expect exposing (equal)
import Main exposing (const0)
import Test exposing (Test, test)


suite : Test
suite =
    test "It should be always 0" <| \_ -> equal const0 0
