module Prima.Pyxis.Separator exposing (render)

import Html exposing (Html, hr)
import Html.Attributes exposing (..)


render : Html msg
render =
    hr
        [ style "border" "none"
        , style "height" "1px"
        , style "background-color" "#e0e0e0%"
        ]
        []
