module Prima.Pyxis.Table.Examples.Update exposing (update)

import Prima.Pyxis.Table.Examples.Model exposing (Model, Msg(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SortBy tableState ->
            ( { model | tableState = tableState }, Cmd.none )
