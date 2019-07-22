module Prima.Pyxis.Table exposing
    ( Config, TableType, State, Header, Row, Column, ColSpan
    , config, initialState, defaultType, alternativeType
    , header, row
    , columnFloat, columnHtml, columnInteger, columnString
    , sortByAsc, sortByDesc, sortByNothing
    , render
    )

{-| Creates a customizable Table component by using predefined Html syntax.


# Configuration

@docs Config, TableType, State, Header, Row, Column, ColSpan


# Configuration Helpers

@docs config, initialState, defaultType, alternativeType


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
import Html.Attributes exposing (attribute, class, classList, colspan)
import Html.Events exposing (onClick)
import List.Extra


{-| Represents the static configuration of the component.
-}
type Config msg
    = Config (Configuration msg)


type alias Configuration msg =
    { tableType : TableType
    , clientSort : Bool
    , headers : List (Header msg)
    , rows : List (Row msg)
    , alternateRows : Bool
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

        in
        Table.config Table.defaultType headers rows alternateRows

    ...

-}
config : TableType -> Bool -> List (Header msg) -> List (Row msg) -> Bool -> Config msg
config tableType clientSort headers rows alternateRows =
    Config (Configuration tableType clientSort headers rows alternateRows)


{-| Represents the table skin.
-}
type TableType
    = Default
    | Alternative


{-| Represents the Default table skin.
-}
defaultType : TableType
defaultType =
    Default


{-| Represents the Alternative table skin.
-}
alternativeType : TableType
alternativeType =
    Alternative


isAlternativeTableType : TableType -> Bool
isAlternativeTableType =
    (==) Alternative


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
    , tagger : Maybe (Slug -> msg)
    }


{-| Creates and Header.

    myHeader : String -> String -> (String -> Msg) -> Table.Header Msg
    myHeader slug content sortByTagger =
        Table.header slug content sortByTagger

-}
header : Slug -> Name -> Maybe (Slug -> msg) -> Header msg
header slug name maybeTagger =
    Header <| HeaderConfiguration slug name maybeTagger


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
    = StringColumn ColSpan String
    | IntegerColumn ColSpan Int
    | FloatColumn ColSpan Float
    | HtmlColumn ColSpan (List (Html msg))


{-| Creates a Column which content is String primitive.
-}
columnString : ColSpan -> String -> Column msg
columnString colSpan content =
    Column (StringColumn colSpan content)


{-| Creates a Column which content is Integer primitive.
-}
columnInteger : ColSpan -> Int -> Column msg
columnInteger colSpan content =
    Column (IntegerColumn colSpan content)


{-| Creates a Column which content is Float primitive.
-}
columnFloat : ColSpan -> Float -> Column msg
columnFloat colSpan content =
    Column (FloatColumn colSpan content)


{-| Creates a Column which content is Html.
-}
columnHtml : ColSpan -> List (Html msg) -> Column msg
columnHtml colSpan content =
    Column (HtmlColumn colSpan content)


type alias Slug =
    String


type alias Name =
    String


{-| Represents the colSpan of a column. Alias for Integer.
-}
type alias ColSpan =
    Int


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
        StringColumn _ content ->
            content

        IntegerColumn _ content ->
            String.fromInt content

        FloatColumn _ content ->
            String.fromFloat content

        HtmlColumn _ _ ->
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
render (State ({ sortBy, sortedColumn } as internalState)) (Config conf) =
    let
        index =
            (Maybe.withDefault 0 << retrieveHeaderIndexBySlug sortedColumn) conf.headers

        sortedRows =
            if conf.clientSort then
                case sortBy of
                    Nothing ->
                        conf.rows

                    Just Asc ->
                        sortRows index conf.rows

                    Just Desc ->
                        (List.reverse << sortRows index) conf.rows

            else
                conf.rows

        headerSlugs =
            List.map (\(Header { slug }) -> slug) conf.headers
    in
    table
        [ classList
            [ ( "m-table", True )
            , ( "m-table--alt", isAlternativeTableType conf.tableType )
            , ( "m-table--alternateRows", conf.alternateRows )
            ]
        ]
        [ renderTHead internalState conf
        , renderTBody headerSlugs sortedRows
        ]


renderTHead : InternalState -> Configuration msg -> Html msg
renderTHead internalState ({ headers } as conf) =
    thead
        [ class "m-table__header" ]
        (List.map (renderTH internalState) headers)


renderTH : InternalState -> Header msg -> Html msg
renderTH { sortBy, sortedColumn } (Header ({ slug, name } as conf)) =
    let
        sort : { sortableAttribute : Html.Attribute msg, sortIcon : Html msg }
        sort =
            case conf.tagger of
                Just tagger ->
                    { sortableAttribute = (onClick << tagger) slug, sortIcon = renderSortIcon sortBy slug }

                Nothing ->
                    { sortableAttribute = attribute "data-unsortable" "", sortIcon = text "" }

        sortColumn : String
        sortColumn =
            case sortedColumn of
                Just columnName ->
                    columnName

                Nothing ->
                    ""
    in
    th
        (sort.sortableAttribute
            :: [ class "m-table__header__item fsSmall"
               ]
        )
        [ text name
        , if sortColumn == slug then
            sort.sortIcon

          else
            text ""
        ]


renderSortIcon : Maybe Sort -> Slug -> Html msg
renderSortIcon sort slug =
    i
        [ classList
            [ ( "a-icon", True )
            , ( "m-table__header__item", True )
            , ( "a-icon-caret-up", sort == Just Asc )
            , ( "a-icon-caret-down", sort == Just Desc )
            ]
        ]
        []


renderTBody : List Slug -> List (Row msg) -> Html msg
renderTBody headerSlugs rows =
    tbody
        [ class "m-table__body" ]
        (List.map (renderTR headerSlugs) rows)


renderTR : List Slug -> Row msg -> Html msg
renderTR headerSlugs (Row columns) =
    let
        columnsDictionary =
            List.map2 (\slug col -> ( slug, col )) headerSlugs columns
    in
    tr
        [ class "m-table__body__row" ]
        (List.map renderTD columnsDictionary)


renderTD : ( Slug, Column msg ) -> Html msg
renderTD ( slug, Column conf ) =
    td
        [ class "m-table__body__row__col fsSmall"
        , (colspan << pickColSpan) conf
        , attribute "data-column" slug
        ]
        (case conf of
            StringColumn _ content ->
                (List.singleton << text) content

            IntegerColumn _ content ->
                (List.singleton << text << String.fromInt) content

            FloatColumn _ content ->
                (List.singleton << text << String.fromFloat) content

            HtmlColumn _ content ->
                content
        )


pickColSpan : ColumnConfiguration msg -> Int
pickColSpan conf =
    case conf of
        StringColumn colSpan _ ->
            colSpan

        IntegerColumn colSpan _ ->
            colSpan

        FloatColumn colSpan _ ->
            colSpan

        HtmlColumn colSpan _ ->
            colSpan
