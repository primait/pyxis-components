module Prima.PyxisV3.AtrTable.Examples.View exposing (view)

import Browser
import Html exposing (Html)
import Prima.PyxisV3.AtrTable as AtrTable
import Prima.PyxisV3.AtrTable.Examples.Model
    exposing
        ( Model
        , Msg(..)
        )
import Prima.PyxisV3.Container as Container
import Prima.PyxisV3.Helpers as Helpers


view : Model -> Browser.Document Msg
view model =
    Browser.Document "Atr Table component" (appBody model)


appBody : Model -> List (Html Msg)
appBody model =
    [ Helpers.pyxisStyle
    , Helpers.pyxisIconSetStyle
    , Container.row
        |> Container.withContent
            [ Html.map AtrTableMsg <| AtrTable.render model.atrTable
            ]
        |> Container.render
    ]
