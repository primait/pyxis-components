module Prima.Pyxis.Form.Field exposing (..)

import Html exposing (Html, text)
import Prima.Pyxis.Form.Checkbox as Checkbox
import Prima.Pyxis.Form.Input as Input
import Prima.Pyxis.Form.Label as Label
import Prima.Pyxis.Form.Radio as Radio
import Prima.Pyxis.Helpers as H


type FormField model msg
    = InputField (InputFieldConfig model msg)
    | CheckboxField (CheckboxFieldConfig model msg)
    | RadioField (RadioFieldConfig model msg)


hasLabel : FormField model msg -> Bool
hasLabel formField =
    case formField of
        InputField { label } ->
            H.isJust label

        CheckboxField { label } ->
            H.isJust label

        RadioField { label } ->
            H.isJust label


pickLabel : FormField model msg -> Maybe (Label.Label msg)
pickLabel formField =
    case formField of
        InputField { label } ->
            label

        CheckboxField { label } ->
            label

        RadioField { label } ->
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


addLabel : Label.Label msg -> FormField model msg -> FormField model msg
addLabel lbl formField =
    case formField of
        InputField fieldConfig ->
            InputField { fieldConfig | label = Just lbl }

        CheckboxField fieldConfig ->
            CheckboxField { fieldConfig | label = Just lbl }

        RadioField fieldConfig ->
            RadioField { fieldConfig | label = Just lbl }


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
            [ Input.render model config ]

        CheckboxField { config } ->
            Checkbox.render model config

        RadioField { config } ->
            Radio.render model config
