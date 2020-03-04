module Prima.Pyxis.Modal.Example exposing (main)

import Browser
import Prima.Pyxis.Modal.Examples.Model exposing (Msg, initialModel)
import Prima.Pyxis.Modal.Examples.Update exposing (update)
import Prima.Pyxis.Modal.Examples.View exposing (view)


main : Program () Bool Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


init : () -> ( Bool, Cmd Msg )
init _ =
    ( initialModel, Cmd.none )
