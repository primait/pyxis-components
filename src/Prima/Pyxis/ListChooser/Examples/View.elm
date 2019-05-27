module Prima.Pyxis.ListChooser.Examples.View exposing (view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (class)
import Prima.Pyxis.Helpers as Helpers
import Prima.Pyxis.ListChooser.Examples.Model
    exposing
        ( Model
        , Msg(..)
        )
import Prima.Pyxis.ListChooser.ListChooser as ListChooser


view : Model -> Browser.Document Msg
view model =
    Browser.Document "ListChooser component" (appBody model)


appBody : Model -> List (Html Msg)
appBody { chooserItemState } =
    [ Helpers.pyxisStyle
    , div
        [ class "a-container a-container--medium directionColumn" ]
        [ Html.map ChoosedMsg <| ListChooser.render chooserItemState <| ListChooser.config 3 "Mostra tutto" "Mostra i primi 3"
        ]
    ]
