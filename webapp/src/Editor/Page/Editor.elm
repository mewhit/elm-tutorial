module Editor.Page.Editor exposing (Model, Msg, init, subscriptions, update, view)

import Browser
import Browser.Events
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
import RemoteData exposing (RemoteData(..))
import Svg exposing (svg, use)
import Svg.Attributes as SA exposing (xlinkHref)



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
    , name : String
    , width : Int
    , height : Int
    , direct : List Package.Package
    , indirect : List Package.Package
    }


decodeFlags : D.Decoder Flags
decodeFlags =
    D.map6 Flags
        (D.field "original" D.string)
        (D.field "name" D.string)
        (D.field "width" D.int)
        (D.field "height" D.int)
        (D.at [ "dependencies", "direct" ] Defaults.decode)
        (D.at [ "dependencies", "indirect" ] Defaults.decode)


defaultFlags : Flags
defaultFlags =
    { original = "original"
    , name = "original"
    , width = 1000
    , height = 700
    , direct = Defaults.direct
    , indirect = Defaults.indirect
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        -- flags =
        --     Result.withDefault defaultFlags (D.decodeValue decodeFlags flagsRaw)
        ( editor, editorCmd ) =
            Editor.Ui.Editor.init flags.original

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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnEditorMsg subMsg ->
            let
                ( editor, status, editorCmd ) =
                    Editor.Ui.Editor.update subMsg model.editor model.status

                packageUi =
                    if Status.isCompiling status then
                        Editor.Ui.Package.dismissAll model.packageUi

                    else
                        model.packageUi
            in
            ( { model | editor = editor, status = status, packageUi = packageUi }
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


view : Model -> Html Msg
view model =
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
            [ Editor.Ui.Package.view packageStyles model.packageUi
                |> Html.map OnPackageMsg
            , Editor.Ui.Editor.viewEditor (Editor.Ui.Package.getSolution model.packageUi) model.isLight model.editor
                |> Html.map OnEditorMsg
            , case getProblems model of
                Just problems ->
                    div
                        [ id "problems-carousel"
                        , if Editor.Ui.ColumnDivider.isRightMost model.window model.divider then
                            style "transform" "translateX(0)"

                          else
                            style "transform" "translateX(100%)"
                        ]
                        [ if model.areProblemsMini then
                            text ""

                          else
                            lazy viewProblemPopup problems
                        ]

                Nothing ->
                    text ""
            , viewNavigation model
            ]
            [ case getProblems model of
                Just problems ->
                    if Editor.Ui.ColumnDivider.isRightMost model.window model.divider then
                        text ""

                    else
                        lazy viewProblemList problems

                Nothing ->
                    text ""
            , case model.editor.result of
                Success result ->
                    case result of
                        CompileResult.Error err ->
                            Html.pre [] [ text err.error ]

                        CompileResult.Steps steps ->
                            steps
                                |> List.map
                                    (\step ->
                                        case step of
                                            CompileResult.RunStart _ ->
                                                text "Start"

                                            CompileResult.TestCompleted r ->
                                                case r of
                                                    CompileResult.TestFail _ ->
                                                        text "Fail"

                                                    CompileResult.TestPass _ ->
                                                        text "Pass"

                                            CompileResult.RunComplete _ ->
                                                text "Completed"
                                    )
                                |> div []

                NotAsked ->
                    text "wait compilation"

                Loading ->
                    text "loader"

                Failure _ ->
                    text "Fail"
            ]
        ]



-- NAVIGATION


viewNavigation : Model -> Html Msg
viewNavigation model =
    Editor.Ui.Navigation.view
        { isLight = model.isLight
        , isOpen = model.isMenuOpen
        , left =
            [ Editor.Ui.Navigation.elmLogo

            -- , Editor.Ui.Navigation.lights OnToggleLights model.isLight
            -- , Editor.Ui.Navigation.packages OnTogglePackages model.isPackageUiOpen
            , Editor.Ui.Editor.viewHint model.editor
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
            , Editor.Ui.Navigation.compilation (OnEditorMsg Editor.Ui.Editor.OnCompile) model.status

            --, Ui.Navigation.share (OnEditorMsg Editor.Ui.Editor.OnCompile)
            --, Ui.Navigation.deploy (OnEditorMsg Editor.Ui.Editor.OnCompile)
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
