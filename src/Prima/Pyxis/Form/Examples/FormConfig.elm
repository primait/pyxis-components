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
import Prima.Pyxis.Form as Form exposing (FormField)
import Prima.Pyxis.Form.Event as Event
import Prima.Pyxis.Form.Examples.Model
    exposing
        ( FieldName(..)
        , FormData
        , Model
        , Msg(..)
        )
import Prima.Pyxis.Form.Validation exposing (Validation(..), typeError)


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
        [ NotEmpty typeError "Empty value is not acceptable."
        , Custom typeError ((<=) 3 << String.length << Maybe.withDefault "" << .username) "Value must be between 3 and 12 characters length."
        ]


password : FormField FormData Msg
password =
    Form.passwordConfig
        "password"
        Nothing
        []
        .password
        [ Event.onInput (UpdateField Password) ]
        [ NotEmpty typeError "Empty value is not acceptable."
        ]


note : FormField FormData Msg
note =
    Form.textareaConfig
        "note"
        (Just "Note")
        []
        .note
        [ Event.onInput (UpdateField Note) ]
        [ NotEmpty typeError "Empty value is not acceptable." ]


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
        [ Custom typeError ((==) "female" << Maybe.withDefault "female" << .gender) "You must select `Female` to proceed." ]


visitedCountries : FormData -> FormField FormData Msg
visitedCountries data =
    Form.checkboxConfig
        "visited_countries"
        (Just "Visited countries")
        []
        (List.map (\( label, slug, checked ) -> ( slug, checked )) << .visitedCountries)
        [ Event.onCheck (UpdateCheckbox VisitedCountries) ]
        (List.map (\( label, slug, checked ) -> Form.checkboxOption label slug checked) data.visitedCountries)
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
            [ Form.selectOption "Milan" "MI"
            , Form.selectOption "Turin" "TO"
            , Form.selectOption "Rome" "RO"
            , Form.selectOption "Naples" "NA"
            , Form.selectOption "Genoa" "GE"
            ]
        )
        [ NotEmpty typeError "Empty value is not acceptable." ]


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
        [ Custom typeError (Maybe.withDefault False << Maybe.map (always True) << .dateOfBirth) "This is not a valid date." ]


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
        [ NotEmpty typeError "Empty value is not acceptable." ]


staticHtml : Model -> FormField FormData Msg
staticHtml model =
    Form.pureHtmlConfig
        [ p [] [ text "Lorem ipsum dolor sit amet." ]
        ]
