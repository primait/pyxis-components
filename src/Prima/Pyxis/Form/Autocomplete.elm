module Prima.Pyxis.Form.Autocomplete exposing
    ( Autocomplete, AutocompleteChoice, autocomplete, autocompleteChoice
    , withAttribute, withClass, withDisabled, withId, withName, withPlaceholder, withThreshold
    , withRegularSize, withSmallSize, withLargeSize
    , withOnBlur, withOnFocus
    , withValidation
    , render
    )

{-|


## Types and Configuration

@docs Autocomplete, AutocompleteChoice, autocomplete, autocompleteChoice


## Options

@docs withAttribute, withClass, withDisabled, withId, withName, withPlaceholder, withThreshold


## Size

@docs withRegularSize, withSmallSize, withLargeSize


## Events

@docs withOnBlur, withOnFocus


## Validations

@docs withValidation


## Rendering

@docs render

-}

import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Events as Events
import Prima.Pyxis.Form.Validation as Validation
import Prima.Pyxis.Helpers as H


{-| Represents the opaque `Autocomplete` configuration.
-}
type Autocomplete model msg
    = Autocomplete (AutocompleteConfig model msg)


{-| Internal. Represents the `Autocomplete` configuration.
-}
type alias AutocompleteConfig model msg =
    { options : List (AutocompleteOption model msg)
    , reader : model -> Maybe String
    , tagger : String -> msg
    , filterReader : model -> Maybe String
    , filterTagger : String -> msg
    , openedReader : model -> Bool
    , autocompleteChoices : List AutocompleteChoice
    }


{-| Creates an autocomplete.
-}
autocomplete : (model -> Maybe String) -> (String -> msg) -> (model -> Maybe String) -> (String -> msg) -> (model -> Bool) -> List AutocompleteChoice -> Autocomplete model msg
autocomplete reader tagger filterReader filterTagger openedReader =
    Autocomplete << AutocompleteConfig [] reader tagger filterReader filterTagger openedReader


{-| Represents the `AutocompleteChoice` configuration.
-}
type alias AutocompleteChoice =
    { value : String
    , label : String
    }


{-| Creates the AutocompleteChoice configuration.
-}
autocompleteChoice : String -> String -> AutocompleteChoice
autocompleteChoice value label =
    AutocompleteChoice value label


{-| Internal. Represents the possible modifiers for an `Autocomplete`.
-}
type AutocompleteOption model msg
    = Attribute (Html.Attribute msg)
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
    | Validation (model -> Maybe Validation.Type)


{-| Represents the `Autocomplete` size.
-}
type AutocompleteSize
    = Small
    | Regular
    | Large


{-| Adds a generic Html.Attribute to the `Autocomplete`.
-}
withAttribute : Html.Attribute msg -> Autocomplete model msg -> Autocomplete model msg
withAttribute attribute =
    addOption (Attribute attribute)


{-| Adds a `class` to the `Autocomplete`.
-}
withClass : String -> Autocomplete model msg -> Autocomplete model msg
withClass class_ =
    addOption (Class class_)


{-| Adds a `disabled` Html.Attribute to the `Autocomplete`.
-}
withDisabled : Bool -> Autocomplete model msg -> Autocomplete model msg
withDisabled disabled =
    addOption (Disabled disabled)


{-| Adds an `id` Html.Attribute to the `Autocomplete`.
-}
withId : String -> Autocomplete model msg -> Autocomplete model msg
withId id =
    addOption (Id id)


{-| Adds a `name` Html.Attribute to the `Autocomplete`.
-}
withName : String -> Autocomplete model msg -> Autocomplete model msg
withName name =
    addOption (Name name)


{-| Attaches the `onBlur` event to the `Autocomplete`.
-}
withOnBlur : msg -> Autocomplete model msg -> Autocomplete model msg
withOnBlur tagger =
    addOption (OnBlur tagger)


{-| Attaches the `onFocus` event to the `Autocomplete`.
-}
withOnFocus : msg -> Autocomplete model msg -> Autocomplete model msg
withOnFocus tagger =
    addOption (OnFocus tagger)


{-| Adds a `class` to the `Autocomplete` which overrides all the previous.
-}
withOverridingClass : String -> Autocomplete model msg -> Autocomplete model msg
withOverridingClass class =
    addOption (OverridingClass class)


{-| Adds a `placeholder` Html.Attribute to the `Autocomplete`.
-}
withPlaceholder : String -> Autocomplete model msg -> Autocomplete model msg
withPlaceholder placeholder =
    addOption (Placeholder placeholder)


{-| Adds a `size` of `Large` to the `Autocomplete`.
-}
withLargeSize : Autocomplete model msg -> Autocomplete model msg
withLargeSize =
    addOption (Size Large)


{-| Adds a `size` of `Regular` to the `Autocomplete`.
-}
withRegularSize : Autocomplete model msg -> Autocomplete model msg
withRegularSize =
    addOption (Size Regular)


{-| Adds a `size` of `Small` to the `Autocomplete`.
-}
withSmallSize : Autocomplete model msg -> Autocomplete model msg
withSmallSize =
    addOption (Size Small)


{-| Adds a `threshold` on the filter to the `Autocomplete`.
-}
withThreshold : Int -> Autocomplete model msg -> Autocomplete model msg
withThreshold threshold =
    addOption (Threshold threshold)


{-| Adds a `Validation` rule to the `Autocomplete`.
-}
withValidation : (model -> Maybe Validation.Type) -> Autocomplete model msg -> Autocomplete model msg
withValidation validation =
    addOption (Validation validation)


{-|


## Renders the `Input`.

    import Html
    import Prima.Pyxis.Form.Autocomplete as Autocomplete
    import Prima.Pyxis.Form.Validation as Validation

    ...

    type Msg =
        OnInput String

    type alias Model =
        { country: Maybe String }

    ...

    view : Html Msg
    view =
        Html.div
            []
            (Autocomplete.country .country OnInput
                |> Autocomplete.withClass "my-custom-class"
                |> Autocomplete.withValidation (Maybe.andThen validate << .country)
            )

    validate : String -> Validation.Type
    validate str =
        if String.isEmpty str then
            Just <| Validation.ErrorWithMessage "Country is empty".
        else
            Nothing

-}
render : model -> Autocomplete model msg -> List (Html msg)
render model ((Autocomplete config) as autocompleteModel) =
    let
        options =
            computeOptions autocompleteModel

        filteredChoices =
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
            , ( "is-small", options.size == Small )
            , ( "is-medium", options.size == Regular )
            , ( "is-large", options.size == Large )
            ]
        , validationAttribute model autocompleteModel
        ]
        [ Html.input
            (buildAttributes model autocompleteModel)
            []
        , Html.ul
            [ Attrs.class "a-form-field__autocomplete__list" ]
            (if List.length filteredChoices > 0 then
                List.map (renderAutocompleteChoice model autocompleteModel) filteredChoices

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
        , (Events.onClick << config.tagger) choice.value
        ]
        [ Html.text choice.label ]


{-| Internal. Renders the `Autocomplete` with no results.
-}
renderAutocompleteNoResults : model -> Autocomplete model msg -> List (Html msg)
renderAutocompleteNoResults model (Autocomplete config) =
    [ Html.li
        [ Attrs.class "a-form-field__autocomplete__list--no-results" ]
        [ Html.text "Nessun risultato." ]
    ]


{-| Internal. Adds a generic option to the `Autocomplete`.
-}
addOption : AutocompleteOption model msg -> Autocomplete model msg -> Autocomplete model msg
addOption option (Autocomplete autocompleteConfig) =
    Autocomplete { autocompleteConfig | options = autocompleteConfig.options ++ [ option ] }


{-| Internal. Represents the list of customizations for the `Autocomplete` component.
-}
type alias Options model msg =
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
    , validations : List (model -> Maybe Validation.Type)
    }


{-| Internal. Represents the initial state of the list of customizations for the `Autocomplete` component.
-}
defaultOptions : Options model msg
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
    , validations = []
    }


{-| Internal. Applies the customizations made by end user to the `Autocomplete` component.
-}
applyOption : AutocompleteOption model msg -> Options model msg -> Options model msg
applyOption modifier options =
    case modifier of
        Attribute attribute ->
            { options | attributes = attribute :: options.attributes }

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

        Validation validation ->
            { options | validations = validation :: options.validations }


{-| Internal. Transforms a list of `class`(es) into a valid Html.Attribute.
-}
classesAttribute : List String -> Html.Attribute msg
classesAttribute =
    Attrs.class << String.join " "


{-| Internal. Transforms the `Validation` status into an Html.Attribute `class`.
-}
validationAttribute : model -> Autocomplete model msg -> Html.Attribute msg
validationAttribute model inputModel =
    let
        options =
            computeOptions inputModel

        errors =
            options.validations
                |> List.filterMap (H.flip identity model)
                |> List.filter Validation.isError

        warnings =
            options.validations
                |> List.filterMap (H.flip identity model)
                |> List.filter Validation.isWarning
    in
    case ( errors, warnings ) of
        ( [], [] ) ->
            Attrs.class "is-valid"

        ( [], _ ) ->
            Attrs.class "has-warning"

        ( _, _ ) ->
            Attrs.class "has-error"


{-| Internal. Transforms the `reader` function into a valid Html.Attribute.
-}
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


{-| Internal. Transforms the `tagger` function into a valid Html.Attribute.
-}
filterTaggerAttribute : Autocomplete model msg -> Html.Attribute msg
filterTaggerAttribute (Autocomplete config) =
    Events.onInput config.filterTagger


{-| Internal. Transforms all the customizations into a list of valid Html.Attribute(s).
-}
buildAttributes : model -> Autocomplete model msg -> List (Html.Attribute msg)
buildAttributes model ((Autocomplete config) as autocompleteModel) =
    let
        options =
            computeOptions autocompleteModel
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
        |> (::) (validationAttribute model autocompleteModel)
        |> (::) (filterReaderAttribute model autocompleteModel)
        |> (::) (filterTaggerAttribute autocompleteModel)


{-| Internal. Applies all the customizations and returns the internal `Options` type.
-}
computeOptions : Autocomplete model msg -> Options model msg
computeOptions (Autocomplete config) =
    List.foldl applyOption defaultOptions config.options
