module Excercise1 exposing (..)

import Expect exposing (equal)
import Fuzz
import Main exposing (Math)
import Test exposing (Test, describe, fuzz, test)


toMath : ( String, Int ) -> Math
toMath ( str, number ) =
    { equation = str, result = number }


suite : Test
suite =
    fuzz (Fuzz.list (Fuzz.tuple ( Fuzz.string, Fuzz.int ))) "type alias Math" <|
        \strIntList ->
            let
                expected =
                    strIntList |> List.map (\( a, b ) -> { equation = a, result = b })
            in
            strIntList |> List.map toMath |> equal expected
