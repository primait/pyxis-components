module Prima.Pyxis.AtrTable.Examples.Update exposing (update)

import Prima.Pyxis.AtrTable.AtrTable as AtrTable
import Prima.Pyxis.AtrTable.Examples.Model
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

                _ =
                    Debug.log "updateAtrStatus" atrDetails
            in
            ( { model | atrTable = updatedAtrTable }, Cmd.none )
