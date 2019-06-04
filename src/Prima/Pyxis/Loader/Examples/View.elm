module Prima.Pyxis.Loader.Examples.View exposing (view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (class)
import Prima.Pyxis.Helpers as Helpers
import Prima.Pyxis.Loader as Loader
import Prima.Pyxis.Loader.Examples.Model exposing (Model, Msg)


view : Model -> Browser.Document Msg
view model =
    Browser.Document "Loader component" (appBody model)


appBody : Model -> List (Html Msg)
appBody _ =
    [ Helpers.pyxisStyle
    , div
        [ class "a-container a-container--medium directionColumn" ]
        (List.map Loader.render [ loaderVehicle, loaderSpinnerSmall, loaderSpinnerMedium ])
    ]




loaderVehicle : Loader.Config
loaderVehicle =
    Loader.vehicle   (Just "Attendi. Stiamo caricando i tuoi dati...")


loaderSpinnerSmall : Loader.Config
loaderSpinnerSmall =
    Loader.spinner Loader.small (Just "Attendi. Stiamo caricando i tuoi dati...")


loaderSpinnerMedium : Loader.Config
loaderSpinnerMedium =
    Loader.spinner Loader.medium (Just "Attendi. Stiamo caricando i tuoi dati...")
