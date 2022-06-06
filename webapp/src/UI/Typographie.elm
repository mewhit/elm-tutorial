module UI.Typographie exposing (..)

import Html exposing (Html, text)
import Html.Attributes exposing (class)


title : List (Html.Attribute msg) -> List (Html msg) -> Html msg
title attrs htmls =
    Html.h1 (class "text-7xl text-pink-600 p-10" :: attrs) htmls


subtitle : List (Html.Attribute msg) -> List (Html msg) -> Html msg
subtitle attrs htmls =
    Html.h1 (class "text-5xl text-green-600 p-5" :: attrs) htmls


p : List (Html.Attribute msg) -> List (Html msg) -> Html msg
p attrs htmls =
    Html.p (class "text-lg text-white" :: attrs) htmls


explaination : List (Html.Attribute msg) -> List (Html msg) -> Html msg
explaination attrs htmls =
    Html.p (class "text-lg text-yellow-900 max-w-3xl" :: attrs) htmls
