module Prima.Pyxis.Messages.Messages exposing
    ( messageErrorConfig
    , messageInfoConfig
    , messageSuccessConfig
    , render
    )

import Html exposing (..)
import Html.Attributes exposing (..)


type alias Config msg =
    { type_ : MessageType
    , content : List (Html msg)
    }


messageInfoConfig : List (Html msg) -> Config msg
messageInfoConfig =
    Config Info


messageSuccessConfig : List (Html msg) -> Config msg
messageSuccessConfig =
    Config Success


messageErrorConfig : List (Html msg) -> Config msg
messageErrorConfig =
    Config Error


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
render config =
    div
        [ classList
            [ ( "message", True )
            , ( "message__success", isMessageSuccess config.type_ )
            , ( "message__error", isMessageError config.type_ )
            , ( "message__info", isMessageInfo config.type_ )
            ]
        ]
        [ div
            [ class "message__icon" ]
            [ i
                [ classList
                    [ ( "icon-success", isMessageSuccess config.type_ )
                    , ( "icon-error", isMessageError config.type_ )
                    , ( "icon-info", isMessageInfo config.type_ )
                    ]
                ]
                []
            ]
        , span
            [ class "message__content" ]
            config.content
        ]
