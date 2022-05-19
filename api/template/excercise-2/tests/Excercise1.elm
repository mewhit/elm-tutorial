module Excercise1 exposing (..)

import Expect exposing (equal)
import Main exposing (copy)
import Test exposing (Test, describe, test, fuzz)
import Fuzz 


suite : Test
suite =
    fuzz (Fuzz.list Fuzz.int) "copy"
        <| \intList -> 
            intList 
                |> List.map copy |> equal intList
        



-- suite : Test
-- suite =
--     test "It should be always 0" <| \_ -> equal const0 0
