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
    { form : Form.Form Msg
    , formData : FormData
    }


initialModel : Model
initialModel =
    Model (Form.init Form.Always) initialFormData


type Field
    = Username
    | Password
    | Privacy


type alias FormData =
    { username : String
    , password : String
    , privacy : Maybe Bool
    }


initialFormData : FormData
initialFormData =
    { username = ""
    , password = ""
    , privacy = Nothing
    }
