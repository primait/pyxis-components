module Prima.Pyxis.Form exposing
    ( Form, InputGroup, Label, Slug, Value
    , init, state, setAsSubmitted
    , isFormSubmitted
    , FormField(..)
    , textConfig, passwordConfig, textareaConfig
    , checkboxConfig, checkboxOption
    , radioConfig, radioOption
    , selectConfig, selectOption
    , datepickerConfig
    , autocompleteConfig, autocompleteOption
    , pureHtmlConfig
    , fieldIsValid, fieldHasError, fieldHasWarning, fieldIsPristine, fieldIsTouched
    , fieldGroupIsValid, fieldGroupHasError, fieldGroupHasWarning
    , render, renderField, renderInputGroupField
    , prependInputGroup, appendInputGroup
    , AbstractField, FormFieldGroup, addField, addFieldGroup, field, fieldGroup, fieldGroupConfig, renderFieldGroup
    )

{-| Allows to create a Form and it's fields using predefined Html syntax.


# Form Configuration

@docs Form, InputGroup, FormRenderer, Label, Slug, Value, formRenderer


# Form Configuration Helpers

@docs init, state, setAsPristine, setAsTouched, setAsSubmitted


# Form State Helpers

@docs isFormSubmitted


# Fields Configuration

@docs FormField


# Input

@docs textConfig, passwordConfig, textareaConfig


# Checkbox

@docs checkboxConfig, checkboxOption


# Radio

@docs radioConfig, radioOption


# Select

@docs selectConfig, selectOption


# Datepicker

@docs datepickerConfig


# Autocomplete

@docs autocompleteConfig, autocompleteOption


# Pure Html

@docs pureHtmlConfig


# Fields Helpers

@docs fieldIsValid, fieldHasError, fieldHasWarning, fieldIsPristine, fieldIsTouched


# FieldGroup Helpers

@docs fieldGroupIsValid, fieldGroupHasError, fieldGroupHasWarning


# Render

@docs render, renderField, renderInputGroupField


# Render Helpers

@docs prependInputGroup, appendInputGroup

-}

import Html exposing (..)
import Html.Attributes
    exposing
        ( attribute
        , checked
        , class
        , classList
        , for
        , id
        , name
        , selected
        , type_
        , value
        )
import Prima.Pyxis.DatePicker as DatePicker
import Prima.Pyxis.Form.Event as Events exposing (Event)
import Prima.Pyxis.Form.Validation as FormValidation
import Prima.Pyxis.Helpers as Helpers


type Form model msg
    = Form (FormConfig model msg)


type alias FormConfig model msg =
    { state : FormState
    , fields : List (AbstractField model msg)
    }


type AbstractField model msg
    = AbstractField (FormField model msg)
    | AbstractGroup (FormFieldGroup model msg)


type FormState
    = NotSubmitted
    | Submitted


type FormFieldGroup model msg
    = FormFieldGroup (FormFieldGroupConfig model msg) (List (FormValidation.Validation model))


type alias FormFieldGroupConfig model msg =
    { label : Label
    , fields : List (FormField model msg)
    }


{-| Represents the configuration of a single form field.
-}
type FormField model msg
    = FormField (FormFieldConfig model msg)


type FormFieldConfig model msg
    = FormFieldAutocompleteConfig (AutocompleteConfig model msg) (List (FormValidation.Validation model))
    | FormFieldCheckboxConfig (CheckboxConfig model msg) (List (FormValidation.Validation model))
    | FormFieldDatepickerConfig (DatepickerConfig model msg) (List (FormValidation.Validation model))
    | FormFieldPasswordConfig (PasswordConfig model msg) (List (FormValidation.Validation model))
    | FormFieldRadioConfig (RadioConfig model msg) (List (FormValidation.Validation model))
    | FormFieldSelectConfig (SelectConfig model msg) (List (FormValidation.Validation model))
    | FormFieldTextareaConfig (TextareaConfig model msg) (List (FormValidation.Validation model))
    | FormFieldTextConfig (TextConfig model msg) (List (FormValidation.Validation model))
    | FormFieldPureHtmlConfig (PureHtmlConfig msg)


{-| Represents the type of group which can wrap a form field.
Used to add a boxed icon in a form field (for instance the calendar icon of the datepicker).
-}
type InputGroup msg
    = Prepend (List (Html msg))
    | Append (List (Html msg))


type alias TextConfig model msg =
    { slug : Slug
    , label : Maybe Label
    , attrs : List (Attribute msg)
    , reader : model -> Maybe Value
    , events : List (Event msg)
    }


type alias PasswordConfig model msg =
    { slug : Slug
    , label : Maybe Label
    , attrs : List (Attribute msg)
    , reader : model -> Maybe Value
    , events : List (Event msg)
    }


type alias TextareaConfig model msg =
    { slug : Slug
    , label : Maybe Label
    , attrs : List (Attribute msg)
    , reader : model -> Maybe Value
    , events : List (Event msg)
    }


type alias RadioConfig model msg =
    { slug : Slug
    , label : Maybe Label
    , attrs : List (Attribute msg)
    , reader : model -> Maybe Value
    , events : List (Event msg)
    , options : List RadioOption
    }


type alias RadioOption =
    { label : Label
    , slug : Slug
    }


type alias CheckboxConfig model msg =
    { slug : Slug
    , label : Maybe Label
    , attrs : List (Attribute msg)
    , reader : model -> List ( Slug, Bool )
    , events : List (Event msg)
    , options : List CheckboxOption
    }


type alias CheckboxOption =
    { label : Label
    , slug : Slug
    , isChecked : Bool
    }


type alias SelectConfig model msg =
    { slug : Slug
    , label : Maybe Label
    , isDisabled : Bool
    , isOpen : Bool
    , placeholder : Maybe String
    , attrs : List (Attribute msg)
    , reader : model -> Maybe Value
    , events : List (Event msg)
    , options : List SelectOption
    }


type alias SelectOption =
    { label : Label
    , slug : Slug
    }


type alias DatepickerConfig model msg =
    { slug : Slug
    , label : Maybe Label
    , attrs : List (Attribute msg)
    , reader : model -> Maybe Value
    , datePickerTagger : DatePicker.Msg -> msg
    , events : List (Event msg)
    , instance : DatePicker.Model
    , showDatePicker : Bool
    }


type alias AutocompleteConfig model msg =
    { slug : Slug
    , label : Maybe Label
    , isOpen : Bool
    , noResults : Maybe Label
    , attrs : List (Attribute msg)
    , filterReader : model -> Maybe Value
    , choiceReader : model -> Maybe Value
    , events : List (Event msg)
    , options : List AutocompleteOption
    }


type alias AutocompleteOption =
    { label : Label
    , slug : Slug
    }


type alias PureHtmlConfig msg =
    { content : List (Html msg)
    }


{-| Alias for String. Useful to have easy-to-read signatures.
-}
type alias Slug =
    String


{-| Alias for String. Useful to have easy-to-read signatures.
-}
type alias Label =
    String


{-| Alias for String. Useful to have easy-to-read signatures.
-}
type alias Value =
    String


type RenderFieldMode
    = Group
    | Single


fieldGroup : FormFieldGroup model msg -> AbstractField model msg
fieldGroup =
    AbstractGroup


field : FormField model msg -> AbstractField model msg
field =
    AbstractField


{-| Returns the Form state
-}
state : Form model msg -> FormState
state (Form formConfig) =
    formConfig.state


{-| Checks if the Form is Submitted.
-}
isFormSubmitted : FormState -> Bool
isFormSubmitted =
    (==) Submitted


{-| Creates an empty, pristine form.
-}
init : Form model msg
init =
    Form (FormConfig NotSubmitted [])


{-| Add rows of fields to the form.

    --
    import Prima.Pyxis.Form as Form
    import Prima.Pyxis.Form.Event as Event
    import Prima.Pyxis.Form.Validation as PrimaFormValidation exposing (Validation(..), SeverityLevel(..), ValidationType(..))

    ...

    type alias Model =
        { data : FormData
        , form : Form FormData Msg
        }

    type alias FormData =
        { username : Maybe String
        }

    type Msg
        = UpdateUsername (Maybe String)

    ...

    usernameConfig : FormField FormData Msg
    usernameConfig =
        Form.textConfig
            "username"
            (Just "Username")
            [ minlength 3, maxlength 12 ]
            .username
            [ Event.onInput UpdateUsername ]
            [ NotEmpty (SeverityLevel Error) "Username must not be blank."
            ]

    ...

    view : Model -> Html Msg
    view ({ form, data } as model) =
        form
            |> Form.addFields [( Form.renderField form data, usernameConfig )]
            |> Form.render

-}
addField : FormField model msg -> Form model msg -> Form model msg
addField formField (Form ({ fields } as config)) =
    Form { config | fields = fields ++ [ AbstractField formField ] }


addFieldGroup : FormFieldGroup model msg -> Form model msg -> Form model msg
addFieldGroup formFieldGroup (Form ({ fields } as config)) =
    Form { config | fields = fields ++ [ AbstractGroup formFieldGroup ] }


{-| Sets the form to Submitted state. When submitted the form will eventually show errors.
-}
setAsSubmitted : Form model msg -> Form model msg
setAsSubmitted (Form config) =
    Form { config | state = Submitted }


{-| Renders a form with all it's fields.
Requires a `Form model msg` created via `Form.init` and `Form.addFields`.
-}
render : model -> Form model msg -> Html msg
render model ((Form { fields }) as formConfig) =
    let
        mapper : AbstractField model msg -> Html msg
        mapper abstractField =
            case abstractField of
                AbstractField formField ->
                    renderField formConfig model formField

                AbstractGroup formFieldGroup ->
                    renderFieldGroup formConfig model formFieldGroup
    in
    div [ class "m-form" ] (List.map mapper fields)


fieldGroupConfig : Label -> List (FormField model msg) -> List (FormValidation.Validation model) -> FormFieldGroup model msg
fieldGroupConfig label fields validations =
    FormFieldGroup (FormFieldGroupConfig label fields) validations


renderFieldGroup : Form model msg -> model -> FormFieldGroup model msg -> Html msg
renderFieldGroup formConfig model formFieldGroup =
    div
        [ classList
            [ ( "a-form__field-group", True )
            , ( "is-valid", fieldGroupIsValid model formFieldGroup )
            , ( "has-error", fieldGroupHasError model formFieldGroup )
            , ( "has-warning", fieldGroupHasWarning model formFieldGroup )
            ]
        ]
        [ renderFieldGroupLabel formFieldGroup
        , renderFieldGroupWrapper formConfig model formFieldGroup
        ]


renderFieldGroupLabel : FormFieldGroup model msg -> Html msg
renderFieldGroupLabel formFieldGroup =
    div
        [ class "a-form__field-group__label" ]
        [ text <| pickFieldGroupLabel formFieldGroup ]


renderFieldGroupFormFields : Form model msg -> model -> FormFieldGroup model msg -> Html msg
renderFieldGroupFormFields formConfig model formFieldGroup =
    div
        [ class "a-form__field-group__fields-list" ]
        (formFieldGroup
            |> pickFieldGroupFields
            |> List.map (renderFieldEngine Group formConfig model)
            |> List.concat
        )


renderFieldGroupWrapper : Form model msg -> model -> FormFieldGroup model msg -> Html msg
renderFieldGroupWrapper formConfig model formFieldGroup =
    div
        [ class "a-form__field-group__fields-wrapper" ]
        [ renderFieldGroupFormFields formConfig model formFieldGroup
        , formFieldGroup
            |> pickFieldGroupFields
            |> List.map pickFieldValidations
            |> List.concat
            |> List.append (pickFieldGroupValidations formFieldGroup)
            |> List.filter (not << Helpers.flip FormValidation.pickFunction model)
            |> renderFieldGroupValidationMessages model formFieldGroup
        ]


renderFieldGroupValidationMessages : model -> FormFieldGroup model msg -> List (FormValidation.Validation model) -> Html msg
renderFieldGroupValidationMessages model formFieldGroup allValidations =
    let
        filterType : FormValidation.ValidationType
        filterType =
            if fieldGroupHasError model formFieldGroup then
                FormValidation.Error

            else
                FormValidation.Warning
    in
    div
        [ class "a-form__field-group__validation-messages-list" ]
        (allValidations
            |> pickOnly filterType
            |> List.map FormValidation.pickValidationMessage
            |> List.map renderFieldGroupSingleValidationMessage
        )


renderFieldGroupSingleValidationMessage : String -> Html msg
renderFieldGroupSingleValidationMessage message =
    span [ class "a-form-field-group-validation-message-list__item" ] [ text message ]


{-| Represents an html which prepends to the form field.
-}
prependInputGroup : List (Html msg) -> InputGroup msg
prependInputGroup =
    Prepend


{-| Represents an html which appends to the form field.
-}
appendInputGroup : List (Html msg) -> InputGroup msg
appendInputGroup =
    Append


{-| Creates a radio option.
-}
radioOption : Label -> Slug -> RadioOption
radioOption =
    RadioOption


{-| Creates a radio option.
-}
checkboxOption : Label -> Slug -> Bool -> CheckboxOption
checkboxOption =
    CheckboxOption


{-| Creates a select option.
-}
selectOption : Label -> Slug -> SelectOption
selectOption =
    SelectOption


{-| Creates an autocomplete option.
-}
autocompleteOption : Label -> Slug -> AutocompleteOption
autocompleteOption =
    AutocompleteOption


{-| Creates an input text field.
This field can handle only onInput, onFocus, onBlur events. Other events will be ignored.

    --
    import Prima.Pyxis.Form as Form exposing (FormField)
    import Prima.Pyxis.Form.Event as Event
    import Prima.Pyxis.Form.Validation as PrimaFormValidation exposing (Validation(..), SeverityLevel(..), ValidationType(..))

    ...

    type alias Msg
        = OnInput (Maybe String)
        | OnFocus
        | OnBlur

    type alias Model =
        { username : Maybe String }

    ...

    usernameConfig : FormField Model Msg
    usernameConfig =
        Form.textConfig
            "username"
            (Just "Username")
            [ minlength 3, maxlength 12 ]
            .username
            [ Event.onInput OnInput
            , Event.onFocus OnFocus
            , Event.onBlur OnBlur
            ]
            [ NotEmpty (SeverityLevel Error) "Empty value is not acceptable."
            ]

-}
textConfig : Slug -> Maybe Label -> List (Attribute msg) -> (model -> Maybe Value) -> List (Event msg) -> List (FormValidation.Validation model) -> FormField model msg
textConfig slug label attrs reader events validations =
    FormField <|
        FormFieldTextConfig
            (TextConfig
                slug
                label
                attrs
                reader
                events
            )
            validations


{-| Creates a password text field. Same configuration as `textConfig`.
-}
passwordConfig : Slug -> Maybe Label -> List (Attribute msg) -> (model -> Maybe Value) -> List (Event msg) -> List (FormValidation.Validation model) -> FormField model msg
passwordConfig slug label attrs reader events validations =
    FormField <|
        FormFieldPasswordConfig
            (PasswordConfig
                slug
                label
                attrs
                reader
                events
            )
            validations


{-| Creates a texarea field. Same configuration as `textConfig`.
-}
textareaConfig : Slug -> Maybe Label -> List (Attribute msg) -> (model -> Maybe Value) -> List (Event msg) -> List (FormValidation.Validation model) -> FormField model msg
textareaConfig slug label attrs reader events validations =
    FormField <|
        FormFieldTextareaConfig
            (TextareaConfig
                slug
                label
                attrs
                reader
                events
            )
            validations


{-| Creates a radio field.
This field can handle only onSelect event. Other events will be ignored.

    --
    import Prima.Pyxis.Form as Form exposing (FormField, RadioOption)
    import Prima.Pyxis.Form.Event as Event

    ...

    type alias Msg
        = OnSelect (Maybe String)

    type alias Model =
        { gender : Maybe String }

    ...

    genderConfig : FormField Model Msg
    genderConfig =
        let
            options : List RadioOption
            options =
                [ Form.radioOption "Male" "male", Form.radioOption "Female", "female" ]
        in
        Form.radioConfig
            "gender"
            (Just "Gender")
            []
            .gender
            [ Event.onSelect OnSelect ]
            options
            []

-}
radioConfig : Slug -> Maybe Label -> List (Attribute msg) -> (model -> Maybe Value) -> List (Event msg) -> List RadioOption -> List (FormValidation.Validation model) -> FormField model msg
radioConfig slug label attrs reader events options validations =
    FormField <|
        FormFieldRadioConfig
            (RadioConfig
                slug
                label
                attrs
                reader
                events
                options
            )
            validations


{-| Creates a checkbox field.
This field can handle only onCheck event. Other events will be ignored.

    --
    import Prima.Pyxis.Form as Form exposing (FormField, Label, Slug, CheckboxOption)
    import Prima.Pyxis.Form.Event as Event
    import Prima.Pyxis.Form.Validation as PrimaFormValidation exposing (Validation(..), SeverityLevel(..), ValidationType(..))

    ...

    type alias Msg
        = OnCheck ( Slug, Bool )

    type alias Model =
        { country : Maybe String
        , countries: List (Label, Slug, Bool)
        }

    ...

    countries : Model -> FormField Model Msg
    countries model =
        let
            reader : (Model -> List (Slug, Bool))
            reader =
                (List.map (\( _, slug, checked ) -> ( slug, checked )) << .countries)

            options : List CheckboxOption
            options =
                List.map (( label, slug, isChecked ) -> Form.checkboxOption label slug isChecked) model.countries
        in
        Form.checkboxConfig
            "countries"
            (Just "Countries")
            []
            reader
            [ Event.onCheck OnCheck ]
            options
            []

-}
checkboxConfig : Slug -> Maybe Label -> List (Attribute msg) -> (model -> List ( Slug, Bool )) -> List (Event msg) -> List CheckboxOption -> List (FormValidation.Validation model) -> FormField model msg
checkboxConfig slug label attrs reader events options validations =
    FormField <|
        FormFieldCheckboxConfig
            (CheckboxConfig
                slug
                label
                attrs
                reader
                events
                options
            )
            validations


{-| Creates a select field. This field is a custom component on desktop devices. It fallbacks to a
native `Html Select` tag on mobile devices.
Infact we need to express `isDisabled` flag as an `Html Attribute` and also as a parameter for this method.

This field can handle only onToggle, onInput, onSelect, onFocus and onBlur events. Other events will be ignored.

    --
    import Prima.Pyxis.Form as Form exposing (FormField, Label, Slug, SelectOption)
    import Prima.Pyxis.Form.Event as Event
    import Html.Attributes
    ...

    type alias Msg
        = OnInput (Maybe String)
        | OnToggle
        | OnSelect (Maybe String)
        | OnFocus
        | OnBlur

    type alias Model =
        { city : Maybe String
        , isOpen : Bool
        , isDisabled : Bool
        }

    ...

    cities : Model -> FormField Model Msg
    cities model =
        let
            options : List SelectOption
            options =
                [ Form.selectOption "Milan" "MI", Form.selectOption "Turin" "TO", Form.selectOption "Rome" "RO" ]
        in
        Form.selectConfig
            "city"
            (Just "City")
            model.isDisabled
            model.isOpen
            (Just "Select a city")
            [ Html.Attributes.disabled model.isDisabled ]
            .city
            [ Event.onToggle OnToggle, Event.onInput OnInput, Event.onSelect OnSelect, Event.onFocus, Event.onBlur ]
            options
            [ NotEmpty (SeverityLevel Error) "Empty value is not acceptable." ]

-}
selectConfig : Slug -> Maybe Label -> Bool -> Bool -> Maybe String -> List (Attribute msg) -> (model -> Maybe Value) -> List (Event msg) -> List SelectOption -> List (FormValidation.Validation model) -> FormField model msg
selectConfig slug label isDisabled isOpen placeholder attrs reader events options validations =
    FormField <|
        FormFieldSelectConfig
            (SelectConfig
                slug
                label
                isDisabled
                isOpen
                placeholder
                attrs
                reader
                events
                options
            )
            validations


{-| Creates a datepicker field.
This field can handle only onInput event. Other events will be ignored.

    --
    import Prima.Pyxis.Form as Form exposing (FormField)
    import Prima.Pyxis.Form.Event as Event
    import Prima.Pyxis.DatePicker as DatePicker
    ...

    type alias Msg
        = OnInput (Maybe String)
        | OnDatePickerChange DatePicker.Msg

    type alias Model =
        { datePicker : DatePicker.Model
        , birthDate : Maybe String
        , isDatePickerOpen : Bool
        }

    ...

    dateOfBirth : Model -> FormField Model Msg
    dateOfBirth model =
        Form.datepickerConfig
            "birthdate"
            (Just "Date of Birth")
            []
            .birthDate
            OnDatePickerChange
            [ Event.onInput OnInput ]
            model.datePicker
            model.isDatePickerOpen
            []

-}
datepickerConfig : Slug -> Maybe Label -> List (Attribute msg) -> (model -> Maybe Value) -> (DatePicker.Msg -> msg) -> List (Event msg) -> DatePicker.Model -> Bool -> List (FormValidation.Validation model) -> FormField model msg
datepickerConfig slug label attrs reader datePickerTagger events datepicker showDatePicker validations =
    FormField <|
        FormFieldDatepickerConfig
            (DatepickerConfig
                slug
                label
                attrs
                reader
                datePickerTagger
                events
                datepicker
                showDatePicker
            )
            validations


{-| Creates an autocomplete field.
This field can handle only onSelect, onAutocompleteFilter, onFocus and onBlur events. Other events will be ignored.

    --
    import Prima.Pyxis.Form as Form exposing (FormField)
    import Prima.Pyxis.Form.Event as Event
    import Tuple
    ...

    type alias Msg
        = OnSelect (Maybe String)
        | OnFilter (Maybe String)

    type alias Model =
        { empireFilter : Maybe String
        , empire : Maybe String
        , isOpen : Bool
        }

    ...

    empire : Model -> FormField Model Msg
    empire model =
        let
            filter : String
            filter =
                Maybe.withDefault "" model.empireFilter

            options : List AutocompleteOption
            options =
                [ ("Roman Empire", "roman")
                , ("Ottoman Empire", "ottoman")
                , ("French Empire", "french")
                , ("British Empire", "british")
                ]
                |> List.filter (String.contains filter << Tuple.first)
                |> List.map (\(label, slug) -> Form.autocompleteOption label slug)
        in
        Form.autocompleteConfig
            "empire"
            (Just "empire")
            model.isOpen
            (Just "No results")
            []
            .empireFilter
            .empire
            [ Event.onAutocompleteFilter OnFilter, Event.onSelect OnSelect ]
            options
            []

-}
autocompleteConfig : String -> Maybe String -> Bool -> Maybe String -> List (Attribute msg) -> (model -> Maybe Value) -> (model -> Maybe Value) -> List (Event msg) -> List AutocompleteOption -> List (FormValidation.Validation model) -> FormField model msg
autocompleteConfig slug label isOpen noResults attrs filterReader choiceReader events options validations =
    FormField <|
        FormFieldAutocompleteConfig
            (AutocompleteConfig
                slug
                label
                isOpen
                noResults
                attrs
                filterReader
                choiceReader
                events
                options
            )
            validations


{-| Creates a pure html field. No events accepeted.

    --
    import Prima.Pyxis.Form as Form exposing (FormField)

    ...

    loremIpsum : FormField Model Msg
    loremIpsum =
        Form.pureHtmlConfig [ text "Lorem ipsum dolor sit amet" ]

-}
pureHtmlConfig : List (Html msg) -> FormField model msg
pureHtmlConfig content =
    FormField <|
        FormFieldPureHtmlConfig
            (PureHtmlConfig
                content
            )


{-| Renders a field by receiving the `Form` and the `FormField` configuration.

    --
    import Html exposing (Html)
    import Prima.Pyxis.Form as Form exposing (Form, FormField)
    import FieldConfig exposing (usernameConfig)

    ...

    type Msg
        = OnInput (Maybe String)

    type alias Model =
        { form : Form FormData Msg
        , data : FormData
        }

    type alias FormData =
        { username: Maybe String
        }

    ...

    view : Model -> Html Msg
    view model =
        ( Form.renderField model.form model.data, [ usernameConfig ] )
            |> Form.render model.form

-}
renderField : Form model msg -> model -> FormField model msg -> Html msg
renderField formConfig model formField =
    wrapper
        (renderFieldEngine Single formConfig model formField)


isRenderFieldGroup : RenderFieldMode -> Bool
isRenderFieldGroup =
    (==) Group


isRenderFieldSingle : RenderFieldMode -> Bool
isRenderFieldSingle =
    (==) Single


renderFieldEngine : RenderFieldMode -> Form model msg -> model -> FormField model msg -> List (Html msg)
renderFieldEngine mode (Form formConfig) model ((FormField opaqueConfig) as formField) =
    let
        lbl config =
            if isRenderFieldSingle mode then
                renderLabel config.slug config.label

            else
                text ""
    in
    (case opaqueConfig of
        FormFieldTextConfig config validation ->
            lbl config :: renderInput formConfig.state model config validation

        FormFieldPasswordConfig config validation ->
            lbl config :: renderPassword formConfig.state model config validation

        FormFieldTextareaConfig config validation ->
            lbl config :: renderTextarea formConfig.state model config validation

        FormFieldRadioConfig config validation ->
            lbl config :: renderRadio model config validation

        FormFieldCheckboxConfig config validation ->
            lbl config :: renderCheckbox model config validation

        FormFieldSelectConfig config validation ->
            lbl config :: renderSelect formConfig.state model config validation

        FormFieldDatepickerConfig config validation ->
            lbl config :: renderDatepicker formConfig.state model config validation

        FormFieldAutocompleteConfig config validation ->
            lbl config :: renderAutocomplete formConfig.state model config validation

        FormFieldPureHtmlConfig config ->
            renderPureHtml config
    )
        ++ (case ( mode, fieldHasError model formField, fieldHasWarning model formField ) of
                ( Single, True, _ ) ->
                    formField
                        |> pickFieldValidations
                        |> List.filter (FormValidation.isError << FormValidation.pickType)
                        |> List.map FormValidation.pickValidationMessage
                        |> List.map renderFieldValidationMessage

                ( Single, False, True ) ->
                    formField
                        |> pickFieldValidations
                        |> List.filter (FormValidation.isWarning << FormValidation.pickType)
                        |> List.map FormValidation.pickValidationMessage
                        |> List.map renderFieldValidationMessage

                ( _, _, _ ) ->
                    []
           )


{-| Renders a field by receiving the `Form`, the `InputGroup`, and the `FormField` configuration.
Useful to build a field with an icon to the left (prepend), or to the right (append).
You can pass any html to this function, but be careful, UI can be broken.

    --
    import Html exposing (Html, i)
    import Html.Attributes exposing (class)
    import Html.Events exposing (onClick)
    import Prima.Pyxis.Form as Form exposing (Form, FormField)
    import FieldConfig exposing (datePickerConfig)

    ...

    type Msg
        = ToggleDatePicker

    type alias Model =
        { form : Form FormData Msg
        , data : FormData
        }

    type alias FormData =
        { birthDate: Maybe String
        }

    ...

    datePickerIcon : Html Msg
    datePickerIcon =
        i
            [ class "a-icon a-icon-calendar cBrandAltDark"
            , onClick ToggleDatePicker
            ]

    view : Model -> Html Msg
    view model =
        ( Form.renderInputGroupField model.form model.data <| Form.appendInputGroup [ datePickerIcon ], [ datePickerConfig ] )
            |> Form.render model.form

-}
renderInputGroupField : Form model msg -> model -> InputGroup msg -> FormField model msg -> List (Html msg)
renderInputGroupField (Form formConfig) model group (FormField opaqueConfig) =
    let
        lbl config =
            renderLabel config.slug config.label

        errors =
            []
    in
    case opaqueConfig of
        FormFieldTextConfig config validation ->
            [ lbl config
            , inputGroupWrapper group <| (renderInput formConfig.state model config validation ++ errors)
            ]

        FormFieldPasswordConfig config validation ->
            [ lbl config
            , inputGroupWrapper group <| (renderPassword formConfig.state model config validation ++ errors)
            ]

        FormFieldTextareaConfig config validation ->
            [ lbl config
            , inputGroupWrapper group <| (renderInput formConfig.state model config validation ++ errors)
            ]

        FormFieldRadioConfig config validation ->
            [ lbl config
            , inputGroupWrapper group <| (renderRadio model config validation ++ errors)
            ]

        FormFieldCheckboxConfig config validation ->
            [ lbl config
            , inputGroupWrapper group <| (renderCheckbox model config validation ++ errors)
            ]

        FormFieldSelectConfig config validation ->
            [ lbl config
            , inputGroupWrapper group <| (renderSelect formConfig.state model config validation ++ errors)
            ]

        FormFieldDatepickerConfig config validation ->
            [ lbl config
            , inputGroupWrapper group <| (renderDatepicker formConfig.state model config validation ++ errors)
            ]

        FormFieldAutocompleteConfig config validation ->
            [ lbl config
            , inputGroupWrapper group <| (renderAutocomplete formConfig.state model config validation ++ errors)
            ]

        FormFieldPureHtmlConfig config ->
            renderPureHtml config


wrapper : List (Html msg) -> Html msg
wrapper =
    div
        [ class "a-form__field"
        ]


inputGroupWrapper : InputGroup msg -> List (Html msg) -> Html msg
inputGroupWrapper group content =
    div
        [ class "m-form__field__group" ]
        ((case group of
            Prepend groupContent ->
                inputGroupPrepend groupContent

            Append groupContent ->
                inputGroupAppend groupContent
         )
            :: content
        )


inputGroupPrepend : List (Html msg) -> Html msg
inputGroupPrepend =
    div
        [ class "m-form__field__group__prepend"
        ]


inputGroupAppend : List (Html msg) -> Html msg
inputGroupAppend =
    div
        [ class "m-form__field__group__append"
        ]


renderLabel : String -> Maybe String -> Html msg
renderLabel slug theLabel =
    case theLabel of
        Nothing ->
            text ""

        Just label ->
            Html.label
                [ for slug
                , class "a-form__field__label"
                ]
                [ text label
                ]


renderFieldValidationMessage : String -> Html msg
renderFieldValidationMessage validationMessage =
    span
        [ class "a-form-field-validation-message" ]
        [ text validationMessage ]


renderInput : FormState -> model -> TextConfig model msg -> List (FormValidation.Validation model) -> List (Html msg)
renderInput formState model ({ reader, slug, label, attrs } as config) validations =
    let
        formField =
            FormField (FormFieldTextConfig config validations)

        compute : (model -> FormField model msg -> Bool) -> Bool
        compute mapper =
            mapper model formField
    in
    [ Html.input
        ([ type_ "text"
         , (value << Maybe.withDefault "" << reader) model
         , id slug
         , name slug
         , classList
            [ ( "a-form__field__input", True )
            , ( "is-valid", compute fieldIsValid )
            , ( "is-pristine", compute fieldIsPristine )
            , ( "is-touched", compute fieldIsTouched )
            , ( "has-error", compute fieldHasError )
            , ( "has-warning", compute fieldHasWarning )
            ]
         ]
            ++ attrs
            ++ Events.onInputAttribute config.events
            ++ Events.onFocusAttribute config.events
            ++ Events.onBlurAttribute config.events
        )
        []
    ]


renderPassword : FormState -> model -> PasswordConfig model msg -> List (FormValidation.Validation model) -> List (Html msg)
renderPassword formState model ({ reader, slug, label, attrs } as config) validations =
    let
        formField =
            FormField (FormFieldPasswordConfig config validations)

        compute : (model -> FormField model msg -> Bool) -> Bool
        compute mapper =
            mapper model formField
    in
    [ Html.input
        ([ type_ "password"
         , (value << Maybe.withDefault "" << reader) model
         , id slug
         , name slug
         , classList
            [ ( "a-form__field__input", True )
            , ( "is-valid", compute fieldIsValid )
            , ( "is-pristine", compute fieldIsPristine )
            , ( "is-touched", compute fieldIsTouched )
            , ( "has-error", compute fieldHasError )
            , ( "has-warning", compute fieldHasWarning )
            ]
         ]
            ++ attrs
            ++ Events.onInputAttribute config.events
            ++ Events.onFocusAttribute config.events
            ++ Events.onBlurAttribute config.events
        )
        []
    ]


renderTextarea : FormState -> model -> TextareaConfig model msg -> List (FormValidation.Validation model) -> List (Html msg)
renderTextarea formState model ({ reader, slug, label, attrs, events } as config) validations =
    let
        formField =
            FormField (FormFieldTextareaConfig config validations)

        compute : (model -> FormField model msg -> Bool) -> Bool
        compute mapper =
            mapper model formField
    in
    [ Html.textarea
        ([ (value << Maybe.withDefault "" << reader) model
         , id slug
         , name slug
         , classList
            [ ( "a-form__field__textarea", True )
            , ( "is-valid", compute fieldIsValid )
            , ( "is-pristine", compute fieldIsPristine )
            , ( "is-touched", compute fieldIsTouched )
            , ( "has-error", compute fieldHasError )
            , ( "has-warning", compute fieldHasWarning )
            ]
         ]
            ++ attrs
            ++ Events.onInputAttribute config.events
            ++ Events.onFocusAttribute config.events
            ++ Events.onBlurAttribute config.events
        )
        []
    ]


renderRadio : model -> RadioConfig model msg -> List (FormValidation.Validation model) -> List (Html msg)
renderRadio model ({ slug, label, options } as config) validations =
    let
        isVertical =
            List.any (hasReachedCharactersLimit << .label) options

        hasReachedCharactersLimit str =
            String.length str >= 35
    in
    [ div
        [ classList
            [ ( "a-form__field__radioOptions", True )
            , ( "is-vertical", isVertical )
            ]
        ]
        ((List.concat << List.indexedMap (\index option -> renderRadioOption model config index option)) options)
    ]


renderRadioOption : model -> RadioConfig model msg -> Int -> RadioOption -> List (Html msg)
renderRadioOption model ({ reader, slug, label, options, attrs } as config) index option =
    let
        optionSlug =
            (String.join "_" << List.map (String.trim << String.toLower)) [ slug, option.slug ]
    in
    [ Html.input
        ([ type_ "radio"
         , value option.slug
         , id optionSlug
         , name slug
         , (checked << (==) option.slug << Maybe.withDefault "" << reader) model
         , classList
            [ ( "a-form__field__radio", True )
            ]
         ]
            ++ attrs
            ++ Events.onSelectAttribute option.slug config.events
        )
        []
    , Html.label
        [ for optionSlug
        , class "a-form__field__radio__label"
        ]
        [ text option.label
        ]
    ]


renderCheckbox : model -> CheckboxConfig model msg -> List (FormValidation.Validation model) -> List (Html msg)
renderCheckbox model ({ slug, label, options } as config) validations =
    (List.concat << List.indexedMap (\index option -> renderCheckboxOption model config index option)) options


renderCheckboxOption : model -> CheckboxConfig model msg -> Int -> CheckboxOption -> List (Html msg)
renderCheckboxOption model ({ reader, attrs } as config) index option =
    let
        slug =
            (String.join "_" << List.map (String.trim << String.toLower)) [ config.slug, option.slug ]
    in
    [ Html.input
        ([ type_ "checkbox"
         , value option.slug
         , id slug
         , name slug
         , classList
            [ ( "a-form__field__checkbox", True )
            ]
         ]
            ++ attrs
            ++ Events.onCheckAttribute option.slug (not option.isChecked) config.events
        )
        []
    , Html.label
        [ for slug
        , class "a-form__field__checkbox__label"
        ]
        [ text option.label
        ]
    ]


renderSelect : FormState -> model -> SelectConfig model msg -> List (FormValidation.Validation model) -> List (Html msg)
renderSelect formState model ({ slug, label, reader, attrs, events } as config) validations =
    let
        options =
            case ( config.placeholder, config.isOpen ) of
                ( Just placeholder, False ) ->
                    SelectOption placeholder "" :: config.options

                ( _, _ ) ->
                    config.options

        formField =
            FormField (FormFieldSelectConfig config validations)

        compute : (model -> FormField model msg -> Bool) -> Bool
        compute mapper =
            mapper model formField
    in
    [ renderCustomSelect formState model config validations
    , Html.select
        ([ id slug
         , name slug
         , classList
            [ ( "a-form__field__select", True )
            , ( "is-valid", compute fieldIsValid )
            , ( "is-pristine", compute fieldIsPristine )
            , ( "is-touched", compute fieldIsTouched )
            , ( "has-error", compute fieldHasError )
            , ( "has-warning", compute fieldHasWarning )
            ]
         ]
            ++ attrs
            ++ Events.onInputAttribute config.events
            ++ Events.onFocusAttribute config.events
            ++ Events.onBlurAttribute config.events
        )
        (List.map (renderSelectOption model config) options)
    ]


renderSelectOption : model -> SelectConfig model msg -> SelectOption -> Html msg
renderSelectOption model { reader, slug, label } option =
    Html.option
        [ value option.slug
        , (selected << (==) option.slug << Maybe.withDefault "" << reader) model
        ]
        [ text option.label
        ]


renderCustomSelect : FormState -> model -> SelectConfig model msg -> List (FormValidation.Validation model) -> Html msg
renderCustomSelect formState model ({ slug, label, reader, isDisabled, isOpen, attrs } as config) validations =
    let
        options =
            case ( config.placeholder, isOpen ) of
                ( Just placeholder, False ) ->
                    SelectOption placeholder "" :: config.options

                ( _, _ ) ->
                    config.options

        formField =
            FormField (FormFieldSelectConfig config validations)

        currentValue =
            options
                |> List.filter (\option -> ((==) option.slug << Maybe.withDefault "" << reader) model)
                |> List.map .label
                |> List.head
                |> Maybe.withDefault (Maybe.withDefault "" config.placeholder)

        compute : (model -> FormField model msg -> Bool) -> Bool
        compute mapper =
            mapper model formField
    in
    div
        ([ classList
            [ ( "a-form__field__customSelect", True )
            , ( "is-open", isOpen )
            , ( "is-disabled", isDisabled )
            , ( "is-valid", compute fieldIsValid )
            , ( "is-pristine", compute fieldIsPristine )
            , ( "is-touched", compute fieldIsTouched )
            , ( "has-error", compute fieldHasError )
            , ( "has-warning", compute fieldHasWarning )
            ]
         ]
            ++ attrs
            ++ Events.onFocusAttribute config.events
            ++ Events.onBlurAttribute config.events
        )
        [ span
            ([ class "a-form__field__customSelect__status"
             ]
                ++ Events.onToggleAttribute config.events
            )
            [ text currentValue
            ]
        , ul
            [ class "a-form__field__customSelect__list" ]
            (List.indexedMap
                (\index option ->
                    renderCustomSelectOption model config option
                )
                options
            )
        ]


renderCustomSelectOption : model -> SelectConfig model msg -> SelectOption -> Html msg
renderCustomSelectOption model ({ reader, slug, label } as config) option =
    li
        ([ classList
            [ ( "a-form__field__customSelect__list__item", True )
            , ( "is-selected", ((==) option.slug << Maybe.withDefault "" << reader) model )
            ]
         ]
            ++ Events.onSelectAttribute option.slug config.events
        )
        [ text option.label
        ]


renderDatepicker : FormState -> model -> DatepickerConfig model msg -> List (FormValidation.Validation model) -> List (Html msg)
renderDatepicker formState model ({ attrs, reader, datePickerTagger, slug, label, instance, showDatePicker, events } as config) validations =
    let
        formField =
            FormField (FormFieldDatepickerConfig config validations)

        inputTextFormat str =
            (String.join "/"
                << List.reverse
                << String.split "-"
            )
                str

        inputDateFormat str =
            (String.join "-"
                << List.reverse
                << String.split "/"
            )
                str

        compute : (model -> FormField model msg -> Bool) -> Bool
        compute mapper =
            mapper model formField
    in
    [ Html.input
        ([ type_ "text"
         , (value << Maybe.withDefault "" << Maybe.map inputTextFormat << reader) model
         , id slug
         , name slug
         , classList
            [ ( "a-form__field__input a-form__field__datepicker", True )
            , ( "is-valid", compute fieldIsValid )
            , ( "is-pristine", compute fieldIsPristine )
            , ( "is-touched", compute fieldIsTouched )
            , ( "has-error", compute fieldHasError )
            , ( "has-warning", compute fieldHasWarning )
            ]
         ]
            ++ attrs
        )
        []
    , (Helpers.renderIf showDatePicker << Html.map datePickerTagger << DatePicker.view) instance
    , Html.input
        ([ attribute "type" "date"
         , (value << Maybe.withDefault "" << Maybe.map inputDateFormat << reader) model
         , id slug
         , name slug
         , classList
            [ ( "a-form__field__date", True )
            , ( "is-valid", compute fieldIsValid )
            , ( "is-pristine", compute fieldIsPristine )
            , ( "is-touched", compute fieldIsTouched )
            , ( "has-error", compute fieldHasError )
            , ( "has-warning", compute fieldHasWarning )
            ]
         ]
            ++ attrs
        )
        []
    ]


renderAutocomplete : FormState -> model -> AutocompleteConfig model msg -> List (FormValidation.Validation model) -> List (Html msg)
renderAutocomplete formState model ({ filterReader, choiceReader, slug, label, isOpen, noResults, attrs, options } as config) validations =
    let
        formField =
            FormField (FormFieldAutocompleteConfig config validations)

        pickLabelByValue opts value =
            (List.head << List.map .label << List.filter ((==) value << .slug)) opts

        valueAttr =
            case
                ( choiceReader model
                , choiceReader model == filterReader model
                , isOpen
                )
            of
                ( Just currentValue, False, False ) ->
                    (value << Maybe.withDefault "" << pickLabelByValue options) currentValue

                _ ->
                    (value << Maybe.withDefault "" << filterReader) model

        compute : (model -> FormField model msg -> Bool) -> Bool
        compute mapper =
            mapper model formField
    in
    [ div
        [ classList
            [ ( "a-form__field__autocomplete", True )
            , ( "is-open", isOpen )
            ]
        ]
        [ Html.input
            ([ type_ "text"
             , valueAttr
             , id slug
             , name slug
             , classList
                [ ( "a-form__field__input", True )
                , ( "is-valid", compute fieldIsValid )
                , ( "is-pristine", compute fieldIsPristine )
                , ( "is-touched", compute fieldIsTouched )
                , ( "has-error", compute fieldHasError )
                , ( "has-warning", compute fieldHasWarning )
                ]
             ]
                ++ attrs
                ++ Events.onAutocompleteFilterAttribute config.events
            )
            []
        , ul
            [ class "a-form__field__autocomplete__list" ]
            (if List.length options > 0 then
                List.indexedMap (\index option -> renderAutocompleteOption model config option) options

             else
                (List.singleton << renderAutocompleteNoResults model) config
            )
        ]
    ]


renderAutocompleteOption : model -> AutocompleteConfig model msg -> AutocompleteOption -> Html msg
renderAutocompleteOption model ({ choiceReader } as config) option =
    li
        ([ classList
            [ ( "a-form__field__autocomplete__list__item", True )
            , ( "is-selected", ((==) option.slug << Maybe.withDefault "" << choiceReader) model )
            ]
         ]
            ++ Events.onSelectAttribute option.slug config.events
        )
        [ text option.label
        ]


renderAutocompleteNoResults : model -> AutocompleteConfig model msg -> Html msg
renderAutocompleteNoResults model { noResults } =
    li
        [ class "a-form__field__autocomplete__list__noResults"
        ]
        [ (text << Maybe.withDefault "") noResults
        ]


renderPureHtml : PureHtmlConfig msg -> List (Html msg)
renderPureHtml { content } =
    content


shouldShowError : model -> FormField model msg -> Bool
shouldShowError model ((FormField opaqueConfig) as config) =
    True


shouldShowWarning : model -> FormField model msg -> Bool
shouldShowWarning model ((FormField opaqueConfig) as config) =
    True



{--
~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~ Helpers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~
--}


pickFieldGroupValidations : FormFieldGroup model msg -> List (FormValidation.Validation model)
pickFieldGroupValidations (FormFieldGroup _ validations) =
    validations


pickFieldGroupFields : FormFieldGroup model msg -> List (FormField model msg)
pickFieldGroupFields (FormFieldGroup { fields } _) =
    fields


pickFieldGroupLabel : FormFieldGroup model msg -> String
pickFieldGroupLabel (FormFieldGroup { label } _) =
    label


pickOnly : FormValidation.ValidationType -> List (FormValidation.Validation model) -> List (FormValidation.Validation model)
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
                |> List.any (not << Helpers.flip FormValidation.pickFunction model)

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
                |> List.any (not << Helpers.flip FormValidation.pickFunction model)

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
        |> List.all (Helpers.flip FormValidation.pickFunction model)


fieldHasError : model -> FormField model msg -> Bool
fieldHasError model formField =
    formField
        |> pickFieldValidations
        |> List.filter (FormValidation.isError << FormValidation.pickType)
        |> List.any (not << Helpers.flip FormValidation.pickFunction model)


fieldHasWarning : model -> FormField model msg -> Bool
fieldHasWarning model formField =
    formField
        |> pickFieldValidations
        |> List.filter (FormValidation.isWarning << FormValidation.pickType)
        |> List.any (not << Helpers.flip FormValidation.pickFunction model)


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


fieldIsTouched : model -> FormField model msg -> Bool
fieldIsTouched model formField =
    not <| fieldIsPristine model formField
