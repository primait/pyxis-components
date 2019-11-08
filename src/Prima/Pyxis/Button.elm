module Prima.Pyxis.Button exposing
    ( Config, Emphasis, Scheme(..)
    , callOut, callOutSmall, primary, primarySmall, secondary, secondarySmall, tertiary, tertiarySmall
    , render, group, groupFluid
    )

{-| Create a `Button` using predefined Html syntax.


# Configuration

@docs Config, Emphasis, Scheme


## Options

@docs callOut, callOutSmall, primary, primarySmall, secondary, secondarySmall, tertiary, tertiarySmall


# Render

@docs render, group, groupFluid

-}

import Html exposing (Html, button, div, span, text)
import Html.Attributes exposing (class, classList, disabled)
import Html.Events exposing (onClick)
import Prima.Pyxis.Helpers as H


{-| Represent the configuration of the button.
-}
type Config msg
    = Config (Configuration msg)


type alias Configuration msg =
    { emphasis : Emphasis
    , size : Size
    , scheme : Scheme
    , label : String
    , action : msg
    }


{-| Represent the visual weight of the button.
-}
type Emphasis
    = CallOut
    | Primary
    | Secondary
    | Tertiary


isCallOut : Emphasis -> Bool
isCallOut =
    (==) CallOut


isPrimary : Emphasis -> Bool
isPrimary =
    (==) Primary


isSecondary : Emphasis -> Bool
isSecondary =
    (==) Secondary


isTertiary : Emphasis -> Bool
isTertiary =
    (==) Tertiary


{-| Represent the color scheme used to render the button.
-}
type Scheme
    = Brand
    | BrandDark


isDark : Scheme -> Bool
isDark =
    (==) BrandDark


type Size
    = Normal
    | Small


isNormal : Size -> Bool
isNormal =
    (==) Normal


isSmall : Size -> Bool
isSmall =
    (==) Small


{-| Create a button with a `Primary` visual weight and a `default size`.

    --

    import Prima.Pyxis.Button as Button

    type Msg =
        Clicked

    ...

    myBtn : Button.Config Msg
    myBtn =
        Button.callOut Button.Brand "Click me!" Clicked

-}
callOut : Scheme -> String -> msg -> Config msg
callOut scheme label action =
    Config (Configuration CallOut Normal scheme label action)


{-| Create a button with a `CallOut` visual weight and a `small size`.
-}
callOutSmall : Scheme -> String -> msg -> Config msg
callOutSmall scheme label action =
    Config (Configuration CallOut Small scheme label action)


{-| Create a button with a `Primary` visual weight and a `default size`.
-}
primary : Scheme -> String -> msg -> Config msg
primary scheme label action =
    Config (Configuration Primary Normal scheme label action)


{-| Create a button with a `Primary` visual weight and a `small size`.
-}
primarySmall : Scheme -> String -> msg -> Config msg
primarySmall scheme label action =
    Config (Configuration Primary Small scheme label action)


{-| Create a button with a `Secondary` visual weight and a `default size`.
-}
secondary : Scheme -> String -> msg -> Config msg
secondary scheme label action =
    Config (Configuration Secondary Normal scheme label action)


{-| Create a button with a `Secondary` visual weight and a `small size`.
-}
secondarySmall : Scheme -> String -> msg -> Config msg
secondarySmall scheme label action =
    Config (Configuration Secondary Small scheme label action)


{-| Create a button with a `Tertiary` visual weight and a `default size`.
-}
tertiary : Scheme -> String -> msg -> Config msg
tertiary scheme label action =
    Config (Configuration Tertiary Normal scheme label action)


{-| Create a button with a `Tertiary` visual weight and a `small size`.
-}
tertiarySmall : Scheme -> String -> msg -> Config msg
tertiarySmall scheme label action =
    Config (Configuration Tertiary Small scheme label action)


{-| Renders the button by receiving it's configuration.

    --

    import Prima.Pyxis.Button as Button

    type Msg =
        Clicked

    ...

    myBtn : Button.Config Msg
    myBtn =
        Button.callOut Button.Brand "Click me!" Clicked

    ...

    view : Html Msg
    view =
        let
            isEnabled =
                True
        in
        Button.render isEnabled myBtn

-}
render : Bool -> Config msg -> Html msg
render isEnabled (Config { emphasis, action, label, scheme, size }) =
    button
        [ classList
            [ ( "a-btn", True )
            , ( "a-btn--callout", isCallOut emphasis )
            , ( "a-btn--primary", isPrimary emphasis )
            , ( "a-btn--secondary", isSecondary emphasis )
            , ( "a-btn--tertiary", isTertiary emphasis )
            , ( "a-btn--small", isSmall size )
            , ( "a-btn--normal", isNormal size )
            , ( "a-btn--dark", isDark scheme )
            ]
        , disabled (not isEnabled)
        , onClick action
        ]
        [ span
            []
            [ text label ]
        ]


{-| Create a button wrapper which can hold a set of `Button`s.

    --

    import Prima.Pyxis.Button as Button

    type Msg =
        Clicked

    ...

    ctaBtn : Button.Config Msg
    ctaBtn =
        Button.callOut Button.brand "Click me!" Clicked


    primaryBtn : Button.Config Msg
    primaryBtn =
        Button.primary Button.brand "Click me!" Clicked

    ...

    view : Html Msg
    view =
        let
            isCtaBtnEnabled =
                True

            isPrimaryBtnEnabled =
                True
        in
        Button.group [(isCtaBtnEnabled, ctaBtn), (isPrimaryBtnEnabled, primaryBtn)]

-}
group : List ( Bool, Config msg ) -> Html msg
group buttonsConfig =
    H.btnGroup (List.map (\( isEnabled, button ) -> render isEnabled button) buttonsConfig)


{-| Create a button wrapper which can hold a set of fluid `Button`s.
-}
groupFluid : List ( Bool, Config msg ) -> Html msg
groupFluid buttonsConfig =
    div
        [ class "m-btnGroup m-btnGroup--coverFluid" ]
        (List.map (\( isEnabled, button ) -> render isEnabled button) buttonsConfig)
