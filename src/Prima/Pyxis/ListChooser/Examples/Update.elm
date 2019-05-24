module Prima.Pyxis.ListChooser.Examples.Update exposing (update)

import Prima.Pyxis.ListChooser.Examples.Model exposing (Model, Msg(..))
import Prima.Pyxis.ListChooser.ListChooser as ListChooser
import Tuple


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "update" msg of
        ChoosedMsg subMsg ->
            let
                ( updatedState, cmd, updatedFinitures ) =
                    ListChooser.update subMsg model.chooserItemState
            in
            ( { model
                | finitures =
                    List.map
                        (\f ->
                            if List.member f.slug <| List.map Tuple.first <| List.filter Tuple.second updatedFinitures then
                                { f | isSelected = True }

                            else
                                { f | isSelected = False }
                        )
                        model.finitures
              }
            , Cmd.none
            )
