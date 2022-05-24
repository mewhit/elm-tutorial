module UI.Modal exposing (..)

import Html exposing (Html, button, div, h3, text)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Svg exposing (path, svg)
import Svg.Attributes as SvgAttr


type alias ModalModel msg =
    { onClose : msg
    , content : List (Html msg)
    }


modal : ModalModel msg -> Html msg
modal model =
    div
        [ Attr.id "popup-modal"
        , Attr.tabindex -1
        , Attr.class "overflow-y-hidden overflow-x-hidden fixed top-0 right-0 left-0 z-50 md:inset-0 h-modal md:h-full  bg-gray-500 bg-opacity-75 flex justify-center items-center"
        ]
        [ div
            [ Attr.class "relative bg-black rounded-lg shadow dark:bg-gray-700"
            ]
            [ button
                [ Attr.type_ "button"
                , Attr.class "absolute top-3 right-2.5 text-gray-400 bg-transparent hover:bg-gray-200 hover:text-gray-900 rounded-lg text-sm p-1.5 ml-auto inline-flex items-center dark:hover:bg-gray-800 dark:hover:text-white"
                , Attr.attribute "data-modal-toggle" "popup-modal"
                , onClick model.onClose
                ]
                [ svg
                    [ SvgAttr.class "w-5 h-5"
                    , SvgAttr.fill "currentColor"
                    , SvgAttr.viewBox "0 0 20 20"
                    ]
                    [ path
                        [ SvgAttr.fillRule "evenodd"
                        , SvgAttr.d "M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z"
                        , SvgAttr.clipRule "evenodd"
                        ]
                        []
                    ]
                ]
            , div
                [ Attr.class "p-10 text-center"
                ]
                model.content
            ]
        ]
