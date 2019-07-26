module Prima.Pyxis.Form.Validation exposing
    ( Validation(..)
    , ValidationType(..), Severity(..)
    , pickError
    )

{-| Allows to create Validation model for the form.


# Configuration

@docs Validation

    import Prima.Pyxis.Form.Validation as PrimaFormValidation exposing (Severity(..), Validation(..), ValidationType(..))
    import Regex

    usernameConfig : Bool -> PrimaForm.FormField LoginData Msg
    usernameConfig enabled =
        PrimaForm.textConfig
            "username"
            (Just "username")
            [ minlength 3, placeholder "username", disabled (not enabled) ]
            .email
            [ PrimaFormEvent.onInput (OnInput UsernameField) ]
            [ PrimaFormValidation.NotEmpty (Severity Error) "insert username"
            , PrimaFormValidation.Expression (Severity Warning) lowerCase "Should contain lowercase"
            ]

    lowerCase : Regex.Regex
    lowerCase =
        Maybe.withDefault Regex.never <|
            Regex.fromString "[a-z]+"


# ValidationType

@docs ValidationType, Severity


# Helpers

@docs pickError

-}

import Regex


{-| Represents a validation entry.
-}
type Validation model
    = NotEmpty Severity String
    | Expression Severity Regex.Regex String
    | Custom Severity (model -> Bool) String


{-| Represents a validation type.
-}
type ValidationType
    = Error
    | Warning


{-| Represents Severity level.
-}
type Severity
    = Severity ValidationType


{-| Pick the error string from a Validation model.
-}
pickError : Validation model -> String
pickError rule =
    case rule of
        NotEmpty (Severity Error) error ->
            error

        Expression (Severity Error) exp error ->
            error

        Custom (Severity Error) customRule error ->
            error

        NotEmpty (Severity Warning) warning ->
            warning

        Expression (Severity Warning) exp warning ->
            warning

        Custom (Severity Warning) customRule warning ->
            warning
