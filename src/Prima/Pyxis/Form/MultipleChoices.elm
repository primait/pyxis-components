module Prima.Pyxis.Form.MultipleChoices exposing
    ( MultiChoices(..)
    , withId, withName, withAttribute, withDisabled
    , render
    , MultiChoicesConfig, MultiChoicesOption(..), Options, addOption, applyOption, buildAttributes, buildMultiChoiceItem, classAttribute, computeOptions, defaultOptions, multiChoices, withClass, withOnBlur, withOnFocus
    )

{-|


## Types

@docs MultiChoices


## Modifiers

@docs withId, withName, withChecked, withAttribute, withDisabled


## Events

@docs withOnChange


## Render

@docs render

-}

import Html exposing (Attribute, Html)
import Html.Attributes as Attrs
import Html.Events as Events
import Prima.Pyxis.Form.Label as Label


{-| Represents the configuration of an Change type.
-}
type MultiChoices model msg
    = MultiChoices (MultiChoicesConfig model msg)


{-| Internal.
-}
type alias MultiChoicesConfig model msg =
    { options : List (MultiChoicesOption model msg)
    , reader : model -> List String
    , writer : String -> msg
    , values : List MultiChoiceItem
    , checked : List MultiChoiceItem
    }


multiChoices : (model -> List String) -> (String -> msg) -> List MultiChoiceItem -> List MultiChoiceItem -> MultiChoices model msg
multiChoices reader writer values =
    MultiChoices << MultiChoicesConfig [] reader writer values


{-| Internal.
-}
type MultiChoicesOption model msg
    = Attribute (Html.Attribute msg)
    | Class String
    | Disabled Bool
    | Id String
    | Name String
    | OnFocus msg
    | OnBlur msg


{-| Internal.
-}
type alias MultiChoiceItem =
    { value : String
    , label : String
    }


buildMultiChoiceItem : String -> String -> MultiChoiceItem
buildMultiChoiceItem value label =
    MultiChoiceItem value label


{-| Internal.
-}
type alias Options msg =
    { attributes : List (Html.Attribute msg)
    , class : List String
    , disabled : Maybe Bool
    , id : Maybe String
    , name : Maybe String
    , onFocus : Maybe msg
    , onBlur : Maybe msg
    }


defaultOptions : Options msg
defaultOptions =
    { attributes = []
    , class = [ "a-form-field__checkbox" ]
    , disabled = Nothing
    , id = Nothing
    , name = Nothing
    , onFocus = Nothing
    , onBlur = Nothing
    }


{-| Internal.
-}
addOption : MultiChoicesOption model msg -> MultiChoices model msg -> MultiChoices model msg
addOption option (MultiChoices multiChoicesConfig) =
    MultiChoices { multiChoicesConfig | options = multiChoicesConfig.options ++ [ option ] }


{-| Sets an `attribute` to the `MultiChoices config`.
-}
withAttribute : Html.Attribute msg -> MultiChoices model msg -> MultiChoices model msg
withAttribute attribute =
    addOption (Attribute attribute)


{-| Sets a `disabled` to the `MultiChoices config`.
-}
withDisabled : Bool -> MultiChoices model msg -> MultiChoices model msg
withDisabled disabled =
    addOption (Disabled disabled)


{-| Sets a `class` to the `MultiChoices config`.
-}
withClass : String -> MultiChoices model msg -> MultiChoices model msg
withClass class_ =
    addOption (Class class_)


{-| Sets an `id` to the `MultiChoices config`.
-}
withId : String -> MultiChoices model msg -> MultiChoices model msg
withId id =
    addOption (Id id)


{-| Sets a `name` to the `MultiChoices config`.
-}
withName : String -> MultiChoices model msg -> MultiChoices model msg
withName name =
    addOption (Name name)


{-| Sets an `onBlur event` to the `MultiChoices config`.
-}
withOnBlur : msg -> MultiChoices model msg -> MultiChoices model msg
withOnBlur tagger =
    addOption (OnBlur tagger)


{-| Sets an `onFocus event` to the `MultiChoices config`.
-}
withOnFocus : msg -> MultiChoices model msg -> MultiChoices model msg
withOnFocus tagger =
    addOption (OnFocus tagger)


{-| Internal.
-}
applyOption : MultiChoicesOption model msg -> Options msg -> Options msg
applyOption modifier options =
    case modifier of
        Attribute attribute ->
            { options | attributes = attribute :: options.attributes }

        Class class ->
            { options | class = class :: options.class }

        Disabled disabled ->
            { options | disabled = Just disabled }

        Id id ->
            { options | id = Just id }

        Name name ->
            { options | name = Just name }

        OnBlur onBlur ->
            { options | onBlur = Just onBlur }

        OnFocus onFocus ->
            { options | onFocus = Just onFocus }


{-| Transforms a `List` of `Class`(es) into a valid `Html.Attribute`.
-}
classAttribute : List String -> Html.Attribute msg
classAttribute =
    Attrs.class << String.join " "


{-| Internal
-}
readerAttribute : model -> MultiChoices model msg -> String -> Html.Attribute msg
readerAttribute model (MultiChoices config) choice =
    model
        |> config.reader
        |> List.member choice
        |> Attrs.checked


{-| Internal
-}
writerAttribute : MultiChoices model msg -> String -> Html.Attribute msg
writerAttribute (MultiChoices config) choice =
    choice
        |> config.writer
        |> Events.onClick


{-| Composes all the modifiers into a set of `Html.Attribute`(s).
-}
buildAttributes : model -> MultiChoices model msg -> String -> List (Html.Attribute msg)
buildAttributes model ((MultiChoices config) as multiChoicesModel) choice =
    let
        options =
            computeOptions multiChoicesModel
    in
    [ options.id
        |> Maybe.map Attrs.id
    , options.name
        |> Maybe.map Attrs.name
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
        |> (::) (readerAttribute model multiChoicesModel choice)
        |> (::) (writerAttribute multiChoicesModel choice)
        |> (::) (Attrs.type_ "checkbox")
        |> (::) (Attrs.value choice)


{-| Renders the `MultiChoices config`.

    import Prima.Pyxis.Form.MultiChoices as MultiChoices

    view : List (Html Msg)
    view =
        [ buildMultiChoiceItem "option_1" "Option 1"
        , buildMultiChoiceItem "option_2" "Option 2"
        ]
            |> MultiChoices.multiChoices
            |> MultiChoices.render

-}
render : model -> MultiChoices model msg -> List (Html msg)
render model ((MultiChoices config) as multiChoicesModel) =
    [ Html.div
        [ Attrs.class "a-form-field__checkbox-options" ]
        (List.map (renderMultiChoices model multiChoicesModel) config.values)
    ]


{-| Internal
-}
renderMultiChoices : model -> MultiChoices model msg -> MultiChoiceItem -> Html msg
renderMultiChoices model ((MultiChoices config) as multiChoicesModel) multiChoiceItem =
    Html.div
        [ Attrs.class "a-form-field__checkbox-options__item" ]
        [ Html.input
            (buildAttributes model multiChoicesModel multiChoiceItem.value)
            []
        , multiChoiceItem.label
            |> Label.label
            |> Label.withOnClick (config.writer multiChoiceItem.value)
            |> Label.withFor multiChoiceItem.value
            |> Label.withOverridingClass "a-form-field__checkbox-options__item__label"
            |> Label.render
        ]


{-| Internal
-}
computeOptions : MultiChoices model msg -> Options msg
computeOptions (MultiChoices config) =
    List.foldl applyOption defaultOptions config.options
