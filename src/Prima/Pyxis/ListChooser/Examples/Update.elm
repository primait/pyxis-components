module Prima.Pyxis.ListChooser.Examples.Update exposing (update)

import Prima.Pyxis.ListChooser.Examples.Model exposing (Model, Msg(..))
import Prima.Pyxis.ListChooser.ListChooser as ListChooser
import Tuple


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChoosedMsg subMsg ->
            let
                ( updatedState, cmd ) =
                    ListChooser.update subMsg model.chooserItemState
            in
            ( { model
                | chooserItemState = updatedState
              }
            , Cmd.none
            )
