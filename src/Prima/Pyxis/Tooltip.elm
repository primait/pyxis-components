module Prima.Pyxis.Tooltip exposing
    ( Config
    , tooltipUpConfig, tooltipDownConfig, tooltipLeftConfig, tooltipRightConfig
    , render
    )

{-| Creates a Tooltip component by using predefined Html syntax.


# Configuration

@docs Config


# Configuration Helpers

@docs tooltipUpConfig, tooltipDownConfig, tooltipLeftConfig, tooltipRightConfig


# Render

@docs render

-}

import Html exposing (..)
import Html.Attributes exposing (..)


{-| Represents the config of a Tooltip
-}
type Config msg
    = Config Configuration


type alias Configuration =
    { type_ : TooltipType
    , content : String
    }


type TooltipType
    = Up
    | Down
    | Left
    | Right


{-| Defines the configuration of an Up tooltip.
-}
tooltipUpConfig : String -> Config msg
tooltipUpConfig content =
    Config (Configuration Up content)


{-| Defines the configuration of a Down tooltip.
-}
tooltipDownConfig : String -> Config msg
tooltipDownConfig content =
    Config (Configuration Down content)


{-| Defines the configuration of an Left tooltip.
-}
tooltipLeftConfig : String -> Config msg
tooltipLeftConfig content =
    Config (Configuration Left content)


{-| Defines the configuration of an Right tooltip.
-}
tooltipRightConfig : String -> Config msg
tooltipRightConfig content =
    Config (Configuration Right content)


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
        [ classList
            [ ( "tooltip", True )
            , ( "tooltip--up", isTooltipUp config.type_ )
            , ( "tooltip--down", isTooltipDown config.type_ )
            , ( "tooltip--left", isTooltipLeft config.type_ )
            , ( "tooltip--down", isTooltipRight config.type_ )
            ]
        ]
        [ text config.content ]
