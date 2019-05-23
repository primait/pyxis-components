module Main exposing (main)

import Browser
import Prima.Pyxis.Tables.Examples.Model exposing (..)
import Prima.Pyxis.Tables.Examples.Update exposing (..)
import Prima.Pyxis.Tables.Examples.View exposing (..)


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
