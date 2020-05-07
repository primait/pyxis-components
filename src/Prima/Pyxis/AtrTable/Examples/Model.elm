module Prima.Pyxis.AtrTable.Examples.Model exposing
    ( Model
    , Msg(..)
    , initialModel
    )

import Prima.Pyxis.AtrTable as AtrTable


type Msg
    = AtrTableMsg AtrTable.Msg


type alias Model =
    { atrDetails : List String
    , atrTable : AtrTable.State
    }


initialModel : Model
initialModel =
    let
        isEditable =
            True
    in
    Model [] <| (Tuple.first << (AtrTable.state isEditable << List.map createAtr)) (List.range 2012 2019)


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
