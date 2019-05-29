module Prima.Pyxis.ListChooser.Examples.Model exposing
    ( Model
    , Msg(..)
    , initialModel
    )

import Html exposing (..)
import Prima.Pyxis.Helpers as Helpers
import Prima.Pyxis.ListChooser as ListChooser exposing (ChooserItem)
import Tuple


type Msg
    = ChoosedMsg ListChooser.Msg


type alias Model =
    { chooserItemState : ListChooser.State
    }


initialModel : Model
initialModel =
    Model
        (Tuple.first <| ListChooser.init ListChooser.viewModePartial itemList)


itemList : List ListChooser.ChooserItem
itemList =
    List.map (\( slug, content ) -> ListChooser.createItem slug content False) finitureList


finitureList : List ( String, String )
finitureList =
    [ ( "finiture_1", "VOLKSWAGEN Golf 1.6 TDI 90 CV 5p. Tech&Sound BlueMo" )
    , ( "finiture_2", "VOLKSWAGEN Golf 1.6 TDI 110 CV 5p. " )
    , ( "finiture_3", "VOLKSWAGEN Golf 2.0 TDI 140 CV 5p. Trendline " )
    , ( "finiture_4", "Mercedes Golf 1.6 TDI 90 CV 5p. Tech&Sound BlueMo" )
    , ( "finiture_5", "Audi Golf 1.6 TDI 110 CV 5p. " )
    , ( "finiture_6", "Tesla Golf 2.0 TDI 140 CV 5p. Trendline " )
    ]
