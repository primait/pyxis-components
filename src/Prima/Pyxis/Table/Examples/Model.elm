module Prima.Pyxis.Table.Examples.Model exposing
    ( Model
    , Msg(..)
    , initialModel
    )

import Prima.Pyxis.Table as Table


type Msg
    = SortBy Table.State


type alias Model =
    { tableState : Table.State
    , sortByColumn : Maybe String
    , sortBy : Maybe Table.Sort
    }


initialModel : Model
initialModel =
    Model
        initialState
        Nothing
        Nothing


initialState : Table.State
initialState =
    Table.init Nothing Nothing
