module Prima.Pyxis.Form.Grid exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)


type Grid msg
    = Grid (GridConfig msg)


type alias GridConfig msg =
    { columnCount : Int
    , children : List (Row msg)
    }


grid : List (Row msg) -> Grid msg
grid =
    Grid << GridConfig 12


type Row msg
    = Row (RowConfig msg)


type alias RowConfig msg =
    { children : List (Column msg)
    }


addRow : Row msg -> Grid msg -> Grid msg
addRow row (Grid gridConfig) =
    Grid { gridConfig | children = gridConfig.children ++ [ row ] }


gridRow : List (Column msg) -> Row msg
gridRow =
    Row << RowConfig


type Column msg
    = Column (ColumnConfig msg)


type alias ColumnConfig msg =
    { children : List (Html msg)
    }


gridCol : List (Html msg) -> Column msg
gridCol children =
    Column <| ColumnConfig children


render : Grid msg -> Html msg
render (Grid gridConfig) =
    div
        [ class "grid" ]
        (List.map (renderRow gridConfig.columnCount) gridConfig.children)


renderRow : Int -> Row msg -> Html msg
renderRow columnCount (Row rowConfig) =
    div
        [ class "grid__row" ]
        (List.map renderCol rowConfig.children)


renderCol : Column msg -> Html msg
renderCol (Column colConfig) =
    div
        [ class "grid__row__col" ]
        colConfig.children
