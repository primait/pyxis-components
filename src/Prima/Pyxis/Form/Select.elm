module Prima.Pyxis.Form.Select exposing (..)

{-|


## Types

@docs Select


## Modifiers

@docs withId, withName, withAttributes, withDisabled, withValue


## Events

@docs withOnInput


## Render

@docs render

-}

import Html exposing (Attribute, Html, div, text)
import Html.Attributes as Attrs exposing (checked, class, classList, id, name, type_, value)
import Html.Events as Events exposing (on)


{-| Represents the configuration of a Select type.
-}
type Select model msg
    = Select (SelectConfig model msg)


{-| Internal.
-}
type alias SelectConfig model msg =
    { options : List (SelectOption model msg)
    , selectValues : List ( String, String )
    }


{-| Internal.
-}
select : List ( String, String ) -> Select model msg
select selectValues =
    Select (SelectConfig [] selectValues)


{-| Internal.
-}
type SelectOption model msg
    = Attributes (List (Html.Attribute msg))
    | Class String
    | Disabled Bool
    | Id String
    | Value (model -> Maybe String)
    | OnInput (String -> msg)
    | OnFocus msg
    | OnBlur msg
    | ExclusiveClass String


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
    , classes = [ "a-form-field__select-native" ]
    , disabled = Nothing
    , id = Nothing
    , value = always Nothing
    , onInput = Nothing
    , onFocus = Nothing
    , onBlur = Nothing
    }


{-| Internal.
-}
addOption : SelectOption model msg -> Select model msg -> Select model msg
addOption option (Select selectConfig) =
    Select { selectConfig | options = selectConfig.options ++ [ option ] }


{-| Sets an `id` to the `Input config`.
-}
withId : String -> Select model msg -> Select model msg
withId id =
    addOption (Id id)


{-| Sets a `disabled` to the `Input config`.
-}
withDisabled : Bool -> Select model msg -> Select model msg
withDisabled disabled =
    addOption (Disabled disabled)


{-| Sets a list of `attributes` to the `Input config`.
-}
withAttributes : List (Html.Attribute msg) -> Select model msg -> Select model msg
withAttributes attributes =
    addOption (Attributes attributes)


{-| Sets a `value` to the `Input config`.
-}
withValue : (model -> Maybe String) -> Select model msg -> Select model msg
withValue value =
    addOption (Value value)


{-| Sets an `onBlur event` to the `Input config`.
-}
withOnBlur : msg -> Select model msg -> Select model msg
withOnBlur tagger =
    addOption (OnBlur tagger)


{-| Sets an `onFocus event` to the `Input config`.
-}
withOnFocus : msg -> Select model msg -> Select model msg
withOnFocus tagger =
    addOption (OnFocus tagger)


{-| Sets an `onInput event` to the `Input config`.
-}
withOnInput : (String -> msg) -> Select model msg -> Select model msg
withOnInput tagger =
    addOption (OnInput tagger)


withExclusiveClass : String -> Select model msg -> Select model msg
withExclusiveClass class_ =
    addOption (ExclusiveClass class_)


{-| Internal.
-}
applyOption : SelectOption model msg -> Options model msg -> Options model msg
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

        ExclusiveClass class_ ->
            { options | classes = [ class_ ] }


{-| Transforms a `List` of `Class`(es) into a valid `Html.Attribute`.
-}
classesAttribute : List String -> Html.Attribute msg
classesAttribute =
    Attrs.class << String.join " "


{-| Composes all the modifiers into a set of `Html.Attribute`(s).
-}
buildAttributes : model -> List (SelectOption model msg) -> List (Html.Attribute msg)
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

    import Prima.Pyxis.Form.Select as Select

    view : List (Html Msg)
        view =
        let
            slug =
                "powerSource"
        in
        Select.select
            [ ( "petrol", "Benzina" ), ( "diesel", "Diesel" ) ]
            |> Select.withValue (Just << .powerSource)
            |> Select.withId slug
            |> Select.withOnInput (OnInput PowerSource)
            |> Field.select
            |> Select.render

-}
render : model -> Select model msg -> List (Html msg)
render model (Select config) =
    [ Html.select
        (buildAttributes model config.options)
        (List.concat
            (List.map
                (\( slug, label ) -> renderSelectOption slug label)
                config.selectValues
            )
        )
    ]


renderSelectOption : String -> String -> List (Html msg)
renderSelectOption slug label =
    [ Html.option
        [ value slug
        , id slug
        ]
        [ Html.text label ]
    ]
