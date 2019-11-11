module Prima.Pyxis.Helpers exposing
    ( btnGroup
    , classesAttribute
    , flip
    , isJust
    , isNothing
    , loremIpsum
    , maybeCons
    , maybeSingleton
    , pyxisStyle
    , pyxisIconSetStyle
    , renderIf
    , renderListIf
    , renderMaybe
    , spacer
    , stopEvt
    , withCmds
    , withoutCmds
    )

import Html exposing (Html, br, div, text)
import Html.Attributes exposing (class, href, rel)
import Html.Events as Evt
import Json.Decode as JD


pyxisStyle : Html msg
pyxisStyle =
    Html.node "link" [ href "http://localhost:8080/pyxis.css", rel "stylesheet" ] []

pyxisIconSetStyle : Html msg
pyxisIconSetStyle =
    Html.node "link" [ href "https://s3.amazonaws.com/icomoon.io/98538/PyxisIconset30/style.css?226kae", rel "stylesheet" ] []

loremIpsum : String
loremIpsum =
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."


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


btnGroup : List (Html msg) -> Html msg
btnGroup =
    div
        [ class "btnGroup" ]


renderMaybe : Maybe (Html msg) -> Html msg
renderMaybe theMaybe =
    case theMaybe of
        Just html ->
            html

        Nothing ->
            Html.text ""


renderListIf : Bool -> List (Html msg) -> List (Html msg)
renderListIf condition html =
    if condition then
        html

    else
        [ text "" ]


flip : (a -> b -> c) -> b -> a -> c
flip mapper b a =
    mapper a b


withCmds : List (Cmd msg) -> model -> ( model, Cmd msg )
withCmds cmds model =
    ( model, Cmd.batch cmds )


withoutCmds : model -> ( model, Cmd msg )
withoutCmds =
    withCmds []


{-| Transforms a list of `class`(es) into a valid Html.Attribute.
-}
classesAttribute : List String -> Html.Attribute msg
classesAttribute =
    class << String.join " "


{-| Stop propagation for custom event and dispatch msg
-}
stopEvt : String -> msg -> Html.Attribute msg
stopEvt eventType msg =
    Evt.custom eventType (JD.succeed { message = msg, stopPropagation = True, preventDefault = True })


{-| A List.singleton implementation that accepts also maybe
-}
maybeSingleton : Maybe a -> List a
maybeSingleton =
    Maybe.withDefault [] << Maybe.map List.singleton


{-| Cons a maybe in a list if is Just
-}
maybeCons : Maybe a -> List a -> List a
maybeCons mA xs =
    case mA of
        Just a ->
            a :: xs

        Nothing ->
            xs
