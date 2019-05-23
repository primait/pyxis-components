module Prima.Pyxis.Message.Message exposing
    ( Config
    , messageErrorConfig
    , messageInfoConfig
    , messageSuccessConfig
    , render
    )

import Html exposing (..)
import Html.Attributes exposing (..)


type Config msg
    = Config (Configuration msg)


type alias Configuration msg =
    { type_ : MessageType
    , content : List (Html msg)
    }


messageInfoConfig : List (Html msg) -> Config msg
messageInfoConfig content =
    Config (Configuration Info content)


messageSuccessConfig : List (Html msg) -> Config msg
messageSuccessConfig content =
    Config (Configuration Success content)


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


render : Config msg -> Html msg
render (Config config) =
    div
        [ classList
            [ ( "m-message", True )
            , ( "m-message--success", isMessageSuccess config.type_ )
            , ( "m-message--error", isMessageError config.type_ )
            , ( "m-message--info", isMessageInfo config.type_ )
            ]
        ]
        [ div
            [ class "m-message__icon" ]
            [ i
                [ classList
                    [ ( "a-icon a-icon-ok", isMessageSuccess config.type_ )
                    , ( "a-icon a-icon-attention", isMessageError config.type_ )
                    , ( "a-icon a-icon-info", isMessageInfo config.type_ )
                    ]
                ]
                []
            ]
        , span
            [ class "m-message__text" ]
            config.content
        ]
