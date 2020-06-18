module Prima.Pyxis.Form.Example.Model exposing
    ( BirthDateField(..)
    , Field(..)
    , FormData
    , Model
    , Msg(..)
    , UIState
    , initialModel
    )

import Date
import Prima.Pyxis.Form as Form
import Prima.Pyxis.Form.Autocomplete as Autocomplete
import Prima.Pyxis.Form.DatePicker as DatePicker
import Prima.Pyxis.Form.Select as Select


type Msg
    = OnInput Field String
    | OnCheck Field Bool
    | OnChange Field String
    | OnFocus Field
    | OnDateInput Field DatePicker.Date
    | OnDatePickerUpdate Field DatePicker.Msg
    | SelectMsg Select.Msg
    | AutocompleteMsg Autocomplete.Msg
    | OnTodayDateReceived Date.Date
    | ToggleTooltip
    | GotCountries (List Autocomplete.AutocompleteChoice)


type alias Model =
    { form : Form.Form FormData Msg
    , formData : FormData
    , today : Maybe Date.Date
    }


initialModel : Model
initialModel =
    Model Form.init initialFormData Nothing


type Field
    = Username
    | Password
    | Privacy
    | GuideType
    | FiscalCode
    | InsuranceType
    | Note
    | VisitedCountries
    | BirthDate
    | BirthDateCompound BirthDateField
    | UserPrivacyMarketing
    | UserPrivacyThirdPart


type BirthDateField
    = Day
    | Month
    | Year


type alias FormData =
    { username : Maybe String
    , password : Maybe String
    , privacy : Maybe Bool
    , guideType : Maybe String
    , powerSource : Maybe String
    , powerSourceSelect : Select.State
    , country : Maybe String
    , countryAutocomplete : Autocomplete.State
    , fiscalCode : Maybe String
    , countryVisited : List String
    , birthDate : DatePicker.Date
    , birthDateDatePicker : Maybe DatePicker.Model
    , birthDateDay : Maybe String
    , birthDateMonth : Maybe String
    , birthDateYear : Maybe String
    , insuranceType : Maybe String
    , note : Maybe String
    , userPrivacyMarketing : Maybe Bool
    , userPrivacyThirdPart : Maybe Bool
    , uiState : UIState
    }


initialFormData : FormData
initialFormData =
    { username = Nothing
    , password = Nothing
    , privacy = Nothing
    , guideType = Nothing
    , powerSource = Nothing
    , powerSourceSelect =
        Select.init
            [ Select.selectChoice "diesel" "Diesel"
            , Select.selectChoice "petrol" "Benzina"
            , Select.selectChoice "hybrid" "Benzina / Elettrico"
            ]
    , country = Nothing
    , countryAutocomplete =
        Autocomplete.init
            |> Autocomplete.withThreshold 1
            |> Autocomplete.withDebouncer 0.5
    , fiscalCode = Nothing
    , countryVisited = [ "italia", "francia" ]
    , birthDate = DatePicker.PartialDate Nothing
    , birthDateDatePicker = Nothing
    , birthDateDay = Nothing
    , birthDateMonth = Nothing
    , birthDateYear = Nothing
    , insuranceType = Nothing
    , note = Nothing
    , userPrivacyMarketing = Nothing
    , userPrivacyThirdPart = Nothing
    , uiState = initialUIState
    }


type alias UIState =
    { birthDateDatePickerOpened : Bool
    , usernameTooltipVisible : Bool
    }


initialUIState : UIState
initialUIState =
    { birthDateDatePickerOpened = False
    , usernameTooltipVisible = False
    }
