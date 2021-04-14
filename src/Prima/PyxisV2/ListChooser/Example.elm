module Prima.PyxisV2.ListChooser.Example exposing (main)

import Browser
import Prima.PyxisV2.ListChooser.Examples.Model exposing (Model, Msg, initialModel)
import Prima.PyxisV2.ListChooser.Examples.Update exposing (update)
import Prima.PyxisV2.ListChooser.Examples.View exposing (view)


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
