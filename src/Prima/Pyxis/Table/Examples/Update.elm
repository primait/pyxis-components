module Prima.Pyxis.Table.Examples.Update exposing (update)

import Prima.Pyxis.Table as Table
import Prima.Pyxis.Table.Examples.Model exposing (Model, Msg(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TableMsg subMsg ->
            ( { model | tableState = Table.update subMsg model.tableState }, Cmd.none )
