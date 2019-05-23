module Prima.Pyxis.Tables.Examples.Update exposing (update)

import Prima.Pyxis.Tables.Examples.Model exposing (..)
import Prima.Pyxis.Tables.Tables as Tables


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Table ->
            ( model, Cmd.none )

        SortBy headerSlug ->
            let
                ( sortAlgorithm, sortFn ) =
                    case model.sortBy of
                        Nothing ->
                            ( Just Asc, Tables.sortByAsc )

                        Just Asc ->
                            ( Just Desc, Tables.sortByDesc )

                        Just Desc ->
                            ( Nothing, Tables.sortByNothing )
            in
            ( { model
                | sortBy = sortAlgorithm
                , tableState = sortFn headerSlug model.tableState
              }
            , Cmd.none
            )
