module Prima.Pyxis.AtrTable.Examples.View exposing (view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (class)
import Prima.Pyxis.AtrTable.AtrTable as AtrTable
import Prima.Pyxis.AtrTable.Examples.Model
    exposing
        ( Model
        , Msg(..)
        )
import Prima.Pyxis.Helpers as Helpers


view : Model -> Browser.Document Msg
view model =
    Browser.Document "Atr Table component" (appBody model)


appBody : Model -> List (Html Msg)
appBody model =
    [ Helpers.pyxisStyle
    , div
        [ class "a-container a-container--medium directionColumn" ]
        [ (Html.map AtrTableMsg
            << AtrTable.render
            << Tuple.first
            << AtrTable.init
            << List.repeat 5
          )
            createAtr
        ]
    ]


createAtr : AtrTable.Atr
createAtr =
    2019
        |> AtrTable.atr
        |> AtrTable.setEqual (Just "1")
        |> AtrTable.setEqualMixed (Just "1")
        |> AtrTable.setEqualObjects (Just "1")
        |> AtrTable.setEqualPeople (Just "1")
        |> AtrTable.setMain (Just "1")
        |> AtrTable.setMainMixed (Just "1")
        |> AtrTable.setMainObjects (Just "1")
        |> AtrTable.setMainPeople (Just "1")
