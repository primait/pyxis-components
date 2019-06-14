module Prima.Pyxis.Form exposing
    ( Form, FormFieldGroup, FormRenderer, Label, Slug, Value, formRenderer
    , init, addFields, setAsPristine, setAsTouched, setAsSubmitted
    , FormField(..)
    , textConfig, passwordConfig, textareaConfig
    , checkboxConfig, checkboxOption
    , radioConfig, radioOption
    , selectConfig, selectOption
    , datepickerConfig
    , autocompleteConfig, autocompleteOption
    , pureHtmlConfig
    , isValid, isPristine
    , render, renderField, renderFieldWithGroup
    , prependGroup, appendGroup
    )

{-| Allows to create a Form and it's fields using predefined Html syntax.


# Form Configuration

@docs Form, FormFieldGroup, FormRenderer, Label, Slug, Value, formRenderer


# Form Configuration Helpers

@docs init, addFields, setAsPristine, setAsTouched, setAsSubmitted


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

@docs isValid, isPristine


# Render

@docs render, renderField, renderFieldWithGroup


# Render Helpers

@docs prependGroup, appendGroup

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
import Prima.Pyxis.Form.Validation as Validation exposing (Validation(..))
import Prima.Pyxis.Helpers as Helpers
import Regex


{-| Represents the `Form` configuration.
-}
type Form model msg
    = Form (FormConfig model msg)


type alias FormConfig model msg =
    { state : FormState
    , renderer : List (FormRenderer model msg)
    }


{-| A list in which each item represents a row of the form.
Each row has is own list of fields (`FormField model msg`) which
will be rendered by the mapper function (`FormField model msg -> List (Html msg)`).
-}
type alias FormRenderer model msg =
    ( FormField model msg -> List (Html msg), List (FormField model msg) )


{-| Utility function to create a FormRenderer instance
-}
formRenderer : (FormField model msg -> List (Html msg)) -> List (FormField model msg) -> FormRenderer model msg
formRenderer rendererFunc fields =
    ( rendererFunc, fields )


type FormState
    = Pristine
    | Touched
    | Submitted


isFormPristine : FormState -> Bool
isFormPristine =
    (==) Pristine


isFormTouched : FormState -> Bool
isFormTouched =
    (==) Touched


isFormSubmitted : FormState -> Bool
isFormSubmitted =
    (==) Submitted


{-| Creates an empty, pristine form.
-}
init : Form model msg
init =
    Form (FormConfig Pristine [])


{-| Add rows of fields to the form.

    --
    import Prima.Pyxis.Form as Form
    import Prima.Pyxis.Form.Event as Event

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
            [ NotEmpty "Username must not be blank."
            ]

    ...

    view : Model -> Html Msg
    view ({ form, data } as model) =
        form
            |> Form.addFields [( Form.renderField form data, usernameConfig )]
            |> Form.render

-}
addFields : List (FormRenderer model msg) -> Form model msg -> Form model msg
addFields renderer (Form config) =
    Form { config | renderer = renderer }


{-| Sets the form to Pristine state.
-}
setAsPristine : Form model msg -> Form model msg
setAsPristine (Form config) =
    Form { config | state = Pristine }


{-| Sets the form to Touched state.
-}
setAsTouched : Form model msg -> Form model msg
setAsTouched (Form config) =
    Form { config | state = Touched }


{-| Sets the form to Submitted state. When submitted the form will eventually show errors.
-}
setAsSubmitted : Form model msg -> Form model msg
setAsSubmitted (Form config) =
    Form { config | state = Submitted }


{-| Renders a form with all it's fields.
Requires a `Form model msg` created via `Form.init` and `Form.addFields`.
-}
render : Form model msg -> Html msg
render (Form { renderer }) =
    let
        renderWrappedFields : FormRenderer model msg -> Html msg
        renderWrappedFields ( mapper, fieldConfigs ) =
            (wrapper << List.concat << List.map mapper) fieldConfigs
    in
    form [] (List.map renderWrappedFields renderer)


{-| Represents the configuration of a single form field.
-}
type FormField model msg
    = FormField (FormFieldConfig model msg)


type FormFieldConfig model msg
    = FormFieldAutocompleteConfig (AutocompleteConfig model msg) (List (Validation model))
    | FormFieldCheckboxConfig (CheckboxConfig model msg) (List (Validation model))
    | FormFieldDatepickerConfig (DatepickerConfig model msg) (List (Validation model))
    | FormFieldPasswordConfig (PasswordConfig model msg) (List (Validation model))
    | FormFieldRadioConfig (RadioConfig model msg) (List (Validation model))
    | FormFieldSelectConfig (SelectConfig model msg) (List (Validation model))
    | FormFieldTextareaConfig (TextareaConfig model msg) (List (Validation model))
    | FormFieldTextConfig (TextConfig model msg) (List (Validation model))
    | FormFieldPureHtmlConfig (PureHtmlConfig msg)


{-| Represents the type of group which can wrap a form field.
Used to add a boxed icon in a form field (for instance the calendar icon of the datepicker).
-}
type FormFieldGroup msg
    = Prepend (List (Html msg))
    | Append (List (Html msg))


{-| Represents an html which prepends to the form field.
-}
prependGroup : List (Html msg) -> FormFieldGroup msg
prependGroup =
    Prepend


{-| Represents an html which appends to the form field.
-}
appendGroup : List (Html msg) -> FormFieldGroup msg
appendGroup =
    Append


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


{-| Creates a radio option.
-}
radioOption : Label -> Slug -> RadioOption
radioOption =
    RadioOption


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


{-| Creates a radio option.
-}
checkboxOption : Label -> Slug -> Bool -> CheckboxOption
checkboxOption =
    CheckboxOption


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


{-| Creates a select option.
-}
selectOption : Label -> Slug -> SelectOption
selectOption =
    SelectOption


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


{-| Creates an autocomplete option.
-}
autocompleteOption : Label -> Slug -> AutocompleteOption
autocompleteOption =
    AutocompleteOption


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


{-| Creates an input text field.
This field can handle only onInput, onFocus, onBlur events. Other events will be ignored.

    --
    import Prima.Pyxis.Form as Form exposing (FormField)
    import Prima.Pyxis.Form.Event as Event

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
            [ NotEmpty "Empty value is not acceptable."
            ]

-}
textConfig : Slug -> Maybe Label -> List (Attribute msg) -> (model -> Maybe Value) -> List (Event msg) -> List (Validation model) -> FormField model msg
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
passwordConfig : Slug -> Maybe Label -> List (Attribute msg) -> (model -> Maybe Value) -> List (Event msg) -> List (Validation model) -> FormField model msg
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
textareaConfig : Slug -> Maybe Label -> List (Attribute msg) -> (model -> Maybe Value) -> List (Event msg) -> List (Validation model) -> FormField model msg
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
radioConfig : Slug -> Maybe Label -> List (Attribute msg) -> (model -> Maybe Value) -> List (Event msg) -> List RadioOption -> List (Validation model) -> FormField model msg
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
checkboxConfig : Slug -> Maybe Label -> List (Attribute msg) -> (model -> List ( Slug, Bool )) -> List (Event msg) -> List CheckboxOption -> List (Validation model) -> FormField model msg
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
            [ NotEmpty "Empty value is not acceptable." ]

-}
selectConfig : Slug -> Maybe Label -> Bool -> Bool -> Maybe String -> List (Attribute msg) -> (model -> Maybe Value) -> List (Event msg) -> List SelectOption -> List (Validation model) -> FormField model msg
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
datepickerConfig : Slug -> Maybe Label -> List (Attribute msg) -> (model -> Maybe Value) -> (DatePicker.Msg -> msg) -> List (Event msg) -> DatePicker.Model -> Bool -> List (Validation model) -> FormField model msg
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
autocompleteConfig : String -> Maybe String -> Bool -> Maybe String -> List (Attribute msg) -> (model -> Maybe Value) -> (model -> Maybe Value) -> List (Event msg) -> List AutocompleteOption -> List (Validation model) -> FormField model msg
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
renderField : Form model msg -> model -> FormField model msg -> List (Html msg)
renderField (Form { state }) model (FormField opaqueConfig) =
    let
        lbl config =
            renderLabel config.slug config.label

        errors =
            (List.singleton
                << Helpers.renderIf (isFormSubmitted state && canShowError model (FormField opaqueConfig))
                << renderError
                << String.join " "
                << pickError model
            )
                opaqueConfig
    in
    (case opaqueConfig of
        FormFieldTextConfig config validation ->
            lbl config :: renderInput state model config validation

        FormFieldPasswordConfig config validation ->
            lbl config :: renderPassword state model config validation

        FormFieldTextareaConfig config validation ->
            lbl config :: renderTextarea state model config validation

        FormFieldRadioConfig config validation ->
            lbl config :: renderRadio model config validation

        FormFieldCheckboxConfig config validation ->
            lbl config :: renderCheckbox model config validation

        FormFieldSelectConfig config validation ->
            lbl config :: renderSelect state model config validation

        FormFieldDatepickerConfig config validation ->
            lbl config :: renderDatepicker state model config validation

        FormFieldAutocompleteConfig config validation ->
            lbl config :: renderAutocomplete state model config validation

        FormFieldPureHtmlConfig config ->
            renderPureHtml config
    )
        ++ errors


{-| Renders a field by receiving the `Form`, the `FormFieldGroup`, and the `FormField` configuration.
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
        ( Form.renderFieldWithGroup model.form model.data <| Form.appendGroup [ datePickerIcon ], [ datePickerConfig ] )
            |> Form.render model.form

-}
renderFieldWithGroup : Form model msg -> model -> FormFieldGroup msg -> FormField model msg -> List (Html msg)
renderFieldWithGroup (Form { state }) model group (FormField opaqueConfig) =
    let
        lbl config =
            renderLabel config.slug config.label

        errors =
            (List.singleton
                << Helpers.renderIf (isFormSubmitted state && canShowError model (FormField opaqueConfig))
                << renderError
                << String.join " "
                << pickError model
            )
                opaqueConfig
    in
    case opaqueConfig of
        FormFieldTextConfig config validation ->
            [ lbl config
            , groupWrapper group <| (renderInput state model config validation ++ errors)
            ]

        FormFieldPasswordConfig config validation ->
            [ lbl config
            , groupWrapper group <| (renderPassword state model config validation ++ errors)
            ]

        FormFieldTextareaConfig config validation ->
            [ lbl config
            , groupWrapper group <| (renderInput state model config validation ++ errors)
            ]

        FormFieldRadioConfig config validation ->
            [ lbl config
            , groupWrapper group <| (renderRadio model config validation ++ errors)
            ]

        FormFieldCheckboxConfig config validation ->
            [ lbl config
            , groupWrapper group <| (renderCheckbox model config validation ++ errors)
            ]

        FormFieldSelectConfig config validation ->
            [ lbl config
            , groupWrapper group <| (renderSelect state model config validation ++ errors)
            ]

        FormFieldDatepickerConfig config validation ->
            [ lbl config
            , groupWrapper group <| (renderDatepicker state model config validation ++ errors)
            ]

        FormFieldAutocompleteConfig config validation ->
            [ lbl config
            , groupWrapper group <| (renderAutocomplete state model config validation ++ errors)
            ]

        FormFieldPureHtmlConfig config ->
            renderPureHtml config


wrapper : List (Html msg) -> Html msg
wrapper =
    div
        [ class "a-form__field"
        ]


groupWrapper : FormFieldGroup msg -> List (Html msg) -> Html msg
groupWrapper group content =
    div
        [ class "m-form__field__group" ]
        ((case group of
            Prepend groupContent ->
                groupPrepend groupContent

            Append groupContent ->
                groupAppend groupContent
         )
            :: content
        )


groupPrepend : List (Html msg) -> Html msg
groupPrepend =
    div
        [ class "m-form__field__group__prepend"
        ]


groupAppend : List (Html msg) -> Html msg
groupAppend =
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


renderError : String -> Html msg
renderError error =
    if (String.isEmpty << String.trim) error then
        text ""

    else
        span
            [ class "a-form__field__error" ]
            [ text error ]


renderInput : FormState -> model -> TextConfig model msg -> List (Validation model) -> List (Html msg)
renderInput state model ({ reader, slug, label, attrs } as config) validations =
    let
        opaqueConfig =
            FormField (FormFieldTextConfig config validations)

        valid =
            isValid model opaqueConfig

        pristine =
            isPristine model opaqueConfig
    in
    [ Html.input
        ([ type_ "text"
         , (value << Maybe.withDefault "" << reader) model
         , id slug
         , name slug
         , classList
            [ ( "a-form__field__input", True )
            , ( "is-valid", valid )
            , ( "is-invalid", isFormSubmitted state && not valid )
            , ( "is-pristine", pristine )
            , ( "is-touched", not pristine )
            ]
         ]
            ++ attrs
            ++ Events.onInputAttribute config.events
            ++ Events.onFocusAttribute config.events
            ++ Events.onBlurAttribute config.events
        )
        []
    ]


renderPassword : FormState -> model -> PasswordConfig model msg -> List (Validation model) -> List (Html msg)
renderPassword state model ({ reader, slug, label, attrs } as config) validations =
    let
        opaqueConfig =
            FormField (FormFieldTextConfig config validations)

        valid =
            isValid model opaqueConfig

        pristine =
            isPristine model opaqueConfig
    in
    [ Html.input
        ([ type_ "password"
         , (value << Maybe.withDefault "" << reader) model
         , id slug
         , name slug
         , classList
            [ ( "a-form__field__input", True )
            , ( "is-valid", valid )
            , ( "is-invalid", isFormSubmitted state && not valid )
            , ( "is-pristine", pristine )
            , ( "is-touched", not pristine )
            ]
         ]
            ++ attrs
            ++ Events.onInputAttribute config.events
            ++ Events.onFocusAttribute config.events
            ++ Events.onBlurAttribute config.events
        )
        []
    ]


renderTextarea : FormState -> model -> TextareaConfig model msg -> List (Validation model) -> List (Html msg)
renderTextarea state model ({ reader, slug, label, attrs, events } as config) validations =
    let
        opaqueConfig =
            FormField (FormFieldTextareaConfig config validations)

        valid =
            isValid model opaqueConfig

        pristine =
            isPristine model opaqueConfig
    in
    [ Html.textarea
        ([ (value << Maybe.withDefault "" << reader) model
         , id slug
         , name slug
         , classList
            [ ( "a-form__field__textarea", True )
            , ( "is-valid", valid )
            , ( "is-invalid", isFormSubmitted state && not valid )
            , ( "is-pristine", pristine )
            , ( "is-touched", not pristine )
            ]
         ]
            ++ attrs
            ++ Events.onInputAttribute config.events
            ++ Events.onFocusAttribute config.events
            ++ Events.onBlurAttribute config.events
        )
        []
    ]


renderRadio : model -> RadioConfig model msg -> List (Validation model) -> List (Html msg)
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


renderCheckbox : model -> CheckboxConfig model msg -> List (Validation model) -> List (Html msg)
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


renderSelect : FormState -> model -> SelectConfig model msg -> List (Validation model) -> List (Html msg)
renderSelect state model ({ slug, label, reader, attrs, events } as config) validations =
    let
        options =
            case ( config.placeholder, config.isOpen ) of
                ( Just placeholder, False ) ->
                    SelectOption placeholder "" :: config.options

                ( _, _ ) ->
                    config.options

        opaqueConfig =
            FormField (FormFieldSelectConfig config validations)

        valid =
            isValid model opaqueConfig

        pristine =
            isPristine model opaqueConfig
    in
    [ renderCustomSelect state model config validations
    , Html.select
        ([ id slug
         , name slug
         , classList
            [ ( "a-form__field__select", True )
            , ( "is-valid", valid )
            , ( "is-invalid", isFormSubmitted state && not valid )
            , ( "is-pristine", pristine )
            , ( "is-touched", not pristine )
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


renderCustomSelect : FormState -> model -> SelectConfig model msg -> List (Validation model) -> Html msg
renderCustomSelect state model ({ slug, label, reader, isDisabled, isOpen, attrs } as config) validations =
    let
        options =
            case ( config.placeholder, isOpen ) of
                ( Just placeholder, False ) ->
                    SelectOption placeholder "" :: config.options

                ( _, _ ) ->
                    config.options

        opaqueConfig =
            FormField (FormFieldSelectConfig config validations)

        valid =
            isValid model opaqueConfig

        pristine =
            isPristine model opaqueConfig

        currentValue =
            options
                |> List.filter (\option -> ((==) option.slug << Maybe.withDefault "" << reader) model)
                |> List.map .label
                |> List.head
                |> Maybe.withDefault (Maybe.withDefault "" config.placeholder)
    in
    div
        ([ classList
            [ ( "a-form__field__customSelect", True )
            , ( "is-open", isOpen )
            , ( "is-valid", valid )
            , ( "is-invalid", isFormSubmitted state && not valid )
            , ( "is-pristine", pristine )
            , ( "is-touched", not pristine )
            , ( "is-disabled", isDisabled )
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


renderDatepicker : FormState -> model -> DatepickerConfig model msg -> List (Validation model) -> List (Html msg)
renderDatepicker state model ({ attrs, reader, datePickerTagger, slug, label, instance, showDatePicker, events } as config) validations =
    let
        opaqueConfig =
            FormField (FormFieldDatepickerConfig config validations)

        valid =
            isValid model opaqueConfig

        pristine =
            isPristine model opaqueConfig

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
    in
    [ Html.input
        ([ type_ "text"
         , (value << Maybe.withDefault "" << Maybe.map inputTextFormat << reader) model
         , id slug
         , name slug
         , classList
            [ ( "a-form__field__input a-form__field__datepicker", True )
            , ( "is-valid", valid )
            , ( "is-invalid", isFormSubmitted state && not valid )
            , ( "is-pristine", pristine )
            , ( "is-touched", not pristine )
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
            , ( "is-valid", valid )
            , ( "is-invalid", not valid )
            , ( "is-pristine", pristine )
            , ( "is-touched", not pristine )
            ]
         ]
            ++ attrs
        )
        []
    ]


renderAutocomplete : FormState -> model -> AutocompleteConfig model msg -> List (Validation model) -> List (Html msg)
renderAutocomplete state model ({ filterReader, choiceReader, slug, label, isOpen, noResults, attrs, options } as config) validations =
    let
        opaqueConfig =
            FormField (FormFieldAutocompleteConfig config validations)

        valid =
            isValid model opaqueConfig

        pristine =
            isPristine model opaqueConfig

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
                , ( "is-valid", valid )
                , ( "is-invalid", isFormSubmitted state && not valid )
                , ( "is-pristine", pristine )
                , ( "is-touched", not pristine )
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


{-| Check if a `FormField` is valid
-}
isValid : model -> FormField model msg -> Bool
isValid model (FormField opaqueConfig) =
    List.all (validate model opaqueConfig) (pickValidationRules opaqueConfig)


{-| Check if a `FormField` is pristine
-}
isPristine : model -> FormField model msg -> Bool
isPristine model (FormField opaqueConfig) =
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


validate : model -> FormFieldConfig model msg -> Validation model -> Bool
validate model config validation =
    let
        isEmpty : Maybe String -> Bool
        isEmpty =
            String.isEmpty << Maybe.withDefault ""
    in
    case ( validation, config ) of
        ( NotEmpty _, FormFieldTextConfig { reader } _ ) ->
            (not << isEmpty << reader) model

        ( NotEmpty _, FormFieldTextareaConfig { reader } _ ) ->
            (not << isEmpty << reader) model

        ( NotEmpty _, FormFieldPasswordConfig { reader } _ ) ->
            (not << isEmpty << reader) model

        ( NotEmpty _, FormFieldRadioConfig { reader } _ ) ->
            (not << isEmpty << reader) model

        ( NotEmpty _, FormFieldSelectConfig { reader } _ ) ->
            (not << isEmpty << reader) model

        ( NotEmpty _, FormFieldAutocompleteConfig { choiceReader } _ ) ->
            (not << isEmpty << choiceReader) model

        ( NotEmpty _, FormFieldDatepickerConfig { reader } _ ) ->
            (not << Helpers.isJust << reader) model

        ( NotEmpty _, FormFieldCheckboxConfig { reader } _ ) ->
            (List.any Tuple.second << reader) model

        ( Expression exp _, FormFieldTextConfig { reader } _ ) ->
            (Regex.contains exp << Maybe.withDefault "" << reader) model

        ( Expression exp _, FormFieldPasswordConfig { reader } _ ) ->
            (Regex.contains exp << Maybe.withDefault "" << reader) model

        ( Expression exp _, FormFieldTextareaConfig { reader } _ ) ->
            (Regex.contains exp << Maybe.withDefault "" << reader) model

        ( Expression exp _, FormFieldAutocompleteConfig { choiceReader } _ ) ->
            (Regex.contains exp << Maybe.withDefault "" << choiceReader) model

        ( Expression exp _, _ ) ->
            True

        ( Custom validator _, _ ) ->
            validator model

        ( _, FormFieldPureHtmlConfig _ ) ->
            True


pickValidationRules : FormFieldConfig model msg -> List (Validation model)
pickValidationRules opaqueConfig =
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

        FormFieldPureHtmlConfig config ->
            []


hasNotEmptyValidation : FormFieldConfig model msg -> Bool
hasNotEmptyValidation opaqueConfig =
    opaqueConfig
        |> pickValidationRules
        |> List.any
            (\validation ->
                case validation of
                    NotEmpty _ ->
                        True

                    _ ->
                        False
            )


pickError : model -> FormFieldConfig model msg -> List String
pickError model opaqueConfig =
    List.filterMap
        (\rule ->
            if validate model opaqueConfig rule then
                Nothing

            else
                (Just << Validation.pickError) rule
        )
        (pickValidationRules opaqueConfig)


canShowError : model -> FormField model msg -> Bool
canShowError model ((FormField opaqueConfig) as config) =
    (not << isValid model) config
        && ((not << isPristine model) config || hasNotEmptyValidation opaqueConfig)
