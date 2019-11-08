module Prima.Pyxis.ListChooser.Examples.View exposing (view)

import Browser
import Html exposing (Html)
import Prima.Pyxis.Container as Container
import Prima.Pyxis.Helpers as Helpers
import Prima.Pyxis.ListChooser as ListChooser
import Prima.Pyxis.ListChooser.Examples.Model
    exposing
        ( Model
        , Msg(..)
        )


view : Model -> Browser.Document Msg
view model =
    Browser.Document "ListChooser component" (appBody model)


appBody : Model -> List (Html Msg)
appBody { state, config } =
    [ Helpers.pyxisStyle
    , Container.column
        |> Container.withContent
            [ Html.map ChosenMsg <| ListChooser.render state config
            ]
        |> Container.render
    ]
