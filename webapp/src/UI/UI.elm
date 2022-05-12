module UI.UI exposing (Id(..), page, pill, toId)

import Html exposing (Html, div, span, text)
import Html.Attributes exposing (class, id)


type Id
    = Id String


toId : String -> Id
toId id_ =
    Id id_


toString : Id -> String
toString id =
    case id of
        Id id_ ->
            id_


pill : String -> String -> Html msg
pill color text_ =
    span [ class <| color ++ " text-lg p-2 pr-10 pl-10 rounded" ] [ text text_ ]


page : Id -> List (Html msg) -> Html msg
page id_ elements =
    div [ id <| toString id_, class "flex flex-col justify-evenly items-center h-screen w-full" ] elements
