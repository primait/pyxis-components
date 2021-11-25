module Prima.PyxisV3.Message exposing
    ( Config
    , error, info, success, alert, errorAlt, infoAlt, successAlt, alertAlt
    , render
    , withClass, withClassList, withAttribute, withSvgIcons
    , withOnClick, withOnMouseDown, withOnMouseUp, withOnMouseEnter, withOnMouseLeave, withOnMouseOver, withOnMouseOut
    )

{-|


## Configuration

@docs Config


## Configuration Methods

@docs error, info, success, alert, errorAlt, infoAlt, successAlt, alertAlt


## Rendering

@docs render


## Options

@docs withClass, withClassList, withAttribute, withSvgIcons


## Event Options

@docs withOnClick, withOnMouseDown, withOnMouseUp, withOnMouseEnter, withOnMouseLeave, withOnMouseOver, withOnMouseOut

-}

import Html exposing (Html, div, i, span)
import Html.Attributes as Attrs
import Html.Events as Events
import Prima.PyxisV3.Helpers as H
import Prima.PyxisV3.Message.Icons as MessageIcon


{-| Represent the configuration of a Message
-}
type Config msg
    = Config (Configuration msg)


type alias Configuration msg =
    { type_ : MessageType
    , kind : MessageKind
    , content : List (Html msg)
    , options : List (MessageOption msg)
    }


{-| Internal. Represents the possible options for a `Message`.
-}
type MessageOption msg
    = Class String
    | ClassList (List ( String, Bool ))
    | Event (Html.Attribute msg)
    | Attribute (Html.Attribute msg)
    | UseSvgIcons


{-| Internal. Represents the list of options for the `Message` component.
-}
type alias Options msg =
    { classes : List String
    , classList : List ( String, Bool )
    , events : List (Html.Attribute msg)
    , attributes : List (Html.Attribute msg)
    , useSvgIcons : Bool
    }


{-| Internal. Represents the initial state of the list of options for the `Message` component.
-}
defaultOptions : Options msg
defaultOptions =
    { classes = []
    , classList = []
    , events = []
    , attributes = []
    , useSvgIcons = False
    }


{-| Internal. Applies the customizations made by end user to the `Message` component.
-}
applyOption : MessageOption msg -> Options msg -> Options msg
applyOption modifier options =
    case modifier of
        Class class ->
            { options | classes = class :: options.classes }

        ClassList list ->
            { options | classList = List.append list options.classList }

        Event action ->
            { options | events = action :: options.events }

        Attribute attr ->
            { options | attributes = attr :: options.attributes }

        UseSvgIcons ->
            { options | useSvgIcons = True }


{-| Internal. Applies all the customizations and returns the internal `Options` type.
-}
computeOptions : Config msg -> Options msg
computeOptions (Config config) =
    List.foldl applyOption defaultOptions config.options


{-| Internal. Adds a generic option to the `Message`.
-}
addOption : MessageOption msg -> Config msg -> Config msg
addOption option (Config messageConfig) =
    Config { messageConfig | options = messageConfig.options ++ [ option ] }


{-| Adds a `class` to the `Message`.
-}
withClass : String -> Config msg -> Config msg
withClass class_ =
    addOption (Class class_)


{-| Adds classes to the `classList` of the `Message`.
-}
withClassList : List ( String, Bool ) -> Config msg -> Config msg
withClassList classList =
    addOption (ClassList classList)


{-| Adds a generic attribute to the `Message`.
-}
withAttribute : Html.Attribute msg -> Config msg -> Config msg
withAttribute attr =
    addOption (Attribute attr)


{-| Tells the `Message` component to use SVG icons instead of Pyxis icons.
-}
withSvgIcons : Config msg -> Config msg
withSvgIcons =
    addOption UseSvgIcons


{-| Adds an `onClick` Html.Event to the `Message`.
-}
withOnClick : msg -> Config msg -> Config msg
withOnClick tagger =
    addOption (Event (Events.onClick tagger))


{-| Adds an `onMouseDown` Html.Event to the `Message`.
-}
withOnMouseDown : msg -> Config msg -> Config msg
withOnMouseDown tagger =
    addOption (Event (Events.onMouseDown tagger))


{-| Adds an `onMouseUp` Html.Event to the `Message`.
-}
withOnMouseUp : msg -> Config msg -> Config msg
withOnMouseUp tagger =
    addOption (Event (Events.onMouseUp tagger))


{-| Adds an `onMouseEnter` Html.Event to the `Message`.
-}
withOnMouseEnter : msg -> Config msg -> Config msg
withOnMouseEnter tagger =
    addOption (Event (Events.onMouseEnter tagger))


{-| Adds an `onMouseLeave` Html.Event to the `Message`.
-}
withOnMouseLeave : msg -> Config msg -> Config msg
withOnMouseLeave tagger =
    addOption (Event (Events.onMouseLeave tagger))


{-| Adds an `onMouseOver` Html.Event to the `Message`.
-}
withOnMouseOver : msg -> Config msg -> Config msg
withOnMouseOver tagger =
    addOption (Event (Events.onMouseOver tagger))


{-| Adds an `onMouseOut` Html.Event to the `Message`.
-}
withOnMouseOut : msg -> Config msg -> Config msg
withOnMouseOut tagger =
    addOption (Event (Events.onMouseOut tagger))


{-| Defines the configuration of an Info message.
-}
info : List (Html msg) -> Config msg
info content =
    Config (Configuration Info Base content [])


{-| Defines the configuration of a Success message.
-}
success : List (Html msg) -> Config msg
success content =
    Config (Configuration Success Base content [])


{-| Defines the configuration of an Error message.
-}
error : List (Html msg) -> Config msg
error content =
    Config (Configuration Error Base content [])


{-| Defines the configuration of an Alert message.
-}
alert : List (Html msg) -> Config msg
alert content =
    Config (Configuration Alert Base content [])


{-| Defines the configuration of an Info message with kind Alt.
-}
infoAlt : List (Html msg) -> Config msg
infoAlt content =
    Config (Configuration Info Alt content [])


{-| Defines the configuration of a Success message with kind Alt.
-}
successAlt : List (Html msg) -> Config msg
successAlt content =
    Config (Configuration Success Alt content [])


{-| Defines the configuration of an Error message with kind Alt.
-}
errorAlt : List (Html msg) -> Config msg
errorAlt content =
    Config (Configuration Error Alt content [])


{-| Defines the configuration of an Alert message with kind Alt.
-}
alertAlt : List (Html msg) -> Config msg
alertAlt content =
    Config (Configuration Alert Alt content [])


type MessageType
    = Info
    | Success
    | Alert
    | Error


isMessageInfo : MessageType -> Bool
isMessageInfo =
    (==) Info


isMessageSuccess : MessageType -> Bool
isMessageSuccess =
    (==) Success


isMessageAlert : MessageType -> Bool
isMessageAlert =
    (==) Alert


isMessageError : MessageType -> Bool
isMessageError =
    (==) Error


type MessageKind
    = Base
    | Alt


isMessageKindBase : MessageKind -> Bool
isMessageKindBase =
    (==) Base


isMessageKindAlt : MessageKind -> Bool
isMessageKindAlt =
    (==) Alt


{-| Renders the Message by receiving it's configuration.
-}
render : Config msg -> Html msg
render ((Config { type_, content }) as config) =
    div
        (buildAttributes config)
        [ div
            [ Attrs.class "message__icon" ]
            (if
                config
                    |> computeOptions
                    |> .useSvgIcons
             then
                [ H.renderIf (isMessageSuccess type_) MessageIcon.renderIconOk
                , H.renderIf (isMessageInfo type_) MessageIcon.renderIconInfo
                , H.renderIf (isMessageAlert type_) MessageIcon.renderIconAlert
                , H.renderIf (isMessageError type_) MessageIcon.renderIconError
                ]

             else
                [ i
                    [ Attrs.classList
                        [ ( "icon icon-ok", isMessageSuccess type_ )
                        , ( "icon icon-info", isMessageInfo type_ )
                        , ( "icon icon-attention", isMessageAlert type_ )
                        , ( "icon icon-danger", isMessageError type_ )
                        ]
                    ]
                    []
                ]
            )
        , span
            [ Attrs.class "message__content" ]
            content
        ]


{-| Internal. Transforms all the customizations into a list of valid Html.Attribute(s).
-}
buildAttributes : Config msg -> List (Html.Attribute msg)
buildAttributes messageConfig =
    let
        options =
            computeOptions messageConfig
    in
    [ buildClassList messageConfig options ]
        |> List.append options.attributes
        |> List.append options.events


{-| Internal. Merges the component configuration and options to a classList attribute.
-}
buildClassList : Config msg -> Options msg -> Html.Attribute msg
buildClassList (Config { type_, kind }) options =
    [ ( "message", True )
    , ( "message--primary", isMessageSuccess type_ )
    , ( "message--info", isMessageInfo type_ )
    , ( "message--alert", isMessageAlert type_ )
    , ( "message--error", isMessageError type_ )
    , ( "message--base", isMessageKindBase kind )
    , ( "message--alt", isMessageKindAlt kind )
    ]
        |> List.append options.classList
        |> List.append (List.map (H.flip Tuple.pair True) options.classes)
        |> Attrs.classList
