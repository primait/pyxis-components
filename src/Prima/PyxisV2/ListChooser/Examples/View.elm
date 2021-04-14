module Prima.PyxisV2.ListChooser.Examples.View exposing (view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (class)
import Prima.PyxisV2.Container as Container
import Prima.PyxisV2.Helpers as Helpers
import Prima.PyxisV2.ListChooser as ListChooser
import Prima.PyxisV2.ListChooser.Examples.Model
    exposing
        ( Model
        , Msg(..)
        )


view : Model -> Browser.Document Msg
view model =
    Browser.Document "ListChooser component" (appBody model)


appBody : Model -> List (Html Msg)
appBody { chooserItemState } =
    [ Helpers.pyxisStyle
    , Container.default
        [ Html.map ChoosedMsg <| ListChooser.render chooserItemState <| ListChooser.config 3 "Mostra tutto" "Mostra i primi 3"
        ]
    ]
