module Prima.Pyxis.Table.Examples.Model exposing
    ( Model
    , Msg(..)
    , initialModel
    )

import Html
import Prima.Pyxis.Table as Table


type Msg
    = TableMsg Table.Msg


type alias Model =
    { tableState : Table.State Msg
    , sortByColumn : Maybe String
    , sortBy : Maybe Table.Sort
    }


initialModel : Model
initialModel =
    Model
        initialState
        Nothing
        Nothing


initialState : Table.State Msg
initialState =
    Table.state Nothing Nothing
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


createHeaders : List String -> List Table.Header
createHeaders headers =
    List.map (\h -> Table.header (String.toLower h) [ Html.strong [] [ Html.text h ] ]) headers


createRows : List (List String) -> List (Table.Row Msg)
createRows rows =
    List.map (Table.row << createColumns) rows


createColumns : List String -> List (Table.Column Msg)
createColumns columns =
    List.map (Table.columnString 1) columns
