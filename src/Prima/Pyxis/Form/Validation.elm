module Prima.Pyxis.Form.Validation exposing
    ( Validation
    , ValidationType(..), SeverityLevel(..)
    , pickError
    , pickValidationFunction, validationConfig
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
    = Validation (ValidationConfig model)


type alias ValidationConfig model =
    { severityLevel : SeverityLevel
    , validationFunction : model -> Bool
    , message : String
    }


validationConfig : SeverityLevel -> (model -> Bool) -> String -> Validation model
validationConfig severity validationFunction message =
    Validation
        (ValidationConfig
            severity
            validationFunction
            message
        )


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
pickError (Validation { message }) =
    message


pickValidationFunction : Validation model -> (model -> Bool)
pickValidationFunction (Validation { validationFunction }) =
    validationFunction
