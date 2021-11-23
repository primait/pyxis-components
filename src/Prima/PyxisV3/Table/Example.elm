module Prima.PyxisV3.Table.Example exposing (main)

import Browser
import Prima.PyxisV3.Table.Examples.Model exposing (Model, Msg(..), initialModel)
import Prima.PyxisV3.Table.Examples.Update exposing (update)
import Prima.PyxisV3.Table.Examples.View exposing (view)


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
