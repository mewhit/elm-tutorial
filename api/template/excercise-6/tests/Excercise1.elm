module Excercise1 exposing (suite)

import Expect exposing (equal)
import Fuzz
import Main exposing (isNumber)
import Test exposing (Test, describe, fuzz, test)



suite : Test
suite =
    describe "isNumber" [
        test "Not Number should be false " (\_ -> "12sdf" |> isNumber |> equal False),
        test "is Number should be true " (\_ -> "12" |> isNumber |> equal True)
    ]

        

