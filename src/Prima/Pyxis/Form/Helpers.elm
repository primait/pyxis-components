module Prima.Pyxis.Form.Helpers exposing (..)

import Prima.Pyxis.Form.Types exposing (FormField, FormFieldConfig(..), FormFieldGroup)
import Prima.Pyxis.Form.Validation as FormValidation exposing (ValidationType)
import Prima.Pyxis.Helpers as Helpers


flip : (a -> b -> c) -> b -> a -> c
flip mapper b a =
    mapper a b


pickFieldGroupValidations : FormFieldGroup model msg -> List (FormValidation.Validation model)
pickFieldGroupValidations (FormFieldGroup opaqueConfig validations) =
    validations


pickOnly : ValidationType -> List (FormValidation.Validation model) -> List (FormValidation.Validation model)
pickOnly type_ validations =
    let
        mapper =
            case type_ of
                FormValidation.Error ->
                    FormValidation.isError

                FormValidation.Warning ->
                    FormValidation.isWarning
    in
    List.filter (mapper << FormValidation.pickType) validations


fieldGroupIsValid : model -> FormFieldGroup model msg -> Bool
fieldGroupIsValid model formFieldGroup =
    not (fieldGroupHasError model formFieldGroup) && not (fieldGroupHasWarning model formFieldGroup)


fieldGroupHasError : model -> FormFieldGroup model msg -> Bool
fieldGroupHasError model (FormFieldGroup { fields } validations) =
    let
        formGroupOwnErrors =
            validations
                |> pickOnly FormValidation.Error
                |> List.any (flip FormValidation.pickFunction model)

        fieldsOwnErrors =
            List.any (fieldHasError model) fields
    in
    formGroupOwnErrors || fieldsOwnErrors


fieldGroupHasWarning : model -> FormFieldGroup model msg -> Bool
fieldGroupHasWarning model (FormFieldGroup { fields } validations) =
    let
        formGroupOwnWarning =
            validations
                |> pickOnly FormValidation.Warning
                |> List.any (flip FormValidation.pickFunction model)

        fieldsOwnWarning =
            List.any (fieldHasError model) fields
    in
    formGroupOwnWarning || fieldsOwnWarning


pickFieldValidations : FormField model msg -> List (FormValidation.Validation model)
pickFieldValidations (FormField opaqueConfig) =
    case opaqueConfig of
        FormFieldTextConfig _ validations ->
            validations

        FormFieldPasswordConfig _ validations ->
            validations

        FormFieldTextareaConfig _ validations ->
            validations

        FormFieldRadioConfig _ validations ->
            validations

        FormFieldSelectConfig _ validations ->
            validations

        FormFieldCheckboxConfig _ validations ->
            validations

        FormFieldDatepickerConfig _ validations ->
            validations

        FormFieldAutocompleteConfig _ validations ->
            validations

        FormFieldPureHtmlConfig _ ->
            []


fieldIsValid : model -> FormField model msg -> Bool
fieldIsValid model formField =
    formField
        |> pickFieldValidations
        |> List.all (flip FormValidation.pickFunction model)


fieldHasError : model -> FormField model msg -> Bool
fieldHasError model formField =
    formField
        |> pickFieldValidations
        |> List.filter (FormValidation.isError << FormValidation.pickType)
        |> List.all (flip FormValidation.pickFunction model)
        |> not


fieldHasWarning : model -> FormField model msg -> Bool
fieldHasWarning model formField =
    formField
        |> pickFieldValidations
        |> List.filter (FormValidation.isWarning << FormValidation.pickType)
        |> List.all (flip FormValidation.pickFunction model)
        |> not


fieldIsPristine : model -> FormField model msg -> Bool
fieldIsPristine model (FormField opaqueConfig) =
    let
        isEmpty : Maybe String -> Bool
        isEmpty =
            String.isEmpty << Maybe.withDefault ""
    in
    case opaqueConfig of
        FormFieldTextConfig { reader } _ ->
            (isEmpty << reader) model

        FormFieldTextareaConfig { reader } _ ->
            (isEmpty << reader) model

        FormFieldPasswordConfig { reader } _ ->
            (isEmpty << reader) model

        FormFieldRadioConfig { reader } _ ->
            (isEmpty << reader) model

        FormFieldSelectConfig { reader } _ ->
            (isEmpty << reader) model

        FormFieldAutocompleteConfig { choiceReader } _ ->
            (isEmpty << choiceReader) model

        FormFieldDatepickerConfig { reader } _ ->
            (Helpers.isNothing << reader) model

        _ ->
            True
