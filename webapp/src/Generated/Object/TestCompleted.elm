-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Generated.Object.TestCompleted exposing (..)

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


event : SelectionSet String Generated.Object.TestCompleted
event =
    Object.selectionForField "String" "event" [] Decode.string


status : SelectionSet String Generated.Object.TestCompleted
status =
    Object.selectionForField "String" "status" [] Decode.string


labels : SelectionSet (List String) Generated.Object.TestCompleted
labels =
    Object.selectionForField "(List String)" "labels" [] (Decode.string |> Decode.list)


failures :
    SelectionSet decodesTo Generated.Object.Failure
    -> SelectionSet (List decodesTo) Generated.Object.TestCompleted
failures object____ =
    Object.selectionForCompositeField "failures" [] object____ (Basics.identity >> Decode.list)


duration : SelectionSet Float Generated.Object.TestCompleted
duration =
    Object.selectionForField "Float" "duration" [] Decode.float
