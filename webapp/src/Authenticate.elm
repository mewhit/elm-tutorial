module Authenticate exposing (..)

import Config exposing (Config)
import Http
import Json.Decode as D
import Json.Decode.Pipeline as D
import RemoteData exposing (WebData)


type alias Body =
    { accessToken : String
    }


signIn : Config -> (WebData String -> msg) -> Cmd msg
signIn config msg =
    Http.get
        { url = config.domain ++ "/auth/github"
        , expect =
            (D.succeed Body |> D.required "access_token" D.string |> D.map .accessToken)
                |> Http.expectJson
                    (RemoteData.fromResult >> msg)
        }
