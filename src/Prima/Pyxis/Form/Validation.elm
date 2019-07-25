module Prima.Pyxis.Form.Validation exposing
    ( Validation(..)
    , ValidationType(..)
    , pickError, severityError, severityWarning
    )

{-| Allows to create Validation model for the form.


# Configuration

@docs Validation

    import Prima.Pyxis.Form.Validation as PrimaFormValidation exposing (severityError, severityWarning)
    import Regex

    usernameConfig : Bool -> PrimaForm.FormField LoginData Msg
    usernameConfig enabled =
        PrimaForm.textConfig
            "username"
            (Just "username")
            [ minlength 3, placeholder "username", disabled (not enabled) ]
            .email
            [ PrimaFormEvent.onInput (OnInput UsernameField) ]
            [ PrimaFormValidation.NotEmpty severityError "insert username"
            , PrimaFormValidation.Expression severityWarning lowerCase "Must contain lowercase"
            ]

    lowerCase : Regex.Regex
    lowerCase =
        Maybe.withDefault Regex.never <|
            Regex.fromString "[a-z]+"


# ValidationType

@docs ValidationType


# Helpers

@docs pickError, severityError, severityWarning

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


{-| Returns ValidationType Error.
-}
severityError : ValidationType
severityError =
    Error


{-| Returns ValidationType Waring.
-}
severityWarning : ValidationType
severityWarning =
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
