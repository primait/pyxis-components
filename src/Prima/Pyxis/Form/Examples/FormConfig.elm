module Prima.Pyxis.Form.Examples.FormConfig exposing
    ( city
    , country
    , dateOfBirth
    , gender
    , genderVertical
    , note
    , password
    , privacy
    , staticHtml
    , username
    , visitedCountries
    )

import Html exposing (Html, p, text)
import Html.Attributes exposing (class, maxlength, minlength)
import Prima.Pyxis.DatePicker as DatePicker
import Prima.Pyxis.Form as Form
    exposing
        ( AutocompleteOption
        , CheckboxOption
        , Event
        , FormField
        , FormFieldConfig
        , RadioOption
        , SelectOption
        , Validation(..)
        )
import Prima.Pyxis.Form.Examples.Model
    exposing
        ( FieldName(..)
        , Model
        , Msg(..)
        )


username : FormField Model Msg
username =
    Form.textConfig
        "user_name"
        (Just "Username & Password")
        [ minlength 3, maxlength 12 ]
        .username
        [ Form.onInput (UpdateField Username)
        , Form.onFocus (OnFocus Username)
        , Form.onBlur (OnBlur Username)
        ]
        [ NotEmpty "Empty value is not acceptable."
        , Custom ((<=) 3 << String.length << Maybe.withDefault "" << .username) "Value must be between 3 and 12 characters length."
        ]


password : FormField Model Msg
password =
    Form.passwordConfig
        "password"
        Nothing
        []
        .password
        [ Form.onInput (UpdateField Password) ]
        [ NotEmpty "Empty value is not acceptable."
        ]


note : FormField Model Msg
note =
    Form.textareaConfig
        "note"
        (Just "Note")
        []
        .note
        [ Form.onInput (UpdateField Note) ]
        
        [ NotEmpty "Empty value is not acceptable." ]


gender : FormField Model Msg
gender =
    Form.radioConfig
        "gender"
        (Just "Gender")
        []
        .gender
        (UpdateField Gender)
        []
        [ RadioOption "Male" "male"
        , RadioOption "Female" "female"
        ]
        [ Custom ((==) "female" << Maybe.withDefault "female" << .gender) "You must select `Female` to proceed." ]


genderVertical : FormField Model Msg
genderVertical =
    Form.radioConfig
        "gender_vertical"
        (Just "Gender")
        []
        .genderVertical
        (UpdateField GenderVertical)
        []
        [ RadioOption "Always Male, but with more, more characters" "male"
        , RadioOption "Always Female, but with longer label" "female"
        ]
        []


privacy : FormField Model Msg
privacy =
    Form.checkboxConfig
        "privacy"
        (Just "Privacy")
        []
        .privacy
        (UpdateFlag Privacy)
        []
        []


visitedCountries : Model -> FormField Model Msg
visitedCountries model =
    Form.checkboxWithOptionsConfig
        "visited_countries"
        (Just "Visited countries")
        []
        (List.map (\( label, slug, checked ) -> ( slug, checked )) << .visitedCountries)
        (UpdateCheckbox VisitedCountries)
        []
        (List.map (\( label, slug, checked ) -> CheckboxOption label slug checked) model.visitedCountries)
        []


city : Bool -> FormField Model Msg
city isOpen =
    Form.selectConfig
        "city"
        (Just "City")
        False
        isOpen
        (Just "Seleziona")
        [ class "formSmall" ]
        .city
        (Toggle City)
        (UpdateField City)
        [ Form.onFocus (OnFocus City) ]
        (List.sortBy .label
            [ SelectOption "Milan" "MI"
            , SelectOption "Turin" "TO"
            , SelectOption "Rome" "RO"
            , SelectOption "Naples" "NA"
            , SelectOption "Genoa" "GE"
            ]
        )
        [ NotEmpty "Empty value is not acceptable." ]


dateOfBirth : Model -> FormField Model Msg
dateOfBirth { isVisibleDP, dateOfBirthDP } =
    Form.datepickerConfig
        "date_of_birth"
        (Just "Date of Birth")
        []
        .dateOfBirth
        (UpdateDatePicker DateOfBirth)
        [ Form.onInput (UpdateField DateOfBirth) ]
        dateOfBirthDP
        isVisibleDP
        [ Custom (Maybe.withDefault False << Maybe.map (always True) << .dateOfBirth) "This is not a valid date." ]


country : Model -> FormField Model Msg
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
        (UpdateAutocomplete Country)
        (UpdateField Country)
        [ Form.onFocus (OnFocus Country) ]
        ([ AutocompleteOption "Aland Islands" "ALA"
         , AutocompleteOption "Austria" "AUT"
         , AutocompleteOption "Belgium" "BEL"
         , AutocompleteOption "Bulgaria" "BGR"
         , AutocompleteOption "Croatia" "HRV"
         , AutocompleteOption "Cyprus" "CYP"
         , AutocompleteOption "Czech Republic" "CZE"
         , AutocompleteOption "Denmark" "DNK"
         , AutocompleteOption "Estonia" "EST"
         , AutocompleteOption "Faroe Islands" "FRO"
         , AutocompleteOption "Finland" "FIN"
         , AutocompleteOption "France" "FRA"
         , AutocompleteOption "French Guiana" "GUF"
         , AutocompleteOption "Germany" "DEU"
         , AutocompleteOption "Gibraltar" "GIB"
         , AutocompleteOption "Greece" "GRC"
         , AutocompleteOption "Hungary" "HUN"
         , AutocompleteOption "Ireland" "IRL"
         , AutocompleteOption "Isle of Man" "IMN"
         , AutocompleteOption "Italy" "ITA"
         , AutocompleteOption "Latvia" "LVA"
         , AutocompleteOption "Lithuania" "LTU"
         , AutocompleteOption "Luxembourg" "LUX"
         , AutocompleteOption "Malta" "MLT"
         , AutocompleteOption "Netherlands" "NLD"
         , AutocompleteOption "Poland" "POL"
         , AutocompleteOption "Portugal" "PRT"
         , AutocompleteOption "Romania" "ROU"
         , AutocompleteOption "Slovakia" "SVK"
         , AutocompleteOption "Slovenia" "SVN"
         , AutocompleteOption "Spain" "ESP"
         , AutocompleteOption "Sweden" "SWE"
         , AutocompleteOption "United Kingdom of Great Britain and Northern Ireland" "GBR"
         ]
            |> List.filter (String.contains lowerFilter << String.toLower << .label)
        )
        [ NotEmpty "Empty value is not acceptable." ]


staticHtml : Model -> FormField Model Msg
staticHtml model =
    Form.pureHtmlConfig
        [ p [] [ text "Lorem ipsum dolor sit amet." ]
        ]
