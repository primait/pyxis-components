module Prima.Pyxis.Form exposing
    ( Form, FormField, FormFieldConfig, Validation(..), FormFieldGroup, Event(..)
    , init, textConfig, passwordConfig, textareaConfig, checkboxConfig, CheckboxOption, checkboxWithOptionsConfig, SelectOption, selectConfig, RadioOption, radioConfig
    , AutocompleteOption
    , autocompleteConfig
    , datepickerConfig
    , pureHtmlConfig
    , render, renderField, renderFieldWithGroup, wrapper
    , isValid
    , isPristine
    , appendGroup, prependGroup, setAsPristine, setAsSubmitted, setAsTouched
    )

{-| Package to build a Form using [Prima Assicurazioni](https://www.prima.it)'s Design System.

In order to keep the configuration as simple as possible we decided to not allow
CSS classes to be changed, also forcing consistency in our ecosystem.


# Definition

@docs Form, FormField, FormFieldConfig, Validation, FormFieldGroup, Event


# Basic components configuration

@docs init, textConfig, passwordConfig, textareaConfig, checkboxConfig, CheckboxOption, checkboxWithOptionsConfig, SelectOption, selectConfig, RadioOption, radioConfig


# Custom components configuration

@docs AutocompleteOption
@docs autocompleteConfig

@docs datepickerConfig


# Static components configuration

@docs pureHtmlConfig


# Render a FormField

@docs render, renderField, renderFieldWithGroup, wrapper


# Check status of a FormField

@docs isValid

@docs isPristine

-}

--import Date exposing (Date, Day(..), Month(..))

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
import Html.Events
    exposing
        ( onBlur
        , onClick
        , onFocus
        , onInput
        )
import Prima.Pyxis.DatePicker as DatePicker
import Regex


type Form model msg
    = Form (FormConfig model msg)


type alias FormConfig model msg =
    { state : FormState
    , showErrors : Bool
    , renderModel : List (RenderModel model msg)
    }


type alias RenderModel model msg =
    ( FormField model msg -> List (Html msg), List (FormField model msg) )


type FormState
    = Pristine
    | Touched
    | Submitted


init : List (RenderModel model msg) -> Form model msg
init renderModel =
    Form (FormConfig Pristine False renderModel)


setAsPristine : Form model msg -> Form model msg
setAsPristine (Form config) =
    Form { config | state = Pristine }


setAsTouched : Form model msg -> Form model msg
setAsTouched (Form config) =
    Form { config | state = Touched }


setAsSubmitted : Form model msg -> Form model msg
setAsSubmitted (Form config) =
    Form { config | state = Submitted }


render : model -> Form model msg -> List (Html msg)
render model (Form { renderModel }) =
    renderModel
        |> List.map
            (\( renderer, fieldConfigs ) ->
                (wrapper << List.concat << List.map renderer) fieldConfigs
            )



--( FormField model msg -> List (Html msg), List (FormField model msg) )


{-| Defines a Field component for a generic form.
Opaque implementation.
-}
type FormField model msg
    = FormField (FormFieldConfig model msg)


{-| Defines a configuration for a Field component.
Opaque implementation.
-}
type FormFieldConfig model msg
    = FormFieldAutocompleteConfig (AutocompleteConfig model msg) (List (Validation model))
    | FormFieldCheckboxConfig (CheckboxConfig model msg) (List (Validation model))
    | FormFieldCheckboxWithOptionsConfig (CheckboxWithOptionsConfig model msg) (List (Validation model))
    | FormFieldDatepickerConfig (DatepickerConfig model msg) (List (Validation model))
    | FormFieldPasswordConfig (PasswordConfig model msg) (List (Validation model))
    | FormFieldRadioConfig (RadioConfig model msg) (List (Validation model))
    | FormFieldSelectConfig (SelectConfig model msg) (List (Validation model))
    | FormFieldTextareaConfig (TextareaConfig model msg) (List (Validation model))
    | FormFieldTextConfig (TextConfig model msg) (List (Validation model))
    | FormFieldPureHtmlConfig (PureHtmlConfig msg)


type Event msg
    = Focus msg
    | Blur msg


type FormFieldGroup msg
    = Prepend (List (Html msg))
    | Append (List (Html msg))


appendGroup : List (Html msg) -> FormFieldGroup msg
appendGroup =
    Append


prependGroup : List (Html msg) -> FormFieldGroup msg
prependGroup =
    Prepend


type alias TextConfig model msg =
    { slug : Slug
    , label : Maybe Label
    , attrs : List (Attribute msg)
    , reader : model -> Maybe Value
    , tagger : Maybe Value -> msg
    , events : List (Event msg)
    }


type alias PasswordConfig model msg =
    { slug : Slug
    , label : Maybe Label
    , attrs : List (Attribute msg)
    , reader : model -> Maybe Value
    , tagger : Maybe Value -> msg
    , events : List (Event msg)
    }


type alias TextareaConfig model msg =
    { slug : Slug
    , label : Maybe Label
    , attrs : List (Attribute msg)
    , reader : model -> Maybe Value
    , tagger : Maybe Value -> msg
    , events : List (Event msg)
    }


type alias RadioConfig model msg =
    { slug : Slug
    , label : Maybe Label
    , attrs : List (Attribute msg)
    , reader : model -> Maybe Value
    , tagger : Maybe Value -> msg
    , events : List (Event msg)
    , options : List RadioOption
    }


{-| Describes an option for a Radio

    [ RadioOption "Italy" "ita" True
    , RadioOption "France" "fra" False
    , RadioOption "Spain" "spa" True
    ]

-}
type alias RadioOption =
    { label : String
    , slug : Slug
    }


type alias CheckboxConfig model msg =
    { slug : Slug
    , label : Maybe Label
    , attrs : List (Attribute msg)
    , reader : model -> Bool
    , tagger : Bool -> msg
    , events : List (Event msg)
    }


type alias CheckboxWithOptionsConfig model msg =
    { slug : Slug
    , label : Maybe Label
    , attrs : List (Attribute msg)
    , reader : model -> List ( Value, Bool )
    , tagger : Value -> Bool -> msg
    , events : List (Event msg)
    , options : List CheckboxOption
    }


{-| Describes an option for a Checkbox

    [ CheckboxOption "Italy" "ita" True
    , CheckboxOption "France" "fra" False
    , CheckboxOption "Spain" "spa" True
    ]

-}
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
    , toggleTagger : Bool -> msg
    , optionTagger : Maybe Value -> msg
    , events : List (Event msg)
    , options : List SelectOption
    }


{-| Describes an option for a Select

    [ SelectOption "Italy" "ita"
    , SelectOption "France" "fra"
    ]

-}
type alias SelectOption =
    { label : String
    , slug : Slug
    }


type alias DatepickerConfig model msg =
    { slug : Slug
    , label : Maybe Label
    , attrs : List (Attribute msg)
    , reader : model -> Maybe Value
    , tagger : Maybe Value -> msg
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
    , filterTagger : Maybe Value -> msg
    , choiceTagger : Maybe Value -> msg
    , events : List (Event msg)
    , options : List AutocompleteOption
    }


{-| Describes an option for an Autocomplete

    [ AutocompleteOption "Italy" "ita"
    , AutocompleteOption "France" "fra"
    ]

-}
type alias AutocompleteOption =
    { label : Label
    , slug : Slug
    }


type alias PureHtmlConfig msg =
    { content : List (Html msg)
    }


type alias Slug =
    String


type alias Label =
    String


type alias Value =
    String


{-| Input Text configuration method.
-}
textConfig : Slug -> Maybe Label -> List (Attribute msg) -> (model -> Maybe Value) -> (Maybe Value -> msg) -> List (Event msg) -> List (Validation model) -> FormField model msg
textConfig slug label attrs reader tagger events validations =
    FormField <| FormFieldTextConfig (TextConfig slug label attrs reader tagger events) validations


{-| Input password configuration method. See `textConfig` for configuration options.
-}
passwordConfig : Slug -> Maybe Label -> List (Attribute msg) -> (model -> Maybe Value) -> (Maybe Value -> msg) -> List (Event msg) -> List (Validation model) -> FormField model msg
passwordConfig slug label attrs reader tagger events validations =
    FormField <| FormFieldPasswordConfig (PasswordConfig slug label attrs reader tagger events) validations


{-| Textarea configuration method. See `textConfig` for configuration options.
-}
textareaConfig : Slug -> Maybe Label -> List (Attribute msg) -> (model -> Maybe Value) -> (Maybe Value -> msg) -> List (Event msg) -> List (Validation model) -> FormField model msg
textareaConfig slug label attrs reader tagger events validations =
    FormField <| FormFieldTextareaConfig (TextareaConfig slug label attrs reader tagger events) validations


{-| Input Radio configuration method.
-}
radioConfig : Slug -> Maybe Label -> List (Attribute msg) -> (model -> Maybe Value) -> (Maybe Value -> msg) -> List (Event msg) -> List RadioOption -> List (Validation model) -> FormField model msg
radioConfig slug label attrs reader tagger events options validations =
    FormField <| FormFieldRadioConfig (RadioConfig slug label attrs reader tagger events options) validations


{-| Checkbox with single option configuration method.
-}
checkboxConfig : Slug -> Maybe Label -> List (Attribute msg) -> (model -> Bool) -> (Bool -> msg) -> List (Event msg) -> List (Validation model) -> FormField model msg
checkboxConfig slug label attrs reader tagger events validations =
    FormField <| FormFieldCheckboxConfig (CheckboxConfig slug label attrs reader tagger events) validations


{-| Checkbox with multiple option configuration method.
-}
checkboxWithOptionsConfig : Slug -> Maybe Label -> List (Attribute msg) -> (model -> List ( Slug, Bool )) -> (Slug -> Bool -> msg) -> List (Event msg) -> List CheckboxOption -> List (Validation model) -> FormField model msg
checkboxWithOptionsConfig slug label attrs reader tagger events options validations =
    FormField <| FormFieldCheckboxWithOptionsConfig (CheckboxWithOptionsConfig slug label attrs reader tagger events options) validations


{-| Select configuration method.
-}
selectConfig : Slug -> Maybe Label -> Bool -> Bool -> Maybe String -> List (Attribute msg) -> (model -> Maybe Value) -> (Bool -> msg) -> (Maybe Value -> msg) -> List (Event msg) -> List SelectOption -> List (Validation model) -> FormField model msg
selectConfig slug label isDisabled isOpen placeholder attrs reader toggleTagger optionTagger events options validations =
    FormField <| FormFieldSelectConfig (SelectConfig slug label isDisabled isOpen placeholder attrs reader toggleTagger optionTagger events options) validations


{-| Datepicker configuration method.
-}
datepickerConfig : Slug -> Maybe Label -> List (Attribute msg) -> (model -> Maybe Value) -> (Maybe Value -> msg) -> (DatePicker.Msg -> msg) -> List (Event msg) -> DatePicker.Model -> Bool -> List (Validation model) -> FormField model msg
datepickerConfig slug label attrs reader tagger datePickerTagger events datepicker showDatePicker validations =
    FormField <|
        FormFieldDatepickerConfig
            (DatepickerConfig
                slug
                label
                attrs
                reader
                tagger
                datePickerTagger
                events
                datepicker
                showDatePicker
            )
            validations


{-| Autocomplete configuration method.
-}
autocompleteConfig : String -> Maybe String -> Bool -> Maybe String -> List (Attribute msg) -> (model -> Maybe Value) -> (model -> Maybe Value) -> (Maybe Value -> msg) -> (Maybe Value -> msg) -> List (Event msg) -> List AutocompleteOption -> List (Validation model) -> FormField model msg
autocompleteConfig slug label isOpen noResults attrs filterReader choiceReader filterTagger choiceTagger events options validations =
    FormField <| FormFieldAutocompleteConfig (AutocompleteConfig slug label isOpen noResults attrs filterReader choiceReader filterTagger choiceTagger events options) validations


{-| Static Html configuration method.
-}
pureHtmlConfig : List (Html msg) -> FormField model msg
pureHtmlConfig content =
    FormField <| FormFieldPureHtmlConfig (PureHtmlConfig content)


{-| Method for rendering a `FormField`
-}
renderField : model -> FormField model msg -> List (Html msg)
renderField model (FormField opaqueConfig) =
    let
        errors =
            (List.singleton
                << renderIf (canShowError model (FormField opaqueConfig))
                << renderError
                << String.join " "
                << pickError model
            )
                opaqueConfig
    in
    (case opaqueConfig of
        FormFieldTextConfig config validation ->
            renderLabel config.slug config.label :: renderInput model config validation

        FormFieldPasswordConfig config validation ->
            renderLabel config.slug config.label :: renderPassword model config validation

        FormFieldTextareaConfig config validation ->
            renderLabel config.slug config.label :: renderTextarea model config validation

        FormFieldRadioConfig config validation ->
            renderLabel config.slug config.label :: renderRadio model config validation

        FormFieldCheckboxConfig config validation ->
            renderLabel config.slug config.label :: renderCheckbox model config validation

        FormFieldCheckboxWithOptionsConfig config validation ->
            renderLabel config.slug config.label :: renderCheckboxWithOptions model config validation

        FormFieldSelectConfig config validation ->
            renderLabel config.slug config.label :: renderSelect model config validation

        FormFieldDatepickerConfig config validation ->
            renderLabel config.slug config.label :: renderDatepicker model config validation

        FormFieldAutocompleteConfig config validation ->
            renderLabel config.slug config.label :: renderAutocomplete model config validation

        FormFieldPureHtmlConfig config ->
            renderPureHtml config
    )
        ++ errors


{-| Method for rendering a `FormField` adding a div which wraps the form field.
-}
renderFieldWithGroup : model -> FormFieldGroup msg -> FormField model msg -> List (Html msg)
renderFieldWithGroup model group (FormField opaqueConfig) =
    let
        errors =
            (List.singleton
                << renderIf (canShowError model (FormField opaqueConfig))
                << renderError
                << String.join " "
                << pickError model
            )
                opaqueConfig
    in
    case opaqueConfig of
        FormFieldTextConfig config validation ->
            [ renderLabel config.slug config.label
            , groupWrapper group <| (renderInput model config validation ++ errors)
            ]

        FormFieldPasswordConfig config validation ->
            [ renderLabel config.slug config.label
            , groupWrapper group <| (renderPassword model config validation ++ errors)
            ]

        FormFieldTextareaConfig config validation ->
            [ renderLabel config.slug config.label
            , groupWrapper group <| (renderInput model config validation ++ errors)
            ]

        FormFieldRadioConfig config validation ->
            [ renderLabel config.slug config.label
            , groupWrapper group <| (renderRadio model config validation ++ errors)
            ]

        FormFieldCheckboxConfig config validation ->
            [ renderLabel config.slug config.label
            , groupWrapper group <| (renderCheckbox model config validation ++ errors)
            ]

        FormFieldCheckboxWithOptionsConfig config validation ->
            [ renderLabel config.slug config.label
            , groupWrapper group <| (renderCheckboxWithOptions model config validation ++ errors)
            ]

        FormFieldSelectConfig config validation ->
            [ renderLabel config.slug config.label
            , groupWrapper group <| (renderSelect model config validation ++ errors)
            ]

        FormFieldDatepickerConfig config validation ->
            [ renderLabel config.slug config.label
            , groupWrapper group <| (renderDatepicker model config validation ++ errors)
            ]

        FormFieldAutocompleteConfig config validation ->
            [ renderLabel config.slug config.label
            , groupWrapper group <| (renderAutocomplete model config validation ++ errors)
            ]

        FormFieldPureHtmlConfig config ->
            renderPureHtml config


{-| Wrapper for a FormField rendered with `render` function.
-}
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


renderInput : model -> TextConfig model msg -> List (Validation model) -> List (Html msg)
renderInput model ({ reader, tagger, slug, label, attrs } as config) validations =
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
         , onInput (tagger << normalizeInput)
         , (value << Maybe.withDefault "" << reader) model
         , id slug
         , name slug
         , classList
            [ ( "a-form__field__input", True )
            , ( "is-valid", valid )
            , ( "is-invalid", not valid )
            , ( "is-pristine", pristine )
            , ( "is-touched", not pristine )
            ]
         ]
            ++ attrs
            ++ addEvents config.events
        )
        []
    ]


renderPassword : model -> PasswordConfig model msg -> List (Validation model) -> List (Html msg)
renderPassword model ({ reader, tagger, slug, label, attrs } as config) validations =
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
         , onInput (tagger << normalizeInput)
         , (value << Maybe.withDefault "" << reader) model
         , id slug
         , name slug
         , classList
            [ ( "a-form__field__input", True )
            , ( "is-valid", valid )
            , ( "is-invalid", not valid )
            , ( "is-pristine", pristine )
            , ( "is-touched", not pristine )
            ]
         ]
            ++ attrs
            ++ addEvents config.events
        )
        []
    ]


renderTextarea : model -> TextareaConfig model msg -> List (Validation model) -> List (Html msg)
renderTextarea model ({ reader, tagger, slug, label, attrs } as config) validations =
    let
        opaqueConfig =
            FormField (FormFieldTextareaConfig config validations)

        valid =
            isValid model opaqueConfig

        pristine =
            isPristine model opaqueConfig
    in
    [ Html.textarea
        ([ onInput (tagger << normalizeInput)
         , (value << Maybe.withDefault "" << reader) model
         , id slug
         , name slug
         , classList
            [ ( "a-form__field__textarea", True )
            , ( "is-valid", valid )
            , ( "is-invalid", not valid )
            , ( "is-pristine", pristine )
            , ( "is-touched", not pristine )
            ]
         ]
            ++ attrs
            ++ addEvents config.events
        )
        []
    ]


renderRadio : model -> RadioConfig model msg -> List (Validation model) -> List (Html msg)
renderRadio model ({ slug, label, options } as config) validations =
    let
        opaqueConfig =
            FormField (FormFieldRadioConfig config validations)

        valid =
            isValid model opaqueConfig

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
renderRadioOption model ({ reader, tagger, slug, label, options, attrs } as config) index option =
    let
        optionSlug =
            (String.join "_" << List.map (String.trim << String.toLower)) [ slug, option.slug ]
    in
    [ Html.input
        ([ type_ "radio"

         {--IE 11 does not behave correctly with onInput --}
         , (onClick << tagger << normalizeInput << .slug) option
         , value option.slug
         , id optionSlug
         , name slug
         , (checked << (==) option.slug << Maybe.withDefault "" << reader) model
         , classList
            [ ( "a-form__field__radio", True )
            ]
         ]
            ++ attrs
            ++ addEvents config.events
        )
        []
    , Html.label
        [ for optionSlug
        , class "a-form__field__radio__label"
        ]
        [ text option.label
        ]
    ]


boolToString : Bool -> String
boolToString v =
    if v then
        "y"

    else
        "n"


renderCheckbox : model -> CheckboxConfig model msg -> List (Validation model) -> List (Html msg)
renderCheckbox model ({ reader, tagger, slug, label, attrs } as config) validations =
    let
        opaqueConfig =
            FormField (FormFieldCheckboxConfig config validations)

        valid =
            isValid model opaqueConfig
    in
    [ Html.input
        ([ type_ "checkbox"
         , (onClick << tagger << not << reader) model
         , (checked << reader) model
         , (value << boolToString << reader) model
         , id slug
         , name slug
         , classList
            [ ( "a-form__field__checkbox", True )
            ]
         ]
            ++ attrs
            ++ addEvents config.events
        )
        []
    , Html.label
        [ for slug
        , class "a-form__field__checkbox__label"
        ]
        [ text " "
        ]
    ]


renderCheckboxWithOptions : model -> CheckboxWithOptionsConfig model msg -> List (Validation model) -> List (Html msg)
renderCheckboxWithOptions model ({ slug, label, options } as config) validations =
    let
        opaqueConfig =
            FormField (FormFieldCheckboxWithOptionsConfig config validations)

        valid =
            isValid model opaqueConfig
    in
    (List.concat << List.indexedMap (\index option -> renderCheckboxOption model config index option)) options


renderCheckboxOption : model -> CheckboxWithOptionsConfig model msg -> Int -> CheckboxOption -> List (Html msg)
renderCheckboxOption model ({ reader, tagger, attrs } as config) index option =
    let
        slug =
            (String.join "_" << List.map (String.trim << String.toLower)) [ config.slug, option.slug ]
    in
    [ Html.input
        ([ type_ "checkbox"
         , (onClick << tagger option.slug << not) option.isChecked
         , value option.slug
         , id slug
         , name slug
         , classList
            [ ( "a-form__field__checkbox", True )
            ]
         ]
            ++ attrs
            ++ addEvents config.events
        )
        []
    , Html.label
        [ for slug
        , class "a-form__field__checkbox__label"
        ]
        [ text option.label
        ]
    ]


renderSelect : model -> SelectConfig model msg -> List (Validation model) -> List (Html msg)
renderSelect model ({ slug, label, reader, optionTagger, attrs } as config) validations =
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
    [ renderCustomSelect model config validations
    , Html.select
        ([ onInput (optionTagger << normalizeInput)
         , id slug
         , name slug
         , classList
            [ ( "a-form__field__select", True )
            , ( "is-valid", valid )
            , ( "is-invalid", not valid )
            , ( "is-pristine", pristine )
            , ( "is-touched", not pristine )
            ]
         ]
            ++ attrs
            ++ addEvents config.events
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


renderCustomSelect : model -> SelectConfig model msg -> List (Validation model) -> Html msg
renderCustomSelect model ({ slug, label, reader, toggleTagger, isDisabled, isOpen, attrs } as config) validations =
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
            , ( "is-invalid", not valid )
            , ( "is-pristine", pristine )
            , ( "is-touched", not pristine )
            , ( "is-disabled", isDisabled )
            ]
         ]
            ++ attrs
            ++ addEvents config.events
        )
        [ span
            [ class "a-form__field__customSelect__status"
            , (onClick << toggleTagger << not) isOpen
            ]
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
renderCustomSelectOption model { reader, optionTagger, slug, label } option =
    li
        [ classList
            [ ( "a-form__field__customSelect__list__item", True )
            , ( "is-selected", ((==) option.slug << Maybe.withDefault "" << reader) model )
            ]
        , (onClick << optionTagger << normalizeInput) option.slug
        ]
        [ text option.label
        ]


renderDatepicker : model -> DatepickerConfig model msg -> List (Validation model) -> List (Html msg)
renderDatepicker model ({ attrs, reader, tagger, datePickerTagger, slug, label, instance, showDatePicker } as config) validations =
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
         , onInput (tagger << normalizeInput)
         , (value << Maybe.withDefault "" << Maybe.map inputTextFormat << reader) model
         , id slug
         , name slug
         , classList
            [ ( "a-form__field__input a-form__field__datepicker", True )
            , ( "is-valid", valid )
            , ( "is-invalid", not valid )
            , ( "is-pristine", pristine )
            , ( "is-touched", not pristine )
            ]
         ]
            ++ attrs
            ++ addEvents config.events
        )
        []
    , (renderIf showDatePicker << Html.map datePickerTagger << DatePicker.view) instance
    , Html.input
        ([ attribute "type" "date"
         , onInput (tagger << normalizeInput)
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
            ++ addEvents config.events
        )
        []
    ]


renderAutocomplete : model -> AutocompleteConfig model msg -> List (Validation model) -> List (Html msg)
renderAutocomplete model ({ filterReader, filterTagger, choiceReader, choiceTagger, slug, label, isOpen, noResults, attrs, options } as config) validations =
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
             , onInput (filterTagger << normalizeInput)
             , valueAttr
             , id slug
             , name slug
             , classList
                [ ( "a-form__field__input", True )
                , ( "is-valid", valid )
                , ( "is-invalid", not valid )
                , ( "is-pristine", pristine )
                , ( "is-touched", not pristine )
                ]
             ]
                ++ attrs
                ++ addEvents config.events
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
renderAutocompleteOption model ({ choiceReader, choiceTagger } as config) option =
    li
        [ classList
            [ ( "a-form__field__autocomplete__list__item", True )
            , ( "is-selected", ((==) option.slug << Maybe.withDefault "" << choiceReader) model )
            ]
        , (onClick << choiceTagger << normalizeInput) option.slug
        ]
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


addEvents : List (Event msg) -> List (Attribute msg)
addEvents =
    List.map
        (\event ->
            case event of
                Focus tagger ->
                    onFocus tagger

                Blur tagger ->
                    onBlur tagger
        )


{-| Validation rules for a FormField.

    NotEmpty "This field cannot be empty."

    Expression (Regex.regex "^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$") "Insert a valid email."

    Custom (\model -> always True) "This error message will never be shown."

-}
type Validation model
    = NotEmpty String
    | Expression Regex.Regex String
    | Custom (model -> Bool) String


{-| Validate a `FormField`.

    isValid model usernameConfig

-}
isValid : model -> FormField model msg -> Bool
isValid model (FormField opaqueConfig) =
    List.all (validate model opaqueConfig) (pickValidationRules opaqueConfig)


{-| Checks the `pristine` status of a `FormField`.

    isPristine model usernameConfig

-}
isPristine : model -> FormField model msg -> Bool
isPristine model (FormField opaqueConfig) =
    case opaqueConfig of
        FormFieldTextConfig { reader } _ ->
            (isEmpty << Maybe.withDefault "" << reader) model

        FormFieldTextareaConfig { reader } _ ->
            (isEmpty << Maybe.withDefault "" << reader) model

        FormFieldPasswordConfig { reader } _ ->
            (isEmpty << Maybe.withDefault "" << reader) model

        FormFieldRadioConfig { reader } _ ->
            (isEmpty << Maybe.withDefault "" << reader) model

        FormFieldSelectConfig { reader } _ ->
            (isEmpty << Maybe.withDefault "" << reader) model

        FormFieldAutocompleteConfig { choiceReader } _ ->
            (isEmpty << Maybe.withDefault "" << choiceReader) model

        FormFieldDatepickerConfig { reader } _ ->
            (isNothing << reader) model

        _ ->
            True


isJust : Maybe a -> Bool
isJust v =
    case v of
        Just _ ->
            True

        Nothing ->
            False


isNothing : Maybe a -> Bool
isNothing =
    not << isJust


validate : model -> FormFieldConfig model msg -> Validation model -> Bool
validate model config validation =
    case ( validation, config ) of
        ( NotEmpty _, FormFieldTextConfig { reader } _ ) ->
            (not << isEmpty << Maybe.withDefault "" << reader) model

        ( NotEmpty _, FormFieldTextareaConfig { reader } _ ) ->
            (not << isEmpty << Maybe.withDefault "" << reader) model

        ( NotEmpty _, FormFieldPasswordConfig { reader } _ ) ->
            (not << isEmpty << Maybe.withDefault "" << reader) model

        ( NotEmpty _, FormFieldRadioConfig { reader } _ ) ->
            (not << isEmpty << Maybe.withDefault "" << reader) model

        ( NotEmpty _, FormFieldSelectConfig { reader } _ ) ->
            (not << isEmpty << Maybe.withDefault "" << reader) model

        ( NotEmpty _, FormFieldAutocompleteConfig { choiceReader } _ ) ->
            (not << isEmpty << Maybe.withDefault "" << choiceReader) model

        ( NotEmpty _, FormFieldDatepickerConfig { reader } _ ) ->
            (not << isJust << reader) model

        ( NotEmpty _, FormFieldCheckboxConfig { reader } _ ) ->
            reader model

        ( NotEmpty _, FormFieldCheckboxWithOptionsConfig { reader } _ ) ->
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

        FormFieldCheckboxWithOptionsConfig _ validations ->
            validations

        FormFieldDatepickerConfig _ validations ->
            validations

        FormFieldAutocompleteConfig _ validations ->
            validations

        FormFieldPureHtmlConfig config ->
            []


pickError : model -> FormFieldConfig model msg -> List String
pickError model opaqueConfig =
    List.filterMap
        (\rule ->
            if validate model opaqueConfig rule then
                Nothing

            else
                (Just << pickValidationError) rule
        )
        (pickValidationRules opaqueConfig)


pickValidationError : Validation model -> String
pickValidationError rule =
    case rule of
        NotEmpty error ->
            error

        Expression exp error ->
            error

        Custom customRule error ->
            error


canShowError : model -> FormField model msg -> Bool
canShowError model config =
    (not << isValid model) config && (not << isPristine model) config


normalizeInput : String -> Maybe String
normalizeInput str =
    if isEmpty str then
        Nothing

    else
        Just str


isEmpty : String -> Bool
isEmpty =
    (==) "" << String.trim


renderIf : Bool -> Html msg -> Html msg
renderIf condition html =
    if condition then
        html

    else
        text ""
