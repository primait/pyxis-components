module Prima.Pyxis.Table.Table exposing
    ( Config, State, Header, Row, Column
    , config, initialState
    , header, row
    , columnFloat, columnHtml, columnInteger, columnString
    , sortByAsc, sortByDesc, sortByNothing
    , render
    )

{-| Creates a customizable Table component by using predefined Html syntax.


# Configuration

@docs Config, State, Header, Row, Column


# Configuration Helpers

@docs config, initialState


# Configuration for Rows & Headers

@docs header, row


# Configuration for Columns

@docs columnFloat, columnHtml, columnInteger, columnString


# Helpers

@docs sortByAsc, sortByDesc, sortByNothing


# Render

@docs render

-}

import Array exposing (Array)
import Html exposing (Html, i, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (attribute, class, classList)
import Html.Events exposing (onClick)
import List.Extra


{-| Represents the static configuration of the component.
-}
type Config msg
    = Config (Configuration msg)


type alias Configuration msg =
    { headers : List (Header msg)
    , rows : List (Row msg)
    , alternateRows : Bool
    , isSortable : Bool
    }


{-| Returns the config of the component.

    ...

    type Msg =
        SortBy String
    ...

    myTableConfig : Table.Config
    myTableConfig =
        let
            headers : List (Table.Header Msg)
            headers =
                List.map (\content -> Table.header (String.toLower content) content SortBy) [ "Country", "Capital city" ]

            rows : List (Table.Row Msg)
            rows =
                List.map (Table.row << List.map Table.columnString ) [ ["Italy", "Rome"], ["France", "Paris"], ["U.K.", "London"] ]

            alternateRows =
                True

            isSortable =
                True
        in
        Table.config headers rows alternateRows isSortable

    ...

-}
config : List (Header msg) -> List (Row msg) -> Bool -> Bool -> Config msg
config headers rows alternateRows isSortable =
    Config (Configuration headers rows alternateRows isSortable)


{-| Represents the basic state of the component.
-}
type State
    = State InternalState


{-| Creates an initial State with no sort applied.
-}
initialState : State
initialState =
    State (InternalState Nothing Nothing)


type alias InternalState =
    { sortBy : Maybe Sort
    , sortedColumn : Maybe Slug
    }


type Sort
    = Asc
    | Desc


{-| Sorts the column defined by Slug in Asc order.
-}
sortByAsc : Slug -> State -> State
sortByAsc sortBySlug (State internalState) =
    State { internalState | sortBy = Just Asc, sortedColumn = Just sortBySlug }


{-| Sorts the column defined by Slug in Desc order.
-}
sortByDesc : Slug -> State -> State
sortByDesc sortBySlug (State internalState) =
    State { internalState | sortBy = Just Desc, sortedColumn = Just sortBySlug }


{-| Unsets sorting for any column.
-}
sortByNothing : Slug -> State -> State
sortByNothing _ (State internalState) =
    State { internalState | sortBy = Nothing, sortedColumn = Nothing }


{-| Represents an Header of the table. It's gonna be rendered as a <th/> tag.
-}
type Header msg
    = Header (HeaderConfiguration msg)


type alias HeaderConfiguration msg =
    { slug : Slug
    , name : Name
    , tagger : Slug -> msg
    }


{-|


## Creates and Header.

    myHeader : String -> String -> (String -> Msg) -> Table.Header Msg
    myHeader slug content sortByTagger =
        Table.header slug content sortByTagger

-}
header : Slug -> Name -> (Slug -> msg) -> Header msg
header slug name tagger =
    Header <| HeaderConfiguration slug name tagger


{-| Represents a Row which contains a list of Columns.
-}
type Row msg
    = Row (List (Column msg))


{-| Creates a Row

    myRow : List (Column Msg) -> Table.Row Msg
    myRow columns =
        Table.row columns

-}
row : List (Column msg) -> Row msg
row columns =
    Row columns


{-| Represents a Column which can manage a specific kind of data.
-}
type Column msg
    = Column (ColumnConfiguration msg)


type ColumnConfiguration msg
    = StringColumn String
    | IntegerColumn Int
    | FloatColumn Float
    | HtmlColumn (List (Html msg))


{-| Creates a Column which content is String primitive.
-}
columnString : String -> Column msg
columnString content =
    Column (StringColumn content)


{-| Creates a Column which content is Integer primitive.
-}
columnInteger : Int -> Column msg
columnInteger content =
    Column (IntegerColumn content)


{-| Creates a Column which content is Float primitive.
-}
columnFloat : Float -> Column msg
columnFloat content =
    Column (FloatColumn content)


{-| Creates a Column which content is Html.
-}
columnHtml : List (Html msg) -> Column msg
columnHtml content =
    Column (HtmlColumn content)


type alias Slug =
    String


type alias Name =
    String


sortRows : Int -> List (Row msg) -> List (Row msg)
sortRows columnIndex rows =
    List.sortBy
        (Maybe.withDefault ""
            << Maybe.map columnToComparable
            << Array.get columnIndex
            << Array.fromList
            << pickColumnsFromRow
        )
        rows


columnToComparable : Column msg -> String
columnToComparable (Column columnConf) =
    case columnConf of
        StringColumn content ->
            content

        IntegerColumn content ->
            String.fromInt content

        FloatColumn content ->
            String.fromFloat content

        HtmlColumn _ ->
            ""


pickColumnsFromRow : Row msg -> List (Column msg)
pickColumnsFromRow (Row columns) =
    columns


retrieveHeaderIndexBySlug : Maybe Slug -> List (Header msg) -> Maybe Int
retrieveHeaderIndexBySlug slug headers =
    headers
        |> List.map (\(Header h) -> h.slug)
        |> List.Extra.findIndex ((==) slug << Just)


{-| Renders a Table by receiving a State and a Config
-}
render : State -> Config msg -> Html msg
render (State ({ sortBy, sortedColumn } as state)) (Config conf) =
    let
        index =
            (Maybe.withDefault 0 << retrieveHeaderIndexBySlug sortedColumn) conf.headers

        sortedRows =
            case sortBy of
                Nothing ->
                    conf.rows

                Just Asc ->
                    sortRows index conf.rows

                Just Desc ->
                    (List.reverse << sortRows index) conf.rows
    in
    table
        [ classList
            [ ( "m-table", True )
            , ( "m-table--alternateRows", conf.alternateRows )
            ]
        ]
        [ renderTHead state conf
        , renderTBody sortedRows
        ]


renderTHead : InternalState -> Configuration msg -> Html msg
renderTHead internalState ({ headers } as conf) =
    thead
        [ class "m-table__header" ]
        (List.map (renderTH internalState conf) headers)


renderTH : InternalState -> Configuration msg -> Header msg -> Html msg
renderTH { sortBy } { isSortable } (Header { slug, name, tagger }) =
    let
        sortableAttribute =
            if isSortable then
                (onClick << tagger) slug

            else
                attribute "data-unsortable" ""
    in
    th
        (sortableAttribute
            :: [ class "m-table__header__item fsSmall"
               ]
        )
        [ text name
        , renderSortIcon sortBy slug
        ]


renderSortIcon : Maybe Sort -> Slug -> Html msg
renderSortIcon sort slug =
    i
        [ classList
            [ ( "a-icon", True )
            , ( "m-table__header__item", True )
            , ( "a-icon--chevron-up", sort == Just Asc )
            , ( "a-icon--chevron-down", sort == Just Desc )
            ]
        ]
        []


renderTBody : List (Row msg) -> Html msg
renderTBody rows =
    tbody
        [ class "m-table__body" ]
        (List.map renderTR rows)


renderTR : Row msg -> Html msg
renderTR (Row columns) =
    tr
        [ class "m-table__body__row" ]
        (List.map renderTD columns)


renderTD : Column msg -> Html msg
renderTD (Column columnType) =
    td
        [ class "m-table__body__row__col fsSmall" ]
        (case columnType of
            StringColumn content ->
                (List.singleton << text) content

            IntegerColumn content ->
                (List.singleton << text << String.fromInt) content

            FloatColumn content ->
                (List.singleton << text << String.fromFloat) content

            HtmlColumn content ->
                content
        )
