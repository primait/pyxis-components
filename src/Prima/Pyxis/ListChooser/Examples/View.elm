module Prima.Pyxis.ListChooser.Examples.View exposing (view)

import Browser
import Html exposing (Html)
import Prima.Pyxis.Container as Container
import Prima.Pyxis.Helpers as Helpers
import Prima.Pyxis.ListChooser as ListChooser
import Prima.Pyxis.ListChooser.Examples.Model
    exposing
        ( Msg(..)
        )


view : ListChooser.State -> Browser.Document Msg
view model =
    Browser.Document "ListChooser component" (appBody model)


appBody : ListChooser.State -> List (Html Msg)
appBody chooserItemState =
    [ Helpers.pyxisStyle
    , Container.column
        |> Container.withContent
            [ Html.map ChosenMsg <| ListChooser.render chooserItemState <| ListChooser.config 3 "Mostra tutto" "Mostra i primi 3"
            ]
        |> Container.render
    ]
