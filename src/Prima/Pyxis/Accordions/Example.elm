module Prima.Pyxis.Accordions.Example exposing (main)

import Browser
import Prima.Pyxis.Accordions.Examples.Model exposing (Model, Msg, initialModel)
import Prima.Pyxis.Accordions.Examples.Update exposing (update)
import Prima.Pyxis.Accordions.Examples.View exposing (view)


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
