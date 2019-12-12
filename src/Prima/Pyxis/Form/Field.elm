module Prima.Pyxis.Form.Field exposing
    ( AutocompleteFieldConfig
    , CheckboxFieldConfig
    , FormField(..)
    , InputFieldConfig
    , MultiChoiceConfig
    , RadioFieldConfig
    , SelectFieldConfig
    , addLabel
    , autocomplete
    , checkbox
    , hasLabel
    , input
    , multiChoice
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
import Prima.Pyxis.Form.Input as Input
import Prima.Pyxis.Form.Label as Label
import Prima.Pyxis.Form.MultiChoice as MultiChoice
import Prima.Pyxis.Form.Radio as Radio
import Prima.Pyxis.Form.RadioButton as RadioButton
import Prima.Pyxis.Form.Select as Select
import Prima.Pyxis.Helpers as H


type FormField model msg
    = InputField (InputFieldConfig model msg)
    | CheckboxField (CheckboxFieldConfig model msg)
    | RadioField (RadioFieldConfig model msg)
    | SelectField (SelectFieldConfig model msg)
    | AutocompleteField (AutocompleteFieldConfig model msg)
    | MultiChoiceField (MultiChoiceConfig model msg)
    | RadioButtonField (RadioButtonConfig model msg)


hasLabel : FormField model msg -> Bool
hasLabel =
    H.isJust << pickLabel


pickLabel : FormField model msg -> Maybe (Label.Label msg)
pickLabel formField =
    case formField of
        AutocompleteField { label } ->
            label

        CheckboxField { label } ->
            label

        InputField { label } ->
            label

        RadioField { label } ->
            label

        SelectField { label } ->
            label

        MultiChoiceField { label } ->
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


type alias CheckboxFieldConfig model msg =
    { config : Checkbox.Checkbox model msg
    , label : Maybe (Label.Label msg)
    }


checkbox : Checkbox.Checkbox model msg -> FormField model msg
checkbox config =
    CheckboxField <| CheckboxFieldConfig config Nothing


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

        CheckboxField fieldConfig ->
            CheckboxField { fieldConfig | label = Just lbl }

        InputField fieldConfig ->
            InputField { fieldConfig | label = Just lbl }

        SelectField fieldConfig ->
            SelectField { fieldConfig | label = Just lbl }

        RadioField fieldConfig ->
            RadioField { fieldConfig | label = Just lbl }

        MultiChoiceField fieldConfig ->
            MultiChoiceField { fieldConfig | label = Just lbl }

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

        CheckboxField { config } ->
            Checkbox.render model config

        RadioField { config } ->
            Radio.render model config

        SelectField { config } ->
            Select.render model config

        AutocompleteField { config } ->
            Autocomplete.render model config

        MultiChoiceField { config } ->
            MultiChoice.render model config

        RadioButtonField { config } ->
            RadioButton.render model config


type alias MultiChoiceConfig model msg =
    { config : MultiChoice.MultiChoice model msg
    , label : Maybe (Label.Label msg)
    }


multiChoice : MultiChoice.MultiChoice model msg -> FormField model msg
multiChoice config =
    MultiChoiceField <| MultiChoiceConfig config Nothing


type alias RadioButtonConfig model msg =
    { config : RadioButton.RadioButton model msg
    , label : Maybe (Label.Label msg)
    }


radioButtonChoice : RadioButton.RadioButton model msg -> FormField model msg
radioButtonChoice config =
    RadioButtonField <| RadioButtonConfig config Nothing
