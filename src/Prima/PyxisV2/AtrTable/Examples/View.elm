module Prima.PyxisV2.AtrTable.Examples.View exposing (view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (class)
import Prima.PyxisV2.AtrTable as AtrTable
import Prima.PyxisV2.AtrTable.Examples.Model
    exposing
        ( Model
        , Msg(..)
        )
import Prima.PyxisV2.Container as Container
import Prima.PyxisV2.Helpers as Helpers


view : Model -> Browser.Document Msg
view model =
    Browser.Document "Atr Table component" (appBody model)


appBody : Model -> List (Html Msg)
appBody model =
    [ Helpers.pyxisStyle
    , Container.default
        [ Html.map AtrTableMsg <| AtrTable.render model.atrTable
        ]
    ]
