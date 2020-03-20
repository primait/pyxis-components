module Prima.Pyxis.Form.Grid exposing (Row, addCol, addCols, addRow, col, create, render, row)

import Html exposing (Html, div)
import Html.Attributes as Attrs


type Config msg
    = Config (List (Row msg))


create : Config msg
create =
    Config []


type Row msg
    = Row (List (Column msg))


row : Row msg
row =
    Row []


addRow : Row msg -> Config msg -> Config msg
addRow row_ (Config grid) =
    Config (grid ++ [ row_ ])


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


render : Config msg -> List (Html msg)
render (Config grid) =
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
