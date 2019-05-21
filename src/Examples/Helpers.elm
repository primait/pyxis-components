module Examples.Helpers exposing (pyxisStyle)

import Html exposing (Html)
import Html.Attributes exposing (href, rel)


pyxisStyle : Html msg
pyxisStyle =
    Html.node "link" [ href "https://d3be8952cnveif.cloudfront.net/css/pyxis-1.6.8.css", rel "stylesheet" ] []
