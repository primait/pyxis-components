module Main exposing (main)

import Browser
import Prima.Pyxis.Table.Examples.Model exposing (..)
import Prima.Pyxis.Table.Examples.Update exposing (..)
import Prima.Pyxis.Table.Examples.View exposing (..)


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
