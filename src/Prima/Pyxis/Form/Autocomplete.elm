module Prima.Pyxis.Form.Autocomplete exposing
    ( Autocomplete, autocomplete
    , withAttributes, withClass, withDisabled, withId, withName, withPlaceholder, withValue
    , withRegularSize, withSmallSize, withLargeSize
    , withOnFilter, withOnChange, withOnBlur, withOnFocus
    , render
    )

{-|


## Types and Configuration

@docs Autocomplete, autocomplete


## Generic modifiers

@docs withAttributes, withClass, withDisabled, withId, withName, withPlaceholder, withValue


## Size modifiers

@docs withRegularSize, withSmallSize, withLargeSize


## Events

@docs withOnFilter, withOnChange, withOnBlur, withOnFocus


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
    , results : List AutocompleteResult
    }


type alias AutocompleteResult =
    { label : String
    , value : String
    }


{-| Internal.
-}
autocomplete : List AutocompleteResult -> Autocomplete model msg
autocomplete =
    Autocomplete <<< AutocompleteConfig []


{-| Represents the possibile modifiers of an `Autocomplete`.
-}
type AutocompleteOption model msg
    = Attributes (List (Html.Attribute msg))
    | Class String
    | Disabled Bool
    | Id String
    | Name String
    | NoResultsLabel String
    | OnBlur msg
    | OnFocus msg
    | OnFilter (String -> msg)
    | OnChange (String -> msg)
    | Placeholder String
    | Size AutocompleteSize
    | FilterValue (model -> Maybe String)
    | Value (model -> Maybe String)


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


withFilterValue : (model -> Maybe String) -> Autocomplete model msg -> Autocomplete model msg
withFilterValue reader =
    addOption (FilterValue reader)


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


{-| Sets the label for `no-results` message into to the `Autocomplete config`.
-}
withNoResultsLabel : String -> Autocomplete model msg -> Autocomplete model msg
withNoResultsLabel lbl =
    addOption (NoResultsLabel lbl)


{-| Sets an `onBlur event` to the `Autocomplete config`.
-}
withOnBlur : msg -> Autocomplete model msg -> Autocomplete model msg
withOnBlur tagger =
    addOption (OnBlur tagger)


{-| Sets an `onChange event` to the `Autocomplete config`.
-}
withOnChange : (String -> msg) -> Autocomplete model msg -> Autocomplete model msg
withOnChange tagger =
    addOption (OnChange tagger)


{-| Sets an `onFilter event` to the `Autocomplete config`.
-}
withOnFilter : (String -> msg) -> Autocomplete model msg -> Autocomplete model msg
withOnFilter tagger =
    addOption (OnFilter tagger)


{-| Sets an `onFocus event` to the `Autocomplete config`.
-}
withOnFocus : msg -> Autocomplete model msg -> Autocomplete model msg
withOnFocus tagger =
    addOption (OnFocus tagger)


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


{-| Sets a `value` to the `Autocomplete config`.
-}
withValue : (model -> Maybe String) -> Autocomplete model msg -> Autocomplete model msg
withValue value =
    addOption (Value value)


{-| Renders the `Autocomplete config`.

    import Prima.Pyxis.Form.Autocomplete as FormAutocomplete

    type Msg
        = OnFilter String
        | OnChange String
        | OnBlur
        | OnFocus

    view : Html Msg
    view =
        FormAutocomplete.autocomplete
            [ FormAutocomplete.id "myId"
            , FormAutocomplete.onFilter OnFilter
            , FormAutocomplete.onChange OnChange
            , FormAutocomplete.onBlur OnBlur
            ]
            |> FormAutocomplete.render

-}
render : model -> Autocomplete model msg -> Html msg
render model autocompleteModel =
    renderWrapper
        [ renderInput model autocompleteModel
        , renderList model autocompleteModel
        ]


renderWrapper : List (Html msg) -> Html msg
renderWrapper =
    Html.div
        [ Attrs.classList
            [ ( "a-form-field__autocomplete", True )
            , ( "is-open", True )
            ]
        ]


renderInput : model -> Autocomplete model msg -> Html msg
renderInput model (Autocomplete config) =
    Html.input
        (buildAttributes model config.options)
        []


renderList : model -> Autocomplete model msg -> Html msg
renderList model (Autocomplete config) =
    Html.ul
        [ Attrs.class "a-form-field__autocomplete__list" ]


{-| Internal.
-}
addOption : AutocompleteOption model msg -> Autocomplete model msg -> Autocomplete model msg
addOption option (Autocomplete inputConfig) =
    Autocomplete { inputConfig | options = inputConfig.options ++ [ option ] }


{-| Internal.
-}
type alias Options model msg =
    { attributes : List (Html.Attribute msg)
    , disabled : Maybe Bool
    , classes : List String
    , filterValue : model -> Maybe String
    , id : Maybe String
    , name : Maybe String
    , noResultsLabel : String
    , onBlur : Maybe msg
    , onChange : Maybe (String -> msg)
    , onFilter : Maybe (String -> msg)
    , onFocus : Maybe msg
    , placeholder : Maybe String
    , size : AutocompleteSize
    , value : model -> Maybe String
    }


{-| Internal.
-}
defaultOptions : Options model msg
defaultOptions =
    { attributes = []
    , disabled = Nothing
    , classes = [ "a-form-field__input" ]
    , filterValue = always Nothing
    , id = Nothing
    , name = Nothing
    , noResultsLabel = "Nessun risultato"
    , onBlur = Nothing
    , onChange = Nothing
    , onFilter = Nothing
    , onFocus = Nothing
    , placeholder = Nothing
    , size = Regular
    , value = always Nothing
    }


{-| Internal.
-}
applyOption : AutocompleteOption model msg -> Options model msg -> Options model msg
applyOption modifier options =
    case modifier of
        Attributes attributes_ ->
            { options | attributes = options.attributes ++ attributes_ }

        Class class_ ->
            { options | classes = class_ :: options.classes }

        Disabled disabled_ ->
            { options | disabled = Just disabled_ }

        FilterValue filterReader_ ->
            { options | filterValue = filterReader_ }

        Id id_ ->
            { options | id = Just id_ }

        Name name_ ->
            { options | name = Just name_ }

        NoResultsLabel noResultsLabel_ ->
            { options | noResultsLabel = noResultsLabel_ }

        OnBlur onBlur_ ->
            { options | onBlur = Just onBlur_ }

        OnChange onChange_ ->
            { options | onChange = Just onChange_ }

        OnFilter onFilter_ ->
            { options | onFilter = Just onFilter_ }

        OnFocus onFocus_ ->
            { options | onFocus = Just onFocus_ }

        Placeholder placeholder_ ->
            { options | placeholder = Just placeholder_ }

        Size size_ ->
            { options | size = size_ }

        Value valueReader_ ->
            { options | value = valueReader_ }


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


{-| Composes all the modifiers into a set of `Html.Attribute`(s).
-}
buildAttributes : model -> List (AutocompleteOption model msg) -> List (Html.Attribute msg)
buildAttributes model modifiers =
    let
        options =
            List.foldl applyOption defaultOptions modifiers
    in
    [ Maybe.map Attrs.id options.id
    , Maybe.map Attrs.name options.name
    , Maybe.map Attrs.disabled options.disabled
    , Maybe.map Attrs.placeholder options.placeholder
    , Maybe.map Attrs.value (options.value model)
    , Maybe.map Events.onInput options.onChange
    , Maybe.map Events.onBlur options.onBlur
    , Maybe.map Events.onFocus options.onFocus
    ]
        |> List.filterMap identity
        |> (++) options.attributes
        |> (::) (classesAttribute options.classes)
        |> (::) (sizeAttribute options.size)
