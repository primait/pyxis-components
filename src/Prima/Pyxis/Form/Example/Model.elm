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
    | GuideTypeField
    | PowerSource


type alias FormData =
    { username : Maybe String
    , password : Maybe String
    , privacy : Maybe Bool
    , guideType : Maybe String
    , powerSource : String
    }


initialFormData : FormData
initialFormData =
    { username = Nothing
    , password = Nothing
    , privacy = Nothing
    , guideType = Nothing
    , powerSource = "petrol"
    }
