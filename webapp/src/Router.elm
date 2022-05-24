module Router exposing (..)

import Url.Parser exposing ((</>), (<?>), Parser, map, oneOf, query, s)
import Url.Parser.Query as Query


type Route
    = Home
    | Callback (Maybe String)


routeParser : Parser (Route -> a) a
routeParser =
    oneOf
        [ map Home (s "")
        , map Callback (s "auth" </> s "github" </> s "callback" <?> Query.string "access_token")
        ]
