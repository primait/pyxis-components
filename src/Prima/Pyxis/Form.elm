module Prima.Pyxis.Form exposing
    ( Config, init, setAsPristine, setAsSubmitted, setAsTouched, isPristine, isTouched, isSubmitted
    , FormField, input, autocomplete, checkbox, date, flag, radio, radioButton, select, textArea
    , withLabel, withAppendableHtml, withFields
    , render
    )

{-|


## Types and Configuration

@docs Config, init, setAsPristine, setAsSubmitted, setAsTouched, isPristine, isTouched, isSubmitted


## Fields

@docs FormField, input, autocomplete, checkbox, date, flag, radio, radioButton, select, textArea


## Manipulating Form and Fields

@docs withLabel, withAppendableHtml, withFields


## Rendering

@docs render

-}

import Html exposing (Html)
import Html.Attributes exposing (class)
import Prima.Pyxis.Form.Autocomplete as Autocomplete
import Prima.Pyxis.Form.Checkbox as Checkbox
import Prima.Pyxis.Form.Date as Date
import Prima.Pyxis.Form.Flag as Flag
import Prima.Pyxis.Form.Grid as Grid
import Prima.Pyxis.Form.Input as Input
import Prima.Pyxis.Form.Label as Label
import Prima.Pyxis.Form.Radio as Radio
import Prima.Pyxis.Form.RadioButton as RadioButton
import Prima.Pyxis.Form.Select as Select
import Prima.Pyxis.Form.TextArea as TextArea
import Prima.Pyxis.Helpers as H


{-| Represent the `Form`.
-}
type Config model msg
    = Config (FormConfig model msg)


type alias FormConfig model msg =
    { state : FormState
    , fields : List (List (FormField model msg))
    }


{-| Create an instance of a `Form`.
-}
init : Config model msg
init =
    Config <| FormConfig Pristine []


{-| Represent the `Form` state.
-}
type FormState
    = Pristine
    | Touched
    | Submitted


{-| Checks if a `Form` is in the `Pristine` state.
-}
isPristine : Config model msg -> Bool
isPristine (Config { state }) =
    state == Pristine


{-| Checks if a `Form` is in the `Touched` state.
-}
isTouched : Config model msg -> Bool
isTouched (Config { state }) =
    state == Touched


{-| Checks if a `Form` is in the `Submitted` state.
-}
isSubmitted : Config model msg -> Bool
isSubmitted (Config { state }) =
    state == Submitted


{-| Sets the `Form` to `Pristine` state.
-}
setAsPristine : Config model msg -> Config model msg
setAsPristine (Config config) =
    Config { config | state = Pristine }


{-| Sets the `Form` to `Submitted` state.
-}
setAsSubmitted : Config model msg -> Config model msg
setAsSubmitted (Config config) =
    Config { config | state = Submitted }


{-| Sets the `Form` to `Touched` state.
-}
setAsTouched : Config model msg -> Config model msg
setAsTouched (Config config) =
    Config { config | state = Touched }


{-| Adds a list of field (which represents a row of the `Grid`) to the `Form`.
-}
withFields : List (FormField model msg) -> Config model msg -> Config model msg
withFields fields (Config formConfig) =
    Config { formConfig | fields = formConfig.fields ++ [ fields ] }


{-| Represent the fields admitted by the `Form`.
-}
type FormField model msg
    = InputField (InputFieldConfig model msg)
    | FlagField (FlagFieldConfig model msg)
    | RadioField (RadioFieldConfig model msg)
    | SelectField (SelectFieldConfig model msg)
    | DateField (DateFieldConfig model msg)
    | AutocompleteField (AutocompleteFieldConfig model msg)
    | CheckboxField (CheckboxFieldConfig model msg)
    | RadioButtonField (RadioButtonFieldConfig model msg)
    | TextAreaField (TextAreaFieldConfig model msg)


{-| Internal. Checks if a field owns a label.
-}
hasLabel : FormField model msg -> Bool
hasLabel =
    H.isJust << pickLabel


{-| Internal. Retrieves the label from a FormField.
-}
pickLabel : FormField model msg -> Maybe (Label.Config msg)
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

        TextAreaField { label } ->
            label

        DateField { label } ->
            label


{-| Internal. Represent the configuration of a `FormField` which holds an `Input` component.
-}
type alias InputFieldConfig model msg =
    { config : Input.Config model msg
    , label : Maybe (Label.Config msg)
    , appendableHtml : List (Html msg)
    }


{-| Transforms an `Input` component into a `FormField`.
-}
input : Input.Config model msg -> FormField model msg
input config =
    InputField <| InputFieldConfig config Nothing []


{-| Internal. Represent the configuration of a `FormField` which holds an `Flag` component.
-}
type alias FlagFieldConfig model msg =
    { config : Flag.Config model msg
    , label : Maybe (Label.Config msg)
    , appendableHtml : List (Html msg)
    }


{-| Transforms a `Flag` component into a `FormField`.
-}
flag : Flag.Config model msg -> FormField model msg
flag config =
    FlagField <| FlagFieldConfig config Nothing []


{-| Internal. Represent the configuration of a `FormField` which holds a `Radio` component.
-}
type alias RadioFieldConfig model msg =
    { config : Radio.Config model msg
    , label : Maybe (Label.Config msg)
    , appendableHtml : List (Html msg)
    }


{-| Transforms a `Radio` component into a `FormField`.
-}
radio : Radio.Config model msg -> FormField model msg
radio config =
    RadioField <| RadioFieldConfig config Nothing []


{-| Internal. Represent the configuration of a `FormField` which holds a `RadioButton` component.
-}
type alias RadioButtonFieldConfig model msg =
    { config : RadioButton.Config model msg
    , label : Maybe (Label.Config msg)
    , appendableHtml : List (Html msg)
    }


{-| Transforms a `RadioButton` component into a `FormField`.
-}
radioButton : RadioButton.Config model msg -> FormField model msg
radioButton config =
    RadioButtonField <| RadioButtonFieldConfig config Nothing []


{-| Internal. Represent the configuration of a `FormField` which holds a `Select` component.
-}
type alias SelectFieldConfig model msg =
    { config : Select.Config model msg
    , label : Maybe (Label.Config msg)
    , appendableHtml : List (Html msg)
    }


{-| Transforms a `Select` component into a `FormField`.
-}
select : Select.Config model msg -> FormField model msg
select config =
    SelectField <| SelectFieldConfig config Nothing []


{-| Internal. Represent the configuration of a `FormField` which holds an `Autocomplete` component.
-}
type alias AutocompleteFieldConfig model msg =
    { config : Autocomplete.Config model msg
    , label : Maybe (Label.Config msg)
    , appendableHtml : List (Html msg)
    }


{-| Transforms an `Autocomplete` component into a `FormField`.
-}
autocomplete : Autocomplete.Config model msg -> FormField model msg
autocomplete config =
    AutocompleteField <| AutocompleteFieldConfig config Nothing []


{-| Internal. Represent the configuration of a `FormField` which holds a `Date` component.
-}
type alias DateFieldConfig model msg =
    { config : Date.Config model msg
    , label : Maybe (Label.Config msg)
    , appendableHtml : List (Html msg)
    }


{-| Transforms a `Date` component into a `FormField`.
-}
date : Date.Config model msg -> FormField model msg
date config =
    DateField <| DateFieldConfig config Nothing []


{-| Internal. Represent the configuration of a `FormField` which holds a `Checkbox` component.
-}
type alias CheckboxFieldConfig model msg =
    { config : Checkbox.Config model msg
    , label : Maybe (Label.Config msg)
    , appendableHtml : List (Html msg)
    }


{-| Transforms a `Checkbox` component into a `FormField`.
-}
checkbox : Checkbox.Config model msg -> FormField model msg
checkbox config =
    CheckboxField <| CheckboxFieldConfig config Nothing []


{-| Internal. Represent the configuration of a `FormField` which holds a `TextArea` component.
-}
type alias TextAreaFieldConfig model msg =
    { config : TextArea.Config model msg
    , label : Maybe (Label.Config msg)
    , appendableHtml : List (Html msg)
    }


{-| Transforms a `TextArea` component into a `FormField`.
-}
textArea : TextArea.Config model msg -> FormField model msg
textArea config =
    TextAreaField <| TextAreaFieldConfig config Nothing []


{-| Adds a `Label` component into a `FormField`.
-}
withLabel : Label.Config msg -> FormField model msg -> FormField model msg
withLabel lbl formField =
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

        TextAreaField fieldConfig ->
            TextAreaField { fieldConfig | label = Just lbl }

        DateField fieldConfig ->
            DateField { fieldConfig | label = Just lbl }


{-| Adds a list of `Html` to a `FormField`. They will be printed after the component tag and it's wrapper.
-}
withAppendableHtml : List (Html msg) -> FormField model msg -> FormField model msg
withAppendableHtml html formField =
    case formField of
        AutocompleteField fieldConfig ->
            AutocompleteField { fieldConfig | appendableHtml = html }

        FlagField fieldConfig ->
            FlagField { fieldConfig | appendableHtml = html }

        InputField fieldConfig ->
            InputField { fieldConfig | appendableHtml = html }

        SelectField fieldConfig ->
            SelectField { fieldConfig | appendableHtml = html }

        RadioField fieldConfig ->
            RadioField { fieldConfig | appendableHtml = html }

        CheckboxField fieldConfig ->
            CheckboxField { fieldConfig | appendableHtml = html }

        RadioButtonField fieldConfig ->
            RadioButtonField { fieldConfig | appendableHtml = html }

        TextAreaField fieldConfig ->
            TextAreaField { fieldConfig | appendableHtml = html }

        DateField fieldConfig ->
            DateField { fieldConfig | appendableHtml = html }


{-| Internal. Transforms a `FormField` label into Html.
-}
renderLabel : FormField model msg -> List (Html msg)
renderLabel formField =
    formField
        |> pickLabel
        |> Maybe.map (List.singleton << Label.render)
        |> Maybe.withDefault []


{-| Internal. Transforms a `FormField` into Html.
-}
renderField : model -> FormField model msg -> List (Html msg)
renderField model formField =
    case formField of
        InputField { config, appendableHtml } ->
            Input.render model config ++ appendableHtml

        FlagField { config, appendableHtml } ->
            Flag.render model config ++ appendableHtml

        RadioField { config, appendableHtml } ->
            Radio.render model config ++ appendableHtml

        SelectField { config, appendableHtml } ->
            Select.render model config ++ appendableHtml

        AutocompleteField { config, appendableHtml } ->
            Autocomplete.render model config ++ appendableHtml

        CheckboxField { config, appendableHtml } ->
            Checkbox.render model config ++ appendableHtml

        RadioButtonField { config, appendableHtml } ->
            RadioButton.render model config ++ appendableHtml

        TextAreaField { config, appendableHtml } ->
            TextArea.render model config ++ appendableHtml

        DateField { config, appendableHtml } ->
            Date.render model config ++ appendableHtml


{-| Renders the form with all his fields.
-}
render : model -> Config model msg -> Html msg
render model (Config formConfig) =
    Html.div
        [ class "m-form" ]
        (formConfig.fields
            |> List.map (H.flip Grid.addRow Grid.create << buildGridRow model)
            |> List.map Grid.render
            |> List.concat
        )


{-| Internal. Create a `Grid` row.
-}
buildGridRow : model -> List (FormField model msg) -> Grid.Row msg
buildGridRow model fields =
    (case fields of
        first :: second :: [] ->
            case ( hasLabel first, hasLabel second ) of
                ( _, True ) ->
                    [ first
                        |> renderLabel
                    , first
                        |> renderField model
                    , second
                        |> renderLabel
                    , second
                        |> renderField model
                    ]

                ( _, False ) ->
                    [ first
                        |> renderLabel
                    , first
                        |> renderField model
                    , second
                        |> renderField model
                    ]

        first :: [] ->
            [ first
                |> renderLabel
            , first
                |> renderField model
            ]

        _ ->
            []
    )
        |> List.map Grid.col
        |> H.flip Grid.addCols Grid.row
