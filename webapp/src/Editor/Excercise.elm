module Editor.Excercise exposing (..)

import Auth exposing (accessToken)
import Config exposing (Config)
import Editor.Data.CompileResult exposing (CompileResult, decode)
import Http
import Http.Extra exposing (post)
import Json.Encode as E
import RemoteData exposing (WebData)


postSource : Config -> String -> String -> (String -> WebData CompileResult -> msg) -> Cmd msg
postSource config source id handler =
    post
        { url = config.domain ++ "/excercise/" ++ id
        , handler = handler id
        , decoder = decode
        , token = config.user |> accessToken
        , body =
            E.object
                [ ( "code", E.string source ) ]
        }
