module Prima.Pyxis.AtrTable.Examples.View exposing (view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (class)
import Prima.Pyxis.AtrTable as AtrTable
import Prima.Pyxis.AtrTable.Examples.Model
    exposing
        ( Model
        , Msg(..)
        )
import Prima.Pyxis.Container as Container
import Prima.Pyxis.Helpers as Helpers


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
