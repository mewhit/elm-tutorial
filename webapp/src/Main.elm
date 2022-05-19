module Main exposing (..)

import Browser
import Browser.Dom exposing (Viewport, getViewport)
import Dict
import Editor.Data.CompileResult exposing (hasFail)
import Editor.Data.Registry.Defaults as Defaults
import Editor.Data.Version exposing (Version(..))
import Editor.Page.Editor as Editor
import Html exposing (Html, button, div, i, nav, span, text)
import Html.Attributes as Attr exposing (class, disabled, href)
import Html.Events exposing (onClick)
import Json.Encode as En exposing (Value)
import Random
import RemoteData exposing (RemoteData(..))
import ScrollTo as ScrollTo
import Task
import UI.UI as UI


type alias Model =
    { domain : String
    , randomPair : ( Int, Int )
    , editor : Editor.Model
    , scrollTo : ScrollTo.State
    , viewport : Maybe Viewport
    }


main : Program { domain : String } Model Msg
main =
    Browser.element
        { init =
            \{ domain } ->
                let
                    ( editorModel, editorCmd ) =
                        Editor.init
                            { original = ""
                            , name = ""
                            , domain = domain
                            , width = 250
                            , height = 250
                            , direct = Defaults.direct
                            , indirect = Defaults.indirect
                            }
                in
                ( { domain = domain, randomPair = ( 0, 10 ), editor = editorModel, scrollTo = ScrollTo.init, viewport = Nothing }
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


p : List (Html.Attribute msg) -> List (Html msg) -> Html msg
p attrs htmls =
    Html.p (class "text-lg text-white" :: attrs) htmls


view : Model -> Html Msg
view model =
    div [ class "bg-black w-screen min-h-screen" ] <|
        case model.viewport of
            Nothing ->
                [ text "loading" ]

            Just _ ->
                [ UI.page introId
                    [ Html.h1 [ class "text-7xl text-pink-600" ] [ text "Elm Tutorial" ]
                    , div []
                        [ p [] [ text "If the indicator is ", span [ class "text-red-500 " ] [ text "red" ], text ", your code or return is wrong" ]
                        , p [] [ text "If the indicator is ", span [ class "text-yellow-500 " ] [ text "yellow" ], text ", maybe place to optimization" ]
                        , p [] [ text "If the indicator is ", span [ class "text-green-500 " ] [ text "green" ], text ", everything is right" ]
                        ]
                    , div []
                        [ Html.h2 [ class "text-pink-600 text-3xl pb-2" ]
                            [ text "Some Usefull Documentations"
                            ]
                        , p [ Attr.class "text-blue-300 text-center" ] [ Html.a [ Attr.href "https://guide.elm-lang.org/core_language.html", Attr.target "_blank" ] [ text "The Elm Guide" ] ]
                        , p [ Attr.class "text-blue-300 text-center" ] [ Html.a [ Attr.href "https://package.elm-lang.org/packages/elm/core/latest/", Attr.target "_blank" ] [ text "Core Package" ] ]
                        ]
                    , navButton (toScrollId excerciseOneId) "Start With Synthase" False
                    ]
                , excerciseOne model
                , excerciseTwo model
                , excerciseThree model

                -- , excerciseFour model
                ]


introId : UI.Id
introId =
    UI.toId "intro"


toScrollId : UI.Id -> UI.Id
toScrollId =
    UI.toString >> (++) "excercise-scroll" >> UI.toId


excerciseOneId : UI.Id
excerciseOneId =
    UI.toId "1"


excerciseTwoId : UI.Id
excerciseTwoId =
    UI.toId "2"


excerciseThreeId : UI.Id
excerciseThreeId =
    UI.toId "3"


excerciseFourId : UI.Id
excerciseFourId =
    UI.toId "4"


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
    , Editor.view excerciseOneId model.editor |> Html.map EditorMsg
    , case Dict.get (UI.toString excerciseOneId) model.editor.editor.result of
        Just (Success result) ->
            if hasFail result then
                UI.pill "bg-red-600" "Fail"

            else
                UI.pill "bg-green-600" "Success"

        _ ->
            UI.pill "bg-yellow-600" "Waiting"
    , navButton (toScrollId excerciseTwoId) "Next" (model.editor.editor.result |> Dict.get (UI.toString excerciseOneId) |> Maybe.withDefault NotAsked |> RemoteData.map hasFail |> RemoteData.withDefault True)
    ]
        |> UI.page (toScrollId excerciseOneId)



-- ++ [ CodeEditor.view [ CodeEditor.id "elm" ] ]


excerciseTwo : Model -> Html Msg
excerciseTwo model =
    [ navButton (toScrollId excerciseOneId) "Previous" False
    , Html.p [ class "text-lg text-yellow-900" ]
        [ text "Create simple function named "
        , span [ class "text-blue-900" ] [ text "copy" ]
        , text " that take "
        , span [ class "text-blue-900" ] [ text "1 Int arguments" ]
        , text " and the "
        , span [ class "text-blue-900" ] [ text "return identical Int" ]
        ]
    , Editor.view excerciseTwoId model.editor |> Html.map EditorMsg
    , case Dict.get (UI.toString excerciseTwoId) model.editor.editor.result of
        Just (Success result) ->
            if hasFail result then
                UI.pill "bg-red-600" "Fail"

            else
                UI.pill "bg-green-600" "Success"

        _ ->
            UI.pill "bg-yellow-600" "Waiting"
    , navButton (toScrollId excerciseThreeId) "Next" (model.editor.editor.result |> Dict.get (UI.toString excerciseTwoId) |> Maybe.withDefault NotAsked |> RemoteData.map hasFail |> RemoteData.withDefault True)
    ]
        |> UI.page (toScrollId excerciseTwoId)


excerciseThree : Model -> Html Msg
excerciseThree model =
    [ navButton (toScrollId excerciseTwoId) "Previous" False
    , Html.p [ class "text-lg text-yellow-900" ]
        [ text "Last one of creating simple function. Create simple function named "
        , span [ class "text-blue-900" ] [ text "add" ]
        , text " that take "
        , span [ class "text-blue-900" ] [ text "2 Int arguments" ]
        , text " and the "
        , span [ class "text-blue-900" ] [ text "return the sum of them" ]
        ]
    , Editor.view excerciseThreeId model.editor |> Html.map EditorMsg
    , case Dict.get (UI.toString excerciseThreeId) model.editor.editor.result of
        Just (Success result) ->
            if hasFail result then
                UI.pill "bg-red-600" "Fail"

            else
                UI.pill "bg-green-600" "Success"

        _ ->
            UI.pill "bg-yellow-600" "Waiting"
    , navButton
        (toScrollId excerciseFourId)
        "Next"
        (model.editor.editor.result |> Dict.get (UI.toString excerciseThreeId) |> Maybe.withDefault NotAsked |> RemoteData.map hasFail |> RemoteData.withDefault True)
    ]
        |> UI.page (toScrollId excerciseThreeId)


excerciseFour : Model -> Html Msg
excerciseFour model =
    [ navButton (toScrollId excerciseThreeId) "Previous" False
    , Html.p [ class "text-lg text-yellow-900" ]
        [ text "Learn how to use "
        , span [ class "text-blue-900" ] [ Html.a [ href "https://package.elm-lang.org/packages/elm/core/latest/Basics#(|%3E)" ] [ text "pipe " ] ]
        , text "replace all "
        , span [ class "text-blue-900" ] [ text "bracket () " ]
        , text "by using only "
        , span [ class "text-blue-900" ] [ text "|>" ]
        ]
    , Editor.view excerciseFourId model.editor |> Html.map EditorMsg
    , case Dict.get (UI.toString excerciseFourId) model.editor.editor.result of
        Just (Success result) ->
            if hasFail result then
                UI.pill "bg-red-600" "Fail"

            else
                UI.pill "bg-green-600" "Success"

        _ ->
            UI.pill "bg-yellow-600" "Waiting"
    ]
        |> UI.page (toScrollId excerciseFourId)
