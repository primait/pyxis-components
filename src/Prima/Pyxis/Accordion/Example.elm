module Prima.Pyxis.Accordion.Example exposing (main)

import Browser
import Prima.Pyxis.Accordion.Examples.Model exposing (Model, Msg, initialModel)
import Prima.Pyxis.Accordion.Examples.Update exposing (update)
import Prima.Pyxis.Accordion.Examples.View exposing (view)


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel, Cmd.none )
