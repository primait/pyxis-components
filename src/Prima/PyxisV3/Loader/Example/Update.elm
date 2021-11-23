module Prima.PyxisV3.Loader.Example.Update exposing (update)

import Prima.PyxisV3.Loader.Example.Model exposing (Model, Msg(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )
