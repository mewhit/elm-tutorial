module Extra.Http.Extra exposing (AccessToken(..), fromString, post)

import Http exposing (Body, Expect)
import Json.Decode as D
import Json.Encode as E
import RemoteData exposing (WebData)


type AccessToken
    = AccessToken String


fromString : String -> AccessToken
fromString str =
    AccessToken str


toHeader : AccessToken -> String
toHeader accessToken =
    case accessToken of
        AccessToken str ->
            "Bearer " ++ str


post :
    { url : String
    , body : E.Value
    , decoder : D.Decoder a
    , handler : WebData a -> msg
    , token : Maybe AccessToken
    }
    -> Cmd msg
post r =
    Http.request
        { method = "POST"
        , headers = [ Http.header "Authorization" (r.token |> Maybe.map toHeader |> Maybe.withDefault "") ]
        , url = r.url
        , body = r.body |> Http.jsonBody
        , expect = Http.expectJson (RemoteData.fromResult >> r.handler) r.decoder
        , timeout = Nothing
        , tracker = Nothing
        }
