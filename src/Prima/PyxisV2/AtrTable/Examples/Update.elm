module Prima.PyxisV2.AtrTable.Examples.Update exposing (update)

import Prima.PyxisV2.AtrTable as AtrTable
import Prima.PyxisV2.AtrTable.Examples.Model
    exposing
        ( Model
        , Msg(..)
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "update" msg of
        AtrTableMsg subMsg ->
            let
                ( updatedAtrTable, atrCmd, atrDetails ) =
                    AtrTable.update subMsg model.atrTable
            in
            ( { model | atrTable = updatedAtrTable }, Cmd.none )
