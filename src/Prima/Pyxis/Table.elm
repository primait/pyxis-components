module Prima.Pyxis.Table exposing
    ( Config, State, Header, Row, Column, ColSpan, Sort(..)
    , base, light, init, header, row, columnFloat, columnHtml, columnInteger, columnString, addHeaders, addRows, addFooters
    , render
    , withAlternateRows, withClass, withClassList, withComparableHtml, withElementClass, withFooterClass, withHeaderClass, withId, withSort
    )

{-|


## Configuration

@docs Config, State, Header, Row, Column, ColSpan, Sort


## Configuration Methods

@docs base, light, init, header, row, columnFloat, columnHtml, columnInteger, columnString, addHeaders, addRows, addFooters


## Rendering

@docs render


## Options

@docs withAlternateRows, withClass, withClassList, withComparableHtml, withElementClass, withFooterClass, withHeaderClass, withId, withSort

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
    , skin : Skin
    , msgMapper : State -> msg
    , headers : List (Header msg)
    , rows : List (Row msg)
    , footerColumns : List (Row msg)
    , options : List (TableOption msg)
    }


{-| Creates a `Table` with the `Base` skin.
-}
base : Bool -> (State -> msg) -> Config msg
base sortable toMsg =
    Config (TableConfig sortable Base toMsg [] [] [] [])


{-| Creates a `Table` with the `Light` skin.
-}
light : Bool -> (State -> msg) -> Config msg
light sortable toMsg =
    Config (TableConfig sortable Light toMsg [] [] [] [])


{-| Internal. Represents the list of available customizations.
-}
type alias Options msg =
    { tableClassList : List ( String, Bool )
    , headerClassList : List ( String, Bool )
    , footerClassList : List ( String, Bool )
    , elementClassList : List ( String, Bool )
    , id : Maybe String
    , alternateRows : Bool
    , htmlConvertFn : Maybe (List (Html msg) -> String)
    }


{-| Internal. Represents the initial state of the list of customizations for the component.
-}
defaultOptions : Options msg
defaultOptions =
    { tableClassList = []
    , headerClassList = []
    , footerClassList = []
    , elementClassList = []
    , id = Nothing
    , alternateRows = False
    , htmlConvertFn = Nothing
    }


{-| Internal. Represents the possible modifiers.
-}
type TableOption msg
    = TableClass String
    | TableClassList (List ( String, Bool ))
    | HeaderClass String
    | FooterClass String
    | ElementClass String
    | Id String
    | AlternateRows Bool
    | HtmlConvertFunction (List (Html msg) -> String)


{-| Internal. Applies the customizations made by the end user to the component.
-}
applyOption : TableOption msg -> Options msg -> Options msg
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

        AlternateRows isAlternate ->
            { options | alternateRows = isAlternate }

        HtmlConvertFunction comparer ->
            { options | htmlConvertFn = Just comparer }


{-| Internal. Applies all the customizations and returns the internal `Options` type.
-}
computeOptions : TableConfig msg -> Options msg
computeOptions tableConfig =
    List.foldl applyOption defaultOptions tableConfig.options


{-| Internal. Adds a generic option to the `Table`.
-}
addOption : TableOption msg -> Config msg -> Config msg
addOption option (Config tableConfig) =
    Config { tableConfig | options = tableConfig.options ++ [ option ] }


{-| Represent the table skin.
-}
type Skin
    = Base
    | Light


{-| Internal.
-}
isLight : Skin -> Bool
isLight =
    (==) Light


{-| Internal.
-}
isBase : Skin -> Bool
isBase =
    (==) Base


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


{-| Sets the alternate rows option for the Table component to `Config`.
-}
withAlternateRows : Bool -> Config msg -> Config msg
withAlternateRows isAlternate =
    addOption (AlternateRows isAlternate)


{-| Sets the function to convert HTML content to string to be compared in sorting.
-}
withComparableHtml : (List (Html msg) -> String) -> Config msg -> Config msg
withComparableHtml comparer =
    addOption (HtmlConvertFunction comparer)


{-| Represent the basic state of the component.
-}
type State
    = State InternalState


{-| Create an initial State defined by Sort and Column.
-}
init : Maybe Sort -> Maybe String -> State
init sortBy sortedColumn =
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
addHeaders : List (Header msg) -> Config msg -> Config msg
addHeaders headers (Config internalConfig) =
    Config { internalConfig | headers = headers }


{-| Sets the content of the rows of the table.
-}
addRows : List (Row msg) -> Config msg -> Config msg
addRows rows (Config internalConfig) =
    Config { internalConfig | rows = rows }


{-| Sets the footer columns of the table.
-}
addFooters : List (Row msg) -> Config msg -> Config msg
addFooters footerColumns (Config internalConfig) =
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
    | HtmlColumn ColSpan (List (Html msg))


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
columnHtml : ColSpan -> List (Html msg) -> Column msg
columnHtml colSpan content =
    Column (HtmlColumn colSpan content)


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
sortRows : Options msg -> Int -> List (Row msg) -> List (Row msg)
sortRows options columnIndex rows =
    List.sortBy
        (Maybe.withDefault ""
            << Maybe.map (columnToComparable options)
            << Array.get columnIndex
            << Array.fromList
            << pickColumnsFromRow
        )
        rows


{-| Converts the content of the available datatypes of the column into a String that can be compared.
-}
columnToComparable : Options msg -> Column msg -> String
columnToComparable options (Column columnConf) =
    case columnConf of
        StringColumn _ content ->
            content

        IntegerColumn _ content ->
            String.fromInt content

        FloatColumn _ content ->
            String.fromFloat content

        HtmlColumn _ content ->
            case options.htmlConvertFn of
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
render (State ({ sortBy, sortedColumn } as internalState)) (Config ({ headers, rows, footerColumns, skin } as conf)) =
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
                        sortRows options index rows

                    Just Desc ->
                        (List.reverse << sortRows options index) rows

            else
                rows

        headerSlugs =
            List.map (\(Header { slug }) -> slug) headers
    in
    table
        [ classList
            ([ ( "m-table", True )
             , ( "m-table--base", isBase skin )
             , ( "m-table--light", isLight skin )
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
renderTHead : InternalState -> TableConfig msg -> Options msg -> Html msg
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
renderTFoot : List Slug -> Options msg -> List (Row msg) -> Html msg
renderTFoot headerSlugs options footerRows =
    tbody
        [ classList (( "m-table__footer", True ) :: options.footerClassList) ]
        (List.map (renderFooterTR headerSlugs) footerRows)


{-| Internal. Renders the table header by receiving State, Config and the contents of the column
-}
renderTH : InternalState -> TableConfig msg -> Header msg -> Html msg
renderTH ({ sortBy, sortedColumn } as internalState) conf (Header { slug, content }) =
    th
        [ class "m-table__header__item"
        , columnNameAttribute slug
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
renderTBody : List Slug -> Options msg -> List (Row msg) -> Html msg
renderTBody headerSlugs options rows =
    tbody
        [ class "m-table__body" ]
        (List.map (renderTR headerSlugs options) rows)


{-| Internal. Renders a row of contents.
-}
renderTR : List Slug -> Options msg -> Row msg -> Html msg
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
renderTD : Options msg -> ( Slug, Column msg ) -> Html msg
renderTD options ( slug, Column conf ) =
    td
        [ classList (( "m-table__body__item", True ) :: options.elementClassList)
        , (colspan << pickColSpan) conf
        , columnNameAttribute slug
        ]
        (case conf of
            StringColumn _ content ->
                (List.singleton << text) content

            IntegerColumn _ content ->
                renderIntColumnTD content

            FloatColumn _ content ->
                renderFloatColumnTD content

            HtmlColumn _ content ->
                content
        )


{-| Internal. Renders a footer cell, accordingly to its content.
-}
renderFooterTD : ( Slug, Column msg ) -> Html msg
renderFooterTD ( slug, Column conf ) =
    td
        [ class "m-table__footer__item"
        , (colspan << pickColSpan) conf
        , columnNameAttribute slug
        ]
        (case conf of
            StringColumn _ content ->
                (List.singleton << text) content

            IntegerColumn _ content ->
                renderIntColumnTD content

            FloatColumn _ content ->
                renderFloatColumnTD content

            HtmlColumn _ content ->
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

        HtmlColumn colSpan _ ->
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


{-| Internal.
-}
columnNameAttribute : String -> Html.Attribute msg
columnNameAttribute slug =
    if String.isEmpty slug then
        attribute "data-without-column-name" ""

    else
        attribute "data-column-name" slug
