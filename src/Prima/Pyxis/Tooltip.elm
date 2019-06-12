module Prima.Pyxis.Tooltip exposing
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

import Html exposing (Html, div, text)
import Html.Attributes exposing (classList)


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
upConfig : String -> Config msg
upConfig content =
    Config (Configuration Up content)


{-| Defines the configuration of a Down tooltip.
-}
downConfig : String -> Config msg
downConfig content =
    Config (Configuration Down content)


{-| Defines the configuration of an Left tooltip.
-}
leftConfig : String -> Config msg
leftConfig content =
    Config (Configuration Left content)


{-| Defines the configuration of an Right tooltip.
-}
rightConfig : String -> Config msg
rightConfig content =
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
            , ( "tooltip--right", isTooltipRight config.type_ )
            ]
        ]
        [ text config.content ]
