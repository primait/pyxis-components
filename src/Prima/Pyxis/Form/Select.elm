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
    , selectChoices : List SelectChoice
    }


select : List SelectChoice -> Select model msg
select =
    Select << SelectConfig []


type alias SelectChoice =
    { value : String
    , label : String
    }


selectChoice : String -> String -> SelectChoice
selectChoice value label =
    SelectChoice value label


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
    , onChange : Maybe (String -> msg)
    , onFocus : Maybe msg
    , onBlur : Maybe msg
    , value : model -> Maybe String
    }


defaultOptions : Options model msg
defaultOptions =
    { attributes = []
    , classes = [ "a-form-field__select--native" ]
    , disabled = Nothing
    , id = Nothing
    , value = always Nothing
    , onChange = Nothing
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


{-| Sets an `onChange event` to the `Select config`.
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

        OnChange onChange_ ->
            { options | onChange = Just onChange_ }

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
    , Maybe.map Events.onInput options.onChange
    , Maybe.map Events.onFocus options.onFocus
    , Maybe.map Events.onBlur options.onBlur
    ]
        |> List.filterMap identity
        |> (++) options.attributes
        |> (::) (classesAttribute options.classes)


{-| Renders the `Radio config`.
-}
render : model -> Select model msg -> List (Html msg)
render model ((Select config) as selectModel) =
    [ Html.select
        (buildAttributes model config.options)
        (List.map (renderSelectChoice model selectModel) config.selectChoices)
    ]


renderSelectChoice : model -> Select model msg -> SelectChoice -> Html msg
renderSelectChoice model (Select config) choice =
    let
        options =
            List.foldl applyOption defaultOptions config.options
    in
    Html.option
        [ Attrs.value choice.value
        , Attrs.selected <| (==) choice.value <| Maybe.withDefault "" <| options.value model
        ]
        [ Html.text choice.label ]
