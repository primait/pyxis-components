module Prima.Pyxis.Form.Validation exposing
    ( Validation(..)
    , pickError
    , ValidationType(..), typeError, typeWarning
    )

{-| Allows to create Validation model for the form.


# Configuration

@docs Validation


# Helpers

@docs pickError

-}

import Regex


{-| Represents a validation entry.
-}
type Validation model
    = NotEmpty ValidationType String
    | Expression ValidationType Regex.Regex String
    | Custom ValidationType (model -> Bool) String


{-| Represents a validation type.
-}
type ValidationType
    = Error
    | Warning


{-| Exposing a validation type Error.
-}
typeError : ValidationType
typeError =
    Error


{-| Exposing a validation type Waring.
-}
typeWarning : ValidationType
typeWarning =
    Warning


{-| Pick the error string from a Validation model.
-}
pickError : Validation model -> String
pickError rule =
    case rule of
        NotEmpty Error error ->
            error

        Expression Error exp error ->
            error

        Custom Error customRule error ->
            error

        NotEmpty Warning warning ->
            warning

        Expression Warning exp warning ->
            warning

        Custom Warning customRule warning ->
            warning
