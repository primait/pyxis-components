module Prima.Pyxis.Form.Validation exposing
    ( Validation, config
    , ValidationType(..)
    , pickFunction, pickValidationMessage, pickType, isError, isWarning
    )

{-| Allows to create Validation model for the form.


# Configuration

@docs Validation, config

    import Prima.Pyxis.Form as PrimaForm
    import Prima.Pyxis.Form.Validation as FormValidation
    import Regex

    ...

    type alias LoginData =
        { username : Maybe String }

    ...

    usernameConfig : Bool -> PrimaForm.FormField LoginData Msg
    usernameConfig enabled =
        PrimaForm.textConfig
            "username"
            (Just "username")
            [ minlength 3, placeholder "username", disabled (not enabled) ]
            .email
            [ PrimaFormEvent.onInput (OnInput UsernameField) ]
            [ FormValidation.config
                FormValidation.Warning
                (\formData -> not (formData.username == Just "notsecureusername"))
                "Username is not secure."
            ]


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


{-| Configure a Validation
-}
config : ValidationType -> (model -> Bool) -> String -> Validation model
config type_ function message =
    Validation (ValidationConfig type_ function message)


{-| Represents a validation type.
-}
type ValidationType
    = Error
    | Warning


{-| Check if given type is warning
-}
isWarning : ValidationType -> Bool
isWarning =
    (==) Warning


{-| Check if given type is error
-}
isError : ValidationType -> Bool
isError =
    (==) Error


{-| Pick the validation string message from a Validation model.
-}
pickValidationMessage : Validation model -> String
pickValidationMessage (Validation { message }) =
    message


{-| Pick the validation string message from a Validation model only if type matches.
-}
pickValidationMessageByType : ValidationType -> Validation model -> Maybe String
pickValidationMessageByType type_ (Validation validationConfig) =
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
