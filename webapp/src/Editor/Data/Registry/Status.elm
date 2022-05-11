module Editor.Data.Registry.Status exposing
    ( Error
    , Status(..)
    , getError
    , isDirectDep
    , isFailed
    , isIndirectDep
    , isSearchable
    )

import Editor.Data.Http
import Editor.Data.Version as V
import Elm.Error as Error
import Http


type Status
    = Loading
    | NotInstalled
    | DirectDep V.Version
    | IndirectDep V.Version
    | Failed Error


type alias Error =
    Editor.Data.Http.Error Error.Error


isDirectDep : Status -> Bool
isDirectDep state =
    case state of
        NotInstalled ->
            False

        Loading ->
            True

        DirectDep _ ->
            True

        IndirectDep _ ->
            False

        Failed _ ->
            False


isIndirectDep : Status -> Bool
isIndirectDep state =
    case state of
        NotInstalled ->
            False

        Loading ->
            False

        DirectDep _ ->
            False

        IndirectDep _ ->
            True

        Failed _ ->
            False


isFailed : Status -> Bool
isFailed state =
    case state of
        NotInstalled ->
            False

        Loading ->
            False

        DirectDep _ ->
            False

        IndirectDep _ ->
            False

        Failed _ ->
            True


isSearchable : Status -> Bool
isSearchable state =
    case state of
        Loading ->
            False

        NotInstalled ->
            True

        DirectDep _ ->
            False

        IndirectDep _ ->
            True

        Failed _ ->
            False


getError : Status -> Maybe Error
getError state =
    case state of
        NotInstalled ->
            Nothing

        Loading ->
            Nothing

        DirectDep _ ->
            Nothing

        IndirectDep _ ->
            Nothing

        Failed error ->
            Just error
