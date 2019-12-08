module Prima.Pyxis.Form.Autocomplete exposing
    ( Autocomplete, AutocompleteChoice, autocomplete, autocompleteChoice
    , withAttributes, withClass, withDisabled, withId, withName, withPlaceholder, withThreshold
    , withRegularSize, withSmallSize, withLargeSize
    , withOnBlur, withOnFocus
    , render
    )

{-|


## Types and Configuration

@docs Autocomplete, AutocompleteChoice, autocomplete, autocompleteChoice


## Generic modifiers

@docs withAttributes, withClass, withDisabled, withId, withName, withPlaceholder, withThreshold


## Size modifiers

@docs withRegularSize, withSmallSize, withLargeSize


## Events

@docs withOnBlur, withOnFocus


## Rendering

@docs render

-}

import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Events as Events


{-| Represents the opaque `Autocomplete` configuration.
-}
type Autocomplete model msg
    = Autocomplete (AutocompleteConfig model msg)


{-| Represents the `Autocomplete` configuration.
-}
type alias AutocompleteConfig model msg =
    { options : List (AutocompleteOption model msg)
    , reader : model -> Maybe String
    , writer : String -> msg
    , filterReader : model -> Maybe String
    , filterWriter : String -> msg
    , openedReader : model -> Bool
    , autocompleteChoices : List AutocompleteChoice
    }


autocomplete : (model -> Maybe String) -> (String -> msg) -> (model -> Maybe String) -> (String -> msg) -> (model -> Bool) -> List AutocompleteChoice -> Autocomplete model msg
autocomplete reader writer filterReader filterWriter openedReader =
    Autocomplete << AutocompleteConfig [] reader writer filterReader filterWriter openedReader


type alias AutocompleteChoice =
    { value : String
    , label : String
    }


autocompleteChoice : String -> String -> AutocompleteChoice
autocompleteChoice value label =
    AutocompleteChoice value label


{-| Represents the possibile modifiers of an `Autocomplete`.
-}
type AutocompleteOption model msg
    = Attributes (List (Html.Attribute msg))
    | Class String
    | Disabled Bool
    | Id String
    | Name String
    | OnBlur msg
    | OnFocus msg
    | OverridingClass String
    | Placeholder String
    | Size AutocompleteSize
    | Threshold Int


{-| Represents the `Autocomplete` size.
-}
type AutocompleteSize
    = Small
    | Regular
    | Large


{-| Sets a list of `attributes` to the `Autocomplete config`.
-}
withAttributes : List (Html.Attribute msg) -> Autocomplete model msg -> Autocomplete model msg
withAttributes attributes =
    addOption (Attributes attributes)


{-| Sets a `class` to the `Autocomplete config`.
-}
withClass : String -> Autocomplete model msg -> Autocomplete model msg
withClass class_ =
    addOption (Class class_)


{-| Sets a `disabled` to the `Autocomplete config`.
-}
withDisabled : Bool -> Autocomplete model msg -> Autocomplete model msg
withDisabled disabled =
    addOption (Disabled disabled)


{-| Sets an `id` to the `Autocomplete config`.
-}
withId : String -> Autocomplete model msg -> Autocomplete model msg
withId id =
    addOption (Id id)


{-| Sets a `size` to the `Autocomplete config`.
-}
withLargeSize : Autocomplete model msg -> Autocomplete model msg
withLargeSize =
    addOption (Size Large)


{-| Sets a `name` to the `Autocomplete config`.
-}
withName : String -> Autocomplete model msg -> Autocomplete model msg
withName name =
    addOption (Name name)


{-| Sets an `onBlur event` to the `Autocomplete config`.
-}
withOnBlur : msg -> Autocomplete model msg -> Autocomplete model msg
withOnBlur tagger =
    addOption (OnBlur tagger)


{-| Sets an `onFocus event` to the `Autocomplete config`.
-}
withOnFocus : msg -> Autocomplete model msg -> Autocomplete model msg
withOnFocus tagger =
    addOption (OnFocus tagger)


{-| Sets a `class` which overrides default classes to the `Autocomplete config`.
-}
withOverridingClass : String -> Autocomplete model msg -> Autocomplete model msg
withOverridingClass class =
    addOption (OverridingClass class)


{-| Sets a `placeholder` to the `Autocomplete config`.
-}
withPlaceholder : String -> Autocomplete model msg -> Autocomplete model msg
withPlaceholder placeholder =
    addOption (Placeholder placeholder)


{-| Sets a `size` to the `Autocomplete config`.
-}
withRegularSize : Autocomplete model msg -> Autocomplete model msg
withRegularSize =
    addOption (Size Regular)


{-| Sets a `size` to the `Autocomplete config`.
-}
withSmallSize : Autocomplete model msg -> Autocomplete model msg
withSmallSize =
    addOption (Size Small)


{-| Sets a `threshold` on the filter to the `Autocomplete config`.
-}
withThreshold : Int -> Autocomplete model msg -> Autocomplete model msg
withThreshold threshold =
    addOption (Threshold threshold)


{-| Renders the `Autocomplete config`.
-}
render : model -> Autocomplete model msg -> List (Html msg)
render model ((Autocomplete config) as autocompleteModel) =
    let
        options =
            List.foldl applyOption defaultOptions config.options

        choices =
            config.autocompleteChoices
                |> List.filter
                    (.label
                        >> String.toLower
                        >> String.contains
                            (model
                                |> config.filterReader
                                |> Maybe.map String.toLower
                                |> Maybe.withDefault ""
                            )
                    )

        hasReachedThreshold =
            model
                |> config.filterReader
                |> Maybe.map String.length
                |> Maybe.withDefault 0
                |> (<=) options.threshold
    in
    [ Html.div
        [ Attrs.classList
            [ ( "a-form-field__autocomplete", True )
            , ( "is-open", hasReachedThreshold && config.openedReader model )
            ]
        ]
        [ Html.input
            (buildAttributes model autocompleteModel)
            []
        , Html.ul
            [ Attrs.class "a-form-field__autocomplete__list" ]
            (if List.length choices > 0 then
                List.map (renderAutocompleteChoice model autocompleteModel) choices

             else
                renderAutocompleteNoResults model autocompleteModel
            )
        ]
    ]


renderAutocompleteChoice : model -> Autocomplete model msg -> AutocompleteChoice -> Html msg
renderAutocompleteChoice model (Autocomplete config) choice =
    Html.li
        [ Attrs.classList
            [ ( "a-form-field__autocomplete__list__item", True )
            , ( "is-selected", Just choice.value == config.reader model )
            ]
        , (Events.onClick << config.writer) choice.value
        ]
        [ Html.text choice.label ]


renderAutocompleteNoResults : model -> Autocomplete model msg -> List (Html msg)
renderAutocompleteNoResults model (Autocomplete config) =
    [ Html.li
        [ Attrs.class "a-form-field__autocomplete__list--no-results" ]
        [ Html.text "Nessun risultato." ]
    ]


{-| Internal.
-}
addOption : AutocompleteOption model msg -> Autocomplete model msg -> Autocomplete model msg
addOption option (Autocomplete autocompleteConfig) =
    Autocomplete { autocompleteConfig | options = autocompleteConfig.options ++ [ option ] }


{-| Represents the options a user can choose to modify
the `Autocomplete` default behaviour.
-}
type alias Options msg =
    { attributes : List (Html.Attribute msg)
    , disabled : Maybe Bool
    , classes : List String
    , id : Maybe String
    , name : Maybe String
    , onFocus : Maybe msg
    , onBlur : Maybe msg
    , placeholder : Maybe String
    , size : AutocompleteSize
    , threshold : Int
    }


{-| Internal.
-}
defaultOptions : Options msg
defaultOptions =
    { attributes = []
    , disabled = Nothing
    , classes = [ "a-form-field__input" ]
    , id = Nothing
    , name = Nothing
    , onFocus = Nothing
    , onBlur = Nothing
    , placeholder = Nothing
    , size = Regular
    , threshold = 1
    }


{-| Internal.
-}
applyOption : AutocompleteOption model msg -> Options msg -> Options msg
applyOption modifier options =
    case modifier of
        Attributes attributes ->
            { options | attributes = options.attributes ++ attributes }

        Class class ->
            { options | classes = class :: options.classes }

        OverridingClass class ->
            { options | classes = [ class ] }

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

        Placeholder placeholder ->
            { options | placeholder = Just placeholder }

        Size size ->
            { options | size = size }

        Threshold threshold ->
            { options | threshold = threshold }


{-| Transforms a `List` of `Class`(es) into a valid `Html.Attribute`.
-}
classesAttribute : List String -> Html.Attribute msg
classesAttribute =
    Attrs.class << String.join " "


{-| Transforms an `AutocompleteSize` into a valid `Html.Attribute`.
-}
sizeAttribute : AutocompleteSize -> Html.Attribute msg
sizeAttribute size =
    Attrs.class
        (case size of
            Small ->
                "is-small"

            Regular ->
                "is-medium"

            Large ->
                "is-large"
        )


filterReaderAttribute : model -> Autocomplete model msg -> Html.Attribute msg
filterReaderAttribute model (Autocomplete config) =
    case
        ( config.reader model
        , config.openedReader model
        )
    of
        ( Just currentValue, False ) ->
            config.autocompleteChoices
                |> List.filter ((==) currentValue << .value)
                |> List.map .label
                |> List.head
                |> Maybe.withDefault ""
                |> Attrs.value

        _ ->
            model
                |> config.filterReader
                |> Maybe.withDefault ""
                |> Attrs.value


filterWriterAttribute : Autocomplete model msg -> Html.Attribute msg
filterWriterAttribute (Autocomplete config) =
    Events.onInput config.filterWriter


{-| Composes all the modifiers into a set of `Html.Attribute`(s).
-}
buildAttributes : model -> Autocomplete model msg -> List (Html.Attribute msg)
buildAttributes model ((Autocomplete config) as autocompleteModel) =
    let
        options =
            List.foldl applyOption defaultOptions config.options
    in
    [ options.id
        |> Maybe.map Attrs.id
    , options.name
        |> Maybe.map Attrs.name
    , options.disabled
        |> Maybe.map Attrs.disabled
    , options.placeholder
        |> Maybe.map Attrs.placeholder
    , options.onBlur
        |> Maybe.map Events.onBlur
    , options.onFocus
        |> Maybe.map Events.onFocus
    ]
        |> List.filterMap identity
        |> (++) options.attributes
        |> (::) (classesAttribute options.classes)
        |> (::) (filterReaderAttribute model autocompleteModel)
        |> (::) (filterWriterAttribute autocompleteModel)
        |> (::) (sizeAttribute options.size)
