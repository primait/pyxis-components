module Prima.Pyxis.Form.Validation exposing
    ( Type(..)
    , isError, isWarning
    , render
    )

{-|


## Configuration

@docs Type


## Methods

@docs isError, isWarning


## Rendering

@docs render

-}

import Html exposing (Html)
import Html.Attributes as Attrs


{-| Represents the available `Validation`s.
-}
type Type
    = Error
    | ErrorWithMessage String
    | Warning
    | WarningWithMessage String


{-| Checks that a `Validation.Type` is an `Error`.
-}
isError : Type -> Bool
isError type_ =
    case type_ of
        Error ->
            True

        ErrorWithMessage _ ->
            True

        _ ->
            False


{-| Checks that a `Validation.Type` is a `Warning`.
-}
isWarning : Type -> Bool
isWarning type_ =
    case type_ of
        Warning ->
            True

        WarningWithMessage _ ->
            True

        _ ->
            False


{-| Renders a `Validation` message.
-}
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
