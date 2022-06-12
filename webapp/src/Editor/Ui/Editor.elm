port module Editor.Ui.Editor exposing (..)

{-| Control the code editor.

Relies on code-editor.js being present.

-}

import Config exposing (Config)
import Dict exposing (Dict)
import Editor.Data.CompileResult as CompileResult
import Editor.Data.Deps as Deps
import Editor.Data.ExcerciseSolution exposing (ExcerciseSolution)
import Editor.Data.Header as Header
import Editor.Data.Hint as Hint
import Editor.Data.Problem as Problem
import Editor.Data.Registry.Package as Package
import Editor.Data.Registry.Solution as Solution
import Editor.Data.Status as Status
import Editor.Data.Version as Version exposing (Version(..))
import Editor.Excercise exposing (GraphData, compileRequest, getSolutionsRequest, postSource)
import Editor.Ui.Icon
import Elm.Error as Error
import FeatherIcons as I
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, onMouseLeave, onMouseOver)
import Html.Lazy exposing (..)
import Json.Decode as D
import Json.Decode.Pipeline as D
import Json.Encode as E
import RemoteData exposing (RemoteData(..), WebData)
import RemoteData.Http as Http
import UI.UI as UI



-- PORTS


port submitSource : String -> Cmd msg


port gotErrors : (E.Value -> msg) -> Sub msg


port gotSuccess : (() -> msg) -> Sub msg



-- MODEL


type alias Model =
    { config : Config
    , source : String
    , hint : Maybe String
    , hintTable : Hint.Table
    , imports : Header.Imports
    , importEnd : Int

    -- , dependencies : DepsInfo
    , selection : Maybe Error.Region
    , result : Dict String (GraphData CompileResult.CompileResult)
    , sources : Dict String String
    }


type DepsInfo
    = Loading
    | Failure
    | Success Deps.Info


setSelection : Error.Region -> Model -> Model
setSelection region model =
    { model | selection = Just region }



-- INIT


defaultExcercise : Dict String String
defaultExcercise =
    [ ( "1", "" )
    , ( "2", "" )
    , ( "3", "" )
    , ( "4", "" )
    , ( "5", "" )
    , ( "6", "isNumber :  String -> Bool\nisNumber str  =\n   Maybe.withDefault False (Maybe.map toTrue) (String.toInt str))" )
    ]
        |> Dict.fromList


init : Config -> String -> ( Model, Cmd Msg )
init config source =
    let
        defaults =
            { source = source
            , config = config
            , hint = Nothing
            , hintTable = Hint.defaultTable
            , imports = Header.defaultImports
            , importEnd = 0

            -- , dependencies = Loading
            , selection = Nothing
            , result = Dict.empty
            , sources = defaultExcercise
            }
    in
    case Header.parse source of
        Nothing ->
            ( defaults
            , getSolutionsRequest config HandleResults
            )

        Just ( imports, importEnd ) ->
            ( { defaults | imports = imports, importEnd = importEnd }
            , getSolutionsRequest config HandleResults
            )



-- fetchDepsInfo : Cmd Msg
-- fetchDepsInfo =
--     Http.get
--         { url = "https://elm.studio/api/compile/deps-info.json"
--         , expect = Http.expectJson GotDepsInfo Deps.decoder
--         }
-- UPDATE


type Msg
    = OnChange String String (Maybe Error.Region)
    | OnSave String (Maybe Error.Region)
    | OnHint (Maybe String)
    | OnCompile String
    | OnReset String
    | HandleResult String (GraphData CompileResult.CompileResult)
    | HandleResults (GraphData (List ExcerciseSolution))
      -- | GotDepsInfo (Result Http.Error Deps.Info)
    | GotSuccess
    | GotErrors E.Value


update : Msg -> Model -> Status.Status -> Config -> ( Model, Status.Status, Cmd Msg )
update msg m status config =
    let
        model =
            { m | config = config }
    in
    case msg of
        OnChange id source selection ->
            ( { model
                | source = source
                , selection = selection
                , sources = Dict.insert id source model.sources
              }
            , Status.changed status
            , Cmd.none
            )

        OnHint hint ->
            ( { model | hint = hint }, status, Cmd.none )

        OnSave source selection ->
            ( updateImports
                { model
                    | source = source
                    , selection = selection
                }
            , Status.compiling status
            , submitSource source
            )

        OnReset id ->
            let
                excercise =
                    Dict.get id defaultExcercise
            in
            case excercise of
                Just e ->
                    ( { model | sources = Dict.insert id e model.sources }, status, Cmd.none )

                Nothing ->
                    ( model, status, Cmd.none )

        OnCompile id ->
            ( updateImports { model | result = Dict.remove id model.result }
            , Status.compiling status
            , Cmd.batch
                [ compileRequest model.config model.source id HandleResult

                -- , postSource model.config model.source id HandleResult2
                -- , submitSource model.source
                ]
            )

        -- GotDepsInfo result ->
        --     case result of
        --         Err _ ->
        --             ( { model | dependencies = Failure }
        --             , status
        --             , Cmd.none
        --             )
        --         Ok info ->
        --             ( { model | hintTable = Hint.buildTable model.imports info, dependencies = Success info }
        --             , status
        --             , Cmd.none
        --             )
        HandleResult id result ->
            ( { model | result = Dict.insert id result model.result }, Status.success, Cmd.none )

        HandleResults results ->
            ( { model
                | result =
                    results
                        |> RemoteData.withDefault []
                        |> List.map (\s -> ( s.excerciseId, RemoteData.Success (CompileResult.Success { code = s.code, steps = s.results }) ))
                        |> Dict.fromList
                        |> Dict.union model.result
                , sources =
                    results
                        |> RemoteData.withDefault []
                        |> List.map (\s -> ( s.excerciseId, s.code ))
                        |> Dict.fromList
                        |> Dict.union model.sources
              }
            , Status.success
            , Cmd.none
            )

        GotSuccess ->
            ( model, Status.success, Cmd.none )

        GotErrors errors ->
            ( model, Status.problems errors, Cmd.none )


updateImports : Model -> Model
updateImports model =
    case Header.parse model.source of
        Nothing ->
            model

        Just ( imports, importEnd ) ->
            model



-- case model.dependencies of
--     Failure ->
--         model
--     Loading ->
--         model
--     Success info ->
--         { model
--             | hintTable = Hint.buildTable imports info
--             , imports = imports
--             , importEnd = importEnd
--         }
-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch [ gotErrors GotErrors, gotSuccess (always GotSuccess) ]



-- VIEW


viewEditor : UI.Id -> Solution.Solution -> Bool -> Model -> Html Msg
viewEditor id_ solution isLight model =
    Html.form
        [ UI.toAttr id_
        , class "editor"
        , target "output"
        ]
        [ textarea [ id <| UI.toString id_ ++ "code", name "code", style "display" "none" ] []
        , case solution.hash of
            Just hash ->
                viewSolutionInput solution hash

            Nothing ->
                viewSolutionInput solution ""
        , lazy5 viewEditor_ id_ (model.sources |> Dict.get (UI.toString id_) |> Maybe.withDefault "") model.selection isLight model.importEnd
        ]


viewSolutionInput : Solution.Solution -> String -> Html msg
viewSolutionInput solution hash =
    let
        toString dict =
            dict
                |> Dict.toList
                |> List.map (\( key, version ) -> Package.nameFromKey key ++ ":" ++ Version.toString version)
                |> String.join ","
    in
    fieldset
        [ style "display" "none" ]
        [ input [ id "hash", name "hash", value hash ] []
        , input [ id "direct", name "direct", value (toString solution.direct) ] []
        , input [ id "indirect", name "indirect", value (toString solution.indirect) ] []
        ]


viewEditor_ : UI.Id -> String -> Maybe Error.Region -> Bool -> Int -> Html Msg
viewEditor_ id_ source selection lights importEnd =
    node
        "code-editor"
        [ attribute "id" <| UI.toString id_ ++ "code-editor"
        , property "source" (E.string source)
        , property "theme" (E.string "dark")
        , property "importEnd" (E.int importEnd)
        , property "selection" <|
            case selection of
                Nothing ->
                    encodeBlankSelection

                Just region ->
                    encodeSelection region
        , on "save" (D.map2 OnSave decodeSource decodeSelection)
        , on "change" (D.map2 (OnChange (id_ |> UI.toString)) decodeSource decodeSelection)
        , on "hint" (D.map OnHint decodeHint)
        ]
        []



-- VIEW / HINT


viewHint : Model -> Html msg
viewHint model =
    case model.hint of
        Nothing ->
            text ""

        Just hint ->
            lazy2 viewHint_ hint model.hintTable


viewHint_ : String -> Hint.Table -> Html msg
viewHint_ token table =
    case Hint.lookup token table of
        Just info ->
            case info of
                Hint.Ambiguous ->
                    text ""

                Hint.Specific hint ->
                    Editor.Ui.Icon.link [ style "padding" "0 10px" ]
                        { icon = I.minusCircle
                        , iconColor = Nothing
                        , label = Just hint.text
                        , alt = "Read more about " ++ hint.text
                        , link = hint.href
                        }

        Nothing ->
            text ""



-- ENCODE / DECODE


encodeSelection : Error.Region -> E.Value
encodeSelection { start, end } =
    E.object
        [ ( "start", E.object [ ( "line", E.int start.line ), ( "column", E.int start.column ) ] )
        , ( "end", E.object [ ( "line", E.int end.line ), ( "column", E.int end.column ) ] )
        ]


encodeBlankSelection : E.Value
encodeBlankSelection =
    E.object
        [ ( "start", E.null )
        , ( "end", E.null )
        ]


decodeSource : D.Decoder String
decodeSource =
    D.at [ "target", "source" ] D.string


decodeSelection : D.Decoder (Maybe Error.Region)
decodeSelection =
    D.at [ "target", "selection" ] <|
        D.map2 (Maybe.map2 Error.Region)
            (D.field "start" (D.nullable decodePosition))
            (D.field "end" (D.nullable decodePosition))


decodePosition : D.Decoder Error.Position
decodePosition =
    D.map2 Error.Position
        (D.field "line" D.int)
        (D.field "column" D.int)


decodeHint : D.Decoder (Maybe String)
decodeHint =
    D.at [ "target", "hint" ] (D.nullable D.string)
