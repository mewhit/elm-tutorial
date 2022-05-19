module Excercise1 exposing (..)

import Expect exposing (equal)
import Main exposing (add)
import Test exposing (Test, describe, test, fuzz)
import Fuzz 


suite : Test
suite =
        fuzz (Fuzz.list (Fuzz.tuple ( Fuzz.int, Fuzz.int ))) "add" <|
            \intList ->
                let
                    exec = \fn -> \(a,b) -> fn a b 
                    
                    expected = intList |> List.map (exec (+))
                in
                    intList |> List.map (exec add) |> equal expected
        



-- suite : Test
-- suite =
--     test "It should be always 0" <| \_ -> equal const0 0
