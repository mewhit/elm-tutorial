port module Main exposing (..)

import Auth
import Authenticate
import Browser
import Browser.Dom exposing (Viewport, getViewport)
import Browser.Navigation as Nav
import Config exposing (Config, setUser)
import Dict
import Editor.Data.CompileResult exposing (hasFail)
import Editor.Data.Registry.Defaults as Defaults
import Editor.Data.Version exposing (Version(..))
import Editor.Editor as Editor
import Extra.Http.Extra exposing (fromString)
import Html exposing (Html, button, div, span, text)
import Html.Attributes as Attr exposing (class, disabled, href)
import Html.Events exposing (onClick)
import Jwt
import RemoteData exposing (RemoteData(..), WebData)
import Router exposing (routeParser)
import ScrollTo as ScrollTo
import Task
import Time
import UI.Modal exposing (modal)
import UI.Typographie exposing (p, title)
import UI.UI as UI
import Url
import Url.Parser


port saveAccessToken : String -> Cmd msg


port accessTokenSaved : (String -> msg) -> Sub msg


type alias Model =
    { config : Config
    , editor : Editor.Model
    , scrollTo : ScrollTo.State
    , viewport : Maybe Viewport
    , key : Nav.Key
    , url : Url.Url
    , signUpModal : Bool
    , signInStatus : WebData String
    }


main : Program { domain : String, accessToken : String, now : Int } Model Msg
main =
    Browser.application
        { init =
            \{ domain, accessToken, now } ->
                \url ->
                    \key ->
                        let
                            config =
                                { domain = domain
                                , user =
                                    if String.isEmpty accessToken then
                                        Auth.Signout

                                    else if Jwt.isExpired (now |> Time.millisToPosix) accessToken |> Result.withDefault True then
                                        Auth.Signout

                                    else
                                        Auth.SignIn { accessToken = fromString accessToken }
                                }

                            ( editorModel, editorCmd ) =
                                Editor.init
                                    { original = ""
                                    , name = ""
                                    , config = config
                                    , width = 250
                                    , height = 250
                                    , direct = Defaults.direct
                                    , indirect = Defaults.indirect
                                    }

                            ( model, cmdMsg ) =
                                update (UrlChanged url)
                                    { editor = editorModel
                                    , scrollTo = ScrollTo.init
                                    , viewport = Nothing
                                    , key = key
                                    , url = url
                                    , signUpModal = False
                                    , signInStatus = NotAsked
                                    , config = config
                                    }
                        in
                        ( model
                        , Cmd.batch
                            [ Cmd.batch [ Task.perform HandleViewport getViewport, Cmd.map EditorMsg editorCmd ]
                            , cmdMsg
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
                    , accessTokenSaved (\_ -> HandleTokenSaved)
                    ]
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }


type Msg
    = EditorMsg Editor.Msg
    | ScrollToMsg ScrollTo.Msg
    | ScrollToId UI.Id
    | HandleViewport Viewport
    | HandleTokenSaved
    | SignIn
    | SignOut
    | CloseModal
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EditorMsg editorMsg ->
            let
                ( editorModel, editorCmd ) =
                    Editor.update editorMsg model.editor model.config
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
            ( { model
                | signUpModal =
                    case model.config.user of
                        Auth.SignIn _ ->
                            False

                        Auth.Signout ->
                            False
              }
            , scrollTo id
            )

        HandleViewport viewport ->
            ( { model | viewport = Just viewport }, Cmd.none )

        HandleTokenSaved ->
            ( model, Nav.reload )

        SignIn ->
            ( { model | signUpModal = True }, Cmd.none )

        SignOut ->
            ( { model | config = setUser Auth.Signout model.config }, saveAccessToken "" )

        CloseModal ->
            ( { model | signUpModal = False }, Cmd.none )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            { model | url = url }
                |> (\model_ ->
                        case Url.Parser.parse routeParser url of
                            Just Router.Home ->
                                ( model_, Cmd.none )

                            Just (Router.Callback (Just token)) ->
                                ( { model | config = setUser (Auth.SignIn { accessToken = fromString token }) model.config }
                                , Cmd.batch [ saveAccessToken token, Nav.pushUrl model.key "/" ]
                                )

                            Just (Router.Callback Nothing) ->
                                ( model_, Cmd.none )

                            _ ->
                                ( model_, Cmd.none )
                   )


scrollTo : UI.Id -> Cmd Msg
scrollTo id =
    case id of
        UI.Id id_ ->
            ScrollTo.scrollTo id_ |> Cmd.map ScrollToMsg


view : Model -> Browser.Document Msg
view model =
    { title = "Elm Tutorial"
    , body =
        [ div [ class "bg-black w-screen min-h-screen" ] <|
            case model.viewport of
                Nothing ->
                    [ text "loading" ]

                Just _ ->
                    [ div [ class "fixed w-full h-12 bg-slate-300 z-20 flex flex-row-reverse pr-5 pl-5" ]
                        [ case model.config.user of
                            Auth.SignIn _ ->
                                button [ onClick SignOut ] [ text "Sign out" ]

                            Auth.Signout ->
                                button [ onClick SignIn ] [ text "Sign in" ]
                        ]
                    , UI.page introId
                        [ title [] [ text "Elm Tutorial" ]
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
                    , excerciseFour model
                    , excerciseFive model
                    , excerciseSix model
                    , if model.signUpModal then
                        modal
                            { onClose = CloseModal
                            , content =
                                [ div [ class "p-10" ] [ UI.Typographie.subtitle [] [ text "Sign In" ], p [ class "" ] [ text "Keep track of your solved excercise, and one day you will compare with others" ] ]
                                , Html.a
                                    [ Attr.href <| model.config.domain ++ "/auth/github"
                                    , Attr.class "bg-gray-500 bg-opacity-75 text-white p-2 rounded"
                                    ]
                                    [ button [] [ text "Sign in with GitHub" ] ]
                                ]
                            }

                      else
                        text ""
                    ]
        ]
    }


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


excerciseFiveId : UI.Id
excerciseFiveId =
    UI.toId "5"


excerciseSixId : UI.Id
excerciseSixId =
    UI.toId "6"


navButton : UI.Id -> String -> Bool -> Html Msg
navButton id_ text_ disabled =
    if disabled then
        Html.button [ class "bg-blue-300 h-16 pl-5 pr-5 rounded text-xl opacity-50", Attr.disabled disabled, onClick <| ScrollToId id_ ] [ text text_ ]

    else
        Html.button [ class "bg-blue-300 h-16 pl-5 pr-5 rounded text-xl", Attr.disabled disabled, onClick <| ScrollToId id_ ] [ text text_ ]


excerciseOne : Model -> Html Msg
excerciseOne model =
    [ navButton introId "Previous" False
    , Html.h3 [ class "text-3xl text-cyan-900" ] [ text "Excercise 1" ]
    , UI.Typographie.explaination []
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
    , UI.Typographie.explaination []
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
    , UI.Typographie.explaination []
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
    , UI.Typographie.explaination []
        [ text "Time to learn how to create "
        , span [ class "text-blue-900" ] [ text "type alias " ]
        , text "I want you to create structure type alias named"
        , span [ class "text-blue-900" ] [ text " Math " ]
        , text "with contains"
        , span [ class "text-blue-900" ] [ text " 2 properties : equation as String and result as Int " ]
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
    , navButton
        (toScrollId excerciseFiveId)
        "Next"
        (model.editor.editor.result |> Dict.get (UI.toString excerciseFourId) |> Maybe.withDefault NotAsked |> RemoteData.map hasFail |> RemoteData.withDefault True)
    ]
        |> UI.page (toScrollId excerciseFourId)


excerciseFive : Model -> Html Msg
excerciseFive model =
    [ navButton (toScrollId excerciseFourId) "Previous" False
    , UI.Typographie.explaination []
        (toHtml
            [ Normal "Time to learn"
            , HighLight "Type"
            , Normal ", I want you to create"
            , HighLight "type named Operator"
            , Normal "containing this three values"
            , HighLight "Add and Minus and (Number Int)"
            ]
        )
    , Editor.view excerciseFiveId model.editor |> Html.map EditorMsg
    , case Dict.get (UI.toString excerciseFiveId) model.editor.editor.result of
        Just (Success result) ->
            if hasFail result then
                UI.pill "bg-red-600" "Fail"

            else
                UI.pill "bg-green-600" "Success"

        _ ->
            UI.pill "bg-yellow-600" "Waiting"
    , navButton
        (toScrollId excerciseSixId)
        "Next"
        (model.editor.editor.result |> Dict.get (UI.toString excerciseFiveId) |> Maybe.withDefault NotAsked |> RemoteData.map hasFail |> RemoteData.withDefault True)
    ]
        |> UI.page (toScrollId excerciseFiveId)


excerciseSix : Model -> Html Msg
excerciseSix model =
    [ navButton (toScrollId excerciseFiveId) "Previous" False
    , UI.Typographie.explaination []
        (toHtml
            [ Normal "Time to learn "
            , HighLight "|>"
            , Normal ", I want you to replace all parenthensis by using "
            , HighLight "|>"
            , Normal "with keeping the same output at the end"
            ]
        )
    , Editor.view excerciseSixId model.editor |> Html.map EditorMsg
    , case Dict.get (UI.toString excerciseSixId) model.editor.editor.result of
        Just (Success result) ->
            if hasFail result then
                UI.pill "bg-red-600" "Fail"

            else
                UI.pill "bg-green-600" "Success"

        _ ->
            UI.pill "bg-yellow-600" "Waiting"
    ]
        |> UI.page (toScrollId excerciseSixId)


type Explaination
    = HighLight String
    | Normal String


toHtml : List Explaination -> List (Html Msg)
toHtml explains =
    let
        html =
            \s ->
                case s of
                    HighLight str ->
                        span [ class "text-blue-900" ] [ text str ]

                    Normal str ->
                        text str
    in
    explains |> List.intersperse (Normal " ") |> List.map html
