module Prima.Pyxis.Modal.Examples.Model exposing
    ( Model
    , Msg(..)
    , initialModel
    )


type Msg
    = Show
    | Hide


type alias Model =
    { isModalVisible : Bool
    }


initialModel : Model
initialModel =
    Model False
