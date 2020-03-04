module Prima.Pyxis.ListChooser.Examples.Update exposing (update)

import Prima.Pyxis.ListChooser as ListChooser
import Prima.Pyxis.ListChooser.Examples.Model exposing (Msg(..))


update : Msg -> ListChooser.State -> ( ListChooser.State, Cmd Msg )
update msg chooserItemState =
    case msg of
        ChoosedMsg subMsg ->
            let
                ( updatedState, _ ) =
                    ListChooser.update subMsg chooserItemState
            in
            ( updatedState
            , Cmd.none
            )
