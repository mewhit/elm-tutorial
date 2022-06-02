module Editor.Data.ExcerciseSolution exposing (..)

import Editor.Data.CompileResult exposing (CompileResult, TestStep)


type alias Excercise =
    { id : String
    }


type alias ExcerciseSolution =
    { id : String
    , code : String
    , excerciseId : String
    , solverId : String
    , results : List TestStep
    }
