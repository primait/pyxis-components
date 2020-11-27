module Prima.Pyxis.Message exposing
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

import Html exposing (Html, div, i, span, text)
import Html.Attributes as Attrs
import Html.Events as Events
import Prima.Pyxis.Helpers as H
import Svg


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
            (if config |> computeOptions |> .useSvgIcons then
                [ H.renderIf (isMessageSuccess type_) renderIconOk
                , H.renderIf (isMessageInfo type_) renderIconInfo
                , H.renderIf (isMessageAlert type_) renderIconAlert
                , H.renderIf (isMessageError type_) renderIconError
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


renderIconOk : Html msg
renderIconOk =
    Svg.node "svg"
        [ Attrs.attribute "role" "icon"
        , Attrs.attribute "xmlns" "http://www.w3.org/2000/svg"
        , Attrs.attribute "viewBox" "0 0 1024 1024"
        ]
        [ Svg.node "title" [] [ text "ok" ]
        , Svg.node "path" [ Attrs.attribute "d" "M275.2 502.4c0 9.6-9.6 19.2-19.2 19.2s-19.2-9.6-19.2-19.2 9.6-19.2 19.2-19.2 19.2 9.6 19.2 19.2zm614.4-6.4v192c0 48-25.6 76.8-35.2 89.6l-41.6 44.8c-28.8 28.8-67.2 32-76.8 32H499.2c-54.4 0-86.4-28.8-92.8-35.2l-32-35.2v3.2c0 35.2-28.8 64-64 64H201.6c-35.2 0-64-28.8-64-64v-336c0-35.2 28.8-64 64-64h105.6c32 0 60.8 25.6 64 57.6l128-131.2 38.4-140.8c3.2-12.8 16-32 38.4-32h67.2c19.2 0 35.2 12.8 35.2 32v230.4h108.8c12.8 0 35.2 6.4 57.6 28.8l28.8 28.8c9.6 9.6 16 22.4 16 35.2zM336 784V451.2c0-16-12.8-28.8-28.8-28.8H201.6c-16 0-28.8 12.8-28.8 28.8V784c0 16 12.8 28.8 28.8 28.8h105.6c16 0 28.8-12.8 28.8-28.8zm518.4-288c0-6.4-3.2-9.6-6.4-16l-28.8-28.8c-12.8-12.8-25.6-16-28.8-16H675.2c-16-3.2-28.8-12.8-28.8-41.6V179.2H576l-3.2 3.2-41.6 144c0 3.2-3.2 6.4-6.4 9.6L368 499.2v233.6l60.8 64c3.2 3.2 25.6 25.6 67.2 25.6h240c3.2 0 32 0 51.2-19.2l41.6-44.8c6.4-6.4 25.6-28.8 25.6-64z" ] []
        ]


renderIconInfo : Html msg
renderIconInfo =
    Svg.node "svg"
        [ Attrs.attribute "role" "icon"
        , Attrs.attribute "xmlns" "http://www.w3.org/2000/svg"
        , Attrs.attribute "viewBox" "0 0 1024 1024"
        ]
        [ Svg.node "title" [] [ text "info" ]
        , Svg.node "path" [ Attrs.attribute "d" "M512 873.6c-198.4 0-361.6-163.2-361.6-361.6S313.6 150.4 512 150.4 873.6 313.6 873.6 512 710.4 873.6 512 873.6zm0-681.6c-176 0-320 144-320 320s144 320 320 320 320-144 320-320-144-320-320-320zm0 550.4c-12.8 0-22.4-9.6-22.4-22.4V454.4c0-12.8 9.6-22.4 22.4-22.4s22.4 9.6 22.4 22.4V720c0 12.8-9.6 22.4-22.4 22.4zm0-342.4c-12.8 0-22.4-9.6-22.4-22.4v-38.4c0-12.8 9.6-22.4 22.4-22.4s22.4 9.6 22.4 22.4v38.4c0 12.8-9.6 22.4-22.4 22.4z" ] []
        ]


renderIconAlert : Html msg
renderIconAlert =
    Svg.node "svg"
        [ Attrs.attribute "role" "icon"
        , Attrs.attribute "xmlns" "http://www.w3.org/2000/svg"
        , Attrs.attribute "viewBox" "0 0 1024 1024"
        ]
        [ Svg.node "title" [] [ text "alert" ]
        , Svg.node "path" [ Attrs.attribute "d" "M528 857.6c-121.6 0-236.8-12.8-345.6-35.2l-16-3.2c-6.4 0-12.8-6.4-16-12.8s-3.2-12.8-3.2-19.2c3.2-6.4 3.2-12.8 6.4-19.2 19.2-51.2 41.6-102.4 64-153.6 80-172.8 176-326.4 275.2-441.6 3.2-6.4 9.6-9.6 19.2-9.6 6.4 0 12.8 3.2 19.2 9.6C630.4 288 726.4 441.6 806.4 614.4c22.4 51.2 44.8 102.4 64 153.6 3.2 9.6 6.4 16 9.6 25.6 3.2 6.4 3.2 12.8-3.2 19.2-3.2 6.4-9.6 9.6-16 12.8-6.4 0-12.8 3.2-22.4 3.2-99.2 19.2-204.8 28.8-310.4 28.8zm-326.4-76.8c102.4 19.2 211.2 32 326.4 32 102.4 0 201.6-9.6 294.4-25.6-19.2-48-38.4-99.2-60.8-150.4C688 476.8 601.6 336 512 227.2 422.4 336 336 476.8 262.4 636.8c-22.4 48-41.6 96-60.8 144zM512 614.4c-12.8 0-22.4-9.6-22.4-22.4V409.6c0-12.8 9.6-22.4 22.4-22.4s22.4 9.6 22.4 22.4V592c0 9.6-9.6 22.4-22.4 22.4zm0 108.8c-12.8 0-22.4-9.6-22.4-22.4v-9.6c0-12.8 9.6-22.4 22.4-22.4s22.4 9.6 22.4 22.4v9.6c0 9.6-9.6 22.4-22.4 22.4z" ] []
        ]


renderIconError : Html msg
renderIconError =
    Svg.node "svg"
        [ Attrs.attribute "role" "icon"
        , Attrs.attribute "xmlns" "http://www.w3.org/2000/svg"
        , Attrs.attribute "viewBox" "0 0 1024 1024"
        ]
        [ Svg.node "title" [] [ text "error" ]
        , Svg.node "path" [ Attrs.attribute "d" "M512 873.6c-198.4 0-361.6-163.2-361.6-361.6S313.6 150.4 512 150.4 873.6 313.6 873.6 512 710.4 873.6 512 873.6zm0-681.6c-176 0-320 144-320 320s144 320 320 320 320-144 320-320-144-320-320-320zm0 361.6c-12.8 0-22.4-9.6-22.4-22.4V352c0-12.8 9.6-22.4 22.4-22.4s22.4 9.6 22.4 22.4v179.2c0 12.8-9.6 22.4-22.4 22.4zm38.4 83.2c0 22.4-16 38.4-38.4 38.4s-38.4-16-38.4-38.4 16-38.4 38.4-38.4 38.4 19.2 38.4 38.4z" ] []
        ]
