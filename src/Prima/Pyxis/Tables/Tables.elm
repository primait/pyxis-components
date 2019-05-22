module Prima.Pyxis.Tables.Tables exposing
    ( Column
    , Config
    , Header
    , Row
    , State
    , config
    , initialState
    , render
    , sortByAsc
    , sortByDesc
    , sortByNothing
    )

import Html exposing (Html, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (class, classList)


type Config msg
    = Config (Configuration msg)


type alias Configuration msg =
    { headers : List (Header msg)
    , rows : List Row
    , tagger : State -> msg
    , alternateRows : Bool
    }


config : List (Header msg) -> List Row -> (State -> msg) -> Bool -> Config msg
config headers rows tagger alternateRows =
    Config (Configuration headers rows tagger alternateRows)


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


type Row
    = Row (List Column)


type Column
    = Column ColumnConfiguration


type ColumnConfiguration
    = StringColumn Name String
    | IntegerColumn Name Int
    | FloatColumn Name Float


type alias Slug =
    String


type alias Name =
    String


render : State -> Config msg -> Html msg
render state (Config { alternateRows, headers, rows }) =
    table
        [ classList
            [ ( "m-table", True )
            , ( "m-table--alternateRows", alternateRows )
            ]
        ]
        [ renderTHead headers
        , renderTBody rows
        ]


renderTHead : List (Header msg) -> Html msg
renderTHead headers =
    thead
        [ class "m-table__header" ]
        (List.map renderTH headers)


renderTH : Header msg -> Html msg
renderTH (Header { slug, name }) =
    th
        [ class "m-table__header__item fsSmall" ]
        [ text name ]


renderTBody : List Row -> Html msg
renderTBody rows =
    tbody
        [ class "m-table__body" ]
        (List.map renderTR rows)


renderTR : Row -> Html msg
renderTR (Row columns) =
    tr
        [ class "m-table__body__row" ]
        (List.map renderTD columns)


renderTD : Column -> Html msg
renderTD (Column columnType) =
    td
        [ class "m-table__body__row__col fsSmall" ]
        (case columnType of
            StringColumn name content ->
                (List.singleton << text) name

            IntegerColumn name content ->
                (List.singleton << text << String.fromInt) content

            FloatColumn name content ->
                (List.singleton << text << String.fromFloat) content
        )
