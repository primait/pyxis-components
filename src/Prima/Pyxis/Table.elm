module Prima.Pyxis.Table exposing
    ( Config, TableType(..), State, Header, Row, Column, ColSpan, Sort(..)
    , config, withClass, withClassList, withHeaderClass, withFooterClass, withElementClass, withId, withTableType, withAlternateRows
    , state, withHeaders, withRows, withFooters, withSort
    , header, row, columnFloat, columnHtml, columnInteger, columnString
    , render
    )

{-| Create a customizable `Table` by using predefined Html syntax.


# Configuration

@docs Config, TableType, State, Header, Row, Column, ColSpan, Sort


## Options

@docs config, withClass, withClassList, withHeaderClass, withFooterClass, withElementClass, withId, withTableType, withAlternateRows


## State

@docs state, withHeaders, withRows, withFooters, withSort


# Configuration for Headers, Rows and Columns

@docs header, row, columnFloat, columnHtml, columnInteger, columnString


# Helpers

@docs sortAsc, sortDesc


# Render

@docs render

-}

import Array
import Html exposing (Html, i, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (attribute, class, classList, colspan)
import Html.Events
import Json.Decode as JD
import List.Extra as LE
import Prima.Pyxis.Helpers as H


{-| Represent the static configuration of the component.
-}
type Config msg
    = Config (TableConfig msg)


type alias TableConfig msg =
    { sortable : Bool
    , msgMapper : State -> msg
    , headers : List (Header msg)
    , rows : List (Row msg)
    , footerColumns : List (Row msg)
    , options : List TableOption
    }


{-| Returns the config of the component.

    tableConfig = Table.config True

    ...

-}
config : Bool -> (State -> msg) -> Config msg
config sortable toMsg =
    Config (TableConfig sortable toMsg [] [] [] [])


{-| Internal. Represents the list of available customizations.
-}
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
    | TableClassList (List ( String, Bool ))
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

        TableClassList classList ->
            { options | tableClassList = classList ++ options.tableClassList }

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
computeOptions : TableConfig msg -> Options
computeOptions tableConfig =
    List.foldl applyOption defaultOptions tableConfig.options


{-| Internal. Adds a generic option to the `Table`.
-}
addOption : TableOption -> Config msg -> Config msg
addOption option (Config tableConfig) =
    Config { tableConfig | options = tableConfig.options ++ [ option ] }


{-| Represent the table skin.
-}
type TableType
    = Default
    | Alternative


{-| Internal. Checks if the table is of Alternative type.
-}
isAlternativeTableType : TableType -> Bool
isAlternativeTableType =
    (==) Alternative


{-| Adds a class for the <table> tag to the `Config`
-}
withClass : String -> Config msg -> Config msg
withClass class =
    addOption (TableClass class)


{-| Adds an entry to the classList of the <table> tag.
-}
withClassList : List ( String, Bool ) -> Config msg -> Config msg
withClassList classList =
    addOption (TableClassList classList)


{-| Adds a class for the <thead> tag to the `Config`.
-}
withHeaderClass : String -> Config msg -> Config msg
withHeaderClass class =
    addOption (HeaderClass class)


{-| Adds a class for the <tfoot> tag to the `Config`.
-}
withFooterClass : String -> Config msg -> Config msg
withFooterClass class =
    addOption (FooterClass class)


{-| Adds a class for the <td> tags to the `Config`.
-}
withElementClass : String -> Config msg -> Config msg
withElementClass class =
    addOption (ElementClass class)


{-| Adds an id for the <table> tag to the `Config`.
-}
withId : String -> Config msg -> Config msg
withId id =
    addOption (Id id)


{-| Sets the type for the Table component to `Config`.
-}
withTableType : TableType -> Config msg -> Config msg
withTableType tableType =
    addOption (Type_ tableType)


{-| Sets the alternate rows option for the Table component to `Config`.
-}
withAlternateRows : Bool -> Config msg -> Config msg
withAlternateRows isAlternate =
    addOption (AlternateRows isAlternate)


{-| Represent the basic state of the component.
-}
type State
    = State InternalState


{-| Create an initial State defined by Sort and Column.
-}
state : Maybe Sort -> Maybe String -> State
state sortBy sortedColumn =
    State (InternalState sortBy sortedColumn)


{-| Internal. Represents the State of the `Table`
-}
type alias InternalState =
    { sortBy : Maybe Sort
    , sortedColumn : Maybe Slug
    }


{-| Represents the sort algorithm
-}
type Sort
    = Asc
    | Desc


{-| Sets the sorting algorithm for a specific column.
-}
withSort : Slug -> Sort -> State -> State
withSort sortedColumnSlug algorithm (State internalState) =
    State { internalState | sortBy = Just algorithm, sortedColumn = Just sortedColumnSlug }


{-| Sets the header columns of the table.
-}
withHeaders : List (Header msg) -> Config msg -> Config msg
withHeaders headers (Config internalConfig) =
    Config { internalConfig | headers = headers }


{-| Sets the content of the rows of the table.
-}
withRows : List (Row msg) -> Config msg -> Config msg
withRows rows (Config internalConfig) =
    Config { internalConfig | rows = rows }


{-| Sets the footer columns of the table.
-}
withFooters : List (Row msg) -> Config msg -> Config msg
withFooters footerColumns (Config internalConfig) =
    Config { internalConfig | footerColumns = footerColumns }


{-| Internal. Updates the sorting algorithm applied to the table.
-}
sortAlgorithm : Maybe Sort -> Maybe Sort
sortAlgorithm sortingBy =
    case sortingBy of
        Nothing ->
            Just Asc

        Just Asc ->
            Just Desc

        Just Desc ->
            Nothing


{-| Internal. Checks of the selected column is currently being sorted
-}
isCurrentlySorted : Slug -> Maybe Slug -> Bool
isCurrentlySorted slug sortedColumn =
    H.isJust sortedColumn && sortedColumn == Just slug


{-| Represent an Header of the table. It's gonna be rendered as a <th/> tag.
-}
type Header msg
    = Header (HeaderConfiguration msg)


{-| Internal. Represents the configuration of a Header column .
-}
type alias HeaderConfiguration msg =
    { slug : Slug
    , content : List (Html msg)
    }


{-| Create the Header.

    myHeader : String -> String -> Table.Header
    myHeader slug content =
        Table.header slug content

-}
header : Slug -> List (Html msg) -> Header msg
header slug content =
    Header <| HeaderConfiguration slug content


{-| Represent a Row which contains a list of Columns.
-}
type Row msg
    = Row (List (Column msg))


{-| Create a Row

    myRow : List Column -> Table.Row
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


{-| Internal. Represents the available configurations for the columns.
-}
type ColumnConfiguration msg
    = StringColumn ColSpan String
    | IntegerColumn ColSpan Int
    | FloatColumn ColSpan Float
    | HtmlColumn ColSpan (Maybe (List (Html msg) -> String)) (List (Html msg))


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


{-| Create a Column which content is Html, that can be sorted using compareFunction.
-}
columnHtml : ColSpan -> Maybe (List (Html msg) -> String) -> List (Html msg) -> Column msg
columnHtml colSpan compareFunction content =
    Column (HtmlColumn colSpan compareFunction content)


{-| Represent the slug of a column. Alias for String.
-}
type alias Slug =
    String


{-| Represent the colSpan of a column. Alias for Integer.
-}
type alias ColSpan =
    Int


{-| Applies the sorting relative of the selected column to the rows.
-}
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


{-| Converts the content of the available datatypes of the column into a String that can be compared.
-}
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
            case compareFunction of
                Just fn ->
                    fn content

                Nothing ->
                    ""


{-| Internal. Returns the columns of a row
-}
pickColumnsFromRow : Row msg -> List (Column msg)
pickColumnsFromRow (Row columns) =
    columns


{-| Internal. Returns the index of the column corresponding to the provided slug
-}
retrieveHeaderIndexBySlug : Maybe Slug -> List (Header msg) -> Maybe Int
retrieveHeaderIndexBySlug slug headers =
    headers
        |> List.map (\(Header h) -> h.slug)
        |> LE.findIndex ((==) slug << Just)


{-| Renders a Table by receiving a State and a Config
-}
render : State -> Config msg -> Html msg
render (State ({ sortBy, sortedColumn } as internalState)) (Config ({ headers, rows, footerColumns } as conf)) =
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
        [ renderTHead internalState conf options
        , renderTBody headerSlugs options sortedRows
        , renderTFoot headerSlugs options footerColumns
        ]


{-| Internal. Renders the table header by receiving State, Config and the Options
-}
renderTHead : InternalState -> TableConfig msg -> Options -> Html msg
renderTHead internalState ({ headers } as conf) options =
    thead
        [ classList (( "m-table__header", True ) :: options.headerClassList)
        ]
        [ tr
            [ class "m-table__header__row" ]
            (List.map (renderTH internalState conf) headers)
        ]


{-| Internal. Renders the table footer by receiving State, Options and the rows of the footer
-}
renderTFoot : List Slug -> Options -> List (Row msg) -> Html msg
renderTFoot headerSlugs options footerRows =
    tbody
        [ classList (( "m-table__footer", True ) :: options.footerClassList) ]
        (List.map (renderFooterTR headerSlugs) footerRows)


{-| Internal. Renders the table header by receiving State, Config and the contents of the column
-}
renderTH : InternalState -> TableConfig msg -> Header msg -> Html msg
renderTH ({ sortBy, sortedColumn } as internalState) conf (Header { slug, content }) =
    th
        [ class "m-table__header__item fs-small"
        , attribute "data-column" slug
        , if conf.sortable then
            internalOnClick slug (State internalState) conf.msgMapper

          else
            attribute "data-unsortable" ""
        ]
        (content
            ++ [ renderSortIcon (isCurrentlySorted slug sortedColumn) sortBy ]
        )


{-| Internal. Renders the onClick attribute, mapping with the outside message type, and updating the sorting.
-}
internalOnClick : String -> State -> (State -> msg) -> Html.Attribute msg
internalOnClick slug (State internalState) msgMapper =
    slug
        |> JD.succeed
        |> JD.map
            (\s ->
                State
                    { internalState
                        | sortedColumn = Just s
                        , sortBy = sortAlgorithm internalState.sortBy
                    }
            )
        |> JD.map msgMapper
        |> Html.Events.on "click"


{-| Internal. Renders the icon representing the current sorting direction
-}
renderSortIcon : Bool -> Maybe Sort -> Html msg
renderSortIcon isSorted algorithm =
    if isSorted then
        i
            [ classList
                [ ( "m-table__header__item__icon", True )
                , ( "a-icon", True )
                , ( "a-icon-caret-up", algorithm == Just Asc )
                , ( "a-icon-caret-down", algorithm == Just Desc )
                ]
            ]
            []

    else
        text ""


{-| Internal. Renders the table body.
-}
renderTBody : List Slug -> Options -> List (Row msg) -> Html msg
renderTBody headerSlugs options rows =
    tbody
        [ class "m-table__body" ]
        (List.map (renderTR headerSlugs options) rows)


{-| Internal. Renders a row of contents.
-}
renderTR : List Slug -> Options -> Row msg -> Html msg
renderTR headerSlugs options (Row columns) =
    let
        columnsDictionary =
            List.map2 (\slug col -> ( slug, col )) headerSlugs columns
    in
    tr
        [ class "m-table__body__row" ]
        (List.map (renderTD options) columnsDictionary)


{-| Internal. Renders a row of footer contents.
-}
renderFooterTR : List Slug -> Row msg -> Html msg
renderFooterTR headerSlugs (Row columns) =
    let
        columnsDictionary =
            List.map2 (\slug col -> ( slug, col )) headerSlugs columns
    in
    tr
        [ class "m-table__footer__row" ]
        (List.map renderFooterTD columnsDictionary)


{-| Internal. Renders a table accordingly to its type.
-}
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


{-| Internal. Renders a footer cell, accordingly to its content.
-}
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


{-| Internal. Returns the colspan attribute value for a cell.
-}
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


{-| Internal. Renders a column of Integer contents.
-}
renderIntColumnTD : Int -> List (Html msg)
renderIntColumnTD =
    List.singleton << text << String.fromInt


{-| Internal. Renders a column of Float contents.
-}
renderFloatColumnTD : Float -> List (Html msg)
renderFloatColumnTD =
    List.singleton << text << String.fromFloat
