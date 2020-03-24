module Prima.Pyxis.Form.Grid exposing (Row, addCol, addCols, addRow, col, create, render, row)

import Html exposing (Html, div)
import Html.Attributes as Attrs


type Grid msg
    = Grid (List (Row msg))


create : Grid msg
create =
    Grid []


type Row msg
    = Row (List (Column msg))


row : Row msg
row =
    Row []


addRow : Row msg -> Grid msg -> Grid msg
addRow row_ (Grid grid) =
    Grid (grid ++ [ row_ ])


type Column msg
    = Column (List (Html msg))


col : List (Html msg) -> Column msg
col children =
    Column children


addCol : Column msg -> Row msg -> Row msg
addCol column (Row rows) =
    Row (rows ++ [ column ])


addCols : List (Column msg) -> Row msg -> Row msg
addCols cols (Row rows) =
    Row (rows ++ cols)


render : Grid msg -> List (Html msg)
render (Grid grid) =
    List.map renderRow grid


renderRow : Row msg -> Html msg
renderRow (Row rows) =
    div
        [ Attrs.class "a-form-field"
        , rows
            |> List.length
            |> String.fromInt
            |> Attrs.attribute "data-children-count"
        ]
        (List.map renderCol rows)


renderCol : Column msg -> Html msg
renderCol (Column col_) =
    div
        [ Attrs.class "a-form-field__item" ]
        col_
