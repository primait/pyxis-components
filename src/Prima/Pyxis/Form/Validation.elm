module Prima.Pyxis.Form.Validation exposing
    ( Validation, Type, error, warning
    , pickFunction, pickMessage, pickType, isError, isWarning
    )

{-| Allows to create Validation model for the form.


# Configuration

@docs Validation, Type, error, warning


# Helpers

@docs pickFunction, pickMessage, pickType, isError, isWarning

-}

import Regex


{-| Represents a validation entry.
-}
type Validation model
    = Validation (ValidationConfig model)


type alias ValidationConfig model =
    { type_ : Type
    , mapper : model -> Bool
    , message : String
    }


warning : (model -> Bool) -> String -> Validation model
warning mapper message =
    Validation <| ValidationConfig Warning mapper message


error : (model -> Bool) -> String -> Validation model
error mapper message =
    Validation <| ValidationConfig Error mapper message


{-| Represents a validation type.
-}
type Type
    = Error
    | Warning


{-| Check if given type is warning
-}
isWarning : Type -> Bool
isWarning =
    (==) Warning


{-| Check if given type is error
-}
isError : Type -> Bool
isError =
    (==) Error


{-| Pick the validation string message from a Validation model.
-}
pickMessage : Validation model -> String
pickMessage (Validation { message }) =
    message


{-| Pick the validation string message from a Validation model only if type matches.
-}
pickMessageByType : Type -> Validation model -> Maybe String
pickMessageByType type_ (Validation validationConfig) =
    if type_ == validationConfig.type_ then
        Just validationConfig.message

    else
        Nothing


{-| Pick the validation evaluation function from a Validation model.
-}
pickFunction : Validation model -> (model -> Bool)
pickFunction (Validation { mapper }) =
    mapper


{-| Pick the validation type from a Validation model.
-}
pickType : Validation model -> Type
pickType (Validation { type_ }) =
    type_
