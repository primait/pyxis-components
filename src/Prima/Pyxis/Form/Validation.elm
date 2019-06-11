module Prima.Pyxis.Form.Validation exposing
    ( Validation(..)
    , pickError
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
    = NotEmpty String
    | Expression Regex.Regex String
    | Custom (model -> Bool) String


{-| Pick the error string from a Validation model.
-}
pickError : Validation model -> String
pickError rule =
    case rule of
        NotEmpty error ->
            error

        Expression exp error ->
            error

        Custom customRule error ->
            error
