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
            [ ( "m-message", True )
            , ( "message__success", isMessageSuccess config.type_ )
            , ( "message__error", isMessageError config.type_ )
            , ( "message__info", isMessageInfo config.type_ )
            ]
        ]
        [ div
            [ class "m-message__icon" ]
            [ i
                [ classList
                    [ ( "a-icon a-icon-success", isMessageSuccess config.type_ )
                    , ( "a-icon a-icon-error", isMessageError config.type_ )
                    , ( "a-icon a-icon-info", isMessageInfo config.type_ )
                    ]
                ]
                []
            ]
        , span
            [ class "m-message__text" ]
            config.content
        ]
