module Prima.Pyxis.Form.Grid exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)


type Grid msg
    = Grid (GridConfig msg)


type alias GridConfig msg =
    { columnCount : Int
    , children : List (Row msg)
    }


create : Grid msg
create =
    Grid <| GridConfig 12 []


type Row msg
    = Row (RowConfig msg)


type alias RowConfig msg =
    { children : List (Column msg)
    }


addRow : Row msg -> Grid msg -> Grid msg
addRow row (Grid gridConfig) =
    Grid { gridConfig | children = gridConfig.children ++ [ row ] }


createRow : Row msg
createRow =
    Row <| RowConfig []


type Column msg
    = Column (ColumnConfig msg)


type alias ColumnConfig msg =
    { children : List (Html msg)
    }


createCol : List (Html msg) -> Column msg
createCol children =
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



rm -rf src/Prima/Pyxis/Accordion/Example\ 2.elm
rm -rf src/Prima/Pyxis/Accordion/Examples/Model\ 2.elm
rm -rf src/Prima/Pyxis/Accordion/Examples/Update\ 2.elm
rm -rf src/Prima/Pyxis/Accordion/Examples/View\ 2.elm
rm -rf src/Prima/Pyxis/AtrTable/Example\ 2.elm
rm -rf src/Prima/Pyxis/AtrTable/Examples/Model\ 2.elm
rm -rf src/Prima/Pyxis/AtrTable/Examples/Update\ 2.elm
rm -rf src/Prima/Pyxis/AtrTable/Examples/View\ 2.elm
rm -rf src/Prima/Pyxis/Button/Example\ 2.elm
rm -rf src/Prima/Pyxis/Link/Example\ 2.elm
rm -rf src/Prima/Pyxis/ListChooser/Example\ 2.elm
rm -rf src/Prima/Pyxis/ListChooser/Examples/Model\ 2.elm
rm -rf src/Prima/Pyxis/ListChooser/Examples/Update\ 2.elm
rm -rf src/Prima/Pyxis/ListChooser/Examples/View\ 2.elm
rm -rf src/Prima/Pyxis/Loader/Example\ 2.elm
rm -rf src/Prima/Pyxis/Loader/Examples/Model\ 2.elm
rm -rf src/Prima/Pyxis/Loader/Examples/Update\ 2.elm
rm -rf src/Prima/Pyxis/Loader/Examples/View\ 2.elm
rm -rf src/Prima/Pyxis/Message/Example\ 2.elm
rm -rf src/Prima/Pyxis/Modal/Example\ 2.elm
rm -rf src/Prima/Pyxis/Modal/Examples/Model\ 2.elm
rm -rf src/Prima/Pyxis/Modal/Examples/Update\ 2.elm
rm -rf src/Prima/Pyxis/Modal/Examples/View\ 2.elm
rm -rf src/Prima/Pyxis/OLD_Form/Event\ 2.elm
rm -rf src/Prima/Pyxis/OLD_Form/Example\ 2.elm
rm -rf src/Prima/Pyxis/OLD_Form/Examples/FormConfig\ 2.elm
rm -rf src/Prima/Pyxis/OLD_Form/Examples/Model\ 2.elm
rm -rf src/Prima/Pyxis/OLD_Form/Examples/Update\ 2.elm
rm -rf src/Prima/Pyxis/OLD_Form/Examples/View\ 2.elm
rm -rf src/Prima/Pyxis/OLD_Form/Validation\ 2.elm
rm -rf src/Prima/Pyxis/Table/Example\ 2.elm
rm -rf src/Prima/Pyxis/Table/Examples/Model\ 2.elm
rm -rf src/Prima/Pyxis/Table/Examples/Update\ 2.elm
rm -rf src/Prima/Pyxis/Table/Examples/View\ 2.elm
rm -rf src/Prima/Pyxis/Tooltip/Example\ 2.elm
