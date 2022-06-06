module Excercise1 exposing (suite)

import Expect exposing (equal)
import Fuzz
import Main exposing (Operator(..))
import Test exposing (Test, describe, fuzz, test)


calcul: Operator -> (Int , Int) -> Int
calcul operator (n1, n2)=
    case operator of 
        Add ->  
            (+) n1 n2
        Minus ->
            (-) n1 n2
        Number n3 -> 
            n3


suite : Test
suite =
    describe "type Operator" [
        fuzz (Fuzz.list (Fuzz.tuple ( Fuzz.int, Fuzz.int ))) "Add" <|
            \strIntList ->
            let
                expected =
                    strIntList |> List.map (\( a, b ) -> a + b)
            in
            strIntList |> List.map (calcul Add) |> equal expected
            , 
        fuzz (Fuzz.list (Fuzz.tuple ( Fuzz.int, Fuzz.int ))) "Minus" <|
            \strIntList ->
            let
                expected =
                    strIntList |> List.map (\( a, b ) -> a - b )
            in
            strIntList |> List.map (calcul Minus) |> equal expected
        ,   fuzz (Fuzz.list  Fuzz.int ) "Number" <|
            \strIntList ->
                strIntList |> List.map (\s -> calcul (Number s) (0,0)) |> equal strIntList
    ]

        

