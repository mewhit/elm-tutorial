-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Generated.Union.Entity_ exposing (..)

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
import Graphql.SelectionSet exposing (FragmentSelectionSet(..), SelectionSet(..))
import Json.Decode as Decode


type alias Fragments decodesTo =
    { onStudent : SelectionSet decodesTo Generated.Object.Student
    , onExcerciseSolution : SelectionSet decodesTo Generated.Object.ExcerciseSolution
    }


{-| Build up a selection for this Union by passing in a Fragments record.
-}
fragments :
    Fragments decodesTo
    -> SelectionSet decodesTo Generated.Union.Entity_
fragments selections____ =
    Object.exhaustiveFragmentSelection
        [ Object.buildFragment "Student" selections____.onStudent
        , Object.buildFragment "ExcerciseSolution" selections____.onExcerciseSolution
        ]


{-| Can be used to create a non-exhaustive set of fragments by using the record
update syntax to add `SelectionSet`s for the types you want to handle.
-}
maybeFragments : Fragments (Maybe decodesTo)
maybeFragments =
    { onStudent = Graphql.SelectionSet.empty |> Graphql.SelectionSet.map (\_ -> Nothing)
    , onExcerciseSolution = Graphql.SelectionSet.empty |> Graphql.SelectionSet.map (\_ -> Nothing)
    }
