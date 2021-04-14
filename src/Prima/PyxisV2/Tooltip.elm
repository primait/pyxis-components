module Prima.PyxisV2.Tooltip exposing
    ( Config
    , upConfig, downConfig, leftConfig, rightConfig
    , render
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
import Prima.PyxisV2.Helpers exposing (renderIf)


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
            [ ( "a-tooltip", True )
            , ( "a-tooltip--up", isTooltipUp config.type_ )
            , ( "a-tooltip--down", isTooltipDown config.type_ )
            , ( "a-tooltip--left", isTooltipLeft config.type_ )
            , ( "a-tooltip--right", isTooltipRight config.type_ )
            ]
         ]
            ++ config.attributes
        )
        config.content
