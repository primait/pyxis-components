module Prima.Pyxis.Form.Select exposing (..)

{-|


## Types

@docs Select, select


## Modifiers

@docs withId, withName, withAttributes, withDisabled, withValue


## Events

@docs withOnSelect


## Render

@docs render

-}

import Html exposing (Attribute, Html, div, text)
import Html.Attributes as Attrs exposing (checked, class, classList, id, name, selected, type_, value)
import Html.Events as Events exposing (on)


{-| Represents the configuration of a Select type.
-}
type Select model msg
    = Select (SelectConfig model msg)


type alias SelectConfig model msg =
    { options : List (SelectOption model msg)
    , selectOptions : List ( String, String )
    }


select : List ( String, String ) -> Select model msg
select =
    Select << SelectConfig []


{-| Internal.
-}
type SelectOption model msg
    = Attributes (List (Html.Attribute msg))
    | Class String
    | Disabled Bool
    | ExclusiveClass String
    | Id String
    | OnChange (String -> msg)
    | OnFocus msg
    | OnBlur msg
    | Value (model -> Maybe String)


{-| Internal.
-}
type alias Options model msg =
    { attributes : List (Html.Attribute msg)
    , classes : List String
    , disabled : Maybe Bool
    , id : Maybe String
    , value : model -> Maybe String
    , onSelect : Maybe (String -> msg)
    , onFocus : Maybe msg
    , onBlur : Maybe msg
    }


defaultOptions : Options model msg
defaultOptions =
    { attributes = []
    , classes = [ "a-form-field__select--native" ]
    , disabled = Nothing
    , id = Nothing
    , value = always Nothing
    , onSelect = Nothing
    , onFocus = Nothing
    , onBlur = Nothing
    }


{-| Internal.
-}
addOption : SelectOption model msg -> Select model msg -> Select model msg
addOption option (Select selectConfig) =
    Select { selectConfig | options = selectConfig.options ++ [ option ] }


{-| Sets a list of `attributes` to the `Select config`.
-}
withAttributes : List (Html.Attribute msg) -> Select model msg -> Select model msg
withAttributes attributes =
    addOption (Attributes attributes)


{-| Sets a `disabled` to the `Select config`.
-}
withDisabled : Bool -> Select model msg -> Select model msg
withDisabled disabled =
    addOption (Disabled disabled)


withExclusiveClass : String -> Select model msg -> Select model msg
withExclusiveClass class_ =
    addOption (ExclusiveClass class_)


{-| Sets an `id` to the `Select config`.
-}
withId : String -> Select model msg -> Select model msg
withId id =
    addOption (Id id)


{-| Sets an `onBlur event` to the `Select config`.
-}
withOnBlur : msg -> Select model msg -> Select model msg
withOnBlur tagger =
    addOption (OnBlur tagger)


{-| Sets an `onFocus event` to the `Select config`.
-}
withOnFocus : msg -> Select model msg -> Select model msg
withOnFocus tagger =
    addOption (OnFocus tagger)


{-| Sets an `onSelect event` to the `Select config`.
-}
withOnChange : (String -> msg) -> Select model msg -> Select model msg
withOnChange tagger =
    addOption (OnChange tagger)


{-| Sets a `value` to the `Select config`.
-}
withValue : (model -> Maybe String) -> Select model msg -> Select model msg
withValue value =
    addOption (Value value)


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

        OnSelect onSelect_ ->
            { options | onSelect = Just onSelect_ }

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
    , Maybe.map Events.onSelect options.onSelect
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
            |> Select.withOnSelect (OnSelect PowerSource)
            |> Field.select
            |> Select.render

-}
render : model -> Select model msg -> List (Html msg)
render model (Select config) =
    [ Html.select
        (buildAttributes model config.options)
        (List.concat
            (List.map
                (\( slug, label ) -> renderSelectOption (Select config) slug label)
                config.selectValues
            )
        )
    ]


renderSelectOption : Select model msg -> String -> String -> List (Html msg)
renderSelectOption (Select config) slug label =
    let
        selected =
            if config.selected == Just slug then
                Attrs.selected True

            else
                Attrs.selected False
    in
    [ Html.option
        [ value slug
        , id slug
        , selected
        ]
        [ Html.text label ]
    ]
