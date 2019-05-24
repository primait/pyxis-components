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
import Prima.Pyxis.ListChooser.ListChooser as ListChooser exposing (..)


view : Model -> Browser.Document Msg
view model =
    Browser.Document "ListChooser component" (appBody model)


appBody : Model -> List (Html Msg)
appBody model =
    let
        myState =
            ListChooser.state <| stringsToChooserItems exampleList

        myConfiguration =
            ListChooser.singleSelectionConfig 5
    in
    [ Helpers.pyxisStyle
    , div
        [ class "a-container a-container--medium directionColumn" ]
        [ ListChooser.render myState myConfiguration
        ]
    ]


exampleList : List String
exampleList =
    [ "VOLKSWAGEN Golf 1.6 TDI 90 CV 5p. Tech&Sound BlueMo", "VOLKSWAGEN Golf 1.6 TDI 90 CV 5p. Trendline BlueMot", "VOLKSWAGEN Golf 1.6 TDI 90 CV 5p. Trendline BlueMot" ]


stringsToChooserItems : List String -> List ChooserItem
stringsToChooserItems list =
    List.map ListChooser.createItem list
