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
    | OnCheck Field String
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


type alias FormData =
    { username : Maybe String
    , password : Maybe String
    , privacy : Maybe String
    , guideType : Maybe String
    , powerSource : Maybe String
    , country : Maybe String
    , countryFilter : Maybe String
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
