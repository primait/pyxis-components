module Prima.Pyxis.Form.Examples.Model exposing
    ( FieldName(..)
    , Flags
    , FormData
    , Label
    , Model
    , Msg(..)
    , Slug
    , highDate
    , initialDate
    , initialFormData
    , initialModel
    , lowDate
    )

import Date exposing (Date)
import Prima.Pyxis.DatePicker as DatePicker
import Prima.Pyxis.Form as Form exposing (ValidationVisibilityPolicy)
import Time exposing (Month(..))


type alias Model =
    { data : FormData
    , formConfig : Form.Form FormData Msg
    }


initialModel : Model
initialModel =
    Model initialFormData (Form.init Form.WhenSubmitted)


type alias FormData =
    { username : Maybe String
    , password : Maybe String
    , note : Maybe String
    , gender : Maybe String
    , city : Maybe String
    , isOpenCity : Bool
    , dateOfBirth : Maybe String
    , dateOfBirthDP : DatePicker.Model
    , isVisibleDP : Bool
    , country : Maybe String
    , countryFilter : Maybe String
    , isOpenCountry : Bool
    , visitedCountries : List ( Label, Slug, Bool )
    }


initialFormData : FormData
initialFormData =
    FormData
        Nothing
        Nothing
        Nothing
        Nothing
        Nothing
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


type FieldName
    = Gender
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
    | UpdateCheckbox FieldName ( Slug, Bool )
    | Toggle FieldName
    | FetchDateToday Date
    | OnFocus FieldName
    | OnBlur FieldName
    | ToggleDatePicker
    | Submit
    | Reset
    | ChangeValidationPolicy ValidationVisibilityPolicy
