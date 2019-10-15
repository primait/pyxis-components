module Prima.Pyxis.Helpers exposing
    ( flip
    , isJust
    , isNothing
    , loremIpsum
    , pyxisStyle
    , renderIf
    , spacer
    )

import Html exposing (Html, br, text)
import Html.Attributes exposing (href, rel)


pyxisStyle : Html msg
pyxisStyle =
    Html.node "link" [ href "http://localhost:8080/pyxis.css", rel "stylesheet" ] []


loremIpsum : String
loremIpsum =
    "Lorem Ipsum"


spacer : Html msg
spacer =
    br [] []


isJust : Maybe a -> Bool
isJust v =
    case v of
        Just _ ->
            True

        Nothing ->
            False


isNothing : Maybe a -> Bool
isNothing =
    not << isJust


renderIf : Bool -> Html msg -> Html msg
renderIf condition html =
    if condition then
        html

    else
        text ""


flip : (a -> b -> c) -> b -> a -> c
flip mapper b a =
    mapper a b
