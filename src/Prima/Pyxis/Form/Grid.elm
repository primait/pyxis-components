module Prima.Pyxis.Form.Grid exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes as Attrs


type Grid msg
    = Grid (GridConfig msg)


type alias GridConfig msg =
    { children : List (Row msg)
    }


create : Grid msg
create =
    Grid <| GridConfig []


type Row msg
    = Row (RowConfig msg)


type alias RowConfig msg =
    { children : List (Column msg)
    }


row : Row msg
row =
    Row <| RowConfig []


addRow : Row msg -> Grid msg -> Grid msg
addRow row_ (Grid gridConfig) =
    Grid { gridConfig | children = gridConfig.children ++ [ row_ ] }


type Column msg
    = Column (ColumnConfig msg)


type alias ColumnConfig msg =
    { children : List (Html msg)
    }


col : List (Html msg) -> Column msg
col children =
    Column <| ColumnConfig children


addCol : Column msg -> Row msg -> Row msg
addCol column (Row rowConfig) =
    Row { rowConfig | children = rowConfig.children ++ [ column ] }


addCols : List (Column msg) -> Row msg -> Row msg
addCols cols (Row rowConfig) =
    Row { rowConfig | children = rowConfig.children ++ cols }


render : Grid msg -> Html msg
render (Grid gridConfig) =
    div
        [ Attrs.class "a-fieldset grid" ]
        (List.map renderRow gridConfig.children)


renderRow : Row msg -> Html msg
renderRow (Row rowConfig) =
    div
        [ Attrs.class "grid__row"
        , rowConfig.children
            |> List.length
            |> String.fromInt
            |> Attrs.attribute "data-children-count"
        ]
        (List.map renderCol rowConfig.children)


renderCol : Column msg -> Html msg
renderCol (Column colConfig) =
    div
        [ Attrs.class "grid__row__col" ]
        colConfig.children
