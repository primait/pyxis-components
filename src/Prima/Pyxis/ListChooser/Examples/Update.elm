module Prima.Pyxis.ListChooser.Examples.Update exposing (update)

import Prima.Pyxis.ListChooser.Examples.Model
    exposing
        ( Model
        , Msg(..)
        )
import Prima.Pyxis.ListChooser.ListChooser as ListChooser


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )
