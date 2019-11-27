module Prima.Pyxis.Form.Examples.FormConfig exposing
    ( address
    , city
    , country
    , dateOfBirth
    , gender
    , note
    , password
    , passwordList
    , staticHtmlField
    , username
    , visitedCountries
    )

import Html exposing (Html, p, text)
import Html.Attributes exposing (class, maxlength, minlength)
import Prima.Pyxis.Form as Form
    exposing
        ( FormField
        , FormFieldList
        , addTooltipToFieldListWhen
        , addTooltipToFieldWhen
        )
import Prima.Pyxis.Form.Event as Event
import Prima.Pyxis.Form.Examples.Model
    exposing
        ( FieldName(..)
        , FormData
        , Model
        , Msg(..)
        )
import Prima.Pyxis.Form.Validation as FormValidation
import Prima.Pyxis.Helpers exposing (isJust)
import Prima.Pyxis.Tooltip as Tooltip


username : FormField FormData Msg
username =
    Form.textConfig
        --Slug
        "user_name"
        --Label
        (Just "Username")
        -- Data attributes
        [ minlength 3, maxlength 12, class "is-large" ]
        --FormData accessor
        .username
        --FormEvent mappings
        [ Event.onInput (UpdateField Username)
        , Event.onFocus (OnFocus Username)
        , Event.onBlur (OnBlur Username)
        ]
        --Form Validations
        [ FormValidation.config FormValidation.Error
            (\formData -> Maybe.withDefault False <| Maybe.map ((<) 3 << String.length) formData.username)
            "Username must be greater than 3 digits"
        , FormValidation.config FormValidation.Warning
            (\formData -> not (formData.username == Just "Prisco"))
            "Dovresti lavorare più su te stesso Prisco!"
        ]


password : FormField FormData Msg
password =
    Form.passwordConfig
        "password"
        Nothing
        [ class "is-medium" ]
        .password
        [ Event.onInput (UpdateField Password) ]
        [ FormValidation.config FormValidation.Error
            (\formData -> isJust formData.password)
            "Password can't be empty"
        , FormValidation.config FormValidation.Warning
            (\formData -> not (formData.password == Just "1234"))
            "You should be more creative"
        ]


confirmPassword : FormField FormData Msg
confirmPassword =
    Form.passwordConfig
        "password_confirm"
        (Just "Conferma Password")
        [ class "is-medium" ]
        .confirmPassword
        [ Event.onInput (UpdateField Password) ]
        [ FormValidation.config FormValidation.Error
            (\formData -> isJust formData.password)
            "Password can't be empty"
        , FormValidation.config FormValidation.Warning
            (\formData -> not (formData.password == formData.confirmPassword))
            "Repeated password is not the same"
        ]
        |> addTooltipToFieldWhen True (Tooltip.upConfig [] [ text "Confirm your password please" ])


passwordList : FormFieldList FormData Msg
passwordList =
    Form.fieldListConfig
        -- Field Group label
        (Just "Password")
        -- Field Group FormFields
        [ password, confirmPassword ]
        -- Field Group own validations
        [ FormValidation.config FormValidation.Warning
            (\formData -> not (formData.username == formData.password))
            "Username and password shouldn't be equal"
        ]
        |> addTooltipToFieldListWhen True (Tooltip.downConfig [] [ text "Tooltip sulla lista" ])


note : FormField FormData Msg
note =
    Form.textareaConfig
        "note"
        (Just "Note")
        []
        .note
        [ Event.onInput (UpdateField Note) ]
        [ FormValidation.config FormValidation.Error
            (\formData -> not (formData.note == Nothing))
            "Note shouldn't be empty"
        ]



--|> addTooltipToFieldWhen True (Tooltip.rightConfig [] [ text "You should write some interesting notes here!" ])


gender : FormField FormData Msg
gender =
    Form.radioConfig
        "gender"
        (Just "Gender")
        []
        .gender
        [ Event.onSelect (UpdateField Gender) ]
        [ Form.radioOption "Male" "male"
        , Form.radioOption "Female" "female"
        ]
        [ FormValidation.config FormValidation.Error
            (\formData -> not (formData.gender == Nothing))
            "Gender shouldn't be empty"
        ]


visitedCountries : FormData -> FormField FormData Msg
visitedCountries data =
    Form.checkboxConfig
        "visited_countries"
        (Just "Visited countries")
        []
        (List.map (\( label, slug, checked ) -> ( slug, checked )) << .visitedCountries)
        [ Event.onCheck (UpdateCheckbox VisitedCountries) ]
        (List.map (\( label, slug, checked ) -> Form.checkboxOption label slug checked) data.visitedCountries)
        [ FormValidation.config FormValidation.Error
            (\formData -> List.any (\( _, _, isSelected ) -> isSelected) formData.visitedCountries)
            "You must select one country"
        ]


city : Bool -> FormField FormData Msg
city isOpen =
    Form.selectConfig
        "city"
        (Just "Città")
        False
        isOpen
        (Just "Seleziona")
        [ class "form-small" ]
        .city
        [ Event.onToggle (Toggle City)
        , Event.onInput (UpdateField City)
        , Event.onSelect (UpdateField City)
        , Event.onFocus (OnFocus City)
        ]
        (List.sortBy .label
            [ Form.selectOption "Milan" "MI"
            , Form.selectOption "Turin" "TO"
            , Form.selectOption "Rome" "RO"
            , Form.selectOption "Naples" "NA"
            , Form.selectOption "Genoa" "GE"
            ]
        )
        [ FormValidation.config FormValidation.Error
            (\formData -> not (formData.city == Nothing))
            "You must select one city"
        ]


dateOfBirth : FormData -> Html Msg -> FormField FormData Msg
dateOfBirth { isVisibleDP, dateOfBirthDP } appendable =
    Form.datepickerConfig
        "date_of_birth"
        (Just "Date of Birth")
        [ class "is-medium" ]
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



--|> addTooltipToFieldWhen True (Tooltip.upConfig [] [ text "Tooltip sul campo" ])


street : FormField FormData Msg
street =
    Form.textConfig
        "street"
        Nothing
        [ minlength 3, maxlength 12, class "is-large" ]
        .street
        [ Event.onInput (UpdateField Street)
        , Event.onFocus (OnFocus Street)
        , Event.onBlur (OnBlur Street)
        ]
        [ FormValidation.config FormValidation.Error
            (\formData -> formData.street /= Nothing)
            "Street can't be null"
        ]


houseNumber : FormField FormData Msg
houseNumber =
    Form.textConfig
        "houseNumber"
        (Just "n.° civico")
        [ minlength 3, maxlength 12, class "is-small" ]
        .houseNumber
        [ Event.onInput (UpdateField HouseNumber)
        , Event.onFocus (OnFocus HouseNumber)
        , Event.onBlur (OnBlur HouseNumber)
        ]
        [ FormValidation.config FormValidation.Error
            (Maybe.withDefault False << Maybe.map (not << String.isEmpty) << .houseNumber)
            "House number can't be null"
        ]


address : FormData -> FormFieldList FormData Msg
address formData =
    Form.fieldListConfig
        (Just "Via")
        [ street, houseNumber ]
        []


country : FormData -> FormField FormData Msg
country { countryFilter, isOpenCountry } =
    let
        lowerFilter =
            (String.toLower << Maybe.withDefault "") countryFilter
    in
    Form.autocompleteConfig
        "country"
        (Just "Country")
        isOpenCountry
        (Just "No results")
        []
        .countryFilter
        .country
        [ Event.onAutocompleteFilter (UpdateAutocomplete Country)
        , Event.onSelect (UpdateField Country)
        , Event.onFocus (OnFocus Country)
        ]
        ([ Form.autocompleteOption "Aland Islands" "ALA"
         , Form.autocompleteOption "Austria" "AUT"
         , Form.autocompleteOption "Belgium" "BEL"
         , Form.autocompleteOption "Bulgaria" "BGR"
         , Form.autocompleteOption "Croatia" "HRV"
         , Form.autocompleteOption "Cyprus" "CYP"
         , Form.autocompleteOption "Czech Republic" "CZE"
         , Form.autocompleteOption "Denmark" "DNK"
         , Form.autocompleteOption "Estonia" "EST"
         , Form.autocompleteOption "Faroe Islands" "FRO"
         , Form.autocompleteOption "Finland" "FIN"
         , Form.autocompleteOption "France" "FRA"
         , Form.autocompleteOption "French Guiana" "GUF"
         , Form.autocompleteOption "Germany" "DEU"
         , Form.autocompleteOption "Gibraltar" "GIB"
         , Form.autocompleteOption "Greece" "GRC"
         , Form.autocompleteOption "Hungary" "HUN"
         , Form.autocompleteOption "Ireland" "IRL"
         , Form.autocompleteOption "Isle of Man" "IMN"
         , Form.autocompleteOption "Italy" "ITA"
         , Form.autocompleteOption "Latvia" "LVA"
         , Form.autocompleteOption "Lithuania" "LTU"
         , Form.autocompleteOption "Luxembourg" "LUX"
         , Form.autocompleteOption "Malta" "MLT"
         , Form.autocompleteOption "Netherlands" "NLD"
         , Form.autocompleteOption "Poland" "POL"
         , Form.autocompleteOption "Portugal" "PRT"
         , Form.autocompleteOption "Romania" "ROU"
         , Form.autocompleteOption "Slovakia" "SVK"
         , Form.autocompleteOption "Slovenia" "SVN"
         , Form.autocompleteOption "Spain" "ESP"
         , Form.autocompleteOption "Sweden" "SWE"
         , Form.autocompleteOption "United Kingdom of Great Britain and Northern Ireland" "GBR"
         ]
            |> List.filter (String.contains lowerFilter << String.toLower << .label)
        )
        [ FormValidation.config FormValidation.Error
            (\formData -> not (formData.country == Nothing))
            "Country must be selected"
        ]


staticHtmlField : FormField FormData Msg
staticHtmlField =
    Form.pureHtmlConfig
        --slug
        "always-error-field"
        [ p [] [ text "You shall not pass" ]
        ]
        [ FormValidation.config FormValidation.Error
            (\formData -> False)
            "This form field will always prints error"
        ]
