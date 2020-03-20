module Prima.Pyxis.Message exposing
    ( Config, error, info, success
    , withClass, withClassList, withAttribute
    , withOnClick, withOnMouseDown, withOnMouseUp, withOnMouseEnter, withOnMouseLeave, withOnMouseOver, withOnMouseOut
    , render
    )

{-| Create a `Message` feedback by using predefined Html syntax.


# Configuration

@docs Config, error, info, success


## Options

@docs withClass, withClassList, withAttribute


## Events

@docs withOnClick, withOnMouseDown, withOnMouseUp, withOnMouseEnter, withOnMouseLeave, withOnMouseOver, withOnMouseOut


# Render

@docs render

-}

import Html exposing (Html, div, i, span)
import Html.Attributes as Attrs
import Html.Events as Events
import Prima.Pyxis.Helpers as H


{-| Represent the configuration of a Message
-}
type Config msg
    = Config (Configuration msg)


type alias Configuration msg =
    { type_ : MessageType
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


{-| Internal. Represents the list of options for the `Message` component.
-}
type alias Options msg =
    { classes : List String
    , classList : List ( String, Bool )
    , events : List (Html.Attribute msg)
    , attributes : List (Html.Attribute msg)
    }


{-| Internal. Represents the initial state of the list of options for the `Message` component.
-}
defaultOptions : Options msg
defaultOptions =
    { classes = []
    , classList = []
    , events = []
    , attributes = []
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
    Config (Configuration Info content [])


{-| Defines the configuration of a Success message.
-}
success : List (Html msg) -> Config msg
success content =
    Config (Configuration Success content [])


{-| Defines the configuration of an Error message.
-}
error : List (Html msg) -> Config msg
error content =
    Config (Configuration Error content [])


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
render ((Config { type_, content }) as config) =
    div
        (buildAttributes config)
        [ div
            [ Attrs.class "m-message__icon" ]
            [ i
                [ Attrs.classList
                    [ ( "a-icon a-icon-ok", isMessageSuccess type_ )
                    , ( "a-icon a-icon-attention", isMessageError type_ )
                    , ( "a-icon a-icon-info", isMessageInfo type_ )
                    ]
                ]
                []
            ]
        , span
            [ Attrs.class "m-message__text" ]
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
buildClassList (Config { type_ }) options =
    [ ( "m-message", True )
    , ( "m-message--success", isMessageSuccess type_ )
    , ( "m-message--error", isMessageError type_ )
    , ( "m-message--info", isMessageInfo type_ )
    ]
        |> List.append options.classList
        |> List.append (List.map (H.flip Tuple.pair True) options.classes)
        |> Attrs.classList
