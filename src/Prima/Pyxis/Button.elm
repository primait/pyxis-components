module Prima.Pyxis.Button exposing
    ( Config, Emphasis, Scheme
    , brand, dark
    , primary, primarySmall, secondary, secondarySmall, tertiary, tertiarySmall
    , render, group
    )

{-| Allows to create a `Button` using predefined Html syntax.


# Configuration

@docs Config, Emphasis, Scheme


# Color Scheme Helpers

@docs brand, dark


# Configuration Helpers

@docs primary, primarySmall, secondary, secondarySmall, tertiary, tertiarySmall


# Rendering

@docs render, group

-}

import Html exposing (Html, button, div, span, text)
import Html.Attributes exposing (class, classList, disabled)
import Html.Events exposing (onClick)


{-| Represents the configuration of the button.
-}
type Config msg
    = Config (Configuration msg)


type alias Configuration msg =
    { emphasis : Emphasis
    , size : Size
    , scheme : Scheme
    , label : String
    , action : msg
    , isDisabled : Bool
    }


{-| Represents the visual weight of the button.
-}
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


{-| Represents the color scheme used to render the button.
-}
type Scheme
    = Brand
    | BrandDark


isDark : Scheme -> Bool
isDark =
    (==) BrandDark


{-| Represents the default color scheme of the button. Used on light backgrounds.
-}
brand : Scheme
brand =
    Brand


{-| Represents the alternative color scheme of the button. Used on dark backgrounds.
-}
dark : Scheme
dark =
    BrandDark


type Size
    = Normal
    | Small


isNormal : Size -> Bool
isNormal =
    (==) Normal


isSmall : Size -> Bool
isSmall =
    (==) Small


{-| Creates a button with a `Primary` visual weight and a `default size`.

    --

    import Prima.Pyxis.Button as Button

    type Msg =
        Clicked

    ...

    myBtn : Button.Config Msg
    myBtn =
        let
            isDisabled =
                False
        in
        Button.primary Button.brand "Click me!" Clicked isDisabled

-}
primary : Scheme -> String -> msg -> Bool -> Config msg
primary scheme label action isDisabled =
    Config (Configuration Primary Normal scheme label action isDisabled)


{-| Creates a button with a `Primary` visual weight and a `small size`.
-}
primarySmall : Scheme -> String -> msg -> Bool -> Config msg
primarySmall scheme label action isDisabled =
    Config (Configuration Primary Small scheme label action isDisabled)


{-| Creates a button with a `Secondary` visual weight and a `default size`.
-}
secondary : Scheme -> String -> msg -> Bool -> Config msg
secondary scheme label action isDisabled =
    Config (Configuration Secondary Normal scheme label action isDisabled)


{-| Creates a button with a `Secondary` visual weight and a `small size`.
-}
secondarySmall : Scheme -> String -> msg -> Bool -> Config msg
secondarySmall scheme label action isDisabled =
    Config (Configuration Secondary Small scheme label action isDisabled)


{-| Creates a button with a `Tertiary` visual weight and a `default size`.
-}
tertiary : Scheme -> String -> msg -> Bool -> Config msg
tertiary scheme label action isDisabled =
    Config (Configuration Tertiary Normal scheme label action isDisabled)


{-| Creates a button with a `Tertiary` visual weight and a `small size`.
-}
tertiarySmall : Scheme -> String -> msg -> Bool -> Config msg
tertiarySmall scheme label action isDisabled =
    Config (Configuration Tertiary Small scheme label action isDisabled)


{-| Renders the button by receiving it's configuration.
-}
render : Config msg -> Html msg
render (Config config) =
    button
        [ classList
            [ ( "a-btn", True )
            , ( "a-btn--primary", isPrimary config.emphasis )
            , ( "a-btn--secondary", isSecondary config.emphasis )
            , ( "a-btn--tertiary", isTertiary config.emphasis )
            , ( "a-btn--small", isSmall config.size )
            , ( "a-btn--dark", isDark config.scheme )
            ]
        , disabled config.isDisabled
        , onClick config.action
        ]
        [ span
            []
            [ text config.label ]
        ]


{-| Creates a button wrapper which can hold a set of `Button`s.
-}
group : List (Config msg) -> Html msg
group buttons =
    div
        [ class "m-btnGroup" ]
        (List.map render buttons)
