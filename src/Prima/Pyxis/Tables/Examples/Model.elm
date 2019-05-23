module Prima.Pyxis.Tables.Examples.Model exposing
    ( Model
    , Msg(..)
    , Sort(..)
    , initialModel
    )

import Prima.Pyxis.Tables.Tables as Tables


type alias Model =
    { headers : List String
    , rows : List (List String)
    , tableState : Tables.State
    , sortByColumn : Maybe String
    , sortBy : Maybe Sort
    }


initialModel : Model
initialModel =
    Model
        [ "Nazione", "Capitale" ]
        [ [ "Italia", "Roma" ], [ "Francia", "Parigi" ], [ "UK", "Londra" ], [ "Russia", "Mosca" ], [ "Spagna", "Madrid" ], [ "Olanda", "Amsterdam" ] ]
        Tables.initialState
        Nothing
        Nothing


type Msg
    = Table
    | SortBy String


type Sort
    = Asc
    | Desc
