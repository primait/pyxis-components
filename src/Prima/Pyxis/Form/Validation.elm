module Prima.Pyxis.Form.Validation exposing
    ( Type(..)
    , isError, isWarning, render
    )

{-| Create `Validation` model for the form.


# Configuration

@docs Type, error, warning

-}

import Html exposing (Html)
import Html.Attributes as Attrs


{-| Represent a validation type.
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
                [ Attrs.class "a-form-warning" ]
                [ Html.text message ]

        ErrorWithMessage message ->
            Html.div
                [ Attrs.class "a-form-error" ]
                [ Html.text message ]

        _ ->
            Html.text ""
