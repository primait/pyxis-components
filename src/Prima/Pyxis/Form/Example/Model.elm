module Prima.Pyxis.Form.Example.Model exposing
    ( Field(..)
    , FormData
    , GuideType(..)
    , Model
    , Msg(..)
    , guideTypeToSlug
    , initialModel
    )

import Prima.Pyxis.Form as Form


type Msg
    = OnInput Field String
    | OnCheck Field Bool
    | OnChange Field String


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


type GuideType
    = Expert
    | Free


guideTypeToSlug : GuideType -> String
guideTypeToSlug guideType =
    case guideType of
        Expert ->
            "expert"

        Free ->
            "free"


type alias FormData =
    { username : Maybe String
    , password : Maybe String
    , privacy : Maybe Bool
    , guideType : Maybe String
    }


initialFormData : FormData
initialFormData =
    { username = Nothing
    , password = Nothing
    , privacy = Nothing
    , guideType = Nothing
    }
