module Prima.Pyxis.Form.Validation exposing
    ( Validation
    , ValidationType(..)
    , pickValidationFunction, pickValidationMessage, isErrorValidation, isWarningValidation
    , validationConfig
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

@docs ValidationType


# Helpers

@docs pickValidationFunction, pickValidationMessage, isErrorValidation, isWarningValidation

-}

import Regex


{-| Represents a validation entry.
-}
type Validation model
    = Validation (ValidationConfig model)


type alias ValidationConfig model =
    { validationType : ValidationType
    , validationFunction : model -> Bool
    , message : String
    }


validationConfig : ValidationType -> (model -> Bool) -> String -> Validation model
validationConfig validationType validationFunction message =
    Validation
        (ValidationConfig
            validationType
            validationFunction
            message
        )


{-| Represents a validation type.
-}
type ValidationType
    = Error
    | Warning


{-| Check if given validationType is warning
-}
isWarningValidation : ValidationType -> Bool
isWarningValidation =
    (==) Warning


{-| Check if given validationType is error
-}
isErrorValidation : ValidationType -> Bool
isErrorValidation =
    (==) Error


{-| Pick the validation string message from a Validation model.
-}
pickValidationMessage : ValidationType -> Validation model -> Maybe String
pickValidationMessage type_ (Validation { message, validationType }) =
    if type_ == validationType then
        Just message

    else
        Nothing


{-| Pick the validation evaluation function from a Validation model.
-}
pickValidationFunction : Validation model -> (model -> Bool)
pickValidationFunction (Validation { validationFunction }) =
    validationFunction
