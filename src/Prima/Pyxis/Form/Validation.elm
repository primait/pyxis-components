module Prima.Pyxis.Form.Validation exposing
    ( Validation(..)
    , ValidationType(..), SeverityLevel(..)
    , pickError
    )

{-| Allows to create Validation model for the form.


# Configuration

@docs Validation

    import Prima.Pyxis.Form.Validation as PrimaFormValidation exposing (SeverityLevel(..), Validation(..), ValidationType(..))
    import Regex

    usernameConfig : Bool -> PrimaForm.FormField LoginData Msg
    usernameConfig enabled =
        PrimaForm.textConfig
            "username"
            (Just "username")
            [ minlength 3, placeholder "username", disabled (not enabled) ]
            .email
            [ PrimaFormEvent.onInput (OnInput UsernameField) ]
            [ PrimaFormValidation.NotEmpty (SeverityLevel Error) "insert username"
            , PrimaFormValidation.Expression (SeverityLevel Warning) lowerCase "Should contain lowercase"
            ]

    lowerCase : Regex.Regex
    lowerCase =
        Maybe.withDefault Regex.never <|
            Regex.fromString "[a-z]+"


# ValidationType

@docs ValidationType, SeverityLevel


# Helpers

@docs pickError

-}

import Regex


{-| Represents a validation entry.
-}
type Validation model
    = NotEmpty SeverityLevel String
    | Expression SeverityLevel Regex.Regex String
    | Custom SeverityLevel (model -> Bool) String


{-| Represents a validation type.
-}
type ValidationType
    = Error
    | Warning


{-| Represents the severity level.
-}
type SeverityLevel
    = SeverityLevel ValidationType


{-| Pick the error string from a Validation model.
-}
pickError : Validation model -> String
pickError rule =
    case rule of
        NotEmpty (SeverityLevel Error) error ->
            error

        Expression (SeverityLevel Error) exp error ->
            error

        Custom (SeverityLevel Error) customRule error ->
            error

        NotEmpty (SeverityLevel Warning) warning ->
            warning

        Expression (SeverityLevel Warning) exp warning ->
            warning

        Custom (SeverityLevel Warning) customRule warning ->
            warning
