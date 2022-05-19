-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Generated.Object.Student exposing (..)

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


id : SelectionSet String Generated.Object.Student
id =
    Object.selectionForField "String" "id" [] Decode.string


firstName : SelectionSet String Generated.Object.Student
firstName =
    Object.selectionForField "String" "firstName" [] Decode.string


lastName : SelectionSet String Generated.Object.Student
lastName =
    Object.selectionForField "String" "lastName" [] Decode.string


nickName : SelectionSet String Generated.Object.Student
nickName =
    Object.selectionForField "String" "nickName" [] Decode.string


email : SelectionSet String Generated.Object.Student
email =
    Object.selectionForField "String" "email" [] Decode.string


completedExcercise :
    SelectionSet decodesTo Generated.Object.ExcerciseSolution
    -> SelectionSet (List decodesTo) Generated.Object.Student
completedExcercise object____ =
    Object.selectionForCompositeField "completedExcercise" [] object____ (Basics.identity >> Decode.list)
