module Prima.Pyxis.ListChooser.Examples.Update exposing (update)

import Prima.Pyxis.ListChooser as ListChooser
import Prima.Pyxis.ListChooser.Examples.Model exposing (Model, Msg(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ config, state } as model) =
    case msg of
        ChosenMsg subMsg ->
            let
                updatedState =
                    ListChooser.update subMsg config state
            in
            ( { model | state = updatedState }
            , Cmd.none
            )
