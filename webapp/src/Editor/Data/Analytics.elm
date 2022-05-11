port module Editor.Data.Analytics exposing (gotJsError, reportError)

import DateFormat as F
import Dict exposing (Dict)
import Editor.Data.Exit as Exit
import Editor.Data.Frame as Frame
import Editor.Data.Registry.Package as Pkg
import Editor.Data.Time
import Http
import Json.Decode as JD
import Json.Encode as JE
import Set
import Time



-- API


port gotJsError : (String -> msg) -> Sub msg


reportError : (Result Http.Error String -> msg) -> String -> Cmd msg
reportError onResult errMsg =
    Http.post
        { url = "https://elm.studio/api/analytics/new-ui-error"
        , body = Http.jsonBody (JE.string errMsg)
        , expect = Http.expectJson onResult JD.string
        }
