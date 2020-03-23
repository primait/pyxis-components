module Prima.Pyxis.Table.Examples.View exposing (view)

import Browser
import Html exposing (Html)
import Prima.Pyxis.Helpers as Helpers
import Prima.Pyxis.Table as Table
import Prima.Pyxis.Table.Examples.Model exposing (Model, Msg(..))


view : Model -> Browser.Document Msg
view model =
    { title = "Table"
    , body = appBody model
    }


appBody : Model -> List (Html Msg)
appBody model =
    [ Helpers.pyxisStyle
    , Html.map TableMsg (Table.render model.tableState createTableConfiguration)
    ]


createTableConfiguration : Table.Config
createTableConfiguration =
    Table.config True
        |> Table.withHeaderClass "element"
