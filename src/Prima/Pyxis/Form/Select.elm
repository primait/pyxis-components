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
    , reader : model -> Maybe String
    , writer : String -> msg
    , openedReader : model -> Bool
    , selectChoices : List SelectChoice
    }


select : (model -> Maybe String) -> (String -> msg) -> (model -> Bool) -> List SelectChoice -> Select model msg
select reader writer openedReader =
    Select << SelectConfig [] reader writer openedReader


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
    | Id String
    | OnFocus msg
    | OnBlur msg
    | OverridingClass String


{-| Internal.
-}
type alias Options msg =
    { attributes : List (Html.Attribute msg)
    , class : List String
    , disabled : Maybe Bool
    , id : Maybe String
    , onFocus : Maybe msg
    , onBlur : Maybe msg
    }


defaultOptions : Options msg
defaultOptions =
    { attributes = []
    , class = [ "a-form-field__select" ]
    , disabled = Nothing
    , id = Nothing
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


withOverridingClass : String -> Select model msg -> Select model msg
withOverridingClass class =
    addOption (OverridingClass class)


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


{-| Internal.
-}
applyOption : SelectOption model msg -> Options msg -> Options msg
applyOption modifier options =
    case modifier of
        Attributes attributes_ ->
            { options | attributes = options.attributes ++ attributes_ }

        Class class_ ->
            { options | class = class_ :: options.class }

        Disabled disabled_ ->
            { options | disabled = Just disabled_ }

        Id id_ ->
            { options | id = Just id_ }

        OnFocus onFocus_ ->
            { options | onFocus = Just onFocus_ }

        OnBlur onBlur_ ->
            { options | onBlur = Just onBlur_ }

        OverridingClass class_ ->
            { options | class = [ class_ ] }


{-| Transforms a `List` of `Class`(es) into a valid `Html.Attribute`.
-}
classAttribute : List String -> Html.Attribute msg
classAttribute =
    Attrs.class << String.join " "


writerAttribute : Select model msg -> Html.Attribute msg
writerAttribute (Select config) =
    Events.onInput config.writer


{-| Composes all the modifiers into a set of `Html.Attribute`(s).
-}
buildAttributes : model -> Select model msg -> List (Html.Attribute msg)
buildAttributes model ((Select config) as selectModel) =
    let
        options =
            List.foldl applyOption defaultOptions config.options
    in
    [ options.id
        |> Maybe.map Attrs.id
    , options.disabled
        |> Maybe.map Attrs.disabled
    , options.onFocus
        |> Maybe.map Events.onFocus
    , options.onBlur
        |> Maybe.map Events.onBlur
    ]
        |> List.filterMap identity
        |> (++) options.attributes
        |> (::) (classAttribute options.class)
        |> (::) (writerAttribute selectModel)


{-| Renders the `Radio config`.
-}
render : model -> Select model msg -> List (Html msg)
render model selectModel =
    [ renderSelect model selectModel
    ]


renderSelect : model -> Select model msg -> Html msg
renderSelect model ((Select config) as selectModel) =
    Html.select
        (buildAttributes model selectModel)
        (List.map (renderSelectChoice model selectModel) config.selectChoices)


renderSelectChoice : model -> Select model msg -> SelectChoice -> Html msg
renderSelectChoice model (Select config) choice =
    Html.option
        [ Attrs.value choice.value
        , Attrs.selected <| (==) choice.value <| Maybe.withDefault "" <| config.reader model
        ]
        [ Html.text choice.label ]
