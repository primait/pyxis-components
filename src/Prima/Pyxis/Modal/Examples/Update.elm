module Prima.Pyxis.Modal.Examples.Update exposing (update)

import Prima.Pyxis.Modal.Examples.Model exposing (Msg(..))


update : Msg -> Bool -> ( Bool, Cmd Msg )
update msg _ =
    case msg of
        Show ->
            ( True, Cmd.none )

        Hide ->
            ( False, Cmd.none )
