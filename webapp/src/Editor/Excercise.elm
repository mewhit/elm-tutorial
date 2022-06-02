module Editor.Excercise exposing (GraphData, compileRequest, getSolutionsRequest, postSource)

import Auth exposing (accessToken)
import Config exposing (Config)
import Editor.Data.CompileResult exposing (CompileError, CompileResult(..), RunStartModel, TestResult(..), TestStep(..), decode)
import Editor.Data.ExcerciseSolution exposing (Excercise, ExcerciseSolution)
import Editor.Data.Problem exposing (generic)
import Extra.Http.Extra exposing (AccessToken(..), post)
import Generated.Mutation as Mutation
import Generated.Object
import Generated.Object.Err
import Generated.Object.ExcerciseSolution
import Generated.Object.Failure
import Generated.Object.Reason
import Generated.Object.ReasonData
import Generated.Object.RunComplete
import Generated.Object.RunStart
import Generated.Object.TestCompleted
import Generated.Query as Query
import Generated.Union
import Generated.Union.CompileResult
import Generated.Union.ExcerciseSolutionResult
import Graphql.Http
import Graphql.Operation exposing (RootMutation)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet, with)
import Json.Encode as E
import RemoteData exposing (RemoteData, WebData)


postSource : Config -> String -> String -> (String -> WebData CompileResult -> msg) -> Cmd msg
postSource config source id handler =
    post
        { url = config.domain ++ "/excercise/" ++ id
        , handler = handler id
        , decoder = decode
        , token = config.user |> accessToken
        , body =
            E.object
                [ ( "code", E.string source ) ]
        }


toHeader : AccessToken -> String
toHeader token =
    case token of
        AccessToken str ->
            "Bearer " ++ str


type alias GraphData a =
    RemoteData (Graphql.Http.Error a) a


getSolutionsRequest : Config -> (GraphData (List ExcerciseSolution) -> msg) -> Cmd msg
getSolutionsRequest config handler =
    Query.solutionByStudentId excerciseSolutionSelection
        |> Graphql.Http.queryRequest (config.domain ++ "/graphql")
        |> Graphql.Http.withHeader "Authorization" (config.user |> accessToken |> Maybe.map toHeader |> Maybe.withDefault "")
        |> Graphql.Http.send (RemoteData.fromResult >> handler)


excerciseSolutionSelection : SelectionSet ExcerciseSolution Generated.Object.ExcerciseSolution
excerciseSolutionSelection =
    SelectionSet.succeed ExcerciseSolution
        |> with Generated.Object.ExcerciseSolution.id
        |> with Generated.Object.ExcerciseSolution.code
        |> with Generated.Object.ExcerciseSolution.excerciseId
        |> with Generated.Object.ExcerciseSolution.userId
        |> with (Generated.Object.ExcerciseSolution.results toTest)


compileRequest : Config -> String -> String -> (String -> GraphData CompileResult -> msg) -> Cmd msg
compileRequest config source id handler =
    mutation ( source, id )
        |> Graphql.Http.mutationRequest (config.domain ++ "/graphql")
        |> Graphql.Http.withHeader "Authorization" (config.user |> accessToken |> Maybe.map toHeader |> Maybe.withDefault "")
        |> Graphql.Http.send (RemoteData.fromResult >> handler id)


mutation : ( String, String ) -> SelectionSet CompileResult RootMutation
mutation ( code, id ) =
    Mutation.compile { data = { code = code, excerciseId = id } }
        compileResultSelection


compileResultSelection : SelectionSet CompileResult Generated.Union.ExcerciseSolutionResult
compileResultSelection =
    Generated.Union.ExcerciseSolutionResult.fragments
        { onErr = toErr
        , onExcerciseSolution = toSuccess
        }


toErr : SelectionSet CompileResult Generated.Object.Err
toErr =
    SelectionSet.succeed CompileError
        |> with Generated.Object.Err.err
        |> SelectionSet.map Error


toSuccess : SelectionSet CompileResult Generated.Object.ExcerciseSolution
toSuccess =
    SelectionSet.succeed Editor.Data.CompileResult.StepModel
        |> with Generated.Object.ExcerciseSolution.code
        |> with (Generated.Object.ExcerciseSolution.results toTest)
        |> SelectionSet.map Success


toTest : SelectionSet TestStep Generated.Union.CompileResult
toTest =
    Generated.Union.CompileResult.fragments
        { onRunComplete = toRunCompleted
        , onRunStart = toRunStart
        , onTestCompleted = toTestCompleted
        }


toRunCompleted : SelectionSet TestStep Generated.Object.RunComplete
toRunCompleted =
    SelectionSet.succeed Editor.Data.CompileResult.RunCompleteModel
        |> with Generated.Object.RunComplete.passed
        |> with Generated.Object.RunComplete.failed
        |> with Generated.Object.RunComplete.duration
        |> SelectionSet.map RunComplete


toRunStart : SelectionSet TestStep Generated.Object.RunStart
toRunStart =
    SelectionSet.succeed RunStartModel
        |> with Generated.Object.RunStart.testCount
        |> with Generated.Object.RunStart.fuzzRuns
        |> with Generated.Object.RunStart.paths
        |> with Generated.Object.RunStart.initialSeed
        |> SelectionSet.map RunStart


type alias T =
    { status : String
    , labels : List String
    , failures : List Editor.Data.CompileResult.TestFailure
    , duration : Float
    }


toTestCompleted : SelectionSet TestStep Generated.Object.TestCompleted
toTestCompleted =
    SelectionSet.succeed T
        |> with Generated.Object.TestCompleted.status
        |> with Generated.Object.TestCompleted.labels
        |> with (Generated.Object.TestCompleted.failures toFailure)
        |> with Generated.Object.TestCompleted.duration
        |> SelectionSet.map (toTestResult >> TestCompleted)


toTestResult : T -> TestResult
toTestResult s =
    if s.status == "fail" then
        { labels = s.labels
        , failures = s.failures
        , duration = s.duration
        }
            |> TestFail

    else
        { labels = s.labels
        , failures = s.failures
        , duration = s.duration
        }
            |> TestPass


toFailure : SelectionSet Editor.Data.CompileResult.TestFailure Generated.Object.Failure
toFailure =
    SelectionSet.succeed Editor.Data.CompileResult.TestFailure
        |> with Generated.Object.Failure.message
        |> with (Generated.Object.Failure.reason toRaison)


toRaison : SelectionSet Editor.Data.CompileResult.TestFailureReason Generated.Object.Reason
toRaison =
    SelectionSet.succeed Editor.Data.CompileResult.TestFailureReason
        |> with Generated.Object.Reason.type_
        |> with (Generated.Object.Reason.data toData)


toData : SelectionSet Editor.Data.CompileResult.TestFailureReasonData Generated.Object.ReasonData
toData =
    SelectionSet.succeed Editor.Data.CompileResult.TestFailureReasonData
        |> with Generated.Object.ReasonData.expected
        |> with Generated.Object.ReasonData.actual
        |> with Generated.Object.ReasonData.comparison



-- decode : SelectionSet CompileResult RootMutation
-- decode =
-- SelectionSet.oneOf
--     [ D.map Error (D.succeed CompileError |> D.required "error" D.string)
--     , D.map Steps
--         (D.list
--             (D.oneOf
--                 [ D.map RunStart
--                     (D.succeed RunStartModel
--                         |> D.required "testCount" D.int
--                         |> D.required "fuzzRuns" D.int
--                         |> D.required "globs" (D.list D.string)
--                         |> D.required "paths" (D.list D.string)
--                         |> D.required "initialSeed" D.string
--                     )
--                 , D.map TestCompleted
--                     (D.field "status" D.string
--                         |> D.andThen
--                             (\statusStr ->
--                                 let
--                                     decodeResult =
--                                         D.succeed Result
--                                             |> D.required "labels" (D.list D.string)
--                                             |> D.required "failures"
--                                                 (D.list
--                                                     (D.succeed TestFailure
--                                                         |> D.required "message" D.string
--                                                         |> D.required "reason"
--                                                             (D.succeed TestFailureReason
--                                                                 |> D.required "type" D.string
--                                                                 |> D.required "data"
--                                                                     (D.succeed TestFailureReasonData
--                                                                         |> D.required "expected" D.string
--                                                                         |> D.required "actual" D.string
--                                                                         |> D.required "comparison" D.string
--                                                                     )
--                                                             )
--                                                     )
--                                                 )
--                                             |> D.required "duration" D.float
--                                 in
--                                 case statusStr of
--                                     "pass" ->
--                                         D.map TestPass decodeResult
--                                     "fail" ->
--                                         D.map TestFail decodeResult
--                                     _ ->
--                                         D.fail ("Unknown status: " ++ statusStr)
--                             )
--                     )
--                 , D.map RunComplete
--                     (D.succeed RunCompleteModel
--                         |> D.required "passed" D.int
--                         |> D.required "failed" D.int
--                         |> D.required "duration" D.float
--                     )
--                 ]
--             )
--         )
--     ]
