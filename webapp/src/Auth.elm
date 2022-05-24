module Auth exposing (Sign(..), User, accessToken)

import Http.Extra exposing (AccessToken)


type alias User =
    { accessToken : AccessToken
    }


type Sign
    = SignIn User
    | Signout


accessToken : Sign -> Maybe AccessToken
accessToken s =
    case s of
        SignIn user ->
            Just user.accessToken

        Signout ->
            Nothing
