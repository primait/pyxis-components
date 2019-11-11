module Prima.Pyxis.Modal.Examples.Update exposing (update)

import Prima.Pyxis.Modal.Examples.Model exposing (Model, Msg(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Show ->
            ( { model | isModalVisible = True }, Cmd.none )

        Hide ->
            ( { model | isModalVisible = False }, Cmd.none )
