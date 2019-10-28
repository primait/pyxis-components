module Prima.Pyxis.Tooltip exposing
    ( Config
    , upConfig, downConfig, leftConfig, rightConfig
    , render
    , class, classList, onBottom, onLeft, onRight, onTop, pTooltip
    )

{-| Creates a Tooltip component by using predefined Html syntax.


# Configuration

@docs Config


# Configuration Helpers

@docs upConfig, downConfig, leftConfig, rightConfig


# Render

@docs render

-}

import Html exposing (Attribute, Html, div, text)
import Html.Attributes as HtmlAttributes
import Prima.Pyxis.Helpers exposing (renderIf)


{-| Represents the config of a Tooltip
-}
type Config msg
    = Config (Configuration msg)


type alias Configuration msg =
    { type_ : TooltipType
    , attributes : List (Attribute msg)
    , content : List (Html msg)
    }


type TooltipType
    = Up
    | Down
    | Left
    | Right


{-| Defines the configuration of an Up tooltip.
-}
upConfig : List (Attribute msg) -> List (Html msg) -> Config msg
upConfig attributes content =
    Config (Configuration Up attributes content)


{-| Defines the configuration of a Down tooltip.
-}
downConfig : List (Attribute msg) -> List (Html msg) -> Config msg
downConfig attributes content =
    Config (Configuration Down attributes content)


{-| Defines the configuration of an Left tooltip.
-}
leftConfig : List (Attribute msg) -> List (Html msg) -> Config msg
leftConfig attributes content =
    Config (Configuration Left attributes content)


{-| Defines the configuration of an Right tooltip.
-}
rightConfig : List (Attribute msg) -> List (Html msg) -> Config msg
rightConfig attributes content =
    Config (Configuration Right attributes content)


isTooltipUp : TooltipType -> Bool
isTooltipUp =
    (==) Up


isTooltipDown : TooltipType -> Bool
isTooltipDown =
    (==) Down


isTooltipLeft : TooltipType -> Bool
isTooltipLeft =
    (==) Left


isTooltipRight : TooltipType -> Bool
isTooltipRight =
    (==) Right


{-| Renders the Tooltip by receiving it's Config.
-}
render : Config msg -> Html msg
render (Config config) =
    div
        ([ HtmlAttributes.classList
            [ ( "tooltip", True )
            , ( "tooltip--up", isTooltipUp config.type_ )
            , ( "tooltip--down", isTooltipDown config.type_ )
            , ( "tooltip--left", isTooltipLeft config.type_ )
            , ( "tooltip--right", isTooltipRight config.type_ )
            ]
         ]
            ++ config.attributes
        )
        config.content


type TooltipAttribute msg
    = Side TooltipType
    | HtmlAttribute (Html.Attribute msg)
    | ShowOn Bool
    | DataModel TooltipDataModel


type alias TooltipDataModel =
    { myConfigAttribute : String }


class : String -> TooltipAttribute msg
class c =
    HtmlAttribute (HtmlAttributes.class c)


classList : List ( String, Bool ) -> TooltipAttribute msg
classList l =
    HtmlAttribute (HtmlAttributes.classList l)


onLeft : TooltipAttribute msg
onLeft =
    Side Left


onRight : TooltipAttribute msg
onRight =
    Side Right


onBottom : TooltipAttribute msg
onBottom =
    Side Down


onTop : TooltipAttribute msg
onTop =
    Side Left


showWhen : Bool -> TooltipAttribute msg
showWhen =
    ShowOn


{-|


## Usage:

import Pyxis.Tooltip as PTooltip exposing (pTooltip)
import Pyxis.TooltipAttributes as PTooltipAttributes
...

    pTooltip
        [ PTooltipAttributes.onLeft
        , PTooltipAttributes.class "my-class"
        , PTooltipAttributes.showWhen True
        ]
        [ text "Happy tooltip"]
    --

-}
demo : Html msg
demo =
    let
        isTooltipVisible =
            True
    in
    pTooltip
        [ onLeft
        , class "additional-class"
        , showWhen isTooltipVisible
        ]
        [ text "Contenuto del tooltip" ]


pTooltip : List (TooltipAttribute msg) -> List (Html msg) -> Html msg
pTooltip params content =
    renderIf (haveToRender params)
        (div
            [ HtmlAttributes.classList
                [ ( "tooltip", True )
                , ( solveTooltipClass params, True )
                ]
            ]
            content
        )


has : TooltipType -> List (TooltipAttribute msg) -> Bool
has type_ list =
    List.any ((==) (Side type_)) list


solveTooltipClass : List (TooltipAttribute msg) -> String
solveTooltipClass params =
    params
        |> List.filterMap
            (\tp ->
                case tp of
                    Side Up ->
                        Just "tooltip--up"

                    Side Down ->
                        Just "tooltip--down"

                    Side Left ->
                        Just "tooltip--left"

                    Side Right ->
                        Just "tooltip--right"

                    _ ->
                        Nothing
            )
        |> List.head
        |> Maybe.withDefault "tooltip--up"


haveToRender : List (TooltipAttribute msg) -> Bool
haveToRender params =
    params
        |> List.filterMap
            (\tp ->
                case tp of
                    ShowOn bool ->
                        Just bool

                    _ ->
                        Nothing
            )
        |> List.head
        |> Maybe.withDefault True
