module Prima.Pyxis.Helpers exposing
    ( loremIpsum
    , pyxisStyle
    , spacer
    )

import Html exposing (Html, br)
import Html.Attributes exposing (href, rel)


pyxisStyle : Html msg
pyxisStyle =
    Html.node "link" [ href "https://d3be8952cnveif.cloudfront.net/css/pyxis-1.7.4.css", rel "stylesheet" ] []


loremIpsum : String
loremIpsum =
    "Lorem Ipsum"


spacer : Html msg
spacer =
    br [] []
