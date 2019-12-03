module Prima.Pyxis.Form.Radio exposing (..)

{-|


## Types

@docs Radio


## Modifiers

@docs withId, withName, withAttributes, withDisabled, withValue


## Events

@docs withOnInput


## Render

@docs render

-}

import Html exposing (Attribute, Html, div)
import Html.Attributes as Attrs exposing (checked, class, classList, id, name, type_, value)
import Html.Events as Events exposing (on)
import Json.Decode as Json
import Prima.Pyxis.Form.Label as Label


{-| Represents the configuration of an Input type.
-}
type Radio model msg
    = Radio (RadioConfig model msg)


{-| Internal.
-}
type alias RadioConfig model msg =
    { options : List (RadioOption model msg)
    , name : String
    , radioValues : List ( String, String )
    }


{-| Internal.
-}
type alias Value =
    String


radio : String -> List ( String, String ) -> Radio model msg
radio name radioOptions =
    Radio (RadioConfig [] name radioOptions)


{-| Internal.
-}
type RadioOption model msg
    = Attributes (List (Html.Attribute msg))
    | Class String
    | Disabled Bool
    | Id String
    | Value (model -> Maybe String)
    | OnInput (String -> msg)
    | OnFocus msg
    | OnBlur msg


{-| Internal.
-}
type alias Options model msg =
    { attributes : List (Html.Attribute msg)
    , classes : List String
    , disabled : Maybe Bool
    , id : Maybe String
    , value : model -> Maybe String
    , onInput : Maybe (String -> msg)
    , onFocus : Maybe msg
    , onBlur : Maybe msg
    }


defaultOptions : Options model msg
defaultOptions =
    { attributes = []
    , classes = [ "a-form-field__radio" ]
    , disabled = Nothing
    , id = Nothing
    , value = always Nothing
    , onInput = Nothing
    , onFocus = Nothing
    , onBlur = Nothing
    }


{-| Internal.
-}
addOption : RadioOption model msg -> Radio model msg -> Radio model msg
addOption option (Radio radioConfig) =
    Radio { radioConfig | options = radioConfig.options ++ [ option ] }


{-| Sets an `id` to the `Input config`.
-}
withId : String -> Radio model msg -> Radio model msg
withId id =
    addOption (Id id)


{-| Sets a `disabled` to the `Input config`.
-}
withDisabled : Bool -> Radio model msg -> Radio model msg
withDisabled disabled =
    addOption (Disabled disabled)


{-| Sets a list of `attributes` to the `Input config`.
-}
withAttributes : List (Html.Attribute msg) -> Radio model msg -> Radio model msg
withAttributes attributes =
    addOption (Attributes attributes)


{-| Sets a `value` to the `Input config`.
-}
withValue : (model -> Maybe String) -> Radio model msg -> Radio model msg
withValue value =
    addOption (Value value)


{-| Sets an `onBlur event` to the `Input config`.
-}
withOnBlur : msg -> Radio model msg -> Radio model msg
withOnBlur tagger =
    addOption (OnBlur tagger)


{-| Sets an `onFocus event` to the `Input config`.
-}
withOnFocus : msg -> Radio model msg -> Radio model msg
withOnFocus tagger =
    addOption (OnFocus tagger)


{-| Sets an `onInput event` to the `Input config`.
-}
withOnInput : (String -> msg) -> Radio model msg -> Radio model msg
withOnInput tagger =
    addOption (OnInput tagger)


{-| Internal.
-}
applyOption : RadioOption model msg -> Options model msg -> Options model msg
applyOption modifier options =
    case modifier of
        Attributes attributes_ ->
            { options | attributes = options.attributes ++ attributes_ }

        Class class_ ->
            { options | classes = class_ :: options.classes }

        Disabled disabled_ ->
            { options | disabled = Just disabled_ }

        Id id_ ->
            { options | id = Just id_ }

        Value reader ->
            { options | value = reader }

        OnFocus onFocus_ ->
            { options | onFocus = Just onFocus_ }

        OnBlur onBlur_ ->
            { options | onBlur = Just onBlur_ }

        OnInput onInput_ ->
            { options | onInput = Just onInput_ }


{-| Transforms a `List` of `Class`(es) into a valid `Html.Attribute`.
-}
classesAttribute : List String -> Html.Attribute msg
classesAttribute =
    Attrs.class << String.join " "


{-| Composes all the modifiers into a set of `Html.Attribute`(s).
-}
buildAttributes : model -> List (RadioOption model msg) -> List (Html.Attribute msg)
buildAttributes model modifiers =
    let
        options =
            List.foldl applyOption defaultOptions modifiers
    in
    [ Maybe.map Attrs.id options.id
    , Maybe.map Attrs.disabled options.disabled
    , Maybe.map Attrs.value (options.value model)
    , Maybe.map Events.onInput options.onInput
    , Maybe.map Events.onFocus options.onFocus
    , Maybe.map Events.onBlur options.onBlur
    ]
        |> List.filterMap identity
        |> (++) options.attributes
        |> (::) (classesAttribute options.classes)


{-| Renders the `Radio config`.

    import Prima.Pyxis.Form.Radio as Radio

    view : List (Html Msg)
    view =
        Radio.radio
            "guideType"
            [ ( "expert", "Esperta" ), ( "free", "Libera" ) ]
            guideTypeToSlug
            |> Field.radio
            |> Radio.render

-}
render : model -> Radio model msg -> List (Html msg)
render model (Radio config) =
    [ div
        [ class "a-form-field__radioOptions"
        ]
        (List.concat
            (List.map
                (\( slug, label ) -> renderRadioOption model (Radio config) slug label)
                config.radioValues
            )
        )
    ]


renderRadioOption : model -> Radio model msg -> String -> String -> List (Html msg)
renderRadioOption model (Radio config) slug label =
    [ Html.input
        ([ type_ "radio"
         , value slug
         , id slug
         , name config.name
         ]
            ++ buildAttributes model config.options
        )
        []
    , Label.label [ Label.for slug ] label
        |> Label.withExclusiveClass "a-form-field__radio__label"
        |> Label.render
    ]
