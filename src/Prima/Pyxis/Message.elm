module Prima.Pyxis.Message exposing
    ( Config
    , messageErrorConfig, messageInfoConfig, messageSuccessConfig
    , render
    )

{-| Create a `Message` feedback by using predefined Html syntax.


# Configuration

@docs Config


## Options

@docs messageErrorConfig, messageInfoConfig, messageSuccessConfig


# Render

@docs render

-}

import Html exposing (Html, div, i, span)
import Html.Attributes exposing (class, classList)


{-| Represent the configuration of a Message
-}
type Config msg
    = Config (Configuration msg)


type alias Configuration msg =
    { type_ : MessageType
    , content : List (Html msg)
    }


{-| Defines the configuration of an Info message.
-}
messageInfoConfig : List (Html msg) -> Config msg
messageInfoConfig content =
    Config (Configuration Info content)


{-| Defines the configuration of a Success message.
-}
messageSuccessConfig : List (Html msg) -> Config msg
messageSuccessConfig content =
    Config (Configuration Success content)


{-| Defines the configuration of an Error message.
-}
messageErrorConfig : List (Html msg) -> Config msg
messageErrorConfig content =
    Config (Configuration Error content)


type MessageType
    = Info
    | Success
    | Error


isMessageInfo : MessageType -> Bool
isMessageInfo =
    (==) Info


isMessageSuccess : MessageType -> Bool
isMessageSuccess =
    (==) Success


isMessageError : MessageType -> Bool
isMessageError =
    (==) Error


{-| Renders the Message by receiving it's configuration.
-}
render : Config msg -> Html msg
render (Config { type_, content }) =
    div
        [ classList
            [ ( "m-message", True )
            , ( "m-message--success", isMessageSuccess type_ )
            , ( "m-message--error", isMessageError type_ )
            , ( "m-message--info", isMessageInfo type_ )
            ]
        ]
        [ div
            [ class "m-message__icon" ]
            [ i
                [ classList
                    [ ( "a-icon a-icon-ok", isMessageSuccess type_ )
                    , ( "a-icon a-icon-attention", isMessageError type_ )
                    , ( "a-icon a-icon-info", isMessageInfo type_ )
                    ]
                ]
                []
            ]
        , span
            [ class "m-message__text" ]
            content
        ]
