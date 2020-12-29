module Prima.Pyxis.Form exposing
    ( Form, FormField, FormFieldset, Legend
    , init
    , withBeside, withVertical
    , withFields, withFieldsAndLegend
    , legend, legendWithPrependableHtml, legendWithAppendableHtml
    , input, inputList, autocomplete, checkbox, date, filterableSelect, flag, radio, radioFlag, radioButton, select, textArea
    , withLabel, withAppendableHtml
    , render
    , RowKind(..), renderField, renderFields, renderLabel
    )

{-|


## Configuration

@docs Form, FormField, FormFieldset, Legend


## Configuration Methods

@docs init


## Change Kind to the Form

@docs withBeside, withVertical


## Adding Fields to the Form

@docs withFields, withFieldsAndLegend


## Defining a fieldset with a legend

@docs legend, legendWithPrependableHtml, legendWithAppendableHtml


## Defining Fields

@docs input, inputList, autocomplete, checkbox, date, filterableSelect, flag, radio, radioFlag, radioButton, select, textArea


## Manipulating Fields

@docs withLabel, withAppendableHtml


## Rendering

@docs render

-}

import Html exposing (Html)
import Html.Attributes exposing (class)
import Maybe.Extra as ME
import Prima.Pyxis.Form.Autocomplete as Autocomplete
import Prima.Pyxis.Form.Checkbox as Checkbox
import Prima.Pyxis.Form.CheckboxFlag as CheckboxFlag
import Prima.Pyxis.Form.Date as Date
import Prima.Pyxis.Form.FilterableSelect as FilterableSelect
import Prima.Pyxis.Form.Grid as Grid
import Prima.Pyxis.Form.Input as Input
import Prima.Pyxis.Form.Label as Label
import Prima.Pyxis.Form.Radio as Radio
import Prima.Pyxis.Form.RadioButton as RadioButton
import Prima.Pyxis.Form.RadioFlag as RadioFlag
import Prima.Pyxis.Form.Select as Select
import Prima.Pyxis.Form.TextArea as TextArea
import Prima.Pyxis.Helpers as H


{-| Represent the `Form`.
-}
type Form model msg
    = Form (FormConfig model msg)


{-| Internal. Represents the configuration of a `Form`.
-}
type alias FormConfig model msg =
    { kind : RowKind
    , fields : List (FormFieldset model msg)
    }


type RowKind
    = Grid
    | Beside
    | Vertical


{-| Create an instance of a `Form`.
You can specify later which fields will go inside it.
-}
init : Form model msg
init =
    Form { kind = Grid, fields = [] }


{-| Create an instance of a `Form` with standard layout where you have
2 fields in line with 1 label.
You can specify later which fields will go inside it.
-}
withBeside : Form model msg -> Form model msg
withBeside (Form formConfig) =
    Form { formConfig | kind = Beside }


{-| Create an instance of a `Form` with vertical layout.
You can specify later which fields will go inside it.
-}
withVertical : Form model msg -> Form model msg
withVertical (Form formConfig) =
    Form { formConfig | kind = Vertical }


{-| Internal. Convenient way to represents a List of FormField.
Think about it as a list of columns for each row of the grid.
-}
type alias FormFieldList model msg =
    List (FormField model msg)


{-| Represents `FormFieldset`.
This is not a one-to-one representation of an html `fieldset` tag.

A `FormFieldset` is made up of a list of list of `FormFields`.
The first list represents the rows of a grid, the latter represents each column of a row.

-}
type FormFieldset model msg
    = WithoutLegend (FormFieldList model msg)
    | WithLegend (Legend msg) (List (FormFieldList model msg))


{-| Represents the `Legend` for a `FormFieldset`.
-}
type Legend msg
    = Legend String (List (Html msg)) (List (Html msg))


{-| Creates a `Legend` for a `FormFieldset`.
-}
legend : String -> Legend msg
legend name =
    Legend name [] []


{-| Creates a `Legend` with prependable Html.
-}
legendWithPrependableHtml : String -> List (Html msg) -> Legend msg
legendWithPrependableHtml name prependableHtml =
    Legend name prependableHtml []


{-| Creates a `Legend` with appendable Html.
-}
legendWithAppendableHtml : String -> List (Html msg) -> Legend msg
legendWithAppendableHtml name appendableHtml =
    Legend name [] appendableHtml


{-| Adds a list of field (which represents a row of the `Grid`) to the `Form`.
-}
withFields : FormFieldList model msg -> Form model msg -> Form model msg
withFields fields (Form formConfig) =
    Form
        { formConfig
            | fields =
                fields
                    |> WithoutLegend
                    |> List.singleton
                    |> List.append formConfig.fields
        }


{-| Adds a list of list of field (which represents a list of row of the `Grid`) to the `Form`.
This list will be wrapped inside a fieldset.
-}
withFieldsAndLegend : Legend msg -> List (FormFieldList model msg) -> Form model msg -> Form model msg
withFieldsAndLegend legend_ fields (Form formConfig) =
    Form
        { formConfig
            | fields =
                fields
                    |> WithLegend legend_
                    |> List.singleton
                    |> List.append formConfig.fields
        }


{-| Represent the fields admitted by the `Form`.
-}
type FormField model msg
    = InputField (InputFieldConfig model msg)
    | InputListField (List (InputFieldConfig model msg))
    | RadioField (RadioFieldConfig model msg)
    | RadioFlagField (RadioFlagFieldConfig model msg)
    | SelectField (SelectFieldConfig model msg)
    | DateField (DateFieldConfig model msg)
    | AutocompleteField (AutocompleteFieldConfig model msg)
    | FilterableSelectField (FilterableSelectFieldConfig model msg)
    | CheckboxField (CheckboxFieldConfig model msg)
    | CheckboxFlagField (CheckboxFlagFieldConfig model msg)
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

        CheckboxField { label } ->
            label

        CheckboxFlagField { label } ->
            label

        InputField { label } ->
            label

        InputListField ({ label } :: _) ->
            label

        InputListField [] ->
            Nothing

        RadioField { label } ->
            label

        RadioFlagField { label } ->
            label

        RadioButtonField { label } ->
            label

        SelectField { label } ->
            label

        TextAreaField { label } ->
            label

        DateField { label } ->
            label

        FilterableSelectField { label } ->
            label


{-| Internal. Represent the configuration of a `FormField` which holds an `Input` component.
-}
type alias InputFieldConfig model msg =
    { config : Input.Input model msg
    , label : Maybe (Label.Label msg)
    , appendableHtml : List (Html msg)
    }


{-| Transforms an `Input` component into a `FormField`.
-}
input : Input.Input model msg -> FormField model msg
input config =
    InputField <| InputFieldConfig config Nothing []


{-| Transforms an `Input` component into a `FormField`.
-}
inputList : List (Input.Input model msg) -> FormField model msg
inputList configs =
    let
        buildConfig : Input.Input model msg -> InputFieldConfig model msg
        buildConfig config =
            InputFieldConfig config Nothing []
    in
    InputListField <| List.map buildConfig configs


{-| Internal. Represent the configuration of a `FormField` which holds an `Flag` component.
-}
type alias CheckboxFlagFieldConfig model msg =
    { config : CheckboxFlag.Flag model msg
    , label : Maybe (Label.Label msg)
    , appendableHtml : List (Html msg)
    }


{-| Transforms a `Flag` component into a `FormField`.
-}
flag : CheckboxFlag.Flag model msg -> FormField model msg
flag config =
    CheckboxFlagField <| CheckboxFlagFieldConfig config Nothing []


{-| Internal. Represent the configuration of a `FormField` which holds a `Radio` component.
-}
type alias RadioFieldConfig model msg =
    { config : Radio.Radio model msg
    , label : Maybe (Label.Label msg)
    , appendableHtml : List (Html msg)
    }


{-| Transforms a `Radio` component into a `FormField`.
-}
radio : Radio.Radio model msg -> FormField model msg
radio config =
    RadioField <| RadioFieldConfig config Nothing []


{-| Internal. Represent the configuration of a `FormField` which holds a `Radio` component.
-}
type alias RadioFlagFieldConfig model msg =
    { config : RadioFlag.RadioFlag model msg
    , label : Maybe (Label.Label msg)
    , appendableHtml : List (Html msg)
    }


{-| Transforms a `RadioFlag` component into a `FormField`.
-}
radioFlag : RadioFlag.RadioFlag model msg -> FormField model msg
radioFlag config =
    RadioFlagField <| RadioFlagFieldConfig config Nothing []


{-| Internal. Represent the configuration of a `FormField` which holds a `RadioButton` component.
-}
type alias RadioButtonFieldConfig model msg =
    { config : RadioButton.RadioButton model msg
    , label : Maybe (Label.Label msg)
    , appendableHtml : List (Html msg)
    }


{-| Transforms a `RadioButton` component into a `FormField`.
-}
radioButton : RadioButton.RadioButton model msg -> FormField model msg
radioButton config =
    RadioButtonField <| RadioButtonFieldConfig config Nothing []


{-| Internal. Represent the configuration of a `FormField` which holds a `Select` component.
-}
type alias SelectFieldConfig model msg =
    { msgMapper : Select.Msg -> msg
    , state : Select.State
    , config : Select.Select model
    , label : Maybe (Label.Label msg)
    , appendableHtml : List (Html msg)
    }


{-| Transforms a `Select` component into a `FormField`.
-}
select : (Select.Msg -> msg) -> Select.State -> Select.Select model -> FormField model msg
select msgMapper state config =
    SelectField <| SelectFieldConfig msgMapper state config Nothing []


{-| Internal. Represent the configuration of a `FormField` which holds an `Autocomplete` component.
-}
type alias AutocompleteFieldConfig model msg =
    { msgMapper : Autocomplete.Msg -> msg
    , state : Autocomplete.State
    , config : Autocomplete.Autocomplete model
    , label : Maybe (Label.Label msg)
    , appendableHtml : List (Html msg)
    }


{-| Transforms an `Autocomplete` component into a `FormField`.
-}
autocomplete : (Autocomplete.Msg -> msg) -> Autocomplete.State -> Autocomplete.Autocomplete model -> FormField model msg
autocomplete msgMapper state config =
    AutocompleteField <| AutocompleteFieldConfig msgMapper state config Nothing []


{-| Internal. Represent the configuration of a `FormField` which holds an `FilterableSelect` component.
-}
type alias FilterableSelectFieldConfig model msg =
    { msgMapper : FilterableSelect.Msg -> msg
    , state : FilterableSelect.State
    , config : FilterableSelect.FilterableSelect model
    , label : Maybe (Label.Label msg)
    , appendableHtml : List (Html msg)
    }


{-| Transforms an `FilterableSelect` component into a `FormField`.
-}
filterableSelect : (FilterableSelect.Msg -> msg) -> FilterableSelect.State -> FilterableSelect.FilterableSelect model -> FormField model msg
filterableSelect msgMapper state config =
    FilterableSelectField <| FilterableSelectFieldConfig msgMapper state config Nothing []


{-| Internal. Represent the configuration of a `FormField` which holds a `Date` component.
-}
type alias DateFieldConfig model msg =
    { config : Date.Date model msg
    , label : Maybe (Label.Label msg)
    , appendableHtml : List (Html msg)
    }


{-| Transforms a `Date` component into a `FormField`.
-}
date : Date.Date model msg -> FormField model msg
date config =
    DateField <| DateFieldConfig config Nothing []


{-| Internal. Represent the configuration of a `FormField` which holds a `Checkbox` component.
-}
type alias CheckboxFieldConfig model msg =
    { config : Checkbox.Checkbox model msg
    , label : Maybe (Label.Label msg)
    , appendableHtml : List (Html msg)
    }


{-| Transforms a `Checkbox` component into a `FormField`.
-}
checkbox : Checkbox.Checkbox model msg -> FormField model msg
checkbox config =
    CheckboxField <| CheckboxFieldConfig config Nothing []


{-| Internal. Represent the configuration of a `FormField` which holds a `TextArea` component.
-}
type alias TextAreaFieldConfig model msg =
    { config : TextArea.TextArea model msg
    , label : Maybe (Label.Label msg)
    , appendableHtml : List (Html msg)
    }


{-| Transforms a `TextArea` component into a `FormField`.
-}
textArea : TextArea.TextArea model msg -> FormField model msg
textArea config =
    TextAreaField <| TextAreaFieldConfig config Nothing []


{-| Adds a `Label` component into a `FormField`.
-}
withLabel : Label.Label msg -> FormField model msg -> FormField model msg
withLabel lbl formField =
    case formField of
        AutocompleteField fieldConfig ->
            AutocompleteField { fieldConfig | label = Just lbl }

        CheckboxField fieldConfig ->
            CheckboxField { fieldConfig | label = Just lbl }

        CheckboxFlagField fieldConfig ->
            CheckboxFlagField { fieldConfig | label = Just lbl }

        InputField fieldConfig ->
            InputField { fieldConfig | label = Just lbl }

        InputListField (fieldConfig :: tail) ->
            InputListField ({ fieldConfig | label = Just lbl } :: tail)

        InputListField [] ->
            formField

        SelectField fieldConfig ->
            SelectField { fieldConfig | label = Just lbl }

        RadioField fieldConfig ->
            RadioField { fieldConfig | label = Just lbl }

        RadioFlagField fieldConfig ->
            RadioFlagField { fieldConfig | label = Just lbl }

        RadioButtonField fieldConfig ->
            RadioButtonField { fieldConfig | label = Just lbl }

        TextAreaField fieldConfig ->
            TextAreaField { fieldConfig | label = Just lbl }

        DateField fieldConfig ->
            DateField { fieldConfig | label = Just lbl }

        FilterableSelectField fieldConfig ->
            FilterableSelectField { fieldConfig | label = Just lbl }


{-| Adds a list of `Html` to a `FormField`. They will be printed after the component tag and it's wrapper.
-}
withAppendableHtml : List (Html msg) -> FormField model msg -> FormField model msg
withAppendableHtml html formField =
    case formField of
        AutocompleteField fieldConfig ->
            AutocompleteField { fieldConfig | appendableHtml = html }

        CheckboxField fieldConfig ->
            CheckboxField { fieldConfig | appendableHtml = html }

        CheckboxFlagField fieldConfig ->
            CheckboxFlagField { fieldConfig | appendableHtml = html }

        InputField fieldConfig ->
            InputField { fieldConfig | appendableHtml = html }

        InputListField fieldConfig ->
            InputListField <|
                case List.reverse fieldConfig of
                    head :: tail ->
                        List.reverse ({ head | appendableHtml = html } :: tail)

                    _ ->
                        fieldConfig

        SelectField fieldConfig ->
            SelectField { fieldConfig | appendableHtml = html }

        RadioField fieldConfig ->
            RadioField { fieldConfig | appendableHtml = html }

        RadioFlagField _ ->
            formField

        RadioButtonField fieldConfig ->
            RadioButtonField { fieldConfig | appendableHtml = html }

        TextAreaField fieldConfig ->
            TextAreaField { fieldConfig | appendableHtml = html }

        DateField fieldConfig ->
            DateField { fieldConfig | appendableHtml = html }

        FilterableSelectField fieldConfig ->
            FilterableSelectField { fieldConfig | appendableHtml = html }


{-| Internal. Transforms a `FormField` label into Html.
-}
renderLabel : FormField model msg -> List (Html msg)
renderLabel formField =
    formField
        |> pickLabel
        |> ME.unwrap [] (List.singleton << Label.render)


{-| Internal. Transforms a `FormField` into Html.
-}
renderField : model -> FormField model msg -> List (Html msg)
renderField model formField =
    case formField of
        InputField { config, appendableHtml } ->
            Input.render model config ++ renderAppendableHtml appendableHtml

        InputListField list ->
            list
                |> List.map (renderField model << InputField)
                |> List.concat

        CheckboxField { config, appendableHtml } ->
            Checkbox.render model config ++ renderAppendableHtml appendableHtml

        CheckboxFlagField { config, appendableHtml } ->
            CheckboxFlag.render model config ++ renderAppendableHtml appendableHtml

        SelectField { msgMapper, state, config, appendableHtml } ->
            config
                |> Select.render model state
                |> List.map (Html.map msgMapper)
                |> H.flip List.append (renderAppendableHtml appendableHtml)

        AutocompleteField { msgMapper, state, config, appendableHtml } ->
            config
                |> Autocomplete.render model state
                |> List.map (Html.map msgMapper)
                |> H.flip List.append (renderAppendableHtml appendableHtml)

        RadioField { config, appendableHtml } ->
            Radio.render model config ++ renderAppendableHtml appendableHtml

        RadioFlagField { config } ->
            RadioFlag.render model config

        RadioButtonField { config, appendableHtml } ->
            RadioButton.render model config ++ renderAppendableHtml appendableHtml

        TextAreaField { config, appendableHtml } ->
            TextArea.render model config ++ renderAppendableHtml appendableHtml

        DateField { config, appendableHtml } ->
            Date.render model config ++ renderAppendableHtml appendableHtml

        FilterableSelectField { msgMapper, state, config, appendableHtml } ->
            config
                |> FilterableSelect.render model state.autocompleteState
                |> List.map (Html.map msgMapper)
                |> H.flip List.append (renderAppendableHtml appendableHtml)


{-| Renders the form with all his fields.
-}
render : model -> Form model msg -> Html msg
render model (Form formConfig) =
    Html.div
        [ class "form" ]
        (formConfig.fields
            |> List.map (renderFieldset model formConfig.kind)
            |> List.concat
        )


renderFieldset : model -> RowKind -> FormFieldset model msg -> List (Html msg)
renderFieldset model kind fieldset =
    case fieldset of
        WithoutLegend fields ->
            fields
                |> List.singleton
                |> renderFields model kind

        WithLegend legend_ fields ->
            [ Html.fieldset
                [ class "form__fieldset" ]
                (fields
                    |> renderFields model kind
                    |> (::) (renderLegend legend_)
                )
            ]


renderLegend : Legend msg -> Html msg
renderLegend (Legend title prependableHtml appendableHtml) =
    Html.legend
        [ class "form__fieldset__legend" ]
        [ prependableHtml
            |> Html.div [ class "form__fieldset__legend__prepend" ]
            |> H.renderIf (List.length prependableHtml > 0)
        , Html.span
            [ class "form__fieldset__legend__title" ]
            [ Html.text title ]
        , appendableHtml
            |> Html.div [ class "form__fieldset__legend__append" ]
            |> H.renderIf (List.length appendableHtml > 0)
        ]


renderAppendableHtml : List (Html msg) -> List (Html msg)
renderAppendableHtml content =
    content
        |> Html.div [ class "form-row__item__append" ]
        |> H.renderIf (List.length content > 0)
        |> List.singleton


renderFields : model -> RowKind -> List (FormFieldList model msg) -> List (Html msg)
renderFields model kind fields =
    case kind of
        Vertical ->
            fields
                |> List.map (buildVerticalRow model)

        _ ->
            fields
                |> List.map (H.flip Grid.addRow Grid.create << buildGridRow model kind)
                |> List.map Grid.render
                |> List.concat


buildVerticalRow : model -> FormFieldList model msg -> Html msg
buildVerticalRow model fields =
    Html.div [ class "form-row is-vertical" ]
        (List.map (renderVerticalField model) fields)


renderVerticalField : model -> FormField model msg -> Html msg
renderVerticalField model field =
    Html.div [ class "form-row__item is-vertical" ]
        (renderLabel field ++ renderField model field)


{-| Internal. Create a `Grid` row.
-}
buildGridRow : model -> RowKind -> FormFieldList model msg -> Grid.Row msg
buildGridRow model kind fields =
    case fields of
        first :: second :: [] ->
            case ( hasLabel first, hasLabel second ) of
                ( _, True ) ->
                    Grid.withFourColumns
                        (renderLabel first)
                        (renderField model first)
                        (renderLabel second)
                        (renderField model second)

                ( _, False ) ->
                    case kind of
                        Grid ->
                            Grid.withThreeColumns
                                (renderLabel first)
                                (renderField model first)
                                (renderField model second)

                        Vertical ->
                            Grid.emptyRow

                        Beside ->
                            Grid.withTwoColumns
                                (renderLabel first)
                                [ Html.div [ class "form-row__item__column" ] (renderField model first)
                                , Html.div [ class "form-row__item__column" ] (renderField model second)
                                ]

        first :: [] ->
            if isRadioFlagField first then
                Grid.withOneColumn
                    (renderLabel first ++ renderField model first)

            else
                Grid.withTwoColumns
                    (renderLabel first)
                    (renderField model first)

        _ ->
            Grid.emptyRow


isRadioFlagField : FormField model msg -> Bool
isRadioFlagField field =
    case field of
        RadioFlagField _ ->
            True

        _ ->
            False
