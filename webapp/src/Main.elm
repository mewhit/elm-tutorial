module Main exposing (..)

import Browser
import Browser.Dom exposing (Viewport, getViewport)
import Editor.Data.Registry.Defaults as Defaults
import Editor.Data.Version exposing (Version(..))
import Editor.Page.Editor as Editor
import Excercises.Excercises as Excercises
import Html exposing (Html, a, button, div, i, nav, span, text)
import Html.Attributes as Attr exposing (class, disabled, href)
import Html.Events exposing (onClick)
import Json.Encode as En exposing (Value)
import Random
import ScrollTo as ScrollTo
import Task


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
    | ScrollToId ScrollId
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


scrollTo : ScrollId -> Cmd Msg
scrollTo id =
    case id of
        Id id_ ->
            ScrollTo.scrollTo id_ |> Cmd.map ScrollToMsg


view : Model -> Html Msg
view model =
    div [ class "bg-black w-screen min-h-screen" ] <|
        case model.viewport of
            Nothing ->
                [ text "loading" ]

            Just _ ->
                [ page introId
                    [ Html.h1 [ class "text-7xl text-pink-900" ] [ text "Elm Tutorial" ]
                    , div []
                        [ Html.p [ class "text-lg text-white" ] [ text "If the indicator is ", span [ class "text-red-500 " ] [ text "red" ], text ", your code or return is wrong" ]
                        , Html.p [ class "text-lg text-white" ] [ text "If the indicator is ", span [ class "text-yellow-500 " ] [ text "yellow" ], text ", maybe place to optimization" ]
                        , Html.p [ class "text-lg text-white" ] [ text "If the indicator is ", span [ class "text-green-500 " ] [ text "green" ], text ", everything is right" ]
                        ]
                    , navButton excerciseOneId "Start With Synthase" False
                    ]
                , excerciseOne model
                , excerciseTwo model.randomPair
                ]


type ScrollId
    = Id String


toScrollId : String -> ScrollId
toScrollId id =
    Id id


toString : ScrollId -> String
toString id =
    case id of
        Id id_ ->
            id_


introId : ScrollId
introId =
    toScrollId "intro"


excerciseOneId : ScrollId
excerciseOneId =
    toScrollId "excercise-one"


excerciseTwoId : ScrollId
excerciseTwoId =
    toScrollId "excercise-two"


page : ScrollId -> List (Html Msg) -> Html Msg
page id elements =
    div [ Attr.id <| toString id, class "flex flex-col justify-evenly items-center h-screen w-full" ] elements


navButton : ScrollId -> String -> Bool -> Html Msg
navButton id_ text_ disabled =
    if disabled then
        Html.button [ class "bg-blue-300 h-16 pl-5 pr-5 rounded text-xl opacity-50", Attr.disabled disabled, onClick <| ScrollToId id_ ] [ text text_ ]

    else
        Html.button [ class "bg-blue-300 h-16 pl-5 pr-5 rounded text-xl", Attr.disabled disabled, onClick <| ScrollToId id_ ] [ text text_ ]



-- ++ excerciseTwo model.randomPair
-- ++ excerciseThree model.randomPair


pastille : String -> String -> Html Msg
pastille color text_ =
    span [ class <| color ++ " text-lg p-2 pr-10 pl-10 rounded" ] [ text text_ ]


excerciseOne : Model -> Html Msg
excerciseOne model =
    let
        result =
            Excercises.one

        successIndicator =
            if result == 0 then
                [ pastille "bg-green-500" "Succeed", navButton excerciseTwoId "Next" False ]

            else
                [ pastille "bg-red-500" "Fail", navButton excerciseTwoId "Next" True ]
    in
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
    , Editor.view model.editor |> Html.map EditorMsg
    ]
        ++ successIndicator
        |> page excerciseOneId



-- ++ [ CodeEditor.view [ CodeEditor.id "elm" ] ]


excerciseTwo : ( Int, Int ) -> Html Msg
excerciseTwo ( min, max ) =
    let
        initial =
            List.range min max

        result =
            initial
                |> List.map Excercises.two

        display =
            if result == initial then
                [ pastille "bg-green-500" "Succeed" ]

            else
                [ pastille "bg-red-500" "Fail"
                , span [ class "text-red-500" ] [ text <| (result |> List.map String.fromInt |> String.join ", ") ++ " must be " ++ (initial |> List.map String.fromInt |> String.join ", ") ]
                ]
    in
    [ navButton excerciseOneId "Previous" False
    , Html.p [ class "text-lg text-yellow-900" ] [ text "This function should have one Int parameter and return this same Int, no matter what!!!" ]
    ]
        ++ display
        |> page excerciseTwoId


excerciseThree : ( Int, Int ) -> List (Html Msg)
excerciseThree ( min, max ) =
    let
        result =
            Excercises.three min max

        display =
            if result == (min + max) then
                [ pastille "bg-green-500" "Succeed" ]

            else
                [ pastille "bg-red-500" "Fail"
                , span [ class "text-red-500" ] [ text <| String.fromInt result ++ " must be " ++ ((min + max) |> String.fromInt) ]
                ]
    in
    Html.p [ class "text-lg text-yellow-900" ] [ text "This function should have Two Int parameter and return this some of them" ]
        :: display
