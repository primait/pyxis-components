module Prima.Pyxis.AtrTable.Examples.Model exposing
    ( Model
    , Msg(..)
    , initialModel
    )

import Prima.Pyxis.AtrTable.AtrTable as AtrTable


type Msg
    = AtrTableMsg AtrTable.Msg


type alias Model =
    { atrDetails : List String
    , atrTable : AtrTable.Config
    }


initialModel : Model
initialModel =
    Model [] <| (Tuple.first << AtrTable.init << List.map createAtr) (List.range 2012 2019)


createAtr : Int -> AtrTable.Atr
createAtr year =
    year
        |> AtrTable.atr
        |> AtrTable.setEqual (Just "1")
        |> AtrTable.setEqualMixed (Just "1")
        |> AtrTable.setEqualObjects (Just "1")
        |> AtrTable.setEqualPeople (Just "1")
        |> AtrTable.setMain (Just "1")
        |> AtrTable.setMainMixed (Just "1")
        |> AtrTable.setMainObjects (Just "1")
        |> AtrTable.setMainPeople (Just "1")
