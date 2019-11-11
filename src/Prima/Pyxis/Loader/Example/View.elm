module Prima.Pyxis.Loader.Example.View exposing (view)

import Browser
import Html exposing (Html)
import Prima.Pyxis.Container as Container
import Prima.Pyxis.Helpers as Helpers
import Prima.Pyxis.Loader as Loader
import Prima.Pyxis.Loader.Example.Model exposing (Model, Msg)


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
