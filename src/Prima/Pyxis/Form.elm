module Prima.Pyxis.Form exposing
    ( Form, Label, Slug, Value
    , init, setAsTouched, setAsSubmitted, addField, addFieldList
    , isFormSubmitted, isFormPristine, isFormTouched
    , InputGroup, prepend, append
    , ValidationVisibilityPolicy(..)
    , pickValidationVisibilityPolicy, validateAlways, validateWhenSubmitted
    , FormField
    , FormFieldList, fieldListConfig
    , textConfig, passwordConfig, textareaConfig
    , checkboxConfig, checkboxOption
    , radioConfig, radioOption
    , selectConfig, selectOption
    , datepickerConfig
    , autocompleteConfig, autocompleteOption
    , pureHtmlConfig
    , fieldIsValid, fieldHasError, fieldHasWarning, fieldIsPristine, fieldIsTouched
    , fieldListIsValid, fieldListHasError, fieldListHasOwnError, fieldListHasFieldError, fieldListHasWarning, fieldListHasOwnWarning, fieldListHasFieldWarning
    , render, renderField, renderFieldList
    , addTooltipToFieldListWhen, addTooltipToFieldWhen, fieldListConfigWithToolTip
    )

{-| Allows to create a Form and it's fields using predefined Html syntax.


# Form Configuration

@docs Form, Label, Slug, Value


# Form Configuration Helpers

@docs init, setAsTouched, setAsSubmitted, addField, addFieldList, addInputGroup


# Form State Helpers

@docs isFormSubmitted, isFormPristine, isFormTouched


# InputGroup

@docs InputGroup, prepend, append


# Validation Visibility Policy

@docs ValidationVisibilityPolicy


# Form Validation Visibility Policy Helpers

@docs pickValidationVisibilityPolicy, validateAlways, validateWhenSubmitted


# Fields Configuration

@docs FormField


# FieldList Configuration

@docs FormFieldList, fieldListConfig


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


# FormField Helpers

@docs fieldIsValid, fieldHasError, fieldHasWarning, fieldIsPristine, fieldIsTouched


# FormFieldList Helpers

@docs fieldListIsValid, fieldListHasError, fieldListHasOwnError, fieldListHasFieldError, fieldListHasWarning, fieldListHasOwnWarning, fieldListHasFieldWarning


# Render

@docs render, renderField, renderInputGroup, renderFieldList

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
import Prima.Pyxis.Helpers as Helpers exposing (renderIf)
import Prima.Pyxis.Tooltip as Tooltip


{-| Public Form data type, it can be created with init function
-}
type Form model msg
    = Form (FormConfig model msg)


type alias FormConfig model msg =
    { state : FormState
    , validationVisibilityPolicy : ValidationVisibilityPolicy
    , fields : List (FormRow model msg)
    }


type FormRow model msg
    = SingleFieldRow (FormField model msg)
    | FieldListRow (FormFieldList model msg)


type FormState
    = Pristine
    | Touched
    | Submitted


{-| It's a collection of form fields rendered together in a single row
-}
type FormFieldList model msg
    = FormFieldList (FormFieldListConfig model msg) (List (FormValidation.Validation model))


type alias FormFieldListConfig model msg =
    { label : Label
    , fields : List (FormField model msg)
    , tooltip : Maybe (Tooltip.Config msg)
    }


{-| Represents the configuration of a single form field.
-}
type FormField model msg
    = SingleField (FormFieldConfig model msg)
    | InputGroupField (InputGroup model msg)


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
Used to add a boxed icon in a form field (for example the calendar icon of the datepicker).
-}
type InputGroup model msg
    = Prepend (List (Html msg)) (FormField model msg)
    | Append (List (Html msg)) (FormField model msg)


type alias TextConfig model msg =
    { slug : Slug
    , label : Maybe Label
    , attrs : List (Attribute msg)
    , reader : model -> Maybe Value
    , events : List (Event msg)
    , tooltip : Maybe (Tooltip.Config msg)
    }


type alias PasswordConfig model msg =
    { slug : Slug
    , label : Maybe Label
    , attrs : List (Attribute msg)
    , reader : model -> Maybe Value
    , events : List (Event msg)
    , tooltip : Maybe (Tooltip.Config msg)
    }


type alias TextareaConfig model msg =
    { slug : Slug
    , label : Maybe Label
    , attrs : List (Attribute msg)
    , reader : model -> Maybe Value
    , events : List (Event msg)
    , tooltip : Maybe (Tooltip.Config msg)
    }


type alias RadioConfig model msg =
    { slug : Slug
    , label : Maybe Label
    , attrs : List (Attribute msg)
    , reader : model -> Maybe Value
    , events : List (Event msg)
    , options : List RadioOption
    , tooltip : Maybe (Tooltip.Config msg)
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
    , tooltip : Maybe (Tooltip.Config msg)
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
    , tooltip : Maybe (Tooltip.Config msg)
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
    , tooltip : Maybe (Tooltip.Config msg)
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
    , tooltip : Maybe (Tooltip.Config msg)
    }


type alias AutocompleteOption =
    { label : Label
    , slug : Slug
    }


type alias PureHtmlConfig msg =
    { content : List (Html msg)
    , slug : Slug
    , tooltip : Maybe (Tooltip.Config msg)
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
    = List
    | Single


{-|


## Specify when the form will show validations.

  - `Always:` validations display will depend only on validation function result.
  - `WhenSubmitted`: validations will be shown only after setAsSubmitted have been called

-}
type ValidationVisibilityPolicy
    = Always
    | WhenSubmitted


{-| Configure a FormFieldList
-}
fieldListConfig : Label -> List (FormField model msg) -> List (FormValidation.Validation model) -> FormFieldList model msg
fieldListConfig label fields validations =
    FormFieldList (FormFieldListConfig label fields Nothing) validations


{-| Configure a FormFieldList with a tooltip
-}
fieldListConfigWithToolTip : Label -> List (FormField model msg) -> List (FormValidation.Validation model) -> Tooltip.Config msg -> FormFieldList model msg
fieldListConfigWithToolTip label fields validations tooltipConfig =
    FormFieldList (FormFieldListConfig label fields (Just tooltipConfig)) validations


{-| Returns form's Validation Visibility Policy
-}
pickValidationVisibilityPolicy : Form model msg -> ValidationVisibilityPolicy
pickValidationVisibilityPolicy (Form { validationVisibilityPolicy }) =
    validationVisibilityPolicy


{-| Checks if the Form state is Pristine.
-}
isFormPristine : Form model msg -> Bool
isFormPristine (Form { state }) =
    isFormStatePristine state


{-| Checks if the Form state is Touched.
-}
isFormTouched : Form model msg -> Bool
isFormTouched (Form { state }) =
    isFormStatePristine state


{-| Checks if the Form state is Submitted.
-}
isFormSubmitted : Form model msg -> Bool
isFormSubmitted (Form { state }) =
    isFormStateSubmitted state


{-| Checks if the given form state is Submitted.
-}
isFormStateSubmitted : FormState -> Bool
isFormStateSubmitted =
    (==) Submitted


{-| Checks if the the given form state is Pristine.
-}
isFormStatePristine : FormState -> Bool
isFormStatePristine =
    (==) Pristine


{-| Checks if the the given form state is Touched.
-}
isFormStateTouched : FormState -> Bool
isFormStateTouched =
    (==) Touched


{-| Creates an empty form with given Validation Visibility Policy in Pristine status (untouched).
-}
init : ValidationVisibilityPolicy -> Form model msg
init validationVisibilityPolicy =
    Form (FormConfig Pristine validationVisibilityPolicy [])


{-| Adds a FormField to the form.

    --
    import Prima.Pyxis.Form as Form
    import Prima.Pyxis.Form.Event as Event
    import Prima.Pyxis.Form.Validation as FormValidation

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

    usernameField : FormField FormData Msg
    usernameField =
        Form.textConfig
            -- Field Slug
            "username"
            -- Label
            (Just "Username")
            -- Data attributes
            [ minlength 3, maxlength 12 ]
            -- FormData accessor
            .username
            -- Event -> Msg mappings
            [ Event.onInput UpdateUsername ]
            -- Form Validations
            [ FormValidation.config FormValidation.Error
              (\formData -> Maybe.withDefault False <| Maybe.map ((<) 3 << String.length) formData.username)
              "Username must be greater than 3 digits"
            ]

    ...

    view : Model -> Html Msg
    view ({ form } as model) =
        form
            |> Form.addField usernameField
            |> Form.render

-}
addField : FormField model msg -> Form model msg -> Form model msg
addField formField (Form ({ fields } as config)) =
    Form { config | fields = fields ++ [ SingleFieldRow formField ] }


{-| Adds a Field Group to the form

    --
    ...
    formFieldList : FormFieldList FormData Msg
    formFieldList =
        Form.fieldListConfig
            -- Field Group label
            "Username & Alternative Username"
            -- Field Group FormFields
            [ username, alternativeUsername ]
            -- Field Group own validations
            [ FormValidation.config FormValidation.Warning
                (\formData -> not (formData.username == formData.alternativeUsername))
                "Username and password shouldn't be equal"
            ]
    ...
    view : Model -> Html Msg
    view ({ form } as model) =
        form
            |> Form.addFieldList formFieldList
            |> Form.render

-}
addFieldList : FormFieldList model msg -> Form model msg -> Form model msg
addFieldList formFieldList (Form ({ fields } as config)) =
    Form { config | fields = fields ++ [ FieldListRow formFieldList ] }


{-| Sets the form to Submitted state.
-}
setAsSubmitted : Form model msg -> Form model msg
setAsSubmitted (Form config) =
    Form { config | state = Submitted }


{-| Sets the form to Touched state (Not Pristine but not yet Submitted).
-}
setAsTouched : Form model msg -> Form model msg
setAsTouched (Form config) =
    Form { config | state = Touched }


{-| Sets the form validation visibility policy to Always
-}
validateAlways : Form model msg -> Form model msg
validateAlways (Form config) =
    Form { config | validationVisibilityPolicy = Always }


{-| Sets the form validation visibility policy to WhenSubmitted
-}
validateWhenSubmitted : Form model msg -> Form model msg
validateWhenSubmitted (Form config) =
    Form { config | validationVisibilityPolicy = WhenSubmitted }


{-| Renders a form with all it's fields.
Requires a `Form model msg` created via `Form.init` and `Form.addFields`.
-}
render : model -> Form model msg -> Html msg
render model ((Form { fields }) as formConfig) =
    let
        mapper : FormRow model msg -> Html msg
        mapper abstractRow =
            case abstractRow of
                SingleFieldRow formField ->
                    renderField formConfig model formField

                FieldListRow formFieldList ->
                    renderFieldList formConfig model formFieldList
    in
    div [ class "o-form" ] (List.map mapper fields)


{-| Renders a single `FormFieldList`

    --
    ...
    formFieldList : FormFieldList FormData Msg
    formFieldList =
        Form.fieldListConfig
            -- Field List label
            "Username & Alternative Username"
            -- Field List FormFields
            [ username, alternativeUsername ]
            -- Field List own validations
            [ FormValidation.config FormValidation.Warning
                (\formData -> not (formData.username == formData.alternativeUsername))
                "Username and password shouldn't be equal"
            ]
    ...
    view : Model -> Html Msg
    view { data, formConfig } =
        div
        [ class "a-container" ]
        [ Config.formFieldList
            |> Form.renderFieldList formConfig data
        ]

-}
renderFieldList : Form model msg -> model -> FormFieldList model msg -> Html msg
renderFieldList formConfig model formFieldList =
    div
        [ classList
            [ ( "m-form-field-list", True )
            , ( "is-valid", fieldListIsValid model formFieldList )
            , ( "has-own-errors", shouldValidate formConfig && fieldListHasOwnError model formFieldList )
            , ( "has-own-warnings", shouldValidate formConfig && fieldListHasOwnWarning model formFieldList )
            , ( "has-field-errors", shouldValidate formConfig && fieldListHasFieldError model formFieldList )
            , ( "has-field-warnings", shouldValidate formConfig && fieldListHasFieldWarning model formFieldList )
            ]
        ]
        [ renderFieldListLabel formFieldList
        , renderFieldListWrapper formConfig model formFieldList
        ]


renderFieldListLabel : FormFieldList model msg -> Html msg
renderFieldListLabel formFieldList =
    div
        [ class "m-form-field-list__label" ]
        [ text <| pickFieldListLabel formFieldList ]


renderFieldListFormFields : Form model msg -> model -> FormFieldList model msg -> Html msg
renderFieldListFormFields formConfig model formFieldList =
    div
        [ class "m-form-field-list__fields-row" ]
        (formFieldList
            |> pickFieldListFields
            |> List.map (renderFieldEngine List formConfig model)
        )


renderFieldListWrapper : Form model msg -> model -> FormFieldList model msg -> Html msg
renderFieldListWrapper formConfig model formFieldList =
    div
        [ class "m-form-field-list__fields-wrapper" ]
        [ renderFieldListFormFields formConfig model formFieldList
        , formFieldList
            |> pickFieldListToolTip
            |> Maybe.map Tooltip.render
            |> Maybe.withDefault (text "")
        , formFieldList
            |> pickFieldListFields
            |> List.map pickFieldValidations
            |> List.concat
            |> List.append (pickFieldListValidations formFieldList)
            |> List.filter (not << Helpers.flip FormValidation.pickFunction model)
            |> renderFieldListValidationMessages model formFieldList
            |> renderIf (shouldValidate formConfig)
        ]


renderFieldListValidationMessages : model -> FormFieldList model msg -> List (FormValidation.Validation model) -> Html msg
renderFieldListValidationMessages model formFieldList allValidations =
    let
        filterType : FormValidation.ValidationType
        filterType =
            if fieldListHasError model formFieldList then
                FormValidation.Error

            else
                FormValidation.Warning
    in
    div
        [ class "m-form-field-list__validation-messages-list" ]
        (allValidations
            |> pickOnly filterType
            |> List.map FormValidation.pickValidationMessage
            |> List.map renderFieldListSingleValidationMessage
        )


renderFieldListSingleValidationMessage : String -> Html msg
renderFieldListSingleValidationMessage message =
    span [ class "m-form-field-list__validation-message-list__item" ] [ text message ]


{-| Creates an InputGroup prepending a given List(Html msg) to a given FormField

    --
    ...
    dateOfBirth : FormData -> Html Msg -> Form.InputGroup FormData Msg
    dateOfBirth { isVisibleDP, dateOfBirthDP } prependable =
        Form.datepickerConfig
            "date_of_birth"
            (Just "Date of Birth")
            []
            .dateOfBirth
            (UpdateDatePicker DateOfBirth)
            [ Event.onInput (UpdateField DateOfBirth) ]
            dateOfBirthDP
            isVisibleDP
            [ FormValidation.config FormValidation.Error
                (\formData -> not (formData.dateOfBirth == Nothing))
                "You must select a date"
            ]|> Form.prepend [ prependable ]

-}
prepend : List (Html msg) -> FormField model msg -> FormField model msg
prepend group field =
    InputGroupField (Prepend group field)


{-| Creates an InputGroup appending a given List(Html msg) to a given FormField

    --
    ...
    dateOfBirth : FormData -> Html Msg -> Form.InputGroup FormData Msg
    dateOfBirth { isVisibleDP, dateOfBirthDP } appendable =
        Form.datepickerConfig
            "date\_of\_birth"
            (Just "Date of Birth")
            []
            .dateOfBirth
            (UpdateDatePicker DateOfBirth)
            [ Event.onInput (UpdateField DateOfBirth) ]
            dateOfBirthDP
            isVisibleDP
            [ FormValidation.config FormValidation.Error
            (\formData -> not (formData.dateOfBirth == Nothing))
            "You must select a date"
            ]
            |> Form.append [ appendable ]

-}
append : List (Html msg) -> FormField model msg -> FormField model msg
append group field =
    InputGroupField (Append group field)


{-| Adds a Pyxis tooltip to a given FormField
-}
addTooltipToFieldWhen : Bool -> Tooltip.Config msg -> FormField model msg -> FormField model msg
addTooltipToFieldWhen show tooltip formField =
    let
        maybeTooltip =
            if show then
                Just tooltip

            else
                Nothing
    in
    case formField of
        SingleField formFieldConfig ->
            SingleField (addTooltipToOpaqueFormFieldConfig maybeTooltip formFieldConfig)

        InputGroupField (Prepend prependable prependedField) ->
            InputGroupField (Prepend prependable (addTooltipToFieldWhen show tooltip prependedField))

        InputGroupField (Append appendable appendedField) ->
            InputGroupField (Append appendable (addTooltipToFieldWhen show tooltip appendedField))


{-| Adds a Pyxis tooltip to a given Field List
-}
addTooltipToFieldListWhen : Bool -> Tooltip.Config msg -> FormFieldList model msg -> FormFieldList model msg
addTooltipToFieldListWhen show tooltip (FormFieldList formFieldListConfig validations) =
    let
        maybeTooltip =
            if show then
                Just tooltip

            else
                Nothing
    in
    FormFieldList (tooltipOpaqueSetter maybeTooltip formFieldListConfig) validations


addTooltipToOpaqueFormFieldConfig : Maybe (Tooltip.Config msg) -> FormFieldConfig model msg -> FormFieldConfig model msg
addTooltipToOpaqueFormFieldConfig tooltip opaqueConfig =
    case opaqueConfig of
        FormFieldAutocompleteConfig config list ->
            FormFieldAutocompleteConfig (tooltipOpaqueSetter tooltip config) list

        FormFieldCheckboxConfig config list ->
            FormFieldCheckboxConfig (tooltipOpaqueSetter tooltip config) list

        FormFieldDatepickerConfig config list ->
            FormFieldDatepickerConfig (tooltipOpaqueSetter tooltip config) list

        FormFieldPasswordConfig config list ->
            FormFieldPasswordConfig (tooltipOpaqueSetter tooltip config) list

        FormFieldRadioConfig config list ->
            FormFieldRadioConfig (tooltipOpaqueSetter tooltip config) list

        FormFieldSelectConfig config list ->
            FormFieldSelectConfig (tooltipOpaqueSetter tooltip config) list

        FormFieldTextareaConfig config list ->
            FormFieldTextareaConfig (tooltipOpaqueSetter tooltip config) list

        FormFieldTextConfig config list ->
            FormFieldTextConfig (tooltipOpaqueSetter tooltip config) list

        FormFieldPureHtmlConfig config ->
            FormFieldPureHtmlConfig (tooltipOpaqueSetter tooltip config)


tooltipOpaqueSetter : Maybe (Tooltip.Config msg) -> { a | tooltip : Maybe (Tooltip.Config msg) } -> { a | tooltip : Maybe (Tooltip.Config msg) }
tooltipOpaqueSetter tooltip opaqueConfig =
    { opaqueConfig | tooltip = tooltip }


{-| Creates a radio option.
-}
radioOption : Label -> Slug -> RadioOption
radioOption =
    RadioOption


{-| Creates a checkbox option.
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
    import Prima.Pyxis.Form.Validation as FormValidation

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
            [ FormValidation.config FormValidation.Error
              (\formData -> not (formData.username == Nothing))
              "Username shouldn't be empty"
            ]

-}
textConfig : Slug -> Maybe Label -> List (Attribute msg) -> (model -> Maybe Value) -> List (Event msg) -> List (FormValidation.Validation model) -> FormField model msg
textConfig slug label attrs reader events validations =
    SingleField <|
        FormFieldTextConfig
            (TextConfig
                slug
                label
                attrs
                reader
                events
                Nothing
            )
            validations


{-| Creates a password text field. Same configuration as `textConfig`.
-}
passwordConfig : Slug -> Maybe Label -> List (Attribute msg) -> (model -> Maybe Value) -> List (Event msg) -> List (FormValidation.Validation model) -> FormField model msg
passwordConfig slug label attrs reader events validations =
    SingleField <|
        FormFieldPasswordConfig
            (PasswordConfig
                slug
                label
                attrs
                reader
                events
                Nothing
            )
            validations


{-| Creates a texarea field. Same configuration as `textConfig`.
-}
textareaConfig : Slug -> Maybe Label -> List (Attribute msg) -> (model -> Maybe Value) -> List (Event msg) -> List (FormValidation.Validation model) -> FormField model msg
textareaConfig slug label attrs reader events validations =
    SingleField <|
        FormFieldTextareaConfig
            (TextareaConfig
                slug
                label
                attrs
                reader
                events
                Nothing
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
    SingleField <|
        FormFieldRadioConfig
            (RadioConfig
                slug
                label
                attrs
                reader
                events
                options
                Nothing
            )
            validations


{-| Creates a checkbox field.
This field can handle only onCheck event. Other events will be ignored.

    --
    import Prima.Pyxis.Form as Form exposing (FormField, Label, Slug, CheckboxOption)
    import Prima.Pyxis.Form.Event as Event
    import Prima.Pyxis.Form.Validation as FormValidation

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
    SingleField <|
        FormFieldCheckboxConfig
            (CheckboxConfig
                slug
                label
                attrs
                reader
                events
                options
                Nothing
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
            [ FormValidation.config FormValidation.Error
              (\formData -> not (formData.city == Nothing))
              "You must select a city"
            ]

-}
selectConfig : Slug -> Maybe Label -> Bool -> Bool -> Maybe String -> List (Attribute msg) -> (model -> Maybe Value) -> List (Event msg) -> List SelectOption -> List (FormValidation.Validation model) -> FormField model msg
selectConfig slug label isDisabled isOpen placeholder attrs reader events options validations =
    SingleField <|
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
                Nothing
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
    SingleField <|
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
                Nothing
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
    SingleField <|
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
                Nothing
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
pureHtmlConfig : String -> List (Html msg) -> FormField model msg
pureHtmlConfig slug content =
    SingleField <|
        FormFieldPureHtmlConfig
            (PureHtmlConfig
                content
                slug
                Nothing
            )


{-| Renders a single `FormField`

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
    view { data, formConfig } =
        div
        [ class "a-container" ]
        [
            usernameConfig
                |> Form.renderField formConfig data
        ]

-}
renderField : Form model msg -> model -> FormField model msg -> Html msg
renderField formConfig model formField =
    renderFieldEngine Single formConfig model formField


{-| Assemble pre-rendered form field elements (input and validations) given by renderEngine
-}
type alias RenderedLabel msg =
    Html msg


type alias RenderedField msg =
    List (Html msg)


type alias RenderedValidations msg =
    List (Html msg)


assemblyFormField : Form model msg -> model -> FormField model msg -> RenderedLabel msg -> RenderedField msg -> RenderedValidations msg -> Html msg
assemblyFormField form model formField renderedLabel renderedField renderedValidations =
    let
        compute : (model -> FormField model msg -> Bool) -> Bool
        compute mapper =
            mapper model formField
    in
    div
        [ classList
            [ ( "a-form-field", True )
            , ( "is-valid", compute fieldIsValid )
            , ( "is-pristine", compute fieldIsPristine )
            , ( "is-touched", compute fieldIsTouched )
            , ( "has-error", shouldValidate form && compute fieldHasError )
            , ( "has-warning", shouldValidate form && compute fieldHasWarning )
            ]
        , attribute "data-slug" (pickFormFieldSlug formField)
        ]
        [ renderedLabel
        , div
            [ class "a-form-field__field-wrapper" ]
            ([ renderedField
             , formField
                |> pickFormFieldTooltip
                |> Maybe.map Tooltip.render
                |> Maybe.withDefault (text "")
                |> List.singleton
             , renderedValidations
                |> Helpers.renderListIf (shouldValidate form)
             ]
                |> List.concat
            )

        --((++)
        --   Helpers.renderListIf (shouldValidate form) renderedValidations renderedField
        -- )
        ]


renderFieldValidationList : model -> FormField model msg -> List (Html msg)
renderFieldValidationList model formField =
    let
        byType : FormValidation.Validation model -> Bool
        byType =
            case ( fieldHasError model formField, fieldHasWarning model formField ) of
                ( True, _ ) ->
                    FormValidation.isError << FormValidation.pickType

                ( False, True ) ->
                    FormValidation.isWarning << FormValidation.pickType

                ( False, False ) ->
                    always False

        byValidity : FormValidation.Validation model -> Bool
        byValidity validation =
            (not << FormValidation.pickFunction validation) model
    in
    formField
        |> pickFieldValidations
        |> List.filter byType
        |> List.filter byValidity
        |> List.map FormValidation.pickValidationMessage
        |> List.map renderFieldValidationMessage


renderFieldEngine : RenderFieldMode -> Form model msg -> model -> FormField model msg -> Html msg
renderFieldEngine mode ((Form formConfig) as form) model formField =
    let
        lbl config =
            if isRenderFieldSingle mode then
                renderLabel config.slug config.label

            else
                text ""

        wrapWhenGroup : List (Html msg) -> List (Html msg)
        wrapWhenGroup =
            case formField of
                SingleField _ ->
                    identity

                InputGroupField inputGroup ->
                    inputGroupWrapper inputGroup

        -- (Label, Field) --
        ( renderedLabel, renderedField ) =
            case pickFormFieldOpaqueConfig formField of
                FormFieldTextConfig config _ ->
                    ( lbl config, wrapWhenGroup <| renderInput model config )

                FormFieldPasswordConfig config _ ->
                    ( lbl config, wrapWhenGroup <| renderPassword model config )

                FormFieldTextareaConfig config _ ->
                    ( lbl config, wrapWhenGroup <| renderTextarea model config )

                FormFieldRadioConfig config _ ->
                    ( lbl config, wrapWhenGroup <| renderRadio model config )

                FormFieldCheckboxConfig config _ ->
                    ( lbl config, wrapWhenGroup <| renderCheckbox config )

                FormFieldSelectConfig config validation ->
                    ( lbl config, wrapWhenGroup <| renderSelect formConfig.state model config validation )

                FormFieldDatepickerConfig config _ ->
                    ( lbl config, wrapWhenGroup <| renderDatepicker model config )

                FormFieldAutocompleteConfig config _ ->
                    ( lbl config, wrapWhenGroup <| renderAutocomplete model config )

                FormFieldPureHtmlConfig config ->
                    ( text "", renderPureHtml config )

        renderedValidations =
            case mode of
                --Print validations only if is SingleField mode and Form shouldValidate
                Single ->
                    renderFieldValidationList model formField

                List ->
                    []
    in
    assemblyFormField form model formField renderedLabel renderedField renderedValidations


inputGroupWrapper : InputGroup model msg -> List (Html msg) -> List (Html msg)
inputGroupWrapper group content =
    [ div
        [ class "m-form-input-group" ]
        ((case group of
            Prepend groupContent _ ->
                inputGroupPrepend groupContent

            Append groupContent _ ->
                inputGroupAppend groupContent
         )
            :: content
        )
    ]


inputGroupPrepend : List (Html msg) -> Html msg
inputGroupPrepend =
    div
        [ class "m-form-input-group__prepend"
        ]


inputGroupAppend : List (Html msg) -> Html msg
inputGroupAppend =
    div
        [ class "m-form-input-group__append"
        ]


renderLabel : String -> Maybe String -> Html msg
renderLabel slug theLabel =
    case theLabel of
        Nothing ->
            text ""

        Just label ->
            Html.label
                [ for slug
                , class "a-form-field__label"
                ]
                [ text label
                ]


renderFieldValidationMessage : String -> Html msg
renderFieldValidationMessage validationMessage =
    span
        [ class "a-form-field__validation-message" ]
        [ text validationMessage ]


renderInput : model -> TextConfig model msg -> List (Html msg)
renderInput model ({ reader, slug, label, attrs } as config) =
    [ Html.input
        ([ type_ "text"
         , (value << Maybe.withDefault "" << reader) model
         , id slug
         , name slug
         , class "a-form-field__input"
         ]
            ++ attrs
            ++ Events.onInputAttribute config.events
            ++ Events.onFocusAttribute config.events
            ++ Events.onBlurAttribute config.events
        )
        []
    ]


renderPassword : model -> PasswordConfig model msg -> List (Html msg)
renderPassword model ({ reader, slug, label, attrs } as config) =
    [ Html.input
        ([ type_ "password"
         , (value << Maybe.withDefault "" << reader) model
         , id slug
         , name slug
         , class "a-form-field__input"
         ]
            ++ attrs
            ++ Events.onInputAttribute config.events
            ++ Events.onFocusAttribute config.events
            ++ Events.onBlurAttribute config.events
        )
        []
    ]


renderTextarea : model -> TextareaConfig model msg -> List (Html msg)
renderTextarea model ({ reader, slug, label, attrs, events } as config) =
    [ Html.textarea
        ([ (value << Maybe.withDefault "" << reader) model
         , id slug
         , name slug
         , class "a-form-field__textarea"
         ]
            ++ attrs
            ++ Events.onInputAttribute config.events
            ++ Events.onFocusAttribute config.events
            ++ Events.onBlurAttribute config.events
        )
        []
    ]


renderRadio : model -> RadioConfig model msg -> List (Html msg)
renderRadio model ({ slug, label, options } as config) =
    let
        isVertical =
            List.any (hasReachedCharactersLimit << .label) options

        hasReachedCharactersLimit str =
            String.length str >= 35
    in
    [ div
        [ classList
            [ ( "a-form-field__radio-options", True )
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
         , class "a-form-field__radio"
         ]
            ++ attrs
            ++ Events.onSelectAttribute option.slug config.events
        )
        []
    , Html.label
        [ for optionSlug
        , class "a-form-field__radio__label"
        ]
        [ text option.label
        ]
    ]


renderCheckbox : CheckboxConfig model msg -> List (Html msg)
renderCheckbox ({ slug, label, options } as config) =
    [ div
        [ class "a-form-field__checkbox-options" ]
        ((List.concat << List.indexedMap (\index option -> renderCheckboxOption config index option)) options)
    ]


renderCheckboxOption : CheckboxConfig model msg -> Int -> CheckboxOption -> List (Html msg)
renderCheckboxOption ({ reader, attrs } as config) index option =
    let
        slug =
            (String.join "_" << List.map (String.trim << String.toLower)) [ config.slug, option.slug ]
    in
    [ Html.input
        ([ type_ "checkbox"
         , value option.slug
         , id slug
         , name slug
         , class "a-form-field__checkbox"
         ]
            ++ attrs
            ++ Events.onCheckAttribute option.slug (not option.isChecked) config.events
        )
        []
    , Html.label
        [ for slug
        , class "a-form-field__checkbox__label"
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
    in
    [ renderCustomSelect model config
    , Html.select
        ([ id slug
         , name slug
         , class "a-form-field__select"
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


renderCustomSelect : model -> SelectConfig model msg -> Html msg
renderCustomSelect model ({ slug, label, reader, isDisabled, isOpen, attrs } as config) =
    let
        options =
            case ( config.placeholder, isOpen ) of
                ( Just placeholder, False ) ->
                    SelectOption placeholder "" :: config.options

                ( _, _ ) ->
                    config.options

        currentValue =
            options
                |> List.filter (\option -> ((==) option.slug << Maybe.withDefault "" << reader) model)
                |> List.map .label
                |> List.head
                |> Maybe.withDefault (Maybe.withDefault "" config.placeholder)
    in
    div
        ([ classList
            [ ( "a-form-field__custom-select", True )
            , ( "is-open", isOpen )
            , ( "is-disabled", isDisabled )
            ]
         ]
            ++ attrs
            ++ Events.onFocusAttribute config.events
            ++ Events.onBlurAttribute config.events
        )
        [ span
            ([ class "a-form-field__custom-select__status"
             ]
                ++ Events.onToggleAttribute config.events
            )
            [ text currentValue
            ]
        , ul
            [ class "a-form-field__custom-select__list" ]
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
            [ ( "a-form-field__custom-select__list__item", True )
            , ( "is-selected", ((==) option.slug << Maybe.withDefault "" << reader) model )
            ]
         ]
            ++ Events.onSelectAttribute option.slug config.events
        )
        [ text option.label
        ]


renderDatepicker : model -> DatepickerConfig model msg -> List (Html msg)
renderDatepicker model ({ attrs, reader, datePickerTagger, slug, label, instance, showDatePicker, events } as config) =
    let
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
         , class "a-form-field__input a-form-field__datepicker"
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
         , class "a-form-field__date"
         ]
            ++ attrs
        )
        []
    ]


renderAutocomplete : model -> AutocompleteConfig model msg -> List (Html msg)
renderAutocomplete model ({ filterReader, choiceReader, slug, label, isOpen, noResults, attrs, options } as config) =
    let
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
            [ ( "a-form-field__autocomplete", True )
            , ( "is-open", isOpen )
            ]
        ]
        [ Html.input
            ([ type_ "text"
             , valueAttr
             , id slug
             , name slug
             , classList
                [ ( "a-form-field__input", True )
                ]
             ]
                ++ attrs
                ++ Events.onAutocompleteFilterAttribute config.events
            )
            []
        , ul
            [ class "a-form-field__autocomplete__list" ]
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
            [ ( "a-form-field__autocomplete__list__item", True )
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
        [ class "a-form-field__autocomplete__list--no-results"
        ]
        [ (text << Maybe.withDefault "") noResults
        ]


renderPureHtml : PureHtmlConfig msg -> List (Html msg)
renderPureHtml { content } =
    content


{-| shouldValidate is based on ValidationVisibilityPolicy and Form.State
-}
shouldValidate : Form model msg -> Bool
shouldValidate (Form formConfig) =
    case ( formConfig.validationVisibilityPolicy, formConfig.state ) of
        ( Always, _ ) ->
            True

        ( WhenSubmitted, Submitted ) ->
            True

        ( WhenSubmitted, Pristine ) ->
            False

        ( WhenSubmitted, Touched ) ->
            False



{--
~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~ Helpers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~
--}


pickFieldListValidations : FormFieldList model msg -> List (FormValidation.Validation model)
pickFieldListValidations (FormFieldList _ validations) =
    validations


pickFieldListFields : FormFieldList model msg -> List (FormField model msg)
pickFieldListFields (FormFieldList { fields } _) =
    fields


pickFieldListLabel : FormFieldList model msg -> String
pickFieldListLabel (FormFieldList { label } _) =
    label


pickFieldListToolTip : FormFieldList model msg -> Maybe (Tooltip.Config msg)
pickFieldListToolTip (FormFieldList { tooltip } _) =
    tooltip


pickFormFieldTooltip : FormField model msg -> Maybe (Tooltip.Config msg)
pickFormFieldTooltip formField =
    case formField of
        SingleField (FormFieldAutocompleteConfig formFieldConfig _) ->
            pickTooltipFromOpaqueConfig formFieldConfig

        SingleField (FormFieldCheckboxConfig formFieldConfig _) ->
            pickTooltipFromOpaqueConfig formFieldConfig

        SingleField (FormFieldDatepickerConfig formFieldConfig _) ->
            pickTooltipFromOpaqueConfig formFieldConfig

        SingleField (FormFieldPasswordConfig formFieldConfig _) ->
            pickTooltipFromOpaqueConfig formFieldConfig

        SingleField (FormFieldRadioConfig formFieldConfig _) ->
            pickTooltipFromOpaqueConfig formFieldConfig

        SingleField (FormFieldSelectConfig formFieldConfig _) ->
            pickTooltipFromOpaqueConfig formFieldConfig

        SingleField (FormFieldTextareaConfig formFieldConfig _) ->
            pickTooltipFromOpaqueConfig formFieldConfig

        SingleField (FormFieldTextConfig formFieldConfig _) ->
            pickTooltipFromOpaqueConfig formFieldConfig

        SingleField (FormFieldPureHtmlConfig formFieldConfig) ->
            pickTooltipFromOpaqueConfig formFieldConfig

        InputGroupField (Append _ formField_) ->
            pickFormFieldTooltip formField_

        InputGroupField (Prepend _ formField_) ->
            pickFormFieldTooltip formField_


pickTooltipFromOpaqueConfig : { a | tooltip : Maybe (Tooltip.Config msg) } -> Maybe (Tooltip.Config msg)
pickTooltipFromOpaqueConfig =
    .tooltip


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


{-| Checks if a given field group is in valid state
-}
fieldListIsValid : model -> FormFieldList model msg -> Bool
fieldListIsValid model formFieldList =
    not (fieldListHasError model formFieldList) && not (fieldListHasWarning model formFieldList)


{-| Checks if a given field group triggers own errors only (not form field ones)
-}
fieldListHasOwnError : model -> FormFieldList model msg -> Bool
fieldListHasOwnError model (FormFieldList { fields } validations) =
    validations
        |> pickOnly FormValidation.Error
        |> List.any (not << Helpers.flip FormValidation.pickFunction model)


{-| Checks if a given field group triggers form field errors (not field group ones)
-}
fieldListHasFieldError : model -> FormFieldList model msg -> Bool
fieldListHasFieldError model (FormFieldList { fields } _) =
    List.any (fieldHasError model) fields


{-| Checks if a given field group triggers errors (both own and field only ones)
-}
fieldListHasError : model -> FormFieldList model msg -> Bool
fieldListHasError model formFieldList =
    fieldListHasFieldError model formFieldList || fieldListHasOwnError model formFieldList


{-| Checks if a given field group triggers own warnings only (not form field ones)
-}
fieldListHasOwnWarning : model -> FormFieldList model msg -> Bool
fieldListHasOwnWarning model (FormFieldList { fields } validations) =
    validations
        |> pickOnly FormValidation.Warning
        |> List.any (not << Helpers.flip FormValidation.pickFunction model)


{-| Checks if a given field group triggers form field warnings (not field group ones)
-}
fieldListHasFieldWarning : model -> FormFieldList model msg -> Bool
fieldListHasFieldWarning model (FormFieldList { fields } _) =
    List.any (fieldHasWarning model) fields


{-| Checks if a given field group triggers warnings (both own and field only ones)
-}
fieldListHasWarning : model -> FormFieldList model msg -> Bool
fieldListHasWarning model formFieldList =
    fieldListHasOwnWarning model formFieldList || fieldListHasFieldWarning model formFieldList


pickFieldValidations : FormField model msg -> List (FormValidation.Validation model)
pickFieldValidations formField =
    case pickFormFieldOpaqueConfig formField of
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


{-| Checks if a given field is valid. All validations are returning True
-}
fieldIsValid : model -> FormField model msg -> Bool
fieldIsValid model formField =
    formField
        |> pickFieldValidations
        |> List.all (Helpers.flip FormValidation.pickFunction model)


{-| Checks if a given field has errors
-}
fieldHasError : model -> FormField model msg -> Bool
fieldHasError model formField =
    formField
        |> pickFieldValidations
        |> List.filter (FormValidation.isError << FormValidation.pickType)
        |> List.any (not << Helpers.flip FormValidation.pickFunction model)


{-| Checks if a given field has warnings
-}
fieldHasWarning : model -> FormField model msg -> Bool
fieldHasWarning model formField =
    formField
        |> pickFieldValidations
        |> List.filter (FormValidation.isWarning << FormValidation.pickType)
        |> List.any (not << Helpers.flip FormValidation.pickFunction model)


{-| Checks if a given field is in Pristine state (the value in the model is Nothing or empty)
-}
fieldIsPristine : model -> FormField model msg -> Bool
fieldIsPristine model formField =
    let
        isEmpty : Maybe String -> Bool
        isEmpty =
            String.isEmpty << Maybe.withDefault ""
    in
    case pickFormFieldOpaqueConfig formField of
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


{-| Checks if a given field have been provided with some input
-}
fieldIsTouched : model -> FormField model msg -> Bool
fieldIsTouched model formField =
    not <| fieldIsPristine model <| formField


pickInputGroupFormField : InputGroup model msg -> FormField model msg
pickInputGroupFormField inputGroup =
    case inputGroup of
        Prepend _ formField ->
            formField

        Append _ formField ->
            formField


isPrependInputGroup : InputGroup model msg -> Bool
isPrependInputGroup inputGroup =
    case inputGroup of
        Prepend list formField ->
            True

        Append list formField ->
            False


isAppendInputGroup : InputGroup model msg -> Bool
isAppendInputGroup inputGroup =
    case inputGroup of
        Prepend list formField ->
            False

        Append list formField ->
            True


pickFormFieldSlug : FormField model msg -> String
pickFormFieldSlug formField =
    case pickFormFieldOpaqueConfig formField of
        FormFieldAutocompleteConfig { slug } _ ->
            slug

        FormFieldCheckboxConfig { slug } _ ->
            slug

        FormFieldDatepickerConfig { slug } _ ->
            slug

        FormFieldPasswordConfig { slug } _ ->
            slug

        FormFieldRadioConfig { slug } _ ->
            slug

        FormFieldSelectConfig { slug } _ ->
            slug

        FormFieldTextareaConfig { slug } _ ->
            slug

        FormFieldTextConfig { slug } _ ->
            slug

        FormFieldPureHtmlConfig { slug } ->
            slug


pickFormFieldOpaqueConfig : FormField model msg -> FormFieldConfig model msg
pickFormFieldOpaqueConfig formField =
    case formField of
        SingleField formFieldConfig ->
            formFieldConfig

        InputGroupField (Prepend _ field) ->
            pickFormFieldOpaqueConfig field

        InputGroupField (Append _ field) ->
            pickFormFieldOpaqueConfig field


isFormFieldSingle : FormField model msg -> Bool
isFormFieldSingle formField =
    case formField of
        SingleField _ ->
            True

        InputGroupField _ ->
            False


isFormFieldGroup : FormField model msg -> Bool
isFormFieldGroup formField =
    case formField of
        SingleField _ ->
            False

        InputGroupField _ ->
            True


isRenderFieldSingle : RenderFieldMode -> Bool
isRenderFieldSingle mode =
    case mode of
        List ->
            False

        Single ->
            True
