module Prima.PyxisV2.Loader.Examples.View exposing (view)

import Browser
import Html exposing (..)
import Prima.PyxisV2.Container as Container
import Prima.PyxisV2.Helpers as Helpers
import Prima.PyxisV2.Loader as Loader
import Prima.PyxisV2.Loader.Examples.Model exposing (Model, Msg)


view : Model -> Browser.Document Msg
view model =
    Browser.Document "Loader component" (appBody model)


appBody : Model -> List (Html Msg)
appBody _ =
    [ Helpers.pyxisStyle
    , Container.default
        (List.map Loader.render [ loaderVehicle, loaderSpinnerSmall, loaderSpinnerMedium ])
    ]


loaderVehicle : Loader.Config
loaderVehicle =
    Loader.vehicle (Just "Attendi. Stiamo caricando i tuoi dati...")


loaderSpinnerSmall : Loader.Config
loaderSpinnerSmall =
    Loader.spinner Loader.small (Just "Attendi. Stiamo caricando i tuoi dati...")


loaderSpinnerMedium : Loader.Config
loaderSpinnerMedium =
    Loader.spinner Loader.medium (Just "Attendi. Stiamo caricando i tuoi dati...")
