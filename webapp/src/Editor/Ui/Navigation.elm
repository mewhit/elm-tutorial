module Editor.Ui.Navigation exposing
    ( Navigation
    , compilation
    , deploy
    , elmLogo
    , lights
    , packages
    , share
    , toggleOpen
    , toggleSplit
    , view
    )

{-| The navigation bar.
-}

import Editor.Data.Status as Status
import Editor.Ui.Icon
import FeatherIcons as I
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick)
import Svg exposing (svg, use)
import Svg.Attributes as SA


{-| -}
type alias Navigation msg =
    { isLight : Bool
    , isOpen : Bool
    , left : List (Html msg)
    , right : List (Html msg)
    }


{-| -}
view : Navigation msg -> Html msg
view config =
    nav
        [ id "menu"
        , classList
            [ ( "open", config.isOpen )
            , ( "closed", not config.isOpen )
            ]
        ]
        [ section
            [ id "actions" ]
            [ aside [] config.left
            , aside [] config.right
            ]
        ]



-- BUTTON / PREMADE


{-| -}
elmLogo : Html msg
elmLogo =
    a [ href "/", class "menu-link", target "_blank" ]
        [ svg
            [ SA.height "14"
            , SA.width "14"
            ]
            [ use [ SA.xlinkHref "#logo" ] []
            ]
        ]


{-| -}
toggleOpen : msg -> Bool -> Html msg
toggleOpen onClick_ isMenuOpen =
    Editor.Ui.Icon.button [ style "padding" "0 10px" ]
        { background = Nothing
        , icon =
            if isMenuOpen then
                I.chevronDown

            else
                I.chevronUp
        , iconColor = Nothing
        , labelColor = Nothing
        , label = Just "Toggle Compilation result"
        , alt =
            if isMenuOpen then
                "Close menu"

            else
                "Open menu"
        , onClick = Just onClick_
        }


{-| -}
toggleSplit : msg -> Html msg
toggleSplit onClick_ =
    Editor.Ui.Icon.button [ style "padding" "0 5px" ]
        { background = Nothing
        , icon = I.code
        , iconColor = Nothing
        , labelColor = Nothing
        , label = Nothing
        , alt = "Open or close result"
        , onClick = Just onClick_
        }


{-| -}
lights : msg -> Bool -> Html msg
lights onClick_ isLight =
    Editor.Ui.Icon.button [ style "padding" "0 10px" ]
        { background = Nothing
        , icon =
            if isLight then
                I.moon

            else
                I.sun
        , iconColor = Nothing
        , labelColor = Nothing
        , label = Just "Lights"
        , alt = "Switch the color scheme"
        , onClick = Just onClick_
        }


{-| -}
compilation : msg -> Status.Status -> Html msg
compilation onClick_ status =
    let
        ( icon, iconColor, label ) =
            case status of
                _ ->
                    ( I.refreshCcw
                    , Just "blue"
                    , "Compile"
                    )
    in
    Editor.Ui.Icon.button [ style "padding" "0 10px" ]
        { background = Nothing
        , icon = icon
        , iconColor = iconColor
        , label = Just label
        , labelColor = Nothing
        , alt = "Compile your code (Ctrl-Enter)"
        , onClick = Just onClick_
        }


{-| -}
packages : msg -> Bool -> Html msg
packages onClick_ isOpen =
    Editor.Ui.Icon.button [ style "padding" "0 10px" ]
        { background =
            if isOpen then
                Just "lightblue"

            else
                Nothing
        , icon = I.package
        , iconColor =
            if isOpen then
                Just "blue"

            else
                Nothing
        , label = Just "Packages"
        , labelColor =
            if isOpen then
                Just "blue"

            else
                Nothing
        , alt = "Add a package"
        , onClick = Just onClick_
        }


{-| -}
share : msg -> Html msg
share onClick_ =
    Editor.Ui.Icon.button [ style "padding" "0 10px" ]
        { background = Nothing
        , icon = I.link
        , iconColor = Nothing
        , label = Just "Share"
        , labelColor = Nothing
        , alt = "Copy link to this code"
        , onClick = Just onClick_
        }


{-| -}
deploy : msg -> Html msg
deploy onClick_ =
    Editor.Ui.Icon.button [ style "padding" "0 10px" ]
        { background = Nothing
        , icon = I.send
        , iconColor = Nothing
        , label = Just "Deploy"
        , labelColor = Nothing
        , alt = "Deploy this project without editor attached"
        , onClick = Just onClick_
        }
