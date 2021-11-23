module Prima.PyxisV3.Accordion.Example exposing (main)

import Browser
import Prima.PyxisV3.Accordion.Examples.Model exposing (Accordion, Msg, initialModel)
import Prima.PyxisV3.Accordion.Examples.Update exposing (update)
import Prima.PyxisV3.Accordion.Examples.View exposing (view)


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
