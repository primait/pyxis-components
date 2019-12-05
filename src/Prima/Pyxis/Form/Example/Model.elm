module Prima.Pyxis.Form.Example.Model exposing
    ( Field(..)
    , FormData
    , Model
    , Msg(..)
    , initialModel
    )

import Prima.Pyxis.Form as Form


type Msg
    = OnInput Field String
    | OnCheck Field Bool
    | OnToggle Field Bool
    | OnSelect Field (Maybe String)


type alias Model =
    { form : Form.Form FormData Msg
    , formData : FormData
    , registrationMonthOpen : Bool
    , registrationYearOpen : Bool
    }


initialModel : Model
initialModel =
    Model (Form.init Form.Always) initialFormData False False


type Field
    = Username
    | Password
    | Privacy
    | GuideTypeField
    | PowerSource
    | RegistrationMonth
    | RegistrationYear


type alias FormData =
    { username : Maybe String
    , password : Maybe String
    , privacy : Maybe Bool
    , guideType : Maybe String
    , powerSource : Maybe String
    , registrationMonth : Maybe String
    , registrationYear : Maybe String
    }


initialFormData : FormData
initialFormData =
    { username = Nothing
    , password = Nothing
    , privacy = Nothing
    , guideType = Nothing
    , powerSource = Nothing
    , registrationMonth = Nothing
    , registrationYear = Nothing
    }
