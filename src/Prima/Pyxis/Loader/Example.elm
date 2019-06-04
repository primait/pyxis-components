module Main exposing (main)

import Browser
import Prima.Pyxis.Loader.Examples.Model exposing (Model, Msg, initialModel)
import Prima.Pyxis.Loader.Examples.Update exposing (update)
import Prima.Pyxis.Loader.Examples.View exposing (view)


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
