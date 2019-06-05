module Prima.Pyxis.Forms.Example exposing
    ( FieldName(..)
    , Label
    , Model
    , Msg(..)
    , Slug
    , cityConfig
    , countryConfig
    , dateOfBirthConfig
    , genderConfig
    , genderVerticalConfig
    , highDate
    , init
    , initialDate
    , initialModel
    , lowDate
    , main
    , noteConfig
    , passwordConfig
    , privacyConfig
    , staticHtml
    , update
    , usernameConfig
    , view
    , visitedCountriesConfig
    )

--import Date.Format
--import Date.Extra.Core exposing (intToMonth)
--import Date.Extra.Create exposing (dateFromFields)

import Browser
import Date exposing (Date)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Prima.Pyxis.DatePicker as DatePicker
import Prima.Pyxis.Form as Form
    exposing
        ( AutocompleteOption
        , CheckboxOption
        , FormField
        , FormFieldConfig
        , RadioOption
        , SelectOption
        , Validation(..)
        )
import Time exposing (Month(..), Weekday(..))



-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- MODEL
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------


type alias Model =
    { username : Maybe String
    , password : Maybe String
    , note : Maybe String
    , gender : Maybe String
    , genderVertical : Maybe String
    , city : Maybe String
    , isOpenCity : Bool
    , privacy : Bool
    , dateOfBirth : Maybe String
    , dateOfBirthDP : DatePicker.Model
    , isVisibleDP : Bool
    , country : Maybe String
    , countryFilter : Maybe String
    , isOpenCountry : Bool
    , visitedCountries : List ( Label, Slug, Bool )
    }


type alias Flags =
    {}


type alias Label =
    String


type alias Slug =
    String


initialDate : Date
initialDate =
    Date.fromCalendarDate 2019 Feb 1


lowDate : Date
lowDate =
    Date.fromCalendarDate 2019 Jan 3


highDate : Date
highDate =
    Date.fromCalendarDate 2019 Apr 29


initialModel : Model
initialModel =
    Model
        Nothing
        Nothing
        Nothing
        Nothing
        Nothing
        Nothing
        False
        False
        Nothing
        (DatePicker.init initialDate ( lowDate, highDate ))
        False
        Nothing
        Nothing
        False
        [ ( "Italy", "ITA", False )
        , ( "France", "FRA", False )
        , ( "U.S.A", "USA", False )
        , ( "Great Britain", "GB", False )
        ]


type FieldName
    = Privacy
    | Gender
    | GenderVertical
    | Username
    | Password
    | City
    | DateOfBirth
    | Country
    | VisitedCountries
    | Note


type Msg
    = UpdateField FieldName (Maybe String)
    | UpdateAutocomplete FieldName (Maybe String)
    | UpdateDatePicker FieldName DatePicker.Msg
    | UpdateDate FieldName (Maybe Date)
    | UpdateFlag FieldName Bool
    | UpdateCheckbox FieldName Slug Bool
    | Toggle FieldName Bool
    | FetchDateToday Date
    | Focus FieldName
    | Blur FieldName
    | ToggleDatePicker



-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- BOOTSTRAP
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( initialModel
    , Cmd.none
    )



-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- CONFIGS
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------


usernameConfig : FormField Model Msg
usernameConfig =
    Form.textConfig
        "user_name"
        (Just "Username & Password")
        [ minlength 3, maxlength 12 ]
        .username
        (UpdateField Username)
        (Focus Username)
        (Blur Username)
        False
        (Just 1)
        [ NotEmpty "Empty value is not acceptable."
        , Custom ((<=) 3 << String.length << Maybe.withDefault "" << .username) "Value must be between 3 and 12 characters length."
        ]


passwordConfig : FormField Model Msg
passwordConfig =
    Form.passwordConfig
        "password"
        Nothing
        []
        .password
        (UpdateField Password)
        (Focus Password)
        (Blur Password)
        False
        (Just 2)
        [ NotEmpty "Empty value is not acceptable."
        ]


noteConfig : FormField Model Msg
noteConfig =
    Form.textareaConfig
        "note"
        (Just "Note")
        []
        .note
        (UpdateField Note)
        (Focus Note)
        (Blur Note)
        False
        (Just 3)
        [ NotEmpty "Empty value is not acceptable." ]


genderConfig : FormField Model Msg
genderConfig =
    Form.radioConfig
        "gender"
        (Just "Gender")
        []
        .gender
        (UpdateField Gender)
        (Focus Gender)
        (Blur Gender)
        [ RadioOption "Male" "male"
        , RadioOption "Female" "female"
        ]
        False
        (Just 4)
        [ Custom ((==) "female" << Maybe.withDefault "female" << .gender) "You must select `Female` to proceed." ]


genderVerticalConfig : FormField Model Msg
genderVerticalConfig =
    Form.radioConfig
        "gender_vertical"
        (Just "Gender")
        []
        .genderVertical
        (UpdateField GenderVertical)
        (Focus GenderVertical)
        (Blur GenderVertical)
        [ RadioOption "Always Male, but with more, more characters" "male"
        , RadioOption "Always Female, but with longer label" "female"
        ]
        False
        (Just 5)
        []


privacyConfig : FormField Model Msg
privacyConfig =
    Form.checkboxConfig
        "privacy"
        (Just "Privacy")
        []
        .privacy
        (UpdateFlag Privacy)
        (Focus Privacy)
        (Blur Privacy)
        False
        (Just 6)
        []


visitedCountriesConfig : Model -> FormField Model Msg
visitedCountriesConfig { visitedCountries } =
    Form.checkboxWithOptionsConfig
        "visited_countries"
        (Just "Visited countries")
        []
        (List.map (\( label, slug, checked ) -> ( slug, checked )) << .visitedCountries)
        (UpdateCheckbox VisitedCountries)
        (Focus Privacy)
        (Blur Privacy)
        (List.map (\( label, slug, checked ) -> CheckboxOption label slug checked) visitedCountries)
        False
        (Just 7)
        []


cityConfig : Bool -> FormField Model Msg
cityConfig isOpen =
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
        (Focus City)
        (Blur City)
        (List.sortBy .label
            [ SelectOption "Milan" "MI"
            , SelectOption "Turin" "TO"
            , SelectOption "Rome" "RO"
            , SelectOption "Naples" "NA"
            , SelectOption "Genoa" "GE"
            ]
        )
        False
        (Just 8)
        [ NotEmpty "Empty value is not acceptable." ]


dateOfBirthConfig : Model -> FormField Model Msg
dateOfBirthConfig { isVisibleDP, dateOfBirthDP } =
    Form.datepickerConfig
        "date_of_birth"
        (Just "Date of Birth")
        []
        .dateOfBirth
        (UpdateField DateOfBirth)
        (UpdateDatePicker DateOfBirth)
        (Focus DateOfBirth)
        (Blur DateOfBirth)
        dateOfBirthDP
        isVisibleDP
        False
        (Just 9)
        [ Custom (Maybe.withDefault False << Maybe.map (always True) << .dateOfBirth) "This is not a valid date." ]


countryConfig : Model -> FormField Model Msg
countryConfig { countryFilter, isOpenCountry } =
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
        (Focus Country)
        (Blur Country)
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
        False
        (Just 10)
        [ NotEmpty "Empty value is not acceptable." ]


staticHtml : Model -> FormField Model Msg
staticHtml model =
    Form.pureHtmlConfig
        [ p [] [ text "Lorem ipsum dolor sit amet." ]
        ]



-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- UPDATE
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateField Username value ->
            ( { model
                | username = value
              }
            , Cmd.none
            )

        UpdateField Password value ->
            ( { model
                | password = value
              }
            , Cmd.none
            )

        UpdateField Note value ->
            ( { model
                | note = value
              }
            , Cmd.none
            )

        UpdateField Gender value ->
            ( { model
                | gender = value
              }
            , Cmd.none
            )

        UpdateField GenderVertical value ->
            ( { model
                | genderVertical = value
              }
            , Cmd.none
            )

        UpdateField City value ->
            ( { model
                | city = value
              }
            , Cmd.none
            )

        UpdateField Country value ->
            ( { model
                | country = value
                , countryFilter = Nothing
                , isOpenCountry = False
              }
            , Cmd.none
            )

        UpdateField DateOfBirth value ->
            let
                unwrap : Maybe (Maybe a) -> Maybe a
                unwrap theMaybe =
                    case theMaybe of
                        Just something ->
                            something

                        Nothing ->
                            Nothing
            in
            ( { model
                | dateOfBirth = value
                , dateOfBirthDP =
                    case (unwrap << Maybe.map (Result.toMaybe << Date.fromIsoString)) value of
                        Just date ->
                            DatePicker.init date ( lowDate, highDate )

                        _ ->
                            model.dateOfBirthDP
              }
            , Cmd.none
            )

        UpdateFlag Privacy value ->
            ( { model
                | privacy = value
              }
            , Cmd.none
            )

        UpdateDatePicker DateOfBirth dpMsg ->
            let
                updatedInstance =
                    DatePicker.update dpMsg model.dateOfBirthDP
            in
            ( { model
                | dateOfBirthDP = updatedInstance
                , dateOfBirth = (Just << Date.format "dd/MM/y" << DatePicker.selectedDate) updatedInstance
              }
            , Cmd.none
            )

        UpdateAutocomplete Country value ->
            ( { model
                | countryFilter = value
                , isOpenCountry = True
              }
            , Cmd.none
            )

        UpdateCheckbox VisitedCountries slug isChecked ->
            ( { model
                | visitedCountries =
                    List.map
                        (\( optLabel, optSlug, optChecked ) ->
                            if optSlug == slug then
                                ( optLabel, optSlug, isChecked )

                            else
                                ( optLabel, optSlug, optChecked )
                        )
                        model.visitedCountries
              }
            , Cmd.none
            )

        Toggle City isOpen ->
            ( { model
                | isOpenCity = isOpen
              }
            , Cmd.none
            )

        ToggleDatePicker ->
            ( { model
                | isVisibleDP = not model.isVisibleDP
              }
            , Cmd.none
            )

        Focus City ->
            ( { model
                | isOpenCity = True
                , isOpenCountry = False
              }
            , Cmd.none
            )

        Focus Country ->
            ( { model
                | isOpenCountry = True
                , isOpenCity = False
              }
            , Cmd.none
            )

        Focus _ ->
            ( model
            , Cmd.none
            )

        Blur _ ->
            ( model
            , Cmd.none
            )

        _ ->
            ( model
            , Cmd.none
            )



-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- VIEW
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------


view : Model -> Html Msg
view model =
    let
        toggleDatePicker =
            div
                [ class "m-form__field__group__append"
                ]
                [ i
                    [ class "a-icon a-icon-calendar cBrandAltDark"
                    , onClick ToggleDatePicker
                    ]
                    []
                ]
    in
    div
        [ class "wrapper" ]
        [ node "link"
            [ Html.Attributes.rel "stylesheet"
            , Html.Attributes.href "https://d3be8952cnveif.cloudfront.net/css/pyxis-1.5.8.css"
            ]
            []
        , div
            [ class "a-container" ]
            [ fieldset
                [ class "a-fieldset" ]
                [ legend
                    [ class "a-fieldset__legend" ]
                    [ text "Form example" ]
                , Form.wrapper <| (Form.render model usernameConfig ++ Form.render model passwordConfig)
                , Form.wrapper <| Form.render model noteConfig
                , Form.wrapper <| Form.render model genderConfig
                , Form.wrapper <| Form.render model genderVerticalConfig
                , Form.wrapper <| Form.render model privacyConfig
                , Form.wrapper <| Form.render model (visitedCountriesConfig model)
                , Form.wrapper <| Form.render model (cityConfig model.isOpenCity)
                , Form.wrapper <| Form.renderWithGroup [ toggleDatePicker ] model (dateOfBirthConfig model)
                , Form.wrapper <| Form.render model (countryConfig model)
                , Form.wrapper <| Form.render model (staticHtml model)
                ]
            ]
        ]
