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


createAtr : Int -> AtrTable.AtrDetail
createAtr year =
    year
        |> AtrTable.atr
        |> AtrTable.paritaria (Just "1")
        |> AtrTable.paritariaMista (Just "1")
        |> AtrTable.paritariaCose (Just "1")
        |> AtrTable.paritariaPersone (Just "1")
        |> AtrTable.principale (Just "1")
        |> AtrTable.principaleMista (Just "1")
        |> AtrTable.principaleCose (Just "1")
        |> AtrTable.principalePersone (Just "1")
