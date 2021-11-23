module Prima.PyxisV3.Loader.Example.View exposing (view)

import Browser
import Html exposing (Html)
import Prima.PyxisV3.Container as Container
import Prima.PyxisV3.Helpers as Helpers
import Prima.PyxisV3.Loader as Loader
import Prima.PyxisV3.Loader.Example.Model exposing (Model, Msg)


view : Model -> Browser.Document Msg
view model =
    Browser.Document "Loader component" (appBody model)


appBody : Model -> List (Html Msg)
appBody _ =
    [ Helpers.pyxisStyle
    , Container.row
        |> Container.withContent (List.map Loader.render [ loaderVehicle, loaderSpinnerSmall, loaderSpinnerMedium ])
        |> Container.render
    ]


loaderVehicle : Loader.Config
loaderVehicle =
    Loader.vehicle
        |> Loader.withText "Attendi. Stiamo caricando i tuoi dati..."


loaderSpinnerSmall : Loader.Config
loaderSpinnerSmall =
    Loader.spinner
        |> Loader.withSmallSize


loaderSpinnerMedium : Loader.Config
loaderSpinnerMedium =
    Loader.spinner
        |> Loader.withText "Attendi. Stiamo caricando i tuoi dati..."
        |> Loader.withMediumSize
