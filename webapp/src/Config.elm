module Config exposing (..)

import Auth


type alias Config =
    { domain : String
    , user : Auth.Sign
    }


setUser : Auth.Sign -> Config -> Config
setUser s c =
    { c | user = s }
