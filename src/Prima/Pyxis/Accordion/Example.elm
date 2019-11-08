module Prima.Pyxis.Accordion.Example exposing (main)

import Browser
import Prima.Pyxis.Accordion.Examples.Model exposing (Accordion, Msg, initialModel)
import Prima.Pyxis.Accordion.Examples.Update exposing (update)
import Prima.Pyxis.Accordion.Examples.View exposing (view)


main : Program () (List Accordion) Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


init : () -> ( List Accordion, Cmd Msg )
init _ =
    ( initialModel, Cmd.none )
