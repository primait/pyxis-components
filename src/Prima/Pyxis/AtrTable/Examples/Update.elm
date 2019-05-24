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
        AtrChanged ->
            ( model, Cmd.none )

        AtrTableMsg subMsg ->
            let
                _ =
                    Debug.log "subMsg" subMsg
            in
            ( model, Cmd.none )
