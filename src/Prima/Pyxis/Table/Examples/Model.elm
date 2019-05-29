module Prima.Pyxis.Table.Examples.Model exposing
    ( Model
    , Msg(..)
    , Sort(..)
    , initialModel
    )

import Prima.Pyxis.Table as Table


type Msg
    = Table
    | SortBy String


type alias Model =
    { headers : List String
    , rows : List (List String)
    , tableState : Table.State
    , sortByColumn : Maybe String
    , sortBy : Maybe Sort
    }


initialModel : Model
initialModel =
    Model
        initialHeaders
        initialRows
        Table.initialState
        Nothing
        Nothing


initialHeaders : List String
initialHeaders =
    [ "Nazione", "Capitale" ]


initialRows : List (List String)
initialRows =
    [ [ "Italia", "Roma" ]
    , [ "Francia", "Parigi" ]
    , [ "UK", "Londra" ]
    , [ "Russia", "Mosca" ]
    , [ "Spagna", "Madrid" ]
    , [ "Olanda", "Amsterdam" ]
    ]


type Sort
    = Asc
    | Desc
