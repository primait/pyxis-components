module Prima.Pyxis.Helpers exposing
    ( addIf
    , btnGroup
    , classesAttribute
    , flip
    , isJust
    , isNothing
    , loremIpsum
    , maybeCons
    , pyxisIconSetStyle
    , pyxisStyle
    , renderIf
    , renderListIf
    , renderMaybe
    , renderOrElse
    , slugify
    , spacer
    , stopEvt
    , validString
    , withCmds
    , withCmdsMap
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


renderOrElse : Bool -> Html msg -> Html msg -> Html msg
renderOrElse bool html1 html2 =
    if bool then
        html1

    else
        html2


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


{-| Used to apply an updated model to the cmds in fluid style updating
-}
withCmdsMap : List (model -> Cmd msg) -> model -> ( model, Cmd msg )
withCmdsMap cmdFunctions model =
    ( model, Cmd.batch <| List.map (\fun -> fun model) cmdFunctions )


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


{-| Cons a maybe in a list if is Just
-}
maybeCons : Maybe a -> List a -> List a
maybeCons mA xs =
    case mA of
        Just a ->
            a :: xs

        Nothing ->
            xs


addIf : Bool -> a -> List a -> List a
addIf condition element list =
    if condition then
        element :: list

    else
        list


validString : String -> Maybe String
validString str =
    case str of
        "" ->
            Nothing

        validStr ->
            Just validStr


slugify : String -> String
slugify =
    String.map
        (\c ->
            if c == ' ' then
                '_'

            else
                c
        )
        >> String.toList
        >> List.filter (\c -> Char.isAlphaNum c || c == ' ')
        >> String.fromList
