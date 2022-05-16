module Main exposing (..)

import Browser
import Browser.Dom exposing (Viewport, getViewport)
import Editor.Data.CompileResult exposing (hasFail)
import Editor.Data.Registry.Defaults as Defaults
import Editor.Data.Version exposing (Version(..))
import Editor.Page.Editor as Editor
import Html exposing (Html, a, button, div, i, nav, span, text)
import Html.Attributes as Attr exposing (class, disabled, href)
import Html.Events exposing (onClick)
import Json.Encode as En exposing (Value)
import Random
import RemoteData exposing (RemoteData(..))
import ScrollTo as ScrollTo
import Task
import UI.UI as UI


type alias Model =
    { randomPair : ( Int, Int )
    , editor : Editor.Model
    , scrollTo : ScrollTo.State
    , viewport : Maybe Viewport
    }


main : Program () Model Msg
main =
    let
        ( editorModel, editorCmd ) =
            Editor.init
                { original = ""
                , name = ""
                , width = 250
                , height = 250
                , direct = Defaults.direct
                , indirect = Defaults.indirect
                }
    in
    Browser.element
        { init =
            \_ ->
                ( { randomPair = ( 0, 10 ), editor = editorModel, scrollTo = ScrollTo.init, viewport = Nothing }
                , Cmd.batch
                    [ Random.generate RandomNumber (Random.pair (Random.int 0 4) (Random.int 5 10))
                    , Cmd.batch [ Task.perform HandleViewport getViewport, Cmd.map EditorMsg editorCmd ]
                    ]
                )
        , view = view
        , update = update
        , subscriptions =
            \model ->
                Sub.batch
                    [ Editor.subscriptions model.editor |> Sub.map EditorMsg
                    , Sub.map ScrollToMsg <|
                        ScrollTo.subscriptions model.scrollTo
                    ]
        }


type Msg
    = RandomNumber ( Int, Int )
    | EditorMsg Editor.Msg
    | ScrollToMsg ScrollTo.Msg
    | ScrollToId UI.Id
    | HandleViewport Viewport


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RandomNumber pair ->
            ( { model | randomPair = pair }, Cmd.none )

        EditorMsg editorMsg ->
            let
                ( editorModel, editorCmd ) =
                    Editor.update editorMsg model.editor
            in
            ( { model | editor = editorModel }, Cmd.map EditorMsg editorCmd )

        ScrollToMsg scrollToMsg ->
            let
                ( scrollToModel, scrollToCmds ) =
                    ScrollTo.update
                        scrollToMsg
                        model.scrollTo
            in
            ( { model | scrollTo = scrollToModel }
            , Cmd.map ScrollToMsg scrollToCmds
            )

        ScrollToId id ->
            ( model
            , scrollTo id
            )

        HandleViewport viewport ->
            ( { model | viewport = Just viewport }, Cmd.none )


scrollTo : UI.Id -> Cmd Msg
scrollTo id =
    case id of
        UI.Id id_ ->
            ScrollTo.scrollTo id_ |> Cmd.map ScrollToMsg


view : Model -> Html Msg
view model =
    div [ class "bg-black w-screen min-h-screen" ] <|
        case model.viewport of
            Nothing ->
                [ text "loading" ]

            Just _ ->
                [ UI.page introId
                    [ Html.h1 [ class "text-7xl text-pink-900" ] [ text "Elm Tutorial" ]
                    , div []
                        [ Html.p [ class "text-lg text-white" ] [ text "If the indicator is ", span [ class "text-red-500 " ] [ text "red" ], text ", your code or return is wrong" ]
                        , Html.p [ class "text-lg text-white" ] [ text "If the indicator is ", span [ class "text-yellow-500 " ] [ text "yellow" ], text ", maybe place to optimization" ]
                        , Html.p [ class "text-lg text-white" ] [ text "If the indicator is ", span [ class "text-green-500 " ] [ text "green" ], text ", everything is right" ]
                        ]
                    , navButton excerciseOneScrollId "Start With Synthase" False
                    ]
                , excerciseOne model
                , excerciseTwo model
                ]


introId : UI.Id
introId =
    UI.toId "intro"


excerciseOneScrollId : UI.Id
excerciseOneScrollId =
    UI.toId "excercise-scroll-one"


excerciseTwoScrollId : UI.Id
excerciseTwoScrollId =
    UI.toId "excercise-scroll-two"


excerciseOneEditorId : UI.Id
excerciseOneEditorId =
    UI.toId "excercise-editor-one"


excerciseTwoEditorId : UI.Id
excerciseTwoEditorId =
    UI.toId "excercise-editor-two"


navButton : UI.Id -> String -> Bool -> Html Msg
navButton id_ text_ disabled =
    if disabled then
        Html.button [ class "bg-blue-300 h-16 pl-5 pr-5 rounded text-xl opacity-50", Attr.disabled disabled, onClick <| ScrollToId id_ ] [ text text_ ]

    else
        Html.button [ class "bg-blue-300 h-16 pl-5 pr-5 rounded text-xl", Attr.disabled disabled, onClick <| ScrollToId id_ ] [ text text_ ]



-- ++ excerciseTwo model.randomPair
-- ++ excerciseThree model.randomPair


excerciseOne : Model -> Html Msg
excerciseOne model =
    [ navButton introId "Previous" False
    , Html.h3 [ class "text-3xl text-cyan-900" ] [ text "Excercise 1" ]
    , Html.p [ class "text-lg text-yellow-900" ]
        [ text "Create simple function named "
        , span [ class "text-blue-900" ] [ text "const0" ]
        , text " that take "
        , span [ class "text-blue-900" ] [ text "0 arguments" ]
        , text " and the "
        , span [ class "text-blue-900" ] [ text "return is always 0" ]
        ]
    , Editor.view excerciseOneEditorId model.editor |> Html.map EditorMsg
    , case model.editor.editor.result of
        Success result ->
            if hasFail result then
                UI.pill "bg-red-600" "Fail"

            else
                UI.pill "bg-green-600" "Success"

        _ ->
            UI.pill "bg-yellow-600" "Waiting"
    , navButton excerciseTwoScrollId "Next" (model.editor.editor.result |> RemoteData.map hasFail |> RemoteData.withDefault True)
    ]
        |> UI.page excerciseOneScrollId



-- ++ [ CodeEditor.view [ CodeEditor.id "elm" ] ]


excerciseTwo : Model -> Html Msg
excerciseTwo model =
    [ navButton excerciseOneScrollId "Previous" False
    , Html.p [ class "text-lg text-yellow-900" ]
        [ text "Create simple function named "
        , span [ class "text-blue-900" ] [ text "copy" ]
        , text " that take "
        , span [ class "text-blue-900" ] [ text "1 Int arguments" ]
        , text " and the "
        , span [ class "text-blue-900" ] [ text "return identical Int" ]
        ]
    , Editor.view excerciseTwoEditorId model.editor |> Html.map EditorMsg
    ]
        |> UI.page excerciseTwoScrollId



-- excerciseThree : ( Int, Int ) -> List (Html Msg)
-- excerciseThree ( min, max ) =
--     let
--         result =
--             Excercises.three min max
--         display =
--             if result == (min + max) then
--                 [ UI.pill "bg-green-500" "Succeed" ]
--             else
--                 [ UI.pill "bg-red-500" "Fail"
--                 , span [ class "text-red-500" ] [ text <| String.fromInt result ++ " must be " ++ ((min + max) |> String.fromInt) ]
--                 ]
--     in
--     Html.p [ class "text-lg text-yellow-900" ] [ text "This function should have Two Int parameter and return this some of them" ]
--         :: display
