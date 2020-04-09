module Prima.Pyxis.Loader.Example.Update exposing (update)

import Prima.Pyxis.Loader.Example.Model exposing (Model, Msg(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update _ model =
    ( model, Cmd.none )
