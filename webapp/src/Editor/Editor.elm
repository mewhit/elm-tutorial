module Editor.Editor exposing (Model, Msg, init, subscriptions, update, view)

import Browser
import Browser.Events
import Config exposing (Config)
import Dict exposing (Dict)
import Editor.Data.Analytics as Analytics
import Editor.Data.CompileResult as CompileResult
import Editor.Data.Deps as Deps
import Editor.Data.Header as Header
import Editor.Data.Hint as Hint
import Editor.Data.Problem as Problem
import Editor.Data.Registry.Defaults as Defaults
import Editor.Data.Registry.Package as Package
import Editor.Data.Status as Status
import Editor.Data.Version exposing (Version)
import Editor.Data.Window as Window exposing (Window)
import Editor.Ui.ColumnDivider
import Editor.Ui.Editor
import Editor.Ui.Navigation
import Editor.Ui.Package
import Editor.Ui.Problem
import Elm.Error as Error
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, onMouseLeave, onMouseOver)
import Html.Lazy exposing (..)
import Http
import Json.Decode as D
import Json.Encode as E
import Maybe.Extra
import RemoteData exposing (RemoteData(..))
import Svg exposing (svg, use)
import Svg.Attributes as SA exposing (xlinkHref)
import UI.UI as UI



-- MAIN
-- MODEL


type alias Model =
    { name : String
    , window : Window
    , editor : Editor.Ui.Editor.Model
    , divider : Editor.Ui.ColumnDivider.Model
    , isLight : Bool
    , isMenuOpen : Bool
    , areProblemsMini : Bool
    , status : Status.Status
    , packageUi : Editor.Ui.Package.Model
    , isPackageUiOpen : Bool
    }


getProblems : Model -> Maybe Problem.Problems
getProblems model =
    case ( Editor.Ui.Package.getProblems model.packageUi, Status.getProblems model.status ) of
        ( Just problems, _ ) ->
            Just problems

        ( Nothing, Just problems ) ->
            Just problems

        ( Nothing, Nothing ) ->
            Nothing



-- INIT


type alias Flags =
    { original : String
    , config : Config
    , name : String
    , width : Int
    , height : Int
    , direct : List Package.Package
    , indirect : List Package.Package
    }



-- decodeFlags : D.Decoder Flags
-- decodeFlags =
--     D.map6 Flags
--         (D.field "original" D.string)
--         (D.field "name" D.string)
--         (D.field "width" D.int)
--         (D.field "height" D.int)
--         (D.at [ "dependencies", "direct" ] Defaults.decode)
--         (D.at [ "dependencies", "indirect" ] Defaults.decode)


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        -- flags =
        --     Result.withDefault defaultFlags (D.decodeValue decodeFlags flagsRaw)
        ( editor, editorCmd ) =
            Editor.Ui.Editor.init flags.config flags.original

        ( packageUi, packageUiCmd ) =
            Editor.Ui.Package.init flags.direct flags.indirect

        window =
            { width = flags.width, height = flags.height }
    in
    ( { name = flags.name
      , window = window
      , editor = editor
      , divider = Editor.Ui.ColumnDivider.init window
      , isLight = True
      , isMenuOpen = False
      , areProblemsMini = False
      , status = Status.changed Status.success
      , packageUi = packageUi
      , isPackageUiOpen = False
      }
    , Cmd.batch
        [ Cmd.map OnEditorMsg editorCmd
        , Cmd.map OnPackageMsg packageUiCmd
        ]
    )



-- UPDATE


type Msg
    = OnEditorMsg Editor.Ui.Editor.Msg
    | OnDividerMsg Editor.Ui.ColumnDivider.Msg
    | OnPackageMsg Editor.Ui.Package.Msg
    | OnPreviousProblem (Maybe Error.Region)
    | OnNextProblem (Maybe Error.Region)
    | OnJumpToProblem Error.Region
    | OnMinimizeProblem Bool
    | OnToggleLights
    | OnToggleMenu
    | OnTogglePackages
    | OnWindowSize Int Int
    | OnReportResult (Result Http.Error String)
    | OnJsError String


update : Msg -> Model -> Config -> ( Model, Cmd Msg )
update msg model config =
    case msg of
        OnEditorMsg subMsg ->
            let
                ( editor, status, editorCmd ) =
                    Editor.Ui.Editor.update subMsg model.editor model.status config

                packageUi =
                    if Status.isCompiling status then
                        Editor.Ui.Package.dismissAll model.packageUi

                    else
                        model.packageUi
            in
            ( { model
                | editor = editor
                , status = status
                , packageUi = packageUi
                , isMenuOpen =
                    case status of
                        Status.Compiling ->
                            True

                        _ ->
                            model.isMenuOpen
              }
            , Cmd.batch
                [ Cmd.map OnEditorMsg editorCmd
                , case status of
                    Status.Failed errMsg ->
                        Analytics.reportError OnReportResult errMsg

                    _ ->
                        Cmd.none
                ]
            )

        OnDividerMsg subMsg ->
            ( { model | divider = Editor.Ui.ColumnDivider.update model.window subMsg model.divider }
            , Cmd.none
            )

        OnPackageMsg subMsg ->
            let
                ( packageUi, shouldRebuild, packageUiCmd ) =
                    Editor.Ui.Package.update subMsg model.packageUi
            in
            ( { model
                | packageUi = packageUi
                , status =
                    if shouldRebuild then
                        Status.changed model.status

                    else
                        model.status
              }
            , Cmd.map OnPackageMsg packageUiCmd
            )

        OnPreviousProblem maybeRegion ->
            ( { model | status = Status.withProblems model.status Problem.focusPrevious }
                |> Maybe.withDefault identity (Maybe.map jumpToRegion maybeRegion)
            , Cmd.none
            )

        OnNextProblem maybeRegion ->
            ( { model | status = Status.withProblems model.status Problem.focusNext }
                |> Maybe.withDefault identity (Maybe.map jumpToRegion maybeRegion)
            , Cmd.none
            )

        OnJumpToProblem region ->
            ( jumpToRegion region model, Cmd.none )

        OnMinimizeProblem isMini ->
            ( { model | areProblemsMini = isMini }, Cmd.none )

        OnToggleLights ->
            ( { model | isLight = not model.isLight }, Cmd.none )

        OnToggleMenu ->
            ( { model | isMenuOpen = not model.isMenuOpen }, Cmd.none )

        OnTogglePackages ->
            let
                isOpenNow =
                    not model.isPackageUiOpen

                push =
                    if isOpenNow then
                        Editor.Ui.ColumnDivider.pushLeft

                    else
                        Editor.Ui.ColumnDivider.pushRight
            in
            ( { model
                | isPackageUiOpen = isOpenNow
                , divider = push model.window Editor.Ui.Package.width model.divider
              }
            , Cmd.none
            )

        OnWindowSize width height ->
            ( { model | window = { width = width, height = height } }, Cmd.none )

        OnReportResult _ ->
            ( model, Cmd.none )

        OnJsError errMsg ->
            ( model, Analytics.reportError OnReportResult errMsg )


jumpToRegion : Error.Region -> Model -> Model
jumpToRegion region model =
    { model | editor = Editor.Ui.Editor.setSelection region model.editor }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Editor.Ui.Editor.subscriptions model.editor
            |> Sub.map OnEditorMsg
        , Browser.Events.onResize OnWindowSize
        , Analytics.gotJsError OnJsError
        ]



-- VIEW


view : UI.Id -> Model -> Html Msg
view id_ model =
    let
        packageStyles =
            if model.isPackageUiOpen then
                if Window.isLessThan model.window Editor.Ui.Package.width then
                    [ style "max-width" Editor.Ui.Package.widthPx, style "border" "0" ]

                else
                    [ style "max-width" Editor.Ui.Package.widthPx ]

            else
                [ style "max-width" "0", style "border" "0" ]
    in
    main_
        [ id "main"
        , class "theme-dark"
        , style "width" "50%"
        , style "height" "300px"
        ]
        [ Editor.Ui.ColumnDivider.view OnDividerMsg
            model.window
            model.divider
            [ viewNavigation id_ model
            , Editor.Ui.Editor.viewEditor id_ (Editor.Ui.Package.getSolution model.packageUi) model.isLight model.editor
                |> Html.map OnEditorMsg
            ]
          <|
            if model.isMenuOpen then
                case Dict.get (id_ |> UI.toString) model.editor.result of
                    Just (Success result) ->
                        case result of
                            CompileResult.Error err ->
                                Just [ Html.pre [] [ text err.error ] ]

                            CompileResult.Success steps ->
                                steps.steps
                                    |> List.map
                                        (\step ->
                                            case step of
                                                CompileResult.TestCompleted r ->
                                                    case r of
                                                        CompileResult.TestFail { labels } ->
                                                            Just (div [ class "flex flex-col" ] [ labels |> String.join " " |> text ])

                                                        CompileResult.TestPass _ ->
                                                            Nothing

                                                _ ->
                                                    Nothing
                                        )
                                    |> Maybe.Extra.values
                                    |> (\s ->
                                            if List.isEmpty s then
                                                Nothing

                                            else
                                                Just s
                                       )

                    Just NotAsked ->
                        Just [ text "wait compilation" ]

                    Just Loading ->
                        Just [ text "loader" ]

                    Just (Failure _) ->
                        Just [ text "Fail" ]

                    Nothing ->
                        Nothing

            else
                Nothing
        ]



-- NAVIGATION


viewNavigation : UI.Id -> Model -> Html Msg
viewNavigation id_ model =
    Editor.Ui.Navigation.view
        { isLight = model.isLight
        , isOpen = model.isMenuOpen
        , left =
            [ Editor.Ui.Editor.viewHint model.editor
            , Editor.Ui.Navigation.compilation (OnEditorMsg <| Editor.Ui.Editor.OnCompile <| UI.toString id_) model.status
            ]
        , right =
            [ case getProblems model of
                Just problems ->
                    if not model.areProblemsMini || not (Editor.Ui.ColumnDivider.isRightMost model.window model.divider) then
                        text ""

                    else
                        lazy viewProblemMini problems

                Nothing ->
                    text ""
            , Editor.Ui.Navigation.toggleOpen OnToggleMenu model.isMenuOpen
            ]
        }



-- PROBLEMS


viewProblemPopup : Problem.Problems -> Html Msg
viewProblemPopup =
    Editor.Ui.Problem.viewCarousel
        { onJump = OnJumpToProblem
        , onPrevious = OnPreviousProblem
        , onNext = OnNextProblem
        , onMinimize = OnMinimizeProblem True
        }


viewProblemMini : Problem.Problems -> Html Msg
viewProblemMini =
    Editor.Ui.Problem.viewCarouselMini
        { onJump = OnJumpToProblem
        , onPrevious = OnPreviousProblem
        , onNext = OnNextProblem
        , onMinimize = OnMinimizeProblem False
        }


viewProblemList : Problem.Problems -> Html Msg
viewProblemList =
    Editor.Ui.Problem.viewList OnJumpToProblem
