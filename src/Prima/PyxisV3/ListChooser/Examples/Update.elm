module Prima.PyxisV3.ListChooser.Examples.Update exposing (update)

import Prima.PyxisV3.ListChooser as ListChooser
import Prima.PyxisV3.ListChooser.Examples.Model exposing (Model, Msg(..))


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
