module Prima.Pyxis.AtrTable.Examples.Model exposing
    ( Model
    , Msg(..)
    , initialModel
    )
import Prima.Pyxis.AtrTable.AtrTable as AtrTable

type Msg
    = AtrChanged
    | AtrTableMsg AtrTable.Msg


type alias Model =
    { atrDetails : List String
    }


initialModel : Model
initialModel =
    Model []
