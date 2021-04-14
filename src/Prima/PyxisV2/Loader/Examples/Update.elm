module Prima.PyxisV2.Loader.Examples.Update exposing (update)

import Prima.PyxisV2.Loader.Examples.Model exposing (Model, Msg(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )
