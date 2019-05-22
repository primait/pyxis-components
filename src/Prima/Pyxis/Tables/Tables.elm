module Prima.Pyxis.Tables.Tables exposing
    ( Column
    , Config
    , Header
    , Row
    , State
    , columnFloat
    , columnHtml
    , columnInteger
    , columnString
    , config
    , initialState
    , render
    , row
    , sortByAsc
    , sortByDesc
    , sortByNothing
    )

import Html exposing (Html, i, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)


type Config msg
    = Config (Configuration msg)


type alias Configuration msg =
    { headers : List (Header msg)
    , rows : List (Row msg)
    , tagger : Slug -> msg
    , alternateRows : Bool
    , isSortable : Bool
    }


config : List (Header msg) -> List (Row msg) -> (Slug -> msg) -> Bool -> Bool -> Config msg
config headers rows tagger alternateRows isSortable =
    Config (Configuration headers rows tagger alternateRows isSortable)


type State
    = State InternalState


initialState : State
initialState =
    State (InternalState Nothing)


type alias InternalState =
    { sortBy : Maybe Sort
    }


type Sort
    = Asc
    | Desc


sortByAsc : State -> State
sortByAsc (State internalState) =
    State { internalState | sortBy = Just Asc }


sortByDesc : State -> State
sortByDesc (State internalState) =
    State { internalState | sortBy = Just Desc }


sortByNothing : State -> State
sortByNothing (State internalState) =
    State { internalState | sortBy = Nothing }


type Header msg
    = Header (HeaderConfiguration msg)


type alias HeaderConfiguration msg =
    { slug : Slug
    , name : Name
    , tagger : Slug -> msg
    }


type Row msg
    = Row (List (Column msg))


row : List (Column msg) -> Row msg
row columns =
    Row columns


type Column msg
    = Column (ColumnConfiguration msg)


type ColumnConfiguration msg
    = StringColumn String
    | IntegerColumn Int
    | FloatColumn Float
    | HtmlColumn (List (Html msg))


columnString : String -> Column msg
columnString content =
    Column (StringColumn content)


columnInteger : Int -> Column msg
columnInteger content =
    Column (IntegerColumn content)


columnFloat : Float -> Column msg
columnFloat content =
    Column (FloatColumn content)


columnHtml : List (Html msg) -> Column msg
columnHtml content =
    Column (HtmlColumn content)


type alias Slug =
    String


type alias Name =
    String


render : State -> Config msg -> Html msg
render state (Config conf) =
    table
        [ classList
            [ ( "m-table", True )
            , ( "m-table--alternateRows", conf.alternateRows )
            ]
        ]
        [ renderTHead state conf
        , renderTBody conf.rows
        ]


renderTHead : State -> Configuration msg -> Html msg
renderTHead (State internalState) ({ headers } as conf) =
    thead
        [ class "m-table__header" ]
        (List.map (renderTH internalState conf) headers)


renderTH : InternalState -> Configuration msg -> Header msg -> Html msg
renderTH { sortBy } { tagger, isSortable } (Header { slug, name }) =
    th
        [ class "m-table__header__item fsSmall"
        , (onClick << tagger) slug
        ]
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
