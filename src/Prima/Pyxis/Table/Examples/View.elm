module Prima.Pyxis.Table.Examples.View exposing (view)

import Browser
import Html exposing (Html, h3, text)
import Html.Attributes exposing (style)
import Prima.Pyxis.Helpers as Helpers
import Prima.Pyxis.Table as Table
import Prima.Pyxis.Table.Examples.Model exposing (..)
import Prima.Pyxis.Table.TableWithAttributes as Table


view : Model -> Browser.Document Msg
view model =
    { title = "Table"
    , body = appBody model
    }


appBody : Model -> List (Html Msg)
appBody model =
    [ Helpers.pyxisStyle
    , h3 [] [ text "Table" ]
    , (Table.render model.tableState << createTableConfiguration) model
    , h3 [] [ text "Table with attributes" ]
    , Table.renderWithAttributes model.tableState
        (createTableConfiguration model)
        [ Table.tableAttributes [ style "background-color" "antiquewhite" ] ]
    ]


createTableConfiguration : Model -> Table.Config Msg
createTableConfiguration model =
    Table.config
        Table.defaultType
        True
        (createHeaders model.headers)
        (createRows model.rows)
        True


createHeaders : List String -> List (Table.Header Msg)
createHeaders headers =
    [ Table.header (String.toLower "Nazione") "Nazione" (Just SortBy)
    , Table.header (String.toLower "Paese") "Paese" (Just SortBy)
    ]


createHeaderItem : String -> Table.Header Msg
createHeaderItem content =
    Table.header (String.toLower content) content (Just SortBy)


createRows : List (List String) -> List (Table.Row Msg)
createRows rows =
    List.map (Table.row << createColumns) rows


createColumns : List String -> List (Table.Column Msg)
createColumns columns =
    List.map (Table.columnString 1) columns
