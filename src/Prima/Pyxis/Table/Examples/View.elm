module Prima.Pyxis.Table.Examples.View exposing (view)

import Browser
import Html exposing (Html)
import Prima.Pyxis.Helpers as Helpers
import Prima.Pyxis.Table.Examples.Model exposing (..)
import Prima.Pyxis.Table.Table as Table


view : Model -> Browser.Document Msg
view model =
    { title = "Table"
    , body = appBody model
    }


appBody : Model -> List (Html Msg)
appBody model =
    [ Helpers.pyxisStyle
    , (Table.render model.tableState << createTableConfiguration) model
    ]


createTableConfiguration : Model -> Table.Config Msg
createTableConfiguration model =
    Table.config
        (createHeaders model.headers)
        (createRows model.rows)
        True
        False


createHeaders : List String -> List (Table.Header Msg)
createHeaders headers =
    List.map createHeaderItem headers


createHeaderItem : String -> Table.Header Msg
createHeaderItem content =
    Table.header (String.toLower content) content SortBy


createRows : List (List String) -> List (Table.Row Msg)
createRows rows =
    List.map (Table.row << createColumns) rows


createColumns : List String -> List (Table.Column Msg)
createColumns columns =
    List.map Table.columnString columns
