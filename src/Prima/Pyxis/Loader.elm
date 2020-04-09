module Prima.Pyxis.Loader exposing
    ( Config
    , spinner, vehicle
    , render
    , withMediumSize, withSmallSize, withText
    )

{-|


## Configuration

@docs Config


## Configuration Methods

@docs spinner, vehicle


## Rendering

@docs render


## Options

@docs withMediumSize, withSmallSize, withText

-}

import Html exposing (Html, div)
import Html.Attributes as HA
import Svg as Svg
import Svg.Attributes as SA


{-| Represent the configuration of the loader.
-}
type Config
    = Config Configuration


type alias Configuration =
    { type_ : LoaderType
    , size : LoaderSize
    , text : Maybe String
    }


{-| Represent the configuration of the loader.
-}
type LoaderSize
    = Small
    | Medium


isLoaderSmall : LoaderSize -> Bool
isLoaderSmall =
    (==) Small


isLoaderMedium : LoaderSize -> Bool
isLoaderMedium =
    (==) Medium


{-| Sets a size to the `Loader`.
-}
withSmallSize : Config -> Config
withSmallSize (Config config) =
    Config { config | size = Small }


{-| Sets a size to the `Loader`.
-}
withMediumSize : Config -> Config
withMediumSize (Config config) =
    Config { config | size = Medium }


{-| Adds a text to the `Loader`.
-}
withText : String -> Config -> Config
withText txt (Config config) =
    Config { config | text = Just txt }


type LoaderType
    = Spinner
    | Vehicle


{-| Represent the configuration of the Spinner loader.
-}
spinner : Config
spinner =
    Config (Configuration Spinner Medium Nothing)


{-| Represent the configuration of the Vehicle loader.
-}
vehicle : Config
vehicle =
    Config (Configuration Vehicle Medium Nothing)


{-| Renders the loader and it's (infinite) animation.
-}
render : Config -> Html msg
render (Config { size, type_, text }) =
    div
        [ HA.classList
            [ ( "m-loader", True )
            , ( "m-loader--small", isLoaderSmall size )
            , ( "m-loader--medium", isLoaderMedium size )
            ]
        ]
        [ case type_ of
            Spinner ->
                renderSpinner

            Vehicle ->
                renderVehicle
        , (Maybe.withDefault (Html.text "") << Maybe.map renderText) text
        ]


renderSpinner : Html msg
renderSpinner =
    Html.div
        [ HA.class "m-loader__spinner"
        ]
        []


renderVehicle : Html msg
renderVehicle =
    Svg.svg
        [ SA.width "150"
        , SA.height "50"
        , SA.class "m-loader__car"
        ]
        [ Svg.g
            [ SA.class "m-loader__car__group"
            ]
            [ Svg.path
                [ SA.class "m-loader__car__group__wheel"
                , SA.d "M184.9,106.3c-12.2,0-21.8-9.6-21.8-21.8s9.6-21.8,21.8-21.8c12.2,0,21.8,9.6,21.8,21.8 S197.1,106.3,184.9,106.3z M184.9,71.2c-7.4,0-12.8,5.9-12.8,12.8c0,7.4,5.9,12.8,12.8,12.8c7.4,0,12.8-5.9,12.8-12.8 C198.2,77.1,192.4,71.2,184.9,71.2z M281.2,106.3c-12.2,0-21.8-9.6-21.8-21.8s9.6-21.8,21.8-21.8c12.2,0,21.8,9.6,21.8,21.8 S292.9,106.3,281.2,106.3z M281.2,71.2c-7.4,0-12.8,5.9-12.8,12.8c0,7.4,5.9,12.8,12.8,12.8c7.4,0,12.8-5.9,12.8-12.8 S288.1,71.2,281.2,71.2z"
                ]
                []
            , Svg.path
                [ SA.class "m-loader__car__group__body"
                , SA.d "M308.8,47.8l-43.6-9c-1.1-0.5-2.7-1.1-3.2-2.1l-17.6-22.9c-2.7-3.7-6.9-5.9-11.2-5.9h-60.6 c-4.3,0-8.5,2.1-11.2,5.3l-28.2,33.5c-3.2,3.7-4.3,9-3.2,13.8l4.8,18.1c1.6,6.4,7.4,10.6,13.8,10.6h17c2.1,0,4.3-2.1,4.3-4.3 c0-2.1-1.6-4.3-4.3-4.3h-17c-2.7,0-4.8-1.6-5.3-4.3l-4.8-18.1c-0.5-2.1,0-4.3,1.1-5.9l28.2-33.5c1.1-1.6,2.7-2.1,4.3-2.1h60.6 c1.6,0,3.2,0.5,4.3,2.1l17.6,22.9c2.1,2.7,5.3,4.8,8.5,5.3l43.6,9c2.7,0.5,4.8,3.2,4.8,5.9v12.2c0,3.2-2.7,5.9-5.9,5.9h-6.4 c-2.1,0-4.3,2.1-4.3,4.3c0,2.1,1.6,4.3,4.3,4.3h6.4c8,0,14.4-6.4,14.9-14.4V62.2C320.6,55.2,315.8,49.4,308.8,47.8z"
                ]
                []
            , Svg.path
                [ SA.class "m-loader__car__group__body"
                , SA.d "M241.8,40.9c0-2.1-1.6-4.3-4.3-4.3h-69.7c-2.1,0-4.3,2.1-4.3,4.3c0,2.1,1.6,4.3,4.3,4.3h69.7 C239.7,45.1,241.8,43,241.8,40.9z"
                ]
                []
            , Svg.path
                [ SA.class "m-loader__car__group__body"
                , SA.d "M263.6,80.2h-61.2c-2.1,0-4.3,2.1-4.3,4.3c0,2.1,1.6,4.3,4.3,4.3h61.2c2.1,0,4.3-2.1,4.3-4.3 C267.9,82.4,266.3,80.2,263.6,80.2z"
                ]
                []
            , Svg.line
                [ SA.class "m-loader__car__group__line m-loader__car__group__line--top"
                , SA.x1 "68"
                , SA.y1 "46.7"
                , SA.x2 "114.2"
                , SA.y2 "46.7"
                ]
                []
            , Svg.line
                [ SA.class "m-loader__car__group__line m-loader__car__group__line--bottom"
                , SA.x1 "33.2"
                , SA.y1 "65.9"
                , SA.x2 "99.4"
                , SA.y2 "65.9"
                ]
                []
            , Svg.line
                [ SA.class "m-loader__car__group__line m-loader__car__group__line--middle"
                , SA.x1 "68"
                , SA.y1 "84.5"
                , SA.x2 "114.2"
                , SA.y2 "84.5"
                ]
                []
            ]
        ]


renderText : String -> Html msg
renderText content =
    Html.div
        [ HA.class "m-loader__text fs-small fw-heavy c-text-dark" ]
        [ Html.p
            []
            [ Html.text content ]
        ]
