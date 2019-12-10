module Prima.Pyxis.Form.Validation exposing
    ( Validation, Type(..)
    , isError, isWarning
    )

{-| Allows to create Validation model for the form.


# Configuration

@docs Validation, Type, error, warning

-}

import Regex


{-| Represents a validation entry.
-}
type Validation model
    = Validation (model -> Type)


{-| Represents a validation type.
-}
type Type
    = Error
    | ErrorWithMessage String
    | Warning
    | WarningWithMessage String


isError : Type -> Bool
isError type_ =
    case type_ of
        Error ->
            True

        ErrorWithMessage _ ->
            True

        _ ->
            False


isWarning : Type -> Bool
isWarning type_ =
    case type_ of
        Warning ->
            True

        WarningWithMessage _ ->
            True

        _ ->
            False
