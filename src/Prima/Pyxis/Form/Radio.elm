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

import Html exposing (Html, div)
import Html.Attributes as Attrs exposing (checked, class, classList, name, type_, value)
import Html.Events as Events


{-| Represents the configuration of an Input type.
-}
type Radio model optionValue msg
    = Radio (RadioConfig model optionValue msg)


{-| Internal.
-}
type alias RadioConfig model optionValue msg =
    { options : List (RadioOption model msg)
    , name : String
    , radioOptions : List optionValue
    , toSlug : optionValue -> String
    }


{-| Internal.
-}
type alias Value =
    String


{-| Internal.
-}
radio : String -> List optionValue -> (optionValue -> String) -> Radio model optionValue msg
radio name radioOptions toSlug =
    Radio (RadioConfig [] name radioOptions toSlug)


{-| Internal.
-}
type RadioOption model msg
    = Attributes (List (Html.Attribute msg))
    | Class String
    | Disabled Bool
    | Id String
    | OnInput (Value -> msg)
    | Value (model -> Maybe String)


{-| Internal.
-}
type alias Options model msg =
    { attributes : List (Html.Attribute msg)
    , classes : List String
    , disabled : Maybe Bool
    , id : Maybe String
    , onInput : Maybe (Value -> msg)
    , value : model -> Maybe String
    }


{-| Internal.
-}
defaultOptions : Options radioValue msg
defaultOptions =
    { attributes = []
    , classes = [ "a-form__field__radioOptions" ]
    , disabled = Nothing
    , id = Nothing
    , onInput = Nothing
    , value = always Nothing
    }


{-| Internal.
-}
addOption : RadioOption model msg -> Radio model optionValue msg -> Radio model optionValue msg
addOption option (Radio radioConfig) =
    Radio { radioConfig | options = radioConfig.options ++ [ option ] }


{-| Sets an `id` to the `Input config`.
-}
withId : String -> Radio model optionValue msg -> Radio model optionValue msg
withId id =
    addOption (Id id)


{-| Sets a `disabled` to the `Input config`.
-}
withDisabled : Bool -> Radio model optionValue msg -> Radio model optionValue msg
withDisabled disabled =
    addOption (Disabled disabled)


{-| Sets a list of `attributes` to the `Input config`.
-}
withAttributes : List (Html.Attribute msg) -> Radio model optionValue msg -> Radio model optionValue msg
withAttributes attributes =
    addOption (Attributes attributes)


{-| Sets a `value` to the `Input config`.
-}
withValue : (model -> Maybe String) -> Radio model optionValue msg -> Radio model optionValue msg
withValue value =
    addOption (Value value)


{-| Sets an `onInput event` to the `Input config`.
-}
withOnInput : (Value -> msg) -> Radio radioValue optionValue msg -> Radio radioValue optionValue msg
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

    --, Maybe.map Events.onInput (options.onInput >> options.converter)
    ]
        |> List.filterMap identity
        |> (++) options.attributes
        |> (::) (classesAttribute options.classes)


{-| Renders the `Input config`.

    import Prima.Pyxis.Form.Input as FormInput

    type Msg
        = OnInput String
        | OnBlur
        | OnFocus

    view : Html Msg
    view =
        FormInput.text
            [ FormInput.id "myId"
            , FormInput.onInput OnInput
            , FormInput.onBlur OnBlur
            ]
            |> FormInput.render

-}
render : model -> Radio model optionValue msg -> Html msg
render model (Radio config) =
    div
        [ class "a-form__field__radioOptions"
        ]
        (List.map
            (\slug -> renderRadioOption model (Radio config) (config.toSlug slug))
            config.radioOptions
        )


renderRadioOption : model -> Radio model optionValue msg -> String -> Html msg
renderRadioOption model (Radio config) slug =
    Html.input
        ([ type_ "radio"
         , value slug
         , class "a-form__field__radio"
         , checked (config.name == slug)
         ]
            ++ buildAttributes model config.options
        )
        []
