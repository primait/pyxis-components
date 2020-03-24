module Prima.Pyxis.Container.Example exposing (main)

import Browser
import Prima.Pyxis.Container.Example.Model as ContainerModel
import Prima.Pyxis.Container.Example.Update as ContainerUpdate
import Prima.Pyxis.Container.Example.View as ContainerView


main : Program () ContainerModel.Model ContainerModel.Msg
main =
    Browser.document
        { init = init
        , view = ContainerView.view
        , update = ContainerUpdate.update
        , subscriptions = \_ -> Sub.none
        }


init : () -> ( ContainerModel.Model, Cmd ContainerModel.Msg )
init _ =
    ( ContainerModel.initialModel, Cmd.none )
