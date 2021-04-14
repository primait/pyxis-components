module Prima.PyxisV2.Table.Examples.Model exposing
    ( Model
    , Msg(..)
    , initialModel
    )

import Prima.PyxisV2.Table as Table


type Msg
    = Table
    | SortBy String


type alias Model =
    { headers : List String
    , rows : List (List String)
    , tableState : Table.State
    , sortByColumn : Maybe String
    , sortBy : Maybe Table.Sort
    , footers : List String
    }


initialModel : Model
initialModel =
    Model
        initialHeaders
        initialRows
        (Table.initialState Nothing Nothing)
        Nothing
        Nothing
        initialHeaders


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
