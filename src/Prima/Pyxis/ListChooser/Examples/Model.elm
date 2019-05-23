module Prima.Pyxis.ListChooser.Examples.Model exposing
    ( Model
    , Msg(..)
    , initialModel
    )

import Html exposing (..)
import Prima.Pyxis.Helpers as Helpers
import Prima.Pyxis.ListChooser.ListChooser as ListChooser


type Msg
    = NoOp


type alias Model =
    { itemsList : List String
    }


initialModel : Model
initialModel =
    Model []
