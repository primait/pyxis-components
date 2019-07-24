module Prima.Pyxis.Table.Examples.Update exposing (update)

import Prima.Pyxis.Table as Table
import Prima.Pyxis.Table.Examples.Model exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Table ->
            ( model, Cmd.none )

        SortBy headerSlug ->
            let
                sortAlgorithm =
                    if isNothing model.sortBy then
                        Table.sortAsc

                    else if model.sortBy == Table.sortAsc then
                        Table.sortDesc

                    else
                        Nothing
            in
            ( { model
                | sortBy = sortAlgorithm
                , tableState = Table.sort (Just headerSlug) sortAlgorithm model.tableState
              }
            , Cmd.none
            )


isNothing : Maybe Table.Sort -> Bool
isNothing =
    (==) Nothing
