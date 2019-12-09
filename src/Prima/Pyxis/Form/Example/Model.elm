module Prima.Pyxis.Form.Example.Model exposing
    ( Field(..)
    , FormData
    , Model
    , Msg(..)
    , UIState
    , initialModel
    )

import Prima.Pyxis.Form as Form


type Msg
    = OnInput Field String
    | OnCheck Field Bool
    | OnFilter Field String
    | OnToggle Field


type alias Model =
    { form : Form.Form FormData Msg
    , formData : FormData
    }


initialModel : Model
initialModel =
    Model (Form.init Form.Always) initialFormData


type Field
    = Username
    | Password
    | Privacy
    | GuideType
    | PowerSource
    | Country
    | FiscalCode


type alias FormData =
    { username : Maybe String
    , password : Maybe String
    , privacy : Maybe Bool
    , guideType : Maybe String
    , powerSource : Maybe String
    , country : Maybe String
    , countryFilter : Maybe String
    , fiscalCode : Maybe String
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
    , uiState = initialUIState
    }


type alias UIState =
    { countryAutocompleteOpened : Bool
    , powerSourceSelectOpened : Bool
    }


initialUIState : UIState
initialUIState =
    { countryAutocompleteOpened = False
    , powerSourceSelectOpened = False
    }
