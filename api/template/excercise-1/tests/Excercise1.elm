module Excercise1 exposing (..)

import Expect exposing (equal)
import Main exposing (const0)
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "const0"
        [ test "It should be always 0" <| \_ -> equal const0 0
        ]



-- suite : Test
-- suite =
--     test "It should be always 0" <| \_ -> equal const0 0
