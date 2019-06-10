module Prima.Pyxis.Form.Examples.FormConfig exposing
    ( city
    , country
    , dateOfBirth
    , gender
    , note
    , password
    , staticHtml
    , username
    , visitedCountries
    )

import Html exposing (Html, p, text)
import Html.Attributes exposing (class, maxlength, minlength)
import Prima.Pyxis.Form as Form
    exposing
        ( AutocompleteOption
        , CheckboxOption
        , FormField
        , FormFieldConfig
        , RadioOption
        , SelectOption
        )
import Prima.Pyxis.Form.Event as Event
import Prima.Pyxis.Form.Examples.Model
    exposing
        ( FieldName(..)
        , FormData
        , Model
        , Msg(..)
        )
import Prima.Pyxis.Validation exposing (..)


username : FormField FormData Msg
username =
    Form.textConfig
        "user_name"
        (Just "Username & Password")
        [ minlength 3, maxlength 12 ]
        .username
        [ Event.onInput (UpdateField Username)
        , Event.onFocus (OnFocus Username)
        , Event.onBlur (OnBlur Username)
        ]
        [ NotEmpty "Empty value is not acceptable."
        , Custom ((<=) 3 << String.length << Maybe.withDefault "" << .username) "Value must be between 3 and 12 characters length."
        ]


password : FormField FormData Msg
password =
    Form.passwordConfig
        "password"
        Nothing
        []
        .password
        [ Event.onInput (UpdateField Password) ]
        [ NotEmpty "Empty value is not acceptable."
        ]


note : FormField FormData Msg
note =
    Form.textareaConfig
        "note"
        (Just "Note")
        []
        .note
        [ Event.onInput (UpdateField Note) ]
        [ NotEmpty "Empty value is not acceptable." ]


gender : FormField FormData Msg
gender =
    Form.radioConfig
        "gender"
        (Just "Gender")
        []
        .gender
        [ Event.onSelect (UpdateField Gender) ]
        [ RadioOption "Male" "male"
        , RadioOption "Female" "female"
        ]
        [ Custom ((==) "female" << Maybe.withDefault "female" << .gender) "You must select `Female` to proceed." ]


visitedCountries : FormData -> FormField FormData Msg
visitedCountries data =
    Form.checkboxConfig
        "visited_countries"
        (Just "Visited countries")
        []
        (List.map (\( label, slug, checked ) -> ( slug, checked )) << .visitedCountries)
        [ Event.onCheck (UpdateCheckbox VisitedCountries) ]
        (List.map (\( label, slug, checked ) -> CheckboxOption label slug checked) data.visitedCountries)
        []


city : Bool -> FormField FormData Msg
city isOpen =
    Form.selectConfig
        "city"
        (Just "City")
        False
        isOpen
        (Just "Seleziona")
        [ class "formSmall" ]
        .city
        [ Event.onToggle (Toggle City)
        , Event.onInput (UpdateField City)
        , Event.onSelect (UpdateField City)
        , Event.onFocus (OnFocus City)
        ]
        (List.sortBy .label
            [ SelectOption "Milan" "MI"
            , SelectOption "Turin" "TO"
            , SelectOption "Rome" "RO"
            , SelectOption "Naples" "NA"
            , SelectOption "Genoa" "GE"
            ]
        )
        [ NotEmpty "Empty value is not acceptable." ]


dateOfBirth : FormData -> FormField FormData Msg
dateOfBirth { isVisibleDP, dateOfBirthDP } =
    Form.datepickerConfig
        "date_of_birth"
        (Just "Date of Birth")
        []
        .dateOfBirth
        (UpdateDatePicker DateOfBirth)
        [ Event.onInput (UpdateField DateOfBirth) ]
        dateOfBirthDP
        isVisibleDP
        [ Custom (Maybe.withDefault False << Maybe.map (always True) << .dateOfBirth) "This is not a valid date." ]


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


staticHtml : Model -> FormField FormData Msg
staticHtml model =
    Form.pureHtmlConfig
        [ p [] [ text "Lorem ipsum dolor sit amet." ]
        ]
