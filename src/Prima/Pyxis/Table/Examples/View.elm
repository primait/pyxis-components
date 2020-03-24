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
    , Table.render model.tableState createTableConfiguration
    ]


createTableConfiguration : Table.Config Msg
createTableConfiguration =
    Table.config True SortBy
        |> Table.withHeaderClass "element"
        |> Table.withHeaders (createHeaders initialHeaders)
        |> Table.withRows (createRows initialRows)
        |> Table.withFooters (createRows [ initialHeaders ])


initialHeaders : List String
initialHeaders =
    [ "Nazione", "Capitale" ]


initialRows : List (List String)
initialRows =
    [ [ "Italia", "Roma" ]
    , [ "Francia", "Parigi" ]
    , [ "UK", "Londra" ]
    , [ "Russia", "Mosca" ]
    , [ "Spagna", "Madrid" ]
    , [ "Olanda", "Amsterdam" ]
    ]


createHeaders : List String -> List (Table.Header Msg)
createHeaders headers =
    List.map (\h -> Table.header (String.toLower h) [ Html.strong [] [ Html.text h ] ]) headers


createRows : List (List String) -> List (Table.Row Msg)
createRows rows =
    List.map (Table.row << createColumns) rows


createColumns : List String -> List (Table.Column Msg)
createColumns columns =
    List.map (Table.columnString 1) columns
