module Prima.Pyxis.Form.Field exposing
    ( AutocompleteFieldConfig
    , CheckboxConfig
    , FormField(..)
    , InputFieldConfig
    , RadioFieldConfig
    , SelectFieldConfig
    , addLabel
    , autocomplete
    , checkbox
    , flag
    , hasLabel
    , input
    , pickLabel
    , radio
    , radioButtonChoice
    , renderField
    , renderLabel
    , select
    )

import Html exposing (Html, text)
import Prima.Pyxis.Form.Autocomplete as Autocomplete
import Prima.Pyxis.Form.Checkbox as Checkbox
import Prima.Pyxis.Form.Flag as Flag
import Prima.Pyxis.Form.Input as Input
import Prima.Pyxis.Form.Label as Label
import Prima.Pyxis.Form.Radio as Radio
import Prima.Pyxis.Form.RadioButton as RadioButton
import Prima.Pyxis.Form.Select as Select
import Prima.Pyxis.Helpers as H


type FormField model msg
    = InputField (InputFieldConfig model msg)
    | FlagField (FlagFieldConfig model msg)
    | RadioField (RadioFieldConfig model msg)
    | SelectField (SelectFieldConfig model msg)
    | AutocompleteField (AutocompleteFieldConfig model msg)
    | CheckboxField (CheckboxConfig model msg)
    | RadioButtonField (RadioButtonConfig model msg)


hasLabel : FormField model msg -> Bool
hasLabel =
    H.isJust << pickLabel


pickLabel : FormField model msg -> Maybe (Label.Label msg)
pickLabel formField =
    case formField of
        AutocompleteField { label } ->
            label

        FlagField { label } ->
            label

        InputField { label } ->
            label

        RadioField { label } ->
            label

        SelectField { label } ->
            label

        CheckboxField { label } ->
            label

        RadioButtonField { label } ->
            label


type alias InputFieldConfig model msg =
    { config : Input.Input model msg
    , label : Maybe (Label.Label msg)
    }


input : Input.Input model msg -> FormField model msg
input config =
    InputField <| InputFieldConfig config Nothing


type alias FlagFieldConfig model msg =
    { config : Flag.Flag model msg
    , label : Maybe (Label.Label msg)
    }


flag : Flag.Flag model msg -> FormField model msg
flag config =
    FlagField <| FlagFieldConfig config Nothing


type alias RadioFieldConfig model msg =
    { config : Radio.Radio model msg
    , label : Maybe (Label.Label msg)
    }


radio : Radio.Radio model msg -> FormField model msg
radio config =
    RadioField <| RadioFieldConfig config Nothing


type alias SelectFieldConfig model msg =
    { config : Select.Select model msg
    , label : Maybe (Label.Label msg)
    }


select : Select.Select model msg -> FormField model msg
select config =
    SelectField <| SelectFieldConfig config Nothing


type alias AutocompleteFieldConfig model msg =
    { config : Autocomplete.Autocomplete model msg
    , label : Maybe (Label.Label msg)
    }


autocomplete : Autocomplete.Autocomplete model msg -> FormField model msg
autocomplete config =
    AutocompleteField <| AutocompleteFieldConfig config Nothing


addLabel : Label.Label msg -> FormField model msg -> FormField model msg
addLabel lbl formField =
    case formField of
        AutocompleteField fieldConfig ->
            AutocompleteField { fieldConfig | label = Just lbl }

        FlagField fieldConfig ->
            FlagField { fieldConfig | label = Just lbl }

        InputField fieldConfig ->
            InputField { fieldConfig | label = Just lbl }

        SelectField fieldConfig ->
            SelectField { fieldConfig | label = Just lbl }

        RadioField fieldConfig ->
            RadioField { fieldConfig | label = Just lbl }

        CheckboxField fieldConfig ->
            CheckboxField { fieldConfig | label = Just lbl }

        RadioButtonField fieldConfig ->
            RadioButtonField { fieldConfig | label = Just lbl }


renderLabel : FormField model msg -> Html msg
renderLabel formField =
    formField
        |> pickLabel
        |> Maybe.map Label.render
        |> Maybe.withDefault (text "")


renderField : model -> FormField model msg -> List (Html msg)
renderField model formField =
    case formField of
        InputField { config } ->
            Input.render model config

        FlagField { config } ->
            Flag.render model config

        RadioField { config } ->
            Radio.render model config

        SelectField { config } ->
            Select.render model config

        AutocompleteField { config } ->
            Autocomplete.render model config

        CheckboxField { config } ->
            Checkbox.render model config

        RadioButtonField { config } ->
            RadioButton.render model config


type alias CheckboxConfig model msg =
    { config : Checkbox.Checkbox model msg
    , label : Maybe (Label.Label msg)
    }


checkbox : Checkbox.Checkbox model msg -> FormField model msg
checkbox config =
    CheckboxField <| CheckboxConfig config Nothing


type alias RadioButtonConfig model msg =
    { config : RadioButton.RadioButton model msg
    , label : Maybe (Label.Label msg)
    }


radioButtonChoice : RadioButton.RadioButton model msg -> FormField model msg
radioButtonChoice config =
    RadioButtonField <| RadioButtonConfig config Nothing
