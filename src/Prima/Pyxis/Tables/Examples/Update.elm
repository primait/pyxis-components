module Prima.Pyxis.Tables.Examples.Update exposing (update)

import Prima.Pyxis.Tables.Examples.Model
    exposing
        ( Model
        , Msg(..)
        )
import Prima.Pyxis.Tables.Tables as Tables


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    --case msg of
    ( model, Cmd.none )
