module Prima.PyxisV3.Commons.InterceptedEvents exposing
    ( InterceptedEvent, onClick, onDoubleClick, on
    , withStopPropagation, withPreventDefault
    , toHtmlAttribute
    )

{-| This module offers some abstractions and common utilities to handle intercepted events.


# Configuration

@docs InterceptedEvent, NativeEvent, onClick, onDoubleClick, on


## Options

@docs withStopPropagation, withPreventDefault


# Event builder

@docs toHtmlAttribute

-}

import Html
import Html.Events
import Json.Decode as JsonDecode
import Prima.PyxisV3.Commons.Interceptor as Interceptor exposing (Interceptor)


{-| Internal use only
This wraps native js event slug
-}
type NativeEvent
    = NativeEvent String


{-| Internal use only
This extract native js event slug from NativeEvent type
-}
nativeEventSlug : NativeEvent -> String
nativeEventSlug (NativeEvent slug) =
    slug


{-| Internal use only, opaquely exposed for type hinting
Wraps together all InterceptedEvents construction flags avoiding to use
pipeable constructing style
-}
type InterceptedEvent msg
    = Config (InterceptedEventConfig msg)


{-| Internal use only
This wraps together all the needed information that i need to produce the event
-}
type alias InterceptedEventConfig msg =
    { nativeEvent : NativeEvent
    , interceptor : Interceptor
    , stopPropagation : Bool
    , preventDefault : Bool
    , msg : msg
    }


{-| Click Native Event constructor


## Use this with Interceptor constructors

    ...
    myFancyDivInterceptor: Interceptor.Interceptor
    myFancyDivInterceptor = Interceptor.targetContainsClassInterceptor "my-fancy-div"
    ...
    onClickMyFancyDiv: Msg -> Html.Attribute Msg
    onClickMyFancyDiv myClickEvent =
          InterceptedEvents.onClick myClickEvent
          |> InterceptedEvents.withPreventDefault
          |> InterceptedEvents.event
    ...
    div
    [ class "my-fancy-div"
    , onClickMyFancyDiv MyFancyDivClicked ]
    [ .. ]
    ...

--

--

-}
onClick : Interceptor -> msg -> InterceptedEvent msg
onClick interceptor msg =
    Config
        { msg = msg
        , interceptor = interceptor
        , nativeEvent = NativeEvent "click"
        , stopPropagation = False
        , preventDefault = False
        }


{-| Double Click Native Event constructor


## Use this with Interceptor constructors

    ...
    myFancyDivInterceptor: Interceptor.Interceptor
    myFancyDivInterceptor = Interceptor.targetContainsClassInterceptor "my-fancy-div"
    ...
    onDoubleClickMyFancyDiv: Msg -> Html.Attribute Msg
    onDoubleClickMyFancyDiv myDoubleClickEvent =
          InterceptedEvents.onDoubleClick myDoubleClickEvent
          |> InterceptedEvents.withPreventDefault
          |> InterceptedEvents.event
    ...
    div
    [ class "my-fancy-div"
    , onDoubleClickMyFancyDiv MyFancyDivDoubleClicked ]
    [ .. ]
    ...

--

-}
onDoubleClick : Interceptor -> msg -> InterceptedEvent msg
onDoubleClick interceptor msg =
    Config
        { msg = msg
        , interceptor = interceptor
        , nativeEvent = NativeEvent "dblclick"
        , stopPropagation = False
        , preventDefault = False
        }


{-| Generic intercepted native event
See <https://developer.mozilla.org/en-US/docs/Web/Events>
for a complete list of JS events names. If you need an event not actually
provided by NativeEvent constructors you should add it here in this module
avoiding this constructor


## Use this with Interceptor constructors

    ...
    myFancyDivInterceptor: InterceptedEvents.Interceptor
    myFancyDivInterceptor = InterceptedEvents.targetContainsClassInterceptor "my-fancy-div"
    ...
    onFocusInMyFancyDiv: Msg -> Html.Attribute Msg
    onFocusInMyFancyDiv myFocusInEvent =
          InterceptedEvents.on "focusin" myFocusInEvent
          |> InterceptedEvents.withStopPropagation
          |> InterceptedEvents.event
    ...
    div
    [ class "my-fancy-div"
    , onFocusInMyFancyDiv MyFancyDivFocusedIn ]
    [ .. ]
    ...

--

-}
on : String -> Interceptor -> msg -> InterceptedEvent msg
on jsEventName interceptor msg =
    Config
        { msg = msg
        , interceptor = interceptor
        , nativeEvent = NativeEvent jsEventName
        , stopPropagation = False
        , preventDefault = False
        }


{-| Optional modifier. Stops event propagation once events is intercepted
-}
withStopPropagation : InterceptedEvent msg -> InterceptedEvent msg
withStopPropagation (Config interceptedEventConfig) =
    { interceptedEventConfig
        | stopPropagation = True
    }
        |> Config


{-| Optional modifier. Avoid triggering any default event listener once intercepted
-}
withPreventDefault : InterceptedEvent msg -> InterceptedEvent msg
withPreventDefault (Config interceptedEventConfig) =
    { interceptedEventConfig
        | preventDefault = True
    }
        |> Config


{-| Converts InterceptedEvent desired intercepted event
-}
toHtmlAttribute : InterceptedEvent msg -> Html.Attribute msg
toHtmlAttribute (Config interceptedEventConfig) =
    interceptedEventConfig
        |> .interceptor
        |> decodeTargetFieldByInterceptor
        |> JsonDecode.andThen (emitIfIntercepted interceptedEventConfig)
        |> Html.Events.custom (nativeEventSlug interceptedEventConfig.nativeEvent)


type alias ElmCustomEvent msg =
    { message : msg
    , stopPropagation : Bool
    , preventDefault : Bool
    }


{-| Internal.
Choose the right emitter rule
-}
emitIfIntercepted : InterceptedEventConfig msg -> String -> JsonDecode.Decoder (ElmCustomEvent msg)
emitIfIntercepted { interceptor, msg, stopPropagation, preventDefault } targetIdentifier =
    case interceptor of
        Interceptor.ContainsClass interceptedClass ->
            emitIfContainsClass interceptedClass targetIdentifier msg stopPropagation preventDefault

        Interceptor.WithId interceptedId ->
            emitIfIdMatches interceptedId targetIdentifier msg stopPropagation preventDefault


{-| Internal.
Emits msg only if class to intercept is in target full className
-}
emitIfContainsClass : String -> String -> msg -> Bool -> Bool -> JsonDecode.Decoder (ElmCustomEvent msg)
emitIfContainsClass interceptedClass targetClass msg stopPropagation preventDefault =
    if String.contains interceptedClass targetClass then
        JsonDecode.succeed
            { message = msg
            , stopPropagation = stopPropagation
            , preventDefault = preventDefault
            }

    else
        JsonDecode.fail "ignoring"


{-| Internal.
Emits msg only if id to intercept and target id are the same
-}
emitIfIdMatches : String -> String -> msg -> Bool -> Bool -> JsonDecode.Decoder (ElmCustomEvent msg)
emitIfIdMatches interceptedId targetId msg stopPropagation preventDefault =
    if interceptedId == targetId then
        JsonDecode.succeed
            { message = msg
            , stopPropagation = stopPropagation
            , preventDefault = preventDefault
            }

    else
        JsonDecode.fail "ignoring"


{-| Internal.
-}
decodeTargetFieldByInterceptor : Interceptor -> JsonDecode.Decoder String
decodeTargetFieldByInterceptor supportedInterceptor =
    case supportedInterceptor of
        Interceptor.ContainsClass _ ->
            decodeTargetClassName

        Interceptor.WithId _ ->
            decodeTargetId


{-| Internal.
Decodes `className` value as a String of something that contains target and className fields
-}
decodeTargetClassName : JsonDecode.Decoder String
decodeTargetClassName =
    decodesTargetWith <|
        JsonDecode.at [ "className" ] JsonDecode.string


{-| Internal.
Decodes `id` value as a String of something that contains target and id fields
-}
decodeTargetId : JsonDecode.Decoder String
decodeTargetId =
    decodesTargetWith <|
        JsonDecode.at [ "id" ] JsonDecode.string


{-| Internal.
Decodes target field on event before everything else
-}
decodesTargetWith : JsonDecode.Decoder any -> JsonDecode.Decoder any
decodesTargetWith decoder =
    JsonDecode.field "target" decoder
