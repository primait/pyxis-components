module Prima.Pyxis.Tables.Examples.View exposing (view)

import Browser
import Prima.Pyxis.Helpers as Helpers
import Prima.Pyxis.Tables.Examples.Model exposing (..)
import Prima.Pyxis.Tables.Tables as Tables


view : Model -> Browser.Document Msg
view model =
    { title = "Table"
    , body =
        [ Helpers.pyxisStyle
        , Tables.render model.tableState <| createTableConfiguration model
        ]
    }


createTableConfiguration : Model -> Tables.Config Msg
createTableConfiguration model =
    Tables.config
        (createHeaders model.headers)
        (createRows model.rows)
        True
        False


createHeaders : List String -> List (Tables.Header Msg)
createHeaders headers =
    List.map (\h -> Tables.header (String.toLower h) h SortBy) headers


createRows : List (List String) -> List (Tables.Row Msg)
createRows rows =
    List.map (\r -> Tables.row <| createColumns r) rows


createColumns : List String -> List (Tables.Column Msg)
createColumns columns =
    List.map (\c -> Tables.columnString c) columns
