module Prima.Pyxis.Loader.Examples.Update exposing (update)

import Prima.Pyxis.Loader.Examples.Model exposing (Model, Msg(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update _ model =
    ( model, Cmd.none )
