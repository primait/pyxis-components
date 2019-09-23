module Prima.Pyxis.Table exposing
    ( Config, TableType, State, Header, Row, Column, ColSpan, Sort
    , config, initialState, defaultType, alternativeType
    , header, row
    , columnFloat, columnHtml, columnInteger, columnString
    , sort, sortAsc, sortDesc
    , render
    , Footer, FooterColumn, FooterRow, footerColumnFloat, footerColumnHtml, footerColumnInteger, footerColumnString, footerRow
    )

{-| Creates a customizable Table component by using predefined Html syntax.


# Configuration

@docs Config, TableType, State, Header, Row, Column, ColSpan, Sort


# Configuration Helpers

@docs config, initialState, defaultType, alternativeType


# Configuration for Rows & Headers

@docs header, row


# Configuration for Columns

@docs columnFloat, columnHtml, columnInteger, columnString


# Helpers

@docs sort, sortAsc, sortDesc


# Render

@docs render

-}

import Array exposing (Array)
import Html exposing (Html, i, table, tbody, td, text, tfoot, th, thead, tr)
import Html.Attributes exposing (attribute, class, classList, colspan)
import Html.Events exposing (onClick)
import List.Extra


{-| Represents the static configuration of the component.
-}
type Config msg
    = Config (Configuration msg)


type alias Configuration msg =
    { tableType : TableType
    , sorting : Bool
    , headers : List (Header msg)
    , rows : List (Row msg)
    , alternateRows : Bool
    , footerColumns : List (FooterRow msg)
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

            footerColumns =
                []

        in
        Table.config Table.defaultType sorting headers rows alternateRows footerColumns

    ...

-}
config : TableType -> Bool -> List (Header msg) -> List (Row msg) -> Bool -> List (FooterRow msg) -> Config msg
config tableType sorting headers rows alternateRows footerColumns =
    Config (Configuration tableType sorting headers rows alternateRows footerColumns)


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


{-| Creates an initial State defined by Sort and Column.
-}
initialState : Maybe Sort -> Maybe String -> State
initialState sortBy sortedColumn =
    State (InternalState sortBy sortedColumn)


type alias InternalState =
    { sortBy : Maybe Sort
    , sortedColumn : Maybe Slug
    }


{-| Represents the sort algorithm
-}
type Sort
    = Asc
    | Desc


{-| Returns the Ascending sort algorithm.
-}
sortAsc : Maybe Sort
sortAsc =
    Just Asc


{-| Returns the Descending sort algorithm.
-}
sortDesc : Maybe Sort
sortDesc =
    Just Desc


{-| Sets the sorting algorithm for a specific column.
-}
sort : Maybe Slug -> Maybe Sort -> State -> State
sort sortedColumnSlug sortAlgorithm (State internalState) =
    State { internalState | sortBy = sortAlgorithm, sortedColumn = sortedColumnSlug }


{-| Represents an Header of the table. It's gonna be rendered as a <th/> tag.
-}
type Header msg
    = Header (HeaderConfiguration msg)


{-| Represents a Footer of the table. It's gonna be rendered as a <tr/> tag inside a tfoot.
-}
type Footer msg
    = Footer (FooterColumnConfiguration msg)


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


{-| Represents a Footer Row which contains a list of Columns.
-}
type FooterRow msg
    = FooterRow (List (FooterColumn msg))


{-| Creates a FooterRow

    myRow : List (FooterColumn Msg) -> Table.footerRow Msg
    myRow columns =
        Table.footerRow columns

-}
footerRow : List (FooterColumn msg) -> FooterRow msg
footerRow columns =
    FooterRow columns


{-| Represents a Column which can manage a specific kind of data.
-}
type Column msg
    = Column (ColumnConfiguration msg)


type ColumnConfiguration msg
    = StringColumn ColSpan String
    | IntegerColumn ColSpan Int
    | FloatColumn ColSpan Float
    | HtmlColumn ColSpan (List (Html msg))


{-| Represents a Footer Column which can manage a specific kind of data.
-}
type FooterColumn msg
    = FooterColumn (FooterColumnConfiguration msg)


type FooterColumnConfiguration msg
    = HtmlFooterColumn ColSpan (List (Html msg))
    | StringFooterColumn ColSpan String
    | IntegerFooterColumn ColSpan Int
    | FloatFooterColumn ColSpan Float


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


{-| Creates a FooterColumn which content is Html.
-}
footerColumnHtml : ColSpan -> List (Html msg) -> FooterColumn msg
footerColumnHtml colSpan content =
    FooterColumn (HtmlFooterColumn colSpan content)


{-| Creates a FooterColumn which content is String primitive.
-}
footerColumnString : ColSpan -> String -> FooterColumn msg
footerColumnString colSpan content =
    FooterColumn (StringFooterColumn colSpan content)


{-| Creates a FooterColumn which content is Integer primitive.
-}
footerColumnInteger : ColSpan -> Int -> FooterColumn msg
footerColumnInteger colSpan content =
    FooterColumn (IntegerFooterColumn colSpan content)


{-| Creates a FooterColumn which content is Float primitive.
-}
footerColumnFloat : ColSpan -> Float -> FooterColumn msg
footerColumnFloat colSpan content =
    FooterColumn (FloatFooterColumn colSpan content)


type alias Slug =
    String


type alias Name =
    String


type alias Value =
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
            if conf.sorting then
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
        , renderTFoot headerSlugs conf.footerColumns
        ]


renderTHead : InternalState -> Configuration msg -> Html msg
renderTHead internalState ({ headers } as conf) =
    thead
        [ class "m-table__header" ]
        (List.map (renderTH internalState) headers)


renderTFoot : List Slug -> List (FooterRow msg) -> Html msg
renderTFoot headerSlugs footerRows =
    tbody
        [ class "m-table__footer" ]
        (List.map (renderFooterTR headerSlugs) footerRows)


renderTH : InternalState -> Header msg -> Html msg
renderTH { sortBy, sortedColumn } (Header ({ slug, name } as conf)) =
    let
        sortAttr : Html.Attribute msg
        sortAttr =
            case conf.tagger of
                Just tagger ->
                    (onClick << tagger) slug

                Nothing ->
                    attribute "data-unsortable" ""
    in
    th
        (sortAttr
            :: [ class "m-table__header__item fsSmall"
               , attribute "data-column" slug
               ]
        )
        [ text name
        , if Maybe.withDefault "" sortedColumn == slug then
            renderSortIcon sortBy slug

          else
            text ""
        ]


renderSortIcon : Maybe Sort -> Slug -> Html msg
renderSortIcon sortAlgorithm slug =
    i
        [ classList
            [ ( "m-table__header__item__icon", True )
            , ( "a-icon", True )
            , ( "a-icon-caret-up", sortAlgorithm == Just Asc )
            , ( "a-icon-caret-down", sortAlgorithm == Just Desc )
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


renderFooterTR : List Slug -> FooterRow msg -> Html msg
renderFooterTR headerSlugs (FooterRow columns) =
    let
        columnsDictionary =
            List.map2 (\slug col -> ( slug, col )) headerSlugs columns
    in
    tr
        [ class "m-table__footer__row" ]
        (List.map renderFooterTD columnsDictionary)


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


renderFooterTD : ( Slug, FooterColumn msg ) -> Html msg
renderFooterTD ( slug, FooterColumn conf ) =
    td
        [ class "m-table__footer__row__col fsSmall"
        , (colspan << pickFooterColSpan) conf
        , attribute "data-column" slug
        ]
        (case conf of
            HtmlFooterColumn _ content ->
                content

            StringFooterColumn _ content ->
                (List.singleton << text) content

            IntegerFooterColumn _ content ->
                (List.singleton << text << String.fromInt) content

            FloatFooterColumn _ content ->
                (List.singleton << text << String.fromFloat) content
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


pickFooterColSpan : FooterColumnConfiguration msg -> Int
pickFooterColSpan conf =
    case conf of
        HtmlFooterColumn colSpan _ ->
            colSpan

        StringFooterColumn colSpan string ->
            colSpan

        IntegerFooterColumn colSpan int ->
            colSpan

        FloatFooterColumn colSpan float ->
            colSpan
