module Editor.Data.CompileResult exposing
    ( CompileError
    , CompileResult(..)
    , Result
    , RunCompleteModel
    , RunStartModel
    , StepModel
    , TestFailure
    , TestFailureReason
    , TestFailureReasonData
    , TestResult(..)
    , TestStep(..)
    , decode
    , hasFail
    )

import Json.Decode as D
import Json.Decode.Pipeline as D


hasFail : CompileResult -> Bool
hasFail compileResult =
    case compileResult of
        Error _ ->
            True

        Success x ->
            x.steps
                |> List.any
                    (\step ->
                        case step of
                            TestCompleted c ->
                                case c of
                                    TestFail _ ->
                                        True

                                    _ ->
                                        False

                            _ ->
                                False
                    )


type CompileResult
    = Error CompileError
    | Success StepModel


type alias CompileError =
    { error : String }


type alias StepModel =
    { code : String
    , steps : List TestStep
    }


type TestStep
    = RunStart RunStartModel
    | TestCompleted TestResult
    | RunComplete RunCompleteModel


type alias Result =
    { labels : List String
    , failures : List TestFailure
    , duration : Float
    }


type alias TestFailure =
    { message : String, reason : TestFailureReason }


type alias TestFailureReason =
    { type_ : String, data : TestFailureReasonData }


type alias TestFailureReasonData =
    { expected : String, actual : String, comparison : String }


type alias RunStartModel =
    { testCount : Int
    , fuzzRuns : Int
    , paths : List String
    , initialSeed : String
    }


type TestResult
    = TestPass Result
    | TestFail Result


type alias RunCompleteModel =
    { passed : Int
    , failed : Int
    , duration : Float
    }


decode : D.Decoder CompileResult
decode =
    D.oneOf
        [ D.map Error (D.succeed CompileError |> D.required "error" D.string)
        , D.map Success
            (D.succeed StepModel
                |> D.required "code" D.string
                |> D.required "steps"
                    (D.list
                        (D.oneOf
                            [ D.map RunStart
                                (D.succeed RunStartModel
                                    |> D.required "testCount" D.int
                                    |> D.required "fuzzRuns" D.int
                                    |> D.required "globs" (D.list D.string)
                                    |> D.required "initialSeed" D.string
                                )
                            , D.map TestCompleted
                                (D.field "status" D.string
                                    |> D.andThen
                                        (\statusStr ->
                                            let
                                                decodeResult =
                                                    D.succeed Result
                                                        |> D.required "labels" (D.list D.string)
                                                        |> D.required "failures"
                                                            (D.list
                                                                (D.succeed TestFailure
                                                                    |> D.required "message" D.string
                                                                    |> D.required "reason"
                                                                        (D.succeed TestFailureReason
                                                                            |> D.required "type" D.string
                                                                            |> D.required "data"
                                                                                (D.succeed TestFailureReasonData
                                                                                    |> D.required "expected" D.string
                                                                                    |> D.required "actual" D.string
                                                                                    |> D.required "comparison" D.string
                                                                                )
                                                                        )
                                                                )
                                                            )
                                                        |> D.required "duration" D.float
                                            in
                                            case statusStr of
                                                "pass" ->
                                                    D.map TestPass decodeResult

                                                "fail" ->
                                                    D.map TestFail decodeResult

                                                _ ->
                                                    D.fail ("Unknown status: " ++ statusStr)
                                        )
                                )
                            , D.map RunComplete
                                (D.succeed RunCompleteModel
                                    |> D.required "passed" D.int
                                    |> D.required "failed" D.int
                                    |> D.required "duration" D.float
                                )
                            ]
                        )
                    )
            )
        ]
