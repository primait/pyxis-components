module Prima.Pyxis.Form.Validation exposing
    ( Validation
    , ValidationType(..)
    , pickFunction, pickValidationMessage, pickType, isError, isWarning
    , config
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

@docs pickFunction, pickValidationMessage, pickType, isError, isWarning

-}

import Regex


{-| Represents a validation entry.
-}
type Validation model
    = Validation (ValidationConfig model)


type alias ValidationConfig model =
    { type_ : ValidationType
    , function : model -> Bool
    , message : String
    }


config : ValidationType -> (model -> Bool) -> String -> Validation model
config type_ function message =
    Validation
        (ValidationConfig
            type_
            function
            message
        )


{-| Represents a validation type.
-}
type ValidationType
    = Error
    | Warning


{-| Check if given type\_ is warning
-}
isWarning : ValidationType -> Bool
isWarning =
    (==) Warning


{-| Check if given type\_ is error
-}
isError : ValidationType -> Bool
isError =
    (==) Error


{-| Pick the validation string message from a Validation model.
-}
pickValidationMessage : ValidationType -> Validation model -> Maybe String
pickValidationMessage type_ (Validation validationConfig) =
    if type_ == validationConfig.type_ then
        Just validationConfig.message

    else
        Nothing


{-| Pick the validation evaluation function from a Validation model.
-}
pickFunction : Validation model -> (model -> Bool)
pickFunction (Validation { function }) =
    function


{-| Pick the validation type from a Validation model.
-}
pickType : Validation model -> ValidationType
pickType (Validation { type_ }) =
    type_
