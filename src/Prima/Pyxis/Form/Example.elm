module Prima.Pyxis.Form.Example exposing (init)

import Prima.Pyxis.Form.Example.Model exposing (Model, initialModel)
import Prima.Pyxis.Form.Example.Update exposing (update)
import Prima.Pyxis.Form.Example.View exposing (view)


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
