-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Generated.InputObject exposing (..)

import Generated.Interface
import Generated.Object
import Generated.Scalar
import Generated.ScalarCodecs
import Generated.Union
import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode


buildStudentInput :
    StudentInputRequiredFields
    -> StudentInput
buildStudentInput required____ =
    { firstName = required____.firstName, lastName = required____.lastName, nickName = required____.nickName, email = required____.email }


type alias StudentInputRequiredFields =
    { firstName : String
    , lastName : String
    , nickName : String
    , email : String
    }


{-| Type for the StudentInput input object.
-}
type alias StudentInput =
    { firstName : String
    , lastName : String
    , nickName : String
    , email : String
    }


{-| Encode a StudentInput into a value that can be used as an argument.
-}
encodeStudentInput : StudentInput -> Value
encodeStudentInput input____ =
    Encode.maybeObject
        [ ( "firstName", Encode.string input____.firstName |> Just ), ( "lastName", Encode.string input____.lastName |> Just ), ( "nickName", Encode.string input____.nickName |> Just ), ( "email", Encode.string input____.email |> Just ) ]