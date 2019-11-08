module Prima.Pyxis.ListChooser.Example exposing (main)

import Browser
import Prima.Pyxis.ListChooser as ListChooser
import Prima.Pyxis.ListChooser.Examples.Model exposing (Msg, initialModel)
import Prima.Pyxis.ListChooser.Examples.Update exposing (update)
import Prima.Pyxis.ListChooser.Examples.View exposing (view)


main : Program () ListChooser.State Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


init : () -> ( ListChooser.State, Cmd Msg )
init _ =
    ( initialModel, Cmd.none )
