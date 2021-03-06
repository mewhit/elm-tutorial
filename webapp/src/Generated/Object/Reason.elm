-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Generated.Object.Reason exposing (..)

import Generated.InputObject
import Generated.Interface
import Generated.Object
import Generated.Scalar
import Generated.ScalarCodecs
import Generated.Union
import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.Operation exposing (RootMutation, RootQuery, RootSubscription)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode


type_ : SelectionSet String Generated.Object.Reason
type_ =
    Object.selectionForField "String" "type" [] Decode.string


data :
    SelectionSet decodesTo Generated.Object.ReasonData
    -> SelectionSet decodesTo Generated.Object.Reason
data object____ =
    Object.selectionForCompositeField "data" [] object____ Basics.identity
