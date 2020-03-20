module Prima.Pyxis.Table exposing
    ( Config, TableType, State, Header, Row, Column, ColSpan, Sort
    , config, initialState, defaultType, alternativeType
    , header, row
    , columnFloat, columnHtml, columnInteger, columnString
    , sort, sortAsc, sortDesc
    , render
    )

{-| Create a customizable `Table` by using predefined Html syntax.


# Configuration

@docs Config, TableType, State, Header, Row, Column, ColSpan, Sort, Footer, FooterColumn, FooterRow


## Options

@docs config, initialState, defaultType, alternativeType


# Configuration for Rows & Headers

@docs header, row, footerRow


# Configuration for Columns

@docs columnFloat, columnHtml, columnInteger, columnString, footerColumnFloat, footerColumnHtml, footerColumnInteger, footerColumnString


# Helpers

@docs sort, sortAsc, sortDesc


# Render

@docs render

-}

import Array
import Html exposing (Html, i, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (attribute, class, classList, colspan)
import Html.Events exposing (onClick)
import List.Extra as LE
import Prima.Pyxis.Helpers as H


{-| Represent the static configuration of the component.
-}
type Config
    = Config TableConfig


type alias TableConfig =
    { sortable : Bool
    , options : List TableOption
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

            createFooterColumns : List String -> List (Table.FooterColumn Msg)
            createFooterColumns columns =
                List.map (Table.footerColumnString 1) columns

            footer : List (Table.FooterRow Msg)
            footer =
                [ Table.footerRow (createFooterColumns [ "Country", "Capital city" ]) ]

        in
        Table.config Table.defaultType sorting headers rows alternateRows footerColumns [("my-custom-class", True)]

    ...

-}
config : Bool -> Config
config sortable =
    Config (TableConfig sortable [])


type alias Options =
    { tableClassList : List ( String, Bool )
    , headerClassList : List ( String, Bool )
    , footerClassList : List ( String, Bool )
    , elementClassList : List ( String, Bool )
    , id : Maybe String
    , tableType : TableType
    , alternateRows : Bool
    }


{-| Internal. Represents the initial state of the list of customizations for the component.
-}
defaultOptions : Options
defaultOptions =
    { tableClassList = []
    , headerClassList = []
    , footerClassList = []
    , elementClassList = []
    , id = Nothing
    , tableType = Default
    , alternateRows = False
    }


{-| Internal. Represents the possible modifiers.
-}
type TableOption
    = TableClass String
    | HeaderClass String
    | FooterClass String
    | ElementClass String
    | Id String
    | Type_ TableType
    | AlternateRows Bool


{-| Internal. Applies the customizations made by the end user to the component.
-}
applyOption : TableOption -> Options -> Options
applyOption modifier options =
    case modifier of
        TableClass class ->
            { options | tableClassList = ( class, True ) :: options.tableClassList }

        HeaderClass class ->
            { options | headerClassList = ( class, True ) :: options.headerClassList }

        FooterClass class ->
            { options | footerClassList = ( class, True ) :: options.footerClassList }

        ElementClass class ->
            { options | elementClassList = ( class, True ) :: options.elementClassList }

        Id id ->
            { options | id = Just id }

        Type_ tableType ->
            { options | tableType = tableType }

        AlternateRows isAlternate ->
            { options | alternateRows = isAlternate }


{-| Internal. Applies all the customizations and returns the internal `Options` type.
-}
computeOptions : TableConfig -> Options
computeOptions tableConfig =
    List.foldl applyOption defaultOptions tableConfig.options


{-| Internal. Adds a generic option to the `Table`.
-}
addOption : TableOption -> Config -> Config
addOption option (Config tableConfig) =
    Config { tableConfig | options = tableConfig.options ++ [ option ] }


{-| Represent the table skin.
-}
type TableType
    = Default
    | Alternative


{-| Represent the Default table skin.
-}
defaultType : TableType
defaultType =
    Default


{-| Represent the Alternative table skin.
-}
alternativeType : TableType
alternativeType =
    Alternative


isAlternativeTableType : TableType -> Bool
isAlternativeTableType =
    (==) Alternative


withTableClass : String -> Config -> Config
withTableClass class =
    addOption (TableClass class)


withHeaderClass : String -> Config -> Config
withHeaderClass class =
    addOption (HeaderClass class)


withFooterClass : String -> Config -> Config
withFooterClass class =
    addOption (FooterClass class)


withElementClass : String -> Config -> Config
withElementClass class =
    addOption (ElementClass class)


withId : String -> Config -> Config
withId id =
    addOption (Id id)


withTableType : TableType -> Config -> Config
withTableType tableType =
    addOption (Type_ tableType)


withAlternateRows : Bool -> Config -> Config
withAlternateRows isAlternate =
    addOption (AlternateRows isAlternate)


{-| Represent the basic state of the component.
-}
type State msg
    = State (InternalState msg)


{-| Create an initial State defined by Sort and Column.
-}
initialState : Maybe Sort -> Maybe String -> State msg
initialState sortBy sortedColumn =
    State (InternalState sortBy sortedColumn [] [] [])


type alias InternalState msg =
    { sortBy : Maybe Sort
    , sortedColumn : Maybe Slug
    , headers : List (Header msg)
    , rows : List (Row msg)
    , footerColumns : List (Row msg)
    }


{-| Represent the sort algorithm
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
sort : Maybe Slug -> Maybe Sort -> State msg -> State msg
sort sortedColumnSlug sortAlgorithm (State internalState) =
    State { internalState | sortBy = sortAlgorithm, sortedColumn = sortedColumnSlug }


withHeaders : List (Header msg) -> State msg -> State msg
withHeaders headers (State internalState) =
    State { internalState | headers = headers }


withRows : List (Row msg) -> State msg -> State msg
withRows rows (State internalState) =
    State { internalState | rows = rows }


withFooters : List (Row msg) -> State msg -> State msg
withFooters footerColumns (State internalState) =
    State { internalState | footerColumns = footerColumns }


{-| Represent an Header of the table. It's gonna be rendered as a <th/> tag.
-}
type Header msg
    = Header (HeaderConfiguration msg)


type alias HeaderConfiguration msg =
    { slug : Slug
    , content : List (Html msg)
    , tagger : Maybe (Slug -> msg)
    }


{-| Create the Header.

    myHeader : String -> String -> (String -> Msg) -> Table.Header Msg
    myHeader slug content sortByTagger =
        Table.header slug content sortByTagger

-}
header : Slug -> List (Html msg) -> Maybe (Slug -> msg) -> Header msg
header slug content maybeTagger =
    Header <| HeaderConfiguration slug content maybeTagger


{-| Represent a Row which contains a list of Columns.
-}
type Row msg
    = Row (List (Column msg))


{-| Create a Row

    myRow : List (Column Msg) -> Table.Row Msg
    myRow columns =
        Table.row columns

-}
row : List (Column msg) -> Row msg
row columns =
    Row columns


{-| Represent a Column which can manage a specific kind of data.
-}
type Column msg
    = Column (ColumnConfiguration msg)


type ColumnConfiguration msg
    = StringColumn ColSpan String
    | IntegerColumn ColSpan Int
    | FloatColumn ColSpan Float
    | HtmlColumn ColSpan (List (Html msg) -> String) (List (Html msg))


{-| Create a Column which content is String primitive.
-}
columnString : ColSpan -> String -> Column msg
columnString colSpan content =
    Column (StringColumn colSpan content)


{-| Create a Column which content is Integer primitive.
-}
columnInteger : ColSpan -> Int -> Column msg
columnInteger colSpan content =
    Column (IntegerColumn colSpan content)


{-| Create a Column which content is Float primitive.
-}
columnFloat : ColSpan -> Float -> Column msg
columnFloat colSpan content =
    Column (FloatColumn colSpan content)


{-| Create a Column which content is Html.
-}
columnHtml : ColSpan -> (List (Html msg) -> String) -> List (Html msg) -> Column msg
columnHtml colSpan compareFunction content =
    Column (HtmlColumn colSpan compareFunction content)


type alias Slug =
    String


{-| Represent the colSpan of a column. Alias for Integer.
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

        HtmlColumn _ compareFunction content ->
            compareFunction content


pickColumnsFromRow : Row msg -> List (Column msg)
pickColumnsFromRow (Row columns) =
    columns


retrieveHeaderIndexBySlug : Maybe Slug -> List (Header msg) -> Maybe Int
retrieveHeaderIndexBySlug slug headers =
    headers
        |> List.map (\(Header h) -> h.slug)
        |> LE.findIndex ((==) slug << Just)


{-| Renders a Table by receiving a State and a Config
-}
render : State msg -> Config -> Html msg
render (State ({ sortBy, sortedColumn, headers, rows, footerColumns } as internalState)) (Config conf) =
    let
        options =
            computeOptions conf

        index =
            (Maybe.withDefault 0 << retrieveHeaderIndexBySlug sortedColumn) headers

        sortedRows =
            if conf.sortable then
                case sortBy of
                    Nothing ->
                        rows

                    Just Asc ->
                        sortRows index rows

                    Just Desc ->
                        (List.reverse << sortRows index) rows

            else
                rows

        headerSlugs =
            List.map (\(Header { slug }) -> slug) headers
    in
    table
        [ classList
            ([ ( "m-table", True )
             , ( "m-table--alt", isAlternativeTableType options.tableType )
             , ( "m-table--alternateRows", options.alternateRows )
             ]
                ++ options.tableClassList
            )
        ]
        [ renderTHead internalState options
        , renderTBody headerSlugs options sortedRows
        , renderTFoot headerSlugs options footerColumns
        ]


renderTHead : InternalState msg -> Options -> Html msg
renderTHead internalState options =
    thead
        [ classList (( "m-table__header", True ) :: options.headerClassList)
        ]
        [ tr
            [ class "m-table__header__row" ]
            (List.map (renderTH internalState) internalState.headers)
        ]


renderTFoot : List Slug -> Options -> List (Row msg) -> Html msg
renderTFoot headerSlugs options footerRows =
    tbody
        [ classList (( "m-table__footer", True ) :: options.footerClassList) ]
        (List.map (renderFooterTR headerSlugs) footerRows)


renderTH : InternalState msg -> Header msg -> Html msg
renderTH { sortBy, sortedColumn } (Header ({ slug, content } as conf)) =
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
        [ sortAttr
        , class "m-table__header__item fs-small"
        , attribute "data-column" slug
        ]
        (content
            ++ [ if H.isJust sortedColumn then
                    renderSortIcon sortBy

                 else
                    text ""
               ]
        )


renderSortIcon : Maybe Sort -> Html msg
renderSortIcon sortAlgorithm =
    i
        [ classList
            [ ( "m-table__header__item__icon", True )
            , ( "a-icon", True )
            , ( "a-icon-caret-up", sortAlgorithm == Just Asc )
            , ( "a-icon-caret-down", sortAlgorithm == Just Desc )
            ]
        ]
        []


renderTBody : List Slug -> Options -> List (Row msg) -> Html msg
renderTBody headerSlugs options rows =
    tbody
        [ class "m-table__body" ]
        (List.map (renderTR headerSlugs options) rows)


renderTR : List Slug -> Options -> Row msg -> Html msg
renderTR headerSlugs options (Row columns) =
    let
        columnsDictionary =
            List.map2 (\slug col -> ( slug, col )) headerSlugs columns
    in
    tr
        [ class "m-table__body__row" ]
        (List.map (renderTD options) columnsDictionary)


renderFooterTR : List Slug -> Row msg -> Html msg
renderFooterTR headerSlugs (Row columns) =
    let
        columnsDictionary =
            List.map2 (\slug col -> ( slug, col )) headerSlugs columns
    in
    tr
        [ class "m-table__footer__row" ]
        (List.map renderFooterTD columnsDictionary)


renderTD : Options -> ( Slug, Column msg ) -> Html msg
renderTD options ( slug, Column conf ) =
    td
        [ classList ([ ( "m-table__body__row__col", True ), ( "fs-small", True ) ] ++ options.elementClassList)
        , (colspan << pickColSpan) conf
        , attribute "data-column" slug
        ]
        (case conf of
            StringColumn _ content ->
                (List.singleton << text) content

            IntegerColumn _ content ->
                renderIntColumnTD content

            FloatColumn _ content ->
                renderFloatColumnTD content

            HtmlColumn _ _ content ->
                content
        )


renderFooterTD : ( Slug, Column msg ) -> Html msg
renderFooterTD ( slug, Column conf ) =
    td
        [ class "m-table__footer__row__col fs-small"
        , (colspan << pickColSpan) conf
        , attribute "data-column" slug
        ]
        (case conf of
            StringColumn _ content ->
                (List.singleton << text) content

            IntegerColumn _ content ->
                renderIntColumnTD content

            FloatColumn _ content ->
                renderFloatColumnTD content

            HtmlColumn _ _ content ->
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

        HtmlColumn colSpan _ _ ->
            colSpan


renderIntColumnTD : Int -> List (Html msg)
renderIntColumnTD =
    List.singleton << text << String.fromInt


renderFloatColumnTD : Float -> List (Html msg)
renderFloatColumnTD =
    List.singleton << text << String.fromFloat
