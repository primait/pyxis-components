module Prima.Pyxis.ListChooser.Examples.Model exposing
    ( Model
    , Msg(..)
    , initialModel
    )

import Prima.Pyxis.ListChooser as ListChooser


type Msg
    = ChosenMsg ListChooser.Msg


type alias Model =
    { config : ListChooser.Config
    , state : ListChooser.State
    }


initialModel : Model
initialModel =
    { config = createinitialConfig
    , state = createInitialState
    }


createinitialConfig : ListChooser.Config
createinitialConfig =
    ListChooser.config 3 "Mostra tutto" "Mostra i primi 3"


createInitialState : ListChooser.State
createInitialState =
    ListChooser.createState ListChooser.Partial
        |> ListChooser.withItems finitureList


finitureList : List ListChooser.ChooserItem
finitureList =
    [ ( "finiture_1", "VOLKSWAGEN Golf 1.6 TDI 90 CV 5p. Tech&Sound BlueMo", False )
    , ( "finiture_2", "VOLKSWAGEN Golf 1.6 TDI 110 CV 5p. ", False )
    , ( "finiture_3", "VOLKSWAGEN Golf 2.0 TDI 140 CV 5p. Trendline ", False )
    , ( "finiture_4", "Mercedes Golf 1.6 TDI 90 CV 5p. Tech&Sound BlueMo", False )
    , ( "finiture_5", "Audi Golf 1.6 TDI 110 CV 5p. ", False )
    , ( "finiture_6", "Tesla Golf 2.0 TDI 140 CV 5p. Trendline ", False )
    ]
        |> List.map (\( slug, label, isSelected ) -> ListChooser.createItem slug label isSelected)
