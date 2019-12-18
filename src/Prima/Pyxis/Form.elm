module Prima.Pyxis.Form exposing
    ( Form, init
    , FormField, input, autocomplete, checkbox, date, flag, radio, radioButton, select
    , withLabel, withFields
    , render
    , gridRow, hasLabel, pickLabel, textArea
    )

{-|


## Types and Configuration

@docs Form, init, setAsPristine, setAsSubmitted, setAsTouched, isPristine, isTouched, isSubmitted


## Fields

@docs FormField, input, autocomplete, checkbox, date, flag, radio, radioButton, select, textarea


## Manipulating Form and Fields

@docs withLabel, withFields


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


{-| Represents the Form
-}
type Form model msg
    = Form (FormConfig model msg)


type alias FormConfig model msg =
    { state : FormState
    , fields : List (List (FormField model msg))
    }


init : Form model msg
init =
    Form <| FormConfig Pristine []


type FormState
    = Pristine
    | Touched
    | Submitted


isPristine : FormState -> Bool
isPristine =
    (==) Pristine


isTouched : FormState -> Bool
isTouched =
    (==) Touched


isSubmitted : FormState -> Bool
isSubmitted =
    (==) Submitted


setAsPristine : Form model msg -> Form model msg
setAsPristine (Form config) =
    Form { config | state = Pristine }


setAsSubmitted : Form model msg -> Form model msg
setAsSubmitted (Form config) =
    Form { config | state = Submitted }


setAsTouched : Form model msg -> Form model msg
setAsTouched (Form config) =
    Form { config | state = Touched }


withFields : List (FormField model msg) -> Form model msg -> Form model msg
withFields fields (Form formConfig) =
    Form { formConfig | fields = formConfig.fields ++ [ fields ] }


gridRow : model -> List (FormField model msg) -> Grid.Row msg
gridRow model fields =
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


{-| Represents the available fields which can be included into the Form.
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

        TextAreaField { label } ->
            label

        DateField { label } ->
            label


{-| Internal. Represents the configuration of a `FormField` which holds an `Input` component.
-}
type alias InputFieldConfig model msg =
    { config : Input.Input model msg
    , label : Maybe (Label.Label msg)
    }


{-| Transforms an `Input` component into a `FormField`.
-}
input : Input.Input model msg -> FormField model msg
input config =
    InputField <| InputFieldConfig config Nothing


{-| Internal. Represents the configuration of a `FormField` which holds an `Flag` component.
-}
type alias FlagFieldConfig model msg =
    { config : Flag.Flag model msg
    , label : Maybe (Label.Label msg)
    }


{-| Transforms a `Flag` component into a `FormField`.
-}
flag : Flag.Flag model msg -> FormField model msg
flag config =
    FlagField <| FlagFieldConfig config Nothing


{-| Internal. Represents the configuration of a `FormField` which holds a `Radio` component.
-}
type alias RadioFieldConfig model msg =
    { config : Radio.Radio model msg
    , label : Maybe (Label.Label msg)
    }


{-| Transforms a `Radio` component into a `FormField`.
-}
radio : Radio.Radio model msg -> FormField model msg
radio config =
    RadioField <| RadioFieldConfig config Nothing


{-| Internal. Represents the configuration of a `FormField` which holds a `RadioButton` component.
-}
type alias RadioButtonFieldConfig model msg =
    { config : RadioButton.RadioButton model msg
    , label : Maybe (Label.Label msg)
    }


{-| Transforms a `RadioButton` component into a `FormField`.
-}
radioButton : RadioButton.RadioButton model msg -> FormField model msg
radioButton config =
    RadioButtonField <| RadioButtonFieldConfig config Nothing


{-| Internal. Represents the configuration of a `FormField` which holds a `Select` component.
-}
type alias SelectFieldConfig model msg =
    { config : Select.Select model msg
    , label : Maybe (Label.Label msg)
    }


{-| Transforms a `Select` component into a `FormField`.
-}
select : Select.Select model msg -> FormField model msg
select config =
    SelectField <| SelectFieldConfig config Nothing


{-| Internal. Represents the configuration of a `FormField` which holds an `Autocomplete` component.
-}
type alias AutocompleteFieldConfig model msg =
    { config : Autocomplete.Autocomplete model msg
    , label : Maybe (Label.Label msg)
    }


{-| Transforms an `Autocomplete` component into a `FormField`.
-}
autocomplete : Autocomplete.Autocomplete model msg -> FormField model msg
autocomplete config =
    AutocompleteField <| AutocompleteFieldConfig config Nothing


{-| Internal. Represents the configuration of a `FormField` which holds a `Date` component.
-}
type alias DateFieldConfig model msg =
    { config : Date.Date model msg
    , label : Maybe (Label.Label msg)
    }


{-| Transforms a `Date` component into a `FormField`.
-}
date : Date.Date model msg -> FormField model msg
date config =
    DateField <| DateFieldConfig config Nothing


{-| Internal. Represents the configuration of a `FormField` which holds a `Checkbox` component.
-}
type alias CheckboxFieldConfig model msg =
    { config : Checkbox.Checkbox model msg
    , label : Maybe (Label.Label msg)
    }


{-| Transforms a `Checkbox` component into a `FormField`.
-}
checkbox : Checkbox.Checkbox model msg -> FormField model msg
checkbox config =
    CheckboxField <| CheckboxFieldConfig config Nothing


{-| Internal. Represents the configuration of a `FormField` which holds a `TextArea` component.
-}
type alias TextAreaFieldConfig model msg =
    { config : TextArea.TextArea model msg
    , label : Maybe (Label.Label msg)
    }


{-| Transforms a `TextArea` component into a `FormField`.
-}
textArea : TextArea.TextArea model msg -> FormField model msg
textArea config =
    TextAreaField <| TextAreaFieldConfig config Nothing


{-| Adds a `Label` component into a `FormField`.
-}
withLabel : Label.Label msg -> FormField model msg -> FormField model msg
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

        TextAreaField { config } ->
            TextArea.render model config

        DateField { config } ->
            Date.render model config


{-| Renders the form with all his fields.
-}
render : model -> Form model msg -> Html msg
render model (Form formConfig) =
    Html.div
        [ class "m-form" ]
        (formConfig.fields
            |> List.map (H.flip Grid.addRow Grid.create << gridRow model)
            |> List.map Grid.render
            |> List.concat
        )
