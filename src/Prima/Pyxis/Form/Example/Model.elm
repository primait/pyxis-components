module Prima.Pyxis.Form.Example.Model exposing
    ( Field(..)
    , FormData
    , Model
    , Msg(..)
    , UIState
    , initialModel
    )

import Date
import Prima.Pyxis.Form as Form
import Prima.Pyxis.Form.DatePicker as DatePicker


type Msg
    = OnInput Field String
    | OnCheck Field Bool
    | OnChange Field String
    | OnFilter Field String
    | OnToggle Field
    | OnFocus Field
    | OnDateInput Field DatePicker.Date
    | OnDatePickerUpdate Field DatePicker.Msg
    | OnTodayDateReceived Date.Date


type alias Model =
    { form : Form.Config FormData Msg
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
    | PowerSource
    | Country
    | FiscalCode
    | InsurancePolicyType
    | Note
    | VisitedCountries
    | BirthDate


type alias FormData =
    { username : Maybe String
    , password : Maybe String
    , privacy : Maybe Bool
    , guideType : Maybe String
    , powerSource : Maybe String
    , country : Maybe String
    , countryFilter : Maybe String
    , fiscalCode : Maybe String
    , countryVisited : List String
    , birthDate : DatePicker.Date
    , birthDateDatePicker : Maybe DatePicker.Model
    , tipoPolizza : Maybe String
    , note : Maybe String
    , uiState : UIState
    }


initialFormData : FormData
initialFormData =
    { username = Nothing
    , password = Nothing
    , privacy = Nothing
    , guideType = Nothing
    , powerSource = Nothing
    , country = Nothing
    , countryFilter = Nothing
    , fiscalCode = Nothing
    , countryVisited = [ "italia", "francia" ]
    , birthDate = DatePicker.PartialDate Nothing
    , birthDateDatePicker = Nothing
    , tipoPolizza = Nothing
    , note = Nothing
    , uiState = initialUIState
    }


type alias UIState =
    { countryAutocompleteOpened : Bool
    , powerSourceSelectOpened : Bool
    , birthDateDatePickerOpened : Bool
    }


initialUIState : UIState
initialUIState =
    { countryAutocompleteOpened = False
    , powerSourceSelectOpened = False
    , birthDateDatePickerOpened = False
    }
