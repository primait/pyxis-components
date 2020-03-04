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
    , (Table.render model.tableState << createTableConfiguration) model
    ]


createTableConfiguration : Model -> Table.Config Msg
createTableConfiguration model =
    Table.config
        Table.defaultType
        True
        (createHeaders model.headers)
        (createRows model.rows)
        True
        createFooters
        [ ( "my-custom-class", True ) ]


createHeaders : List String -> List (Table.Header Msg)
createHeaders _ =
    [ Table.header (String.toLower "Nazione") "Nazione" (Just SortBy)
    , Table.header (String.toLower "Paese") "Paese" (Just SortBy)
    ]


createFooters : List (Table.FooterRow Msg)
createFooters =
    [ Table.footerRow (createFooterColumns [ "Nazione", "Paese" ]) ]


createRows : List (List String) -> List (Table.Row Msg)
createRows rows =
    List.map (Table.row << createColumns) rows


createColumns : List String -> List (Table.Column Msg)
createColumns columns =
    List.map (Table.columnString 1) columns


createFooterColumns : List String -> List (Table.FooterColumn Msg)
createFooterColumns columns =
    List.map (Table.footerColumnString 1) columns
