module Prima.Pyxis.Button exposing
    ( Config
    , group
    , primary
    , primarySmall
    , render
    , secondary
    , secondarySmall
    , tertiary
    , tertiarySmall
    )

import Html exposing (Html, button, div, span, text)
import Html.Attributes exposing (class, classList, disabled)
import Html.Events exposing (onClick)


type Config msg
    = Config (Configuration msg)


type alias Configuration msg =
    { emphasis : Emphasis
    , size : Size
    , label : String
    , action : msg
    , isDisabled : Bool
    }


type Emphasis
    = Primary
    | Secondary
    | Tertiary


isPrimary : Emphasis -> Bool
isPrimary =
    (==) Primary


isSecondary : Emphasis -> Bool
isSecondary =
    (==) Secondary


isTertiary : Emphasis -> Bool
isTertiary =
    (==) Tertiary


type Size
    = Normal
    | Small


isNormal : Size -> Bool
isNormal =
    (==) Normal


isSmall : Size -> Bool
isSmall =
    (==) Small


primary : String -> msg -> Bool -> Config msg
primary label action isDisabled =
    Config (Configuration Primary Normal label action isDisabled)


primarySmall : String -> msg -> Bool -> Config msg
primarySmall label action isDisabled =
    Config (Configuration Primary Small label action isDisabled)


secondary : String -> msg -> Bool -> Config msg
secondary label action isDisabled =
    Config (Configuration Secondary Normal label action isDisabled)


secondarySmall : String -> msg -> Bool -> Config msg
secondarySmall label action isDisabled =
    Config (Configuration Secondary Small label action isDisabled)


tertiary : String -> msg -> Bool -> Config msg
tertiary label action isDisabled =
    Config (Configuration Tertiary Normal label action isDisabled)


tertiarySmall : String -> msg -> Bool -> Config msg
tertiarySmall label action isDisabled =
    Config (Configuration Tertiary Small label action isDisabled)


render : Config msg -> Html msg
render (Config config) =
    button
        [ classList
            [ ( "a-btn", True )
            , ( "a-btn--primary", isPrimary config.emphasis )
            , ( "a-btn--secondary", isSecondary config.emphasis )
            , ( "a-btn--tertiary", isTertiary config.emphasis )
            , ( "a-btn--small", isSmall config.size )
            ]
        , disabled config.isDisabled
        , onClick config.action
        ]
        [ span
            []
            [ text config.label ]
        ]


group : List (Config msg) -> Html msg
group buttons =
    div
        [ class "m-btnGroup" ]
        (List.map render buttons)
