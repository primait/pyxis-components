module Prima.Pyxis.Form.TextArea exposing
    ( TextArea
    , withAttribute, withClass, withDisabled, withId, withName, withPlaceholder, withValidation
    , withRegularSize, withSmallSize, withLargeSize
    , withPrependGroup, withAppendGroup, withGroupClass
    , withOnBlur, withOnFocus
    , render
    , taggerAttribute, textArea, withOverridingClass
    )

{-|


## Types and Configuration

@docs TextArea


## Generic modifiers

@docs withAttribute, withClass, withDisabled, withId, withName, withPlaceholder, withValidation


## Size modifiers

@docs withRegularSize, withSmallSize, withLargeSize


## TextAreaGroup modifiers

@docs withPrependGroup, withAppendGroup, withGroupClass


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


{-| Represents the opaque `TextArea` configuration.
-}
type TextArea model msg
    = TextArea (TextAreaConfig model msg)


{-| Represents the `TextArea` configuration.
-}
type alias TextAreaConfig model msg =
    { options : List (TextAreaOption model msg)
    , reader : model -> Maybe String
    , tagger : String -> msg
    }


{-| Creates a textArea with the default options.
-}
textArea : (model -> Maybe String) -> (String -> msg) -> TextArea model msg
textArea reader tagger =
    TextArea <| TextAreaConfig [] reader tagger


{-| Represents the possible modifiers of an `TextArea`.
-}
type TextAreaOption model msg
    = AppendGroup (List (Html msg))
    | Attribute (Html.Attribute msg)
    | Class String
    | Disabled Bool
    | GroupClass String
    | Id String
    | Name String
    | OnBlur msg
    | OnFocus msg
    | OverridingClass String
    | Placeholder String
    | PrependGroup (List (Html msg))
    | Size TextAreaSize
    | Validation (model -> Maybe Validation.Type)


{-| Represents the `TextArea` size.
-}
type TextAreaSize
    = Small
    | Regular
    | Large


withAppendGroup : List (Html msg) -> TextArea model msg -> TextArea model msg
withAppendGroup html =
    addOption (AppendGroup html)


{-| Sets an `attribute` to the `TextArea config`.
-}
withAttribute : Html.Attribute msg -> TextArea model msg -> TextArea model msg
withAttribute attribute =
    addOption (Attribute attribute)


{-| Sets a `class` to the `TextArea config`.
-}
withClass : String -> TextArea model msg -> TextArea model msg
withClass class_ =
    addOption (Class class_)


{-| Sets a `disabled` to the `TextArea config`.
-}
withDisabled : Bool -> TextArea model msg -> TextArea model msg
withDisabled disabled =
    addOption (Disabled disabled)


{-| Sets a `class` to the `AppendGroup` or `PrependGroup` of the `TextArea config`.
-}
withGroupClass : String -> TextArea model msg -> TextArea model msg
withGroupClass class =
    addOption (GroupClass class)


{-| Sets an `id` to the `TextArea config`.
-}
withId : String -> TextArea model msg -> TextArea model msg
withId id =
    addOption (Id id)


{-| Sets a `name` to the `TextArea config`.
-}
withName : String -> TextArea model msg -> TextArea model msg
withName name =
    addOption (Name name)


{-| Sets an `onBlur event` to the `TextArea config`.
-}
withOnBlur : msg -> TextArea model msg -> TextArea model msg
withOnBlur tagger =
    addOption (OnBlur tagger)


{-| Sets an `onFocus event` to the `TextArea config`.
-}
withOnFocus : msg -> TextArea model msg -> TextArea model msg
withOnFocus tagger =
    addOption (OnFocus tagger)


{-| Sets a `class` which overrides default classes to the `TextArea config`.
-}
withOverridingClass : String -> TextArea model msg -> TextArea model msg
withOverridingClass class =
    addOption (OverridingClass class)


{-| Sets a `placeholder` to the `TextArea config`.
-}
withPlaceholder : String -> TextArea model msg -> TextArea model msg
withPlaceholder placeholder =
    addOption (Placeholder placeholder)


withPrependGroup : List (Html msg) -> TextArea model msg -> TextArea model msg
withPrependGroup html =
    addOption (PrependGroup html)


{-| Sets a `size` to the `TextArea config`.
-}
withRegularSize : TextArea model msg -> TextArea model msg
withRegularSize =
    addOption (Size Regular)


{-| Sets a `size` to the `TextArea config`.
-}
withSmallSize : TextArea model msg -> TextArea model msg
withSmallSize =
    addOption (Size Small)


{-| Sets a `size` to the `TextArea config`.
-}
withLargeSize : TextArea model msg -> TextArea model msg
withLargeSize =
    addOption (Size Large)


withValidation : (model -> Maybe Validation.Type) -> TextArea model msg -> TextArea model msg
withValidation validation =
    addOption (Validation validation)


{-| Renders the `TextArea config`.
-}
render : model -> TextArea model msg -> List (Html msg)
render model textAreaModel =
    let
        options =
            computeOptions textAreaModel
    in
    case ( options.prependGroup, options.appendGroup ) of
        ( Just html, _ ) ->
            [ renderGroup
                (renderPrependGroup textAreaModel html
                    :: renderTextArea model textAreaModel
                    :: renderValidationMessages model textAreaModel
                )
            ]

        ( _, Just html ) ->
            [ renderGroup
                (renderAppendGroup textAreaModel html
                    :: renderTextArea model textAreaModel
                    :: renderValidationMessages model textAreaModel
                )
            ]

        _ ->
            renderTextArea model textAreaModel :: renderValidationMessages model textAreaModel


renderTextArea : model -> TextArea model msg -> Html msg
renderTextArea model textAreaModel =
    Html.textarea
        (buildAttributes model textAreaModel)
        []


renderGroup : List (Html msg) -> Html msg
renderGroup =
    Html.div
        [ Attrs.class "m-form-textarea-group" ]


renderAppendGroup : TextArea model msg -> List (Html msg) -> Html msg
renderAppendGroup textAreaModel =
    let
        options =
            computeOptions textAreaModel
    in
    Html.div
        [ Attrs.class "m-form-textarea-group__append"
        , Attrs.class <| String.join " " options.groupClasses
        ]


renderPrependGroup : TextArea model msg -> List (Html msg) -> Html msg
renderPrependGroup textAreaModel =
    let
        options =
            computeOptions textAreaModel
    in
    Html.div
        [ Attrs.class "m-form-textarea-group__prepend"
        , Attrs.class <| String.join " " options.groupClasses
        ]


renderValidationMessages : model -> TextArea model msg -> List (Html msg)
renderValidationMessages model textAreaModel =
    let
        options =
            computeOptions textAreaModel

        warnings =
            options.validations
                |> List.filterMap (H.flip identity model)
                |> List.filter Validation.isWarning

        errors =
            options.validations
                |> List.filterMap (H.flip identity model)
                |> List.filter Validation.isError
    in
    case ( errors, warnings ) of
        ( [], _ ) ->
            List.map Validation.render warnings

        ( _, _ ) ->
            List.map Validation.render errors


{-| Internal.
-}
addOption : TextAreaOption model msg -> TextArea model msg -> TextArea model msg
addOption option (TextArea textAreaConfig) =
    TextArea { textAreaConfig | options = textAreaConfig.options ++ [ option ] }


{-| Represents the options a user can choose to modify
the `TextArea` default behaviour.
-}
type alias Options model msg =
    { appendGroup : Maybe (List (Html msg))
    , attributes : List (Html.Attribute msg)
    , disabled : Maybe Bool
    , classes : List String
    , groupClasses : List String
    , id : Maybe String
    , name : Maybe String
    , onFocus : Maybe msg
    , onBlur : Maybe msg
    , placeholder : Maybe String
    , prependGroup : Maybe (List (Html msg))
    , size : TextAreaSize
    , validations : List (model -> Maybe Validation.Type)
    }


{-| Internal.
-}
defaultOptions : Options model msg
defaultOptions =
    { appendGroup = Nothing
    , attributes = []
    , disabled = Nothing
    , classes = [ "a-form-field__textarea" ]
    , groupClasses = []
    , id = Nothing
    , name = Nothing
    , onFocus = Nothing
    , onBlur = Nothing
    , placeholder = Nothing
    , prependGroup = Nothing
    , size = Regular
    , validations = []
    }


{-| Internal.
-}
applyOption : TextAreaOption model msg -> Options model msg -> Options model msg
applyOption modifier options =
    case modifier of
        AppendGroup html ->
            { options | appendGroup = Just html }

        Attribute attribute ->
            { options | attributes = attribute :: options.attributes }

        Class class ->
            { options | classes = class :: options.classes }

        OverridingClass class ->
            { options | classes = [ class ] }

        Disabled disabled ->
            { options | disabled = Just disabled }

        GroupClass class ->
            { options | groupClasses = class :: options.groupClasses }

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

        PrependGroup html ->
            { options | prependGroup = Just html }

        Size size ->
            { options | size = size }

        Validation validation ->
            { options | validations = validation :: options.validations }


{-| Transforms a `List` of `Class`(es) into a valid `Html.Attribute`.
-}
classesAttribute : List String -> Html.Attribute msg
classesAttribute =
    Attrs.class << String.join " "


{-| Transforms an `TextAreaSize` into a valid `Html.Attribute`.
-}
sizeAttribute : TextAreaSize -> Html.Attribute msg
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


readerAttribute : model -> TextArea model msg -> Html.Attribute msg
readerAttribute model (TextArea config) =
    (Attrs.value << Maybe.withDefault "" << config.reader) model


taggerAttribute : TextArea model msg -> Html.Attribute msg
taggerAttribute (TextArea config) =
    Events.onInput config.tagger


validationAttribute : model -> TextArea model msg -> Html.Attribute msg
validationAttribute model ((TextArea config) as textAreaModel) =
    let
        options =
            computeOptions textAreaModel

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


{-| Composes all the modifiers into a set of `Html.Attribute`(s).
-}
buildAttributes : model -> TextArea model msg -> List (Html.Attribute msg)
buildAttributes model ((TextArea config) as textAreaModel) =
    let
        options =
            computeOptions textAreaModel
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
        |> (::) (readerAttribute model textAreaModel)
        |> (::) (taggerAttribute textAreaModel)
        |> (::) (sizeAttribute options.size)
        |> (::) (validationAttribute model textAreaModel)


{-| Internal
-}
computeOptions : TextArea model msg -> Options model msg
computeOptions (TextArea config) =
    List.foldl applyOption defaultOptions config.options
