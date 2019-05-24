module Prima.Pyxis.ListChooser.Examples.Model exposing
    ( Model
    , Msg(..)
    , initialModel
    )

import Html exposing (..)
import Prima.Pyxis.Helpers as Helpers
import Prima.Pyxis.ListChooser.ListChooser as ListChooser exposing (ChooserItem)
import Tuple


type Msg
    = ChoosedMsg ListChooser.Msg


type alias Model =
    { finitures : List Finiture
    , chooserItemState : ListChooser.State
    }


type alias Finiture =
    { slug : String
    , content : String
    , isSelected : Bool
    }


initialModel : Model
initialModel =
    Model
        (buildList Finiture)
        (Tuple.first <| ListChooser.init <| buildList ListChooser.createItem)


buildList : (String -> String -> Bool -> something) -> List something
buildList constructor =
    List.map (\( slug, content ) -> constructor slug content False) finitureList


finitureList : List ( String, String )
finitureList =
    [ ( "finiture_1", "VOLKSWAGEN Golf 1.6 TDI 90 CV 5p. Tech&Sound BlueMo" )
    , ( "finiture_2", "VOLKSWAGEN Golf 1.6 TDI 110 CV 5p. " )
    , ( "finiture_3", "VOLKSWAGEN Golf 2.0 TDI 140 CV 5p. Trendline " )
    ]
