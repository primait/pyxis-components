module Prima.Pyxis.Table.Examples.Update exposing (update)

import Prima.Pyxis.Table.Examples.Model exposing (..)
import Prima.Pyxis.Table.Table as Table


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Table ->
            ( model, Cmd.none )

        SortBy headerSlug ->
            let
                ( sortAlgorithm, sortMapper ) =
                    case model.sortBy of
                        Nothing ->
                            ( Just Asc, Table.sortByAsc )

                        Just Asc ->
                            ( Just Desc, Table.sortByDesc )

                        Just Desc ->
                            ( Nothing, Table.sortByNothing )
            in
            ( { model
                | sortBy = sortAlgorithm
                , tableState = sortMapper headerSlug model.tableState
              }
            , Cmd.none
            )
