module Prima.PyxisV3.ListChooser.Examples.View exposing (view)

import Browser
import Html exposing (Html)
import Prima.PyxisV3.Container as Container
import Prima.PyxisV3.Helpers as Helpers
import Prima.PyxisV3.ListChooser as ListChooser
import Prima.PyxisV3.ListChooser.Examples.Model
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
