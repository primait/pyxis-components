module Prima.Pyxis.Accordions.Examples.View exposing
    ( appBody
    , view
    )

import Browser
import Html exposing (..)
import Html.Attributes exposing (class)
import Prima.Pyxis.Helpers as Helpers
import Prima.Pyxis.Tables.Examples.Model
    exposing
        ( Model
        , Msg(..)
        )
import Prima.Pyxis.Tables.Tables as Tables


view : Model -> Browser.Document Msg
view model =
    Browser.Document "Table component" (appBody model)


appBody : Model -> List (Html Msg)
appBody model =
    [ Helpers.pyxisStyle
    , div
        [ class "a-container a-container--medium directionColumn" ]
        []
    ]
