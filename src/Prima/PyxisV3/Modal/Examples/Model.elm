module Prima.PyxisV3.Modal.Examples.Model exposing
    ( Modal(..)
    , Model
    , Msg(..)
    , initialModel
    )

import Prima.PyxisV3.Modal as Modal


type Msg
    = Show Modal
    | Hide Modal
    | PrintMsg String


type Modal
    = Small
    | Medium
    | Large


type alias Model =
    { messageToPrint : String
    , isModalVisible : Bool
    , smallModalConfig : Modal.Config Msg
    , largeModalConfig : Modal.Config Msg
    }


initialModel : Model
initialModel =
    { messageToPrint = ""
    , isModalVisible = False
    , smallModalConfig = Modal.smallAlt False (Hide Small)
    , largeModalConfig = Modal.large False (Hide Large)
    }
