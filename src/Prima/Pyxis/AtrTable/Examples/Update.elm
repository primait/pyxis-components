module Prima.Pyxis.AtrTable.Examples.Update exposing (update)

import Prima.Pyxis.AtrTable as AtrTable
import Prima.Pyxis.AtrTable.Examples.Model
    exposing
        ( Model
        , Msg(..)
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AtrTableMsg subMsg ->
            let
                ( updatedAtrTable, _, _ ) =
                    AtrTable.update subMsg model.atrTable
            in
            ( { model | atrTable = updatedAtrTable }, Cmd.none )
