module Prima.Pyxis.Form exposing
    ( FormField, FormFieldConfig, Validation(..)
    , textConfig, passwordConfig, textareaConfig, checkboxConfig, CheckboxOption, checkboxWithOptionsConfig, SelectOption, selectConfig, RadioOption, radioConfig
    , AutocompleteOption
    , autocompleteConfig
    , datepickerConfig
    , pureHtmlConfig
    , render, renderWithGroup, wrapper
    , isValid
    , isPristine
    )

{-| Package to build a Form using [Prima Assicurazioni](https://www.prima.it)'s Design System.

In order to keep the configuration as simple as possible we decided to not allow
CSS classes to be changed, also forcing consistency in our ecosystem.


# Definition

@docs FormField, FormFieldConfig, Validation


# Basic components configuration

@docs textConfig, passwordConfig, textareaConfig, checkboxConfig, CheckboxOption, checkboxWithOptionsConfig, SelectOption, selectConfig, RadioOption, radioConfig


# Custom components configuration

@docs AutocompleteOption
@docs autocompleteConfig

@docs datepickerConfig


# Static components configuration

@docs pureHtmlConfig


# Render a FormField

@docs render, renderWithGroup, wrapper


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
        , tabindex
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


type alias TextConfig model msg =
    { slug : String
    , label : Maybe String
    , attrs : List (Attribute msg)
    , reader : model -> Maybe String
    , tagger : Maybe String -> msg
    , onFocus : msg
    , onBlur : msg
    , forceShowError : Bool
    , tabIndex : Maybe Int
    }


type alias PasswordConfig model msg =
    { slug : String
    , label : Maybe String
    , attrs : List (Attribute msg)
    , reader : model -> Maybe String
    , tagger : Maybe String -> msg
    , onFocus : msg
    , onBlur : msg
    , forceShowError : Bool
    , tabIndex : Maybe Int
    }


type alias TextareaConfig model msg =
    { slug : String
    , label : Maybe String
    , attrs : List (Attribute msg)
    , reader : model -> Maybe String
    , tagger : Maybe String -> msg
    , onFocus : msg
    , onBlur : msg
    , forceShowError : Bool
    , tabIndex : Maybe Int
    }


type alias RadioConfig model msg =
    { slug : String
    , label : Maybe String
    , attrs : List (Attribute msg)
    , reader : model -> Maybe String
    , tagger : Maybe String -> msg
    , onFocus : msg
    , onBlur : msg
    , options : List RadioOption
    , forceShowError : Bool
    , tabIndex : Maybe Int
    }


{-| Describes an option for a Radio

    [ RadioOption "Italy" "ita" True
    , RadioOption "France" "fra" False
    , RadioOption "Spain" "spa" True
    ]

-}
type alias RadioOption =
    { label : String
    , slug : String
    }


type alias CheckboxConfig model msg =
    { slug : String
    , label : Maybe String
    , attrs : List (Attribute msg)
    , reader : model -> Bool
    , tagger : Bool -> msg
    , onFocus : msg
    , onBlur : msg
    , forceShowError : Bool
    , tabIndex : Maybe Int
    }


type alias CheckboxWithOptionsConfig model msg =
    { slug : String
    , label : Maybe String
    , attrs : List (Attribute msg)
    , reader : model -> List ( String, Bool )
    , tagger : String -> Bool -> msg
    , onFocus : msg
    , onBlur : msg
    , options : List CheckboxOption
    , forceShowError : Bool
    , tabIndex : Maybe Int
    }


{-| Describes an option for a Checkbox

    [ CheckboxOption "Italy" "ita" True
    , CheckboxOption "France" "fra" False
    , CheckboxOption "Spain" "spa" True
    ]

-}
type alias CheckboxOption =
    { label : String
    , slug : String
    , isChecked : Bool
    }


type alias SelectConfig model msg =
    { slug : String
    , label : Maybe String
    , isDisabled : Bool
    , isOpen : Bool
    , placeholder : Maybe String
    , attrs : List (Attribute msg)
    , reader : model -> Maybe String
    , toggleTagger : Bool -> msg
    , optionTagger : Maybe String -> msg
    , onFocus : msg
    , onBlur : msg
    , options : List SelectOption
    , forceShowError : Bool
    , tabIndex : Maybe Int
    }


{-| Describes an option for a Select

    [ SelectOption "Italy" "ita"
    , SelectOption "France" "fra"
    ]

-}
type alias SelectOption =
    { label : String
    , slug : String
    }


type alias DatepickerConfig model msg =
    { slug : String
    , label : Maybe String
    , attrs : List (Attribute msg)
    , reader : model -> Maybe String
    , tagger : Maybe String -> msg
    , datePickerTagger : DatePicker.Msg -> msg
    , onFocus : msg
    , onBlur : msg
    , instance : DatePicker.Model
    , showDatePicker : Bool
    , forceShowError : Bool
    , tabIndex : Maybe Int
    }


type alias AutocompleteConfig model msg =
    { slug : String
    , label : Maybe String
    , isOpen : Bool
    , noResults : Maybe String
    , attrs : List (Attribute msg)
    , filterReader : model -> Maybe String
    , choiceReader : model -> Maybe String
    , filterTagger : Maybe String -> msg
    , choiceTagger : Maybe String -> msg
    , onFocus : msg
    , onBlur : msg
    , options : List AutocompleteOption
    , forceShowError : Bool
    , tabIndex : Maybe Int
    }


{-| Describes an option for an Autocomplete

    [ AutocompleteOption "Italy" "ita"
    , AutocompleteOption "France" "fra"
    ]

-}
type alias AutocompleteOption =
    { label : String
    , slug : String
    }


type alias PureHtmlConfig msg =
    { content : List (Html msg)
    }


{-| Input Text configuration method.

    import Prima.Form as Form exposing (FormField, FormFieldConfig, Validation(..))
    ...

    type Msg
        = OnInputUsername (Maybe String)
        | OnFocusUsername
        | OnBlurUsername
        ...

    type alias Model =
        { username : Maybe String
        ...
        }

    usernameConfig : FormField Model Msg
    usernameConfig  =
        textConfig
            "username"
            "Username:"
            [ minlength 3, maxlength 12, disabled False ]
            .username
            OnInputUsername
            OnFocusUsername
            OnBlurUsername
            alwaysShowErrors
            Nothing
            [ NotEmpty "Empty value is not acceptable."
            , Custom ((<=) 3 << String.length << Maybe.withDefault "" << .username) "Value must be between 3 and 12 characters length."
            ]

-}
textConfig : String -> Maybe String -> List (Attribute msg) -> (model -> Maybe String) -> (Maybe String -> msg) -> msg -> msg -> Bool -> Maybe Int -> List (Validation model) -> FormField model msg
textConfig slug label attrs reader tagger onFocus onBlur doForceShowError tabIndex validations =
    FormField <| FormFieldTextConfig (TextConfig slug label attrs reader tagger onFocus onBlur doForceShowError (Maybe.map ((*) 10) tabIndex)) validations


{-| Input password configuration method. See `textConfig` for configuration options.
-}
passwordConfig : String -> Maybe String -> List (Attribute msg) -> (model -> Maybe String) -> (Maybe String -> msg) -> msg -> msg -> Bool -> Maybe Int -> List (Validation model) -> FormField model msg
passwordConfig slug label attrs reader tagger onFocus onBlur doForceShowError tabIndex validations =
    FormField <| FormFieldPasswordConfig (PasswordConfig slug label attrs reader tagger onFocus onBlur doForceShowError (Maybe.map ((*) 10) tabIndex)) validations


{-| Textarea configuration method. See `textConfig` for configuration options.
-}
textareaConfig : String -> Maybe String -> List (Attribute msg) -> (model -> Maybe String) -> (Maybe String -> msg) -> msg -> msg -> Bool -> Maybe Int -> List (Validation model) -> FormField model msg
textareaConfig slug label attrs reader tagger onFocus onBlur doForceShowError tabIndex validations =
    FormField <| FormFieldTextareaConfig (TextareaConfig slug label attrs reader tagger onFocus onBlur doForceShowError (Maybe.map ((*) 10) tabIndex)) validations


{-| Input Radio configuration method.

    import Prima.Form as Form exposing (FormField, FormFieldConfig, Validation(..))
    ...

    type Msg
        = OnChangeGender (Maybe String)
        | OnFocusGender
        | OnBlurGender
        ...

    type alias Model =
        { gender : Maybe String
        ...
        }

    genderConfig : FormField Model Msg
    genderConfig =
        Form.radioConfig
            "gender"
            "Gender"
            []
            .gender
            OnChangeGender
            OnFocusGender
            OnBlurGender
            alwaysShowErrors
            [ RadioOption "Male" "male" , RadioOption "Female" "female" ]
            Nothing
            [ Custom ((==) "female" << Maybe.withDefault "female" << .gender) "You must select `Female` to proceed." ]

-}
radioConfig : String -> Maybe String -> List (Attribute msg) -> (model -> Maybe String) -> (Maybe String -> msg) -> msg -> msg -> List RadioOption -> Bool -> Maybe Int -> List (Validation model) -> FormField model msg
radioConfig slug label attrs reader tagger onFocus onBlur options doForceShowError tabIndex validations =
    FormField <| FormFieldRadioConfig (RadioConfig slug label attrs reader tagger onFocus onBlur options doForceShowError (Maybe.map ((*) 10) tabIndex)) validations


{-| Checkbox with single option configuration method.

    import Prima.Form as Form exposing (FormField, FormFieldConfig, Validation(..))
    ...

    type Msg
        = OnChangePrivacy Bool
        | OnFocusPrivacy
        | OnBlurPrivacy
        ...

    type alias Model =
        { privacy : Bool
        ...
        }

    ...
    acceptPrivacyConfig : FormField Model Msg
    acceptPrivacyConfig =
        Form.checkboxConfig
            "privacy"
            "Do you accept our Privacy Policy?"
            []
            .privacy
            OnChangePrivacy
            OnFocusPrivacy
            OnBlurPrivacy
            alwaysShowErrors
            Nothing
            []

-}
checkboxConfig : String -> Maybe String -> List (Attribute msg) -> (model -> Bool) -> (Bool -> msg) -> msg -> msg -> Bool -> Maybe Int -> List (Validation model) -> FormField model msg
checkboxConfig slug label attrs reader tagger onFocus onBlur doForceShowError tabIndex validations =
    FormField <| FormFieldCheckboxConfig (CheckboxConfig slug label attrs reader tagger onFocus onBlur doForceShowError (Maybe.map ((*) 10) tabIndex)) validations


{-| Checkbox with multiple option configuration method.

    import Prima.Form as Form exposing (FormField, FormFieldConfig, Validation(..))
    ...

    type Msg
        = OnChangeVisitedCountries String Bool
        | OnFocusVisitedCountries
        | OnBlurVisitedCountries
        ...

    type alias Model =
        { visitedCountries : List (String, String, Bool)
        ...
        }

    ...
    visitedCountriesConfig : List ( String, String, Bool ) -> FormField Model Msg
    visitedCountriesConfig options =
        Form.checkboxWithOptionsConfig
            "visited_countries"
            "Visited countries"
            []
            (List.map (\( label, slug, checked ) -> ( slug, checked )) << .visitedCountries)
            OnChangeVisitedCountries
            OnFocusVisitedCountries
            OnBlurVisitedCountries
            (List.map (\( label, slug, checked ) -> CheckboxOption label slug checked) options)
            alwaysShowErrors
            Nothing
            []

-}
checkboxWithOptionsConfig : String -> Maybe String -> List (Attribute msg) -> (model -> List ( String, Bool )) -> (String -> Bool -> msg) -> msg -> msg -> List CheckboxOption -> Bool -> Maybe Int -> List (Validation model) -> FormField model msg
checkboxWithOptionsConfig slug label attrs reader tagger onFocus onBlur options doForceShowError tabIndex validations =
    FormField <| FormFieldCheckboxWithOptionsConfig (CheckboxWithOptionsConfig slug label attrs reader tagger onFocus onBlur options doForceShowError (Maybe.map ((*) 10) tabIndex)) validations


{-| Select configuration method.

    import Prima.Form as Form exposing (FormField, FormFieldConfig, Validation(..))
    ...

    type Msg
        = OnChangeCity (Maybe String)
        | OnFocusCity
        | OnBlurCity
        | ToggleCity
        ...

    type alias Model =
        { city : Maybe String
        , isOpenCitySelect : Bool
        , isDisabledCity: Bool
        ...
        }

    ...

    cityConfig : Bool -> Bool -> FormField Model Msg
    cityConfig isDisabledCity isOpenCitySelect =
        Form.selectConfig
            "city"
            "City"
            isDisabledCity
            isOpenCitySelect
            (Just "Select any option")
            []
            .city
            ToggleCity
            OnChangeCity
            OnFocusCity
            OnBlurCity
            (List.sortBy .label [ SelectOption "Milan" "MI" , SelectOption "Turin" "TO" , SelectOption "Rome" "RO" , SelectOption "Naples" "NA" , SelectOption "Genoa" "GE" ] )
            alwaysShowErrors
            Nothing
            [ NotEmpty "Empty value is not acceptable." ]

-}
selectConfig : String -> Maybe String -> Bool -> Bool -> Maybe String -> List (Attribute msg) -> (model -> Maybe String) -> (Bool -> msg) -> (Maybe String -> msg) -> msg -> msg -> List SelectOption -> Bool -> Maybe Int -> List (Validation model) -> FormField model msg
selectConfig slug label isDisabled isOpen placeholder attrs reader toggleTagger optionTagger onFocus onBlur options doForceShowError tabIndex validations =
    FormField <| FormFieldSelectConfig (SelectConfig slug label isDisabled isOpen placeholder attrs reader toggleTagger optionTagger onFocus onBlur options doForceShowError (Maybe.map ((*) 10) tabIndex)) validations


{-| Datepicker configuration method.

    import DatePicker
    import Date.Format
    import Prima.Form as Form exposing (FormField, FormFieldConfig, Validation(..))
    ...

    type Msg
        = OnInputBirthDate (Maybe String)
        | OnFocusBirthDate
        | OnBlurBirthDate
        | OnChangeBirthDateDatePicker DatePicker.Msg
        ...

    type alias Model =
      { dateOfBirth : Maybe String
      , dateOfBirthDP: DatePicker.Model
      ...
      }

    update : Msg -> Model -> ( Model, Cmd Msg )
    update msg model =
        case msg of
          OnChangeBirthDateDatePicker dpMsg ->
              let
                  updatedInstance =
                      DatePicker.update dpMsg model.dateOfBirthDP
              in
              { model | dateOfBirthDP = updatedInstance, dateOfBirth = (Just << Date.Format.format "%d/%m/%Y" << DatePicker.selectedDate) updatedInstance } ! []
          ...

-}
datepickerConfig : String -> Maybe String -> List (Attribute msg) -> (model -> Maybe String) -> (Maybe String -> msg) -> (DatePicker.Msg -> msg) -> msg -> msg -> DatePicker.Model -> Bool -> Bool -> Maybe Int -> List (Validation model) -> FormField model msg
datepickerConfig slug label attrs reader tagger datePickerTagger onFocus onBlur datepicker showDatePicker doForceShowError tabIndex validations =
    FormField <|
        FormFieldDatepickerConfig
            (DatepickerConfig
                slug
                label
                attrs
                reader
                tagger
                datePickerTagger
                onFocus
                onBlur
                datepicker
                showDatePicker
                doForceShowError
                (Maybe.map ((*) 10) tabIndex)
            )
            validations


{-| Autocomplete configuration method.

    import Prima.Form as Form exposing (FormField, FormFieldConfig, Validation(..))
    ...

    type Msg
        = OnSelectCountry (Maybe String)
        | OnFilterCountry (Maybe String)
        | OnFocusCountry
        | OnBlurCountry
        ...

    type alias Model =
        { country : Maybe String
        , countryFilter : Maybe String
        , isOpenCountryAutocomplete: Bool
        ...
        }

    ...

    countryConfig : Bool -> Maybe String -> FormField Model Msg
    countryConfig isOpenCountryAutocomplete countryFilter =
        let
            lowerFilter =
                (String.toLower << Maybe.withDefault "") countryFilter
        in
        Form.autocompleteConfig
            "country"
            "Country"
            isOpenCountry
            (Just "No results")
            []
            .countryFilter
            .country
            OnFilterCountry
            OnSelectCountry
            OnFocusCountry
            OnBlurCountry
            alwaysShowErrors
            (List.filter (String.contains lowerFilter << String.toLower << .label) <| [ AutocompleteOption "Italy" "ITA", AutocompleteOption "Brasil" "BRA", AutocompleteOption "France" "FRA", AutocompleteOption "England" "ENG", AutocompleteOption "USA" "USA", AutocompleteOption "Japan" "JAP" ])
            Nothing
            [ NotEmpty "Empty value is not acceptable." ]

-}
autocompleteConfig : String -> Maybe String -> Bool -> Maybe String -> List (Attribute msg) -> (model -> Maybe String) -> (model -> Maybe String) -> (Maybe String -> msg) -> (Maybe String -> msg) -> msg -> msg -> List AutocompleteOption -> Bool -> Maybe Int -> List (Validation model) -> FormField model msg
autocompleteConfig slug label isOpen noResults attrs filterReader choiceReader filterTagger choiceTagger onFocus onBlur options doForceShowError tabIndex validations =
    FormField <| FormFieldAutocompleteConfig (AutocompleteConfig slug label isOpen noResults attrs filterReader choiceReader filterTagger choiceTagger onFocus onBlur options doForceShowError (Maybe.map ((*) 10) tabIndex)) validations


{-| Static Html configuration method.

    import Prima.Form as Form exposing (FormField, FormFieldConfig, Validation(..))
    ...

    staticHtmlConfig : List (Html Msg) -> FormField Model Msg
    staticHtmlConfig content =
      Form.pureHtmlConfig content

-}
pureHtmlConfig : List (Html msg) -> FormField model msg
pureHtmlConfig content =
    FormField <| FormFieldPureHtmlConfig (PureHtmlConfig content)


{-| Method for rendering a `FormField`
-}
render : model -> FormField model msg -> List (Html msg)
render model (FormField opaqueConfig) =
    let
        valid =
            validate model opaqueConfig

        pristine =
            isUntouched model opaqueConfig

        errors =
            (List.singleton
                << renderIf ((not valid && not pristine) || forceShowError opaqueConfig)
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
renderWithGroup : List (Html msg) -> model -> FormField model msg -> List (Html msg)
renderWithGroup groupsContent model (FormField opaqueConfig) =
    let
        valid =
            validate model opaqueConfig

        pristine =
            isUntouched model opaqueConfig

        errors =
            (renderIf ((not valid && not pristine) || forceShowError opaqueConfig)
                << renderError
                << String.join " "
                << pickError model
            )
                opaqueConfig
    in
    case opaqueConfig of
        FormFieldTextConfig config validation ->
            [ renderLabel config.slug config.label
            , groupWrapper <| groupsContent ++ (renderInput model config validation ++ [ errors ])
            ]

        FormFieldPasswordConfig config validation ->
            [ renderLabel config.slug config.label
            , groupWrapper <| groupsContent ++ (renderPassword model config validation ++ [ errors ])
            ]

        FormFieldTextareaConfig config validation ->
            [ renderLabel config.slug config.label
            , groupWrapper <| groupsContent ++ (renderInput model config validation ++ [ errors ])
            ]

        FormFieldRadioConfig config validation ->
            [ renderLabel config.slug config.label
            , groupWrapper <| groupsContent ++ (renderRadio model config validation ++ [ errors ])
            ]

        FormFieldCheckboxConfig config validation ->
            [ renderLabel config.slug config.label
            , groupWrapper <| groupsContent ++ (renderCheckbox model config validation ++ [ errors ])
            ]

        FormFieldCheckboxWithOptionsConfig config validation ->
            [ renderLabel config.slug config.label
            , groupWrapper <| groupsContent ++ (renderCheckboxWithOptions model config validation ++ [ errors ])
            ]

        FormFieldSelectConfig config validation ->
            [ renderLabel config.slug config.label
            , groupWrapper <| groupsContent ++ (renderSelect model config validation ++ [ errors ])
            ]

        FormFieldDatepickerConfig config validation ->
            [ renderLabel config.slug config.label
            , groupWrapper <| groupsContent ++ (renderDatepicker model config validation ++ [ errors ])
            ]

        FormFieldAutocompleteConfig config validation ->
            [ renderLabel config.slug config.label
            , groupWrapper <| groupsContent ++ (renderAutocomplete model config validation ++ [ errors ])
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


groupWrapper : List (Html msg) -> Html msg
groupWrapper =
    div
        [ class "m-form__field__group" ]


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
renderInput model ({ reader, tagger, slug, label, attrs, tabIndex } as config) validations =
    let
        valid =
            validate model (FormFieldTextConfig config validations)

        pristine =
            isUntouched model (FormFieldTextConfig config validations)
    in
    [ Html.input
        ([ type_ "text"
         , onInput (tagger << normalizeInput)
         , onFocus config.onFocus
         , onBlur config.onBlur
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
            ++ (Maybe.withDefault [] << Maybe.map (List.singleton << tabindex)) tabIndex
        )
        []
    ]


renderPassword : model -> PasswordConfig model msg -> List (Validation model) -> List (Html msg)
renderPassword model ({ reader, tagger, slug, label, attrs, tabIndex } as config) validations =
    let
        valid =
            validate model (FormFieldPasswordConfig config validations)

        pristine =
            isUntouched model (FormFieldPasswordConfig config validations)
    in
    [ Html.input
        ([ type_ "password"
         , onInput (tagger << normalizeInput)
         , onFocus config.onFocus
         , onBlur config.onBlur
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
            ++ (Maybe.withDefault [] << Maybe.map (List.singleton << tabindex)) tabIndex
        )
        []
    ]


renderTextarea : model -> TextareaConfig model msg -> List (Validation model) -> List (Html msg)
renderTextarea model ({ reader, tagger, slug, label, attrs, tabIndex } as config) validations =
    let
        valid =
            validate model (FormFieldTextareaConfig config validations)

        pristine =
            isUntouched model (FormFieldTextareaConfig config validations)
    in
    [ Html.textarea
        ([ onInput (tagger << normalizeInput)
         , onFocus config.onFocus
         , onBlur config.onBlur
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
            ++ (Maybe.withDefault [] << Maybe.map (List.singleton << tabindex)) tabIndex
        )
        []
    ]


renderRadio : model -> RadioConfig model msg -> List (Validation model) -> List (Html msg)
renderRadio model ({ slug, label, options, tabIndex } as config) validations =
    let
        valid =
            validate model (FormFieldRadioConfig config validations)

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
renderRadioOption model ({ reader, tagger, slug, label, options, attrs, tabIndex } as config) index option =
    let
        optionSlug =
            (String.join "_" << List.map (String.trim << String.toLower)) [ slug, option.slug ]
    in
    [ Html.input
        ([ type_ "radio"

         {--IE 11 does not behave correctly with onInput --}
         , (onClick << tagger << normalizeInput << .slug) option
         , onFocus config.onFocus
         , onBlur config.onBlur
         , value option.slug
         , id optionSlug
         , name slug
         , (checked << (==) option.slug << Maybe.withDefault "" << reader) model
         , classList
            [ ( "a-form__field__radio", True )
            ]
         ]
            ++ attrs
            ++ (Maybe.withDefault [] << Maybe.map (List.singleton << tabindex << (+) index)) tabIndex
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
renderCheckbox model ({ reader, tagger, slug, label, attrs, tabIndex } as config) validations =
    let
        valid =
            validate model (FormFieldCheckboxConfig config validations)
    in
    [ Html.input
        ([ type_ "checkbox"
         , (onClick << tagger << not << reader) model
         , onFocus config.onFocus
         , onBlur config.onBlur
         , (checked << reader) model
         , (value << boolToString << reader) model
         , id slug
         , name slug
         , classList
            [ ( "a-form__field__checkbox", True )
            ]
         ]
            ++ attrs
            ++ (Maybe.withDefault [] << Maybe.map (List.singleton << tabindex)) tabIndex
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
renderCheckboxWithOptions model ({ slug, label, options, tabIndex } as config) validations =
    let
        valid =
            validate model (FormFieldCheckboxWithOptionsConfig config validations)
    in
    (List.concat << List.indexedMap (\index option -> renderCheckboxOption model config index option)) options


renderCheckboxOption : model -> CheckboxWithOptionsConfig model msg -> Int -> CheckboxOption -> List (Html msg)
renderCheckboxOption model ({ reader, tagger, attrs, tabIndex } as config) index option =
    let
        slug =
            (String.join "_" << List.map (String.trim << String.toLower)) [ config.slug, option.slug ]
    in
    [ Html.input
        ([ type_ "checkbox"
         , (onClick << tagger option.slug << not) option.isChecked
         , onFocus config.onFocus
         , onBlur config.onBlur
         , value option.slug
         , id slug
         , name slug
         , classList
            [ ( "a-form__field__checkbox", True )
            ]
         ]
            ++ attrs
            ++ (Maybe.withDefault [] << Maybe.map (List.singleton << tabindex << (+) index)) tabIndex
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
renderSelect model ({ slug, label, reader, optionTagger, attrs, tabIndex } as config) validations =
    let
        options =
            case ( config.placeholder, config.isOpen ) of
                ( Just placeholder, False ) ->
                    SelectOption placeholder "" :: config.options

                ( _, _ ) ->
                    config.options

        valid =
            validate model (FormFieldSelectConfig config validations)

        pristine =
            isUntouched model (FormFieldSelectConfig config validations)
    in
    [ renderCustomSelect model config validations
    , Html.select
        ([ onInput (optionTagger << normalizeInput)
         , onFocus config.onFocus
         , onBlur config.onBlur
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
            ++ (Maybe.withDefault [] << Maybe.map (List.singleton << tabindex)) tabIndex
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
renderCustomSelect model ({ slug, label, reader, toggleTagger, isDisabled, isOpen, attrs, tabIndex } as config) validations =
    let
        options =
            case ( config.placeholder, isOpen ) of
                ( Just placeholder, False ) ->
                    SelectOption placeholder "" :: config.options

                ( _, _ ) ->
                    config.options

        valid =
            validate model (FormFieldSelectConfig config validations)

        pristine =
            isUntouched model (FormFieldSelectConfig config validations)

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
         , onFocus config.onFocus
         , onBlur config.onBlur
         ]
            ++ attrs
            ++ (Maybe.withDefault [] << Maybe.map (List.singleton << tabindex)) tabIndex
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
                    renderCustomSelectOption model config (Maybe.withDefault 0 tabIndex + index) option
                )
                options
            )
        ]


renderCustomSelectOption : model -> SelectConfig model msg -> Int -> SelectOption -> Html msg
renderCustomSelectOption model { reader, optionTagger, slug, label } tabIndex option =
    li
        [ classList
            [ ( "a-form__field__customSelect__list__item", True )
            , ( "is-selected", ((==) option.slug << Maybe.withDefault "" << reader) model )
            ]
        , (onClick << optionTagger << normalizeInput) option.slug
        , tabindex tabIndex
        ]
        [ text option.label
        ]


renderDatepicker : model -> DatepickerConfig model msg -> List (Validation model) -> List (Html msg)
renderDatepicker model ({ attrs, reader, tagger, datePickerTagger, slug, label, instance, showDatePicker, tabIndex } as config) validations =
    let
        valid =
            validate model (FormFieldDatepickerConfig config validations)

        pristine =
            isUntouched model (FormFieldDatepickerConfig config validations)

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
         , onFocus config.onFocus
         , onBlur config.onBlur
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
            ++ (Maybe.withDefault [] << Maybe.map (List.singleton << tabindex)) tabIndex
        )
        []
    , (renderIf showDatePicker << Html.map datePickerTagger << DatePicker.view) instance
    , Html.input
        ([ attribute "type" "date"
         , onInput (tagger << normalizeInput)
         , (value << Maybe.withDefault "" << Maybe.map inputDateFormat << reader) model
         , onFocus config.onFocus
         , onBlur config.onBlur
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


renderAutocomplete : model -> AutocompleteConfig model msg -> List (Validation model) -> List (Html msg)
renderAutocomplete model ({ filterReader, filterTagger, choiceReader, choiceTagger, slug, label, isOpen, noResults, attrs, options, tabIndex } as config) validations =
    let
        valid =
            validate model (FormFieldAutocompleteConfig config validations)

        pristine =
            isUntouched model (FormFieldAutocompleteConfig config validations)

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
             , onFocus config.onFocus
             , onBlur config.onBlur
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
                ++ (Maybe.withDefault [] << Maybe.map (List.singleton << tabindex)) tabIndex
            )
            []
        , ul
            [ class "a-form__field__autocomplete__list" ]
            (if List.length options > 0 then
                List.indexedMap (\index option -> renderAutocompleteOption model config (Maybe.withDefault 0 tabIndex + index) option) options

             else
                (List.singleton << renderAutocompleteNoResults model) config
            )
        ]
    ]


renderAutocompleteOption : model -> AutocompleteConfig model msg -> Int -> AutocompleteOption -> Html msg
renderAutocompleteOption model ({ choiceReader, choiceTagger } as config) tabIndex option =
    li
        [ classList
            [ ( "a-form__field__autocomplete__list__item", True )
            , ( "is-selected", ((==) option.slug << Maybe.withDefault "" << choiceReader) model )
            ]
        , (onClick << choiceTagger << normalizeInput) option.slug
        , tabindex tabIndex
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
    validate model opaqueConfig


{-| Checks the `pristine` status of a `FormField`.

    isPristine model usernameConfig

-}
isPristine : model -> FormField model msg -> Bool
isPristine model (FormField opaqueConfig) =
    isUntouched model opaqueConfig


validate : model -> FormFieldConfig model msg -> Bool
validate model opaqueConfig =
    List.all (validateRule model opaqueConfig) (pickValidationRules opaqueConfig)


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


validateRule : model -> FormFieldConfig model msg -> Validation model -> Bool
validateRule model config validation =
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
            (List.any (\( slug, isChecked ) -> isChecked) << reader) model

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


isUntouched : model -> FormFieldConfig model msg -> Bool
isUntouched model opaqueConfig =
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
            if validateRule model opaqueConfig rule then
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


normalizeInput : String -> Maybe String
normalizeInput str =
    if isEmpty str then
        Nothing

    else
        Just str


isEmpty : String -> Bool
isEmpty =
    (==) "" << String.trim


forceShowError : FormFieldConfig model msg -> Bool
forceShowError opaqueConfig =
    case opaqueConfig of
        FormFieldTextConfig config _ ->
            config.forceShowError

        FormFieldPasswordConfig config _ ->
            config.forceShowError

        FormFieldTextareaConfig config _ ->
            config.forceShowError

        FormFieldRadioConfig config _ ->
            config.forceShowError

        FormFieldCheckboxConfig config _ ->
            config.forceShowError

        FormFieldCheckboxWithOptionsConfig config _ ->
            config.forceShowError

        FormFieldSelectConfig config _ ->
            config.forceShowError

        FormFieldDatepickerConfig config _ ->
            config.forceShowError

        FormFieldAutocompleteConfig config _ ->
            config.forceShowError

        FormFieldPureHtmlConfig config ->
            False


renderIf : Bool -> Html msg -> Html msg
renderIf condition html =
    if condition then
        html

    else
        text ""
