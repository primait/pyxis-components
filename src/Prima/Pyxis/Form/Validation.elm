module Prima.Pyxis.Form.Validation exposing
    ( Validation, Type(..)
    , isError, isWarning, render
    )

{-| Allows to create Validation model for the form.


# Configuration

@docs Validation, Type, error, warning

-}

import Html exposing (Html)
import Html.Attributes as Attrs
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


render : Type -> Html msg
render type_ =
    case type_ of
        WarningWithMessage message ->
            Html.div
                [ Attrs.class "a-form-field__error" ]
                [ Html.text message ]

        ErrorWithMessage message ->
            Html.div
                [ Attrs.class "a-form-field__error" ]
                [ Html.text message ]

        _ ->
            Html.text ""
