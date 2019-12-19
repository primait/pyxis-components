module Prima.Pyxis.Form.TextArea exposing
    ( TextArea
    , withAttribute, withClass, withDefaultValue, withDisabled, withId, withName, withPlaceholder
    , withRegularSize, withSmallSize, withLargeSize
    , withOnBlur, withOnFocus
    , withValidation
    , render
    , taggerAttribute, textArea, withOverridingClass
    )

{-|


## Types and Configuration

@docs TextArea


## Options

@docs withAttribute, withClass, withDefaultValue, withDisabled, withId, withName, withPlaceholder


## Size modifiers

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


{-| Represents the opaque `TextArea` configuration.
-}
type TextArea model msg
    = TextArea (TextAreaConfig model msg)


{-| Internal. Represents the `TextArea` configuration.
-}
type alias TextAreaConfig model msg =
    { options : List (TextAreaOption model msg)
    , reader : model -> Maybe String
    , tagger : String -> msg
    }


{-| Creates an `textarea`.
-}
textArea : (model -> Maybe String) -> (String -> msg) -> TextArea model msg
textArea reader tagger =
    TextArea <| TextAreaConfig [] reader tagger


{-| Internal. Represents the possible modifiers for an `TextArea`.
-}
type TextAreaOption model msg
    = Attribute (Html.Attribute msg)
    | Class String
    | DefaultValue (Maybe String)
    | Disabled Bool
    | Id String
    | Name String
    | OnBlur msg
    | OnFocus msg
    | OverridingClass String
    | Placeholder String
    | Size TextAreaSize
    | Validation (model -> Maybe Validation.Type)


type Default
    = Indeterminate
    | Value (Maybe String)


{-| Internal. Represents the `TextArea` size.
-}
type TextAreaSize
    = Small
    | Regular
    | Large


{-| Adds a generic Html.Attribute to the `TextArea`.
-}
withAttribute : Html.Attribute msg -> TextArea model msg -> TextArea model msg
withAttribute attribute =
    addOption (Attribute attribute)


{-| Adds a `class` to the `TextArea`.
-}
withClass : String -> TextArea model msg -> TextArea model msg
withClass class_ =
    addOption (Class class_)


{-| Adds a default value to the `Textarea`.
Useful to teach the component about it's `pristine/touched` state.
-}
withDefaultValue : Maybe String -> TextArea model msg -> TextArea model msg
withDefaultValue value =
    addOption (DefaultValue value)


{-| Adds a `disabled` Html.Attribute to the `TextArea`.
-}
withDisabled : Bool -> TextArea model msg -> TextArea model msg
withDisabled disabled =
    addOption (Disabled disabled)


{-| Adds an `id` Html.Attribute to the `TextArea`.
-}
withId : String -> TextArea model msg -> TextArea model msg
withId id =
    addOption (Id id)


{-| Adds a `name` Html.Attribute to the `TextArea`.
-}
withName : String -> TextArea model msg -> TextArea model msg
withName name =
    addOption (Name name)


{-| Attaches the `onBlur` event to the `TextArea`.
-}
withOnBlur : msg -> TextArea model msg -> TextArea model msg
withOnBlur tagger =
    addOption (OnBlur tagger)


{-| Attaches the `onFocus` event to the `TextArea`.
-}
withOnFocus : msg -> TextArea model msg -> TextArea model msg
withOnFocus tagger =
    addOption (OnFocus tagger)


{-| Adds a `class` to the `TextArea` which overrides all the previous.
-}
withOverridingClass : String -> TextArea model msg -> TextArea model msg
withOverridingClass class =
    addOption (OverridingClass class)


{-| Adds a `placeholder` Html.Attribute to the `TextArea`.
-}
withPlaceholder : String -> TextArea model msg -> TextArea model msg
withPlaceholder placeholder =
    addOption (Placeholder placeholder)


{-| Adds a `size` of `Regular` to the `TextArea`.
-}
withRegularSize : TextArea model msg -> TextArea model msg
withRegularSize =
    addOption (Size Regular)


{-| Sets a `size` of `Small` to the `TextArea`.
-}
withSmallSize : TextArea model msg -> TextArea model msg
withSmallSize =
    addOption (Size Small)


{-| Adds a `size` of `Large` to the `TextArea`.
-}
withLargeSize : TextArea model msg -> TextArea model msg
withLargeSize =
    addOption (Size Large)


{-| Adds a `Validation` rule to the `TextArea`.
-}
withValidation : (model -> Maybe Validation.Type) -> TextArea model msg -> TextArea model msg
withValidation validation =
    addOption (Validation validation)


{-| Internal. Adds a generic option to the `TextArea`.
-}
addOption : TextAreaOption model msg -> TextArea model msg -> TextArea model msg
addOption option (TextArea textAreaConfig) =
    TextArea { textAreaConfig | options = textAreaConfig.options ++ [ option ] }


{-| Internal. Represents the list of customizations for the `TextArea` component.
-}
type alias Options model msg =
    { attributes : List (Html.Attribute msg)
    , defaultValue : Default
    , disabled : Maybe Bool
    , classes : List String
    , groupClasses : List String
    , id : Maybe String
    , name : Maybe String
    , onFocus : Maybe msg
    , onBlur : Maybe msg
    , placeholder : Maybe String
    , size : TextAreaSize
    , validations : List (model -> Maybe Validation.Type)
    }


{-| Internal. Represents the initial state of the list of customizations for the `TextArea` component.
-}
defaultOptions : Options model msg
defaultOptions =
    { attributes = []
    , defaultValue = Indeterminate
    , disabled = Nothing
    , classes = [ "a-form-field__textarea" ]
    , groupClasses = []
    , id = Nothing
    , name = Nothing
    , onFocus = Nothing
    , onBlur = Nothing
    , placeholder = Nothing
    , size = Regular
    , validations = []
    }


{-| Internal. Applies the customizations made by end user to the `TextArea` component.
-}
applyOption : TextAreaOption model msg -> Options model msg -> Options model msg
applyOption modifier options =
    case modifier of
        Attribute attribute ->
            { options | attributes = attribute :: options.attributes }

        Class class ->
            { options | classes = class :: options.classes }

        OverridingClass class ->
            { options | classes = [ class ] }

        DefaultValue value ->
            { options | defaultValue = Value value }

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

        Validation validation ->
            { options | validations = validation :: options.validations }


{-| Internal. Transforms an `TextAreaSize` into a valid Html.Attribute.
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


{-| Internal. Transforms the `reader` function into a valid Html.Attribute.
-}
readerAttribute : model -> TextArea model msg -> Html.Attribute msg
readerAttribute model (TextArea config) =
    (Attrs.value << Maybe.withDefault "" << config.reader) model


{-| Internal. Transforms the `tagger` function into a valid Html.Attribute.
-}
taggerAttribute : TextArea model msg -> Html.Attribute msg
taggerAttribute (TextArea config) =
    Events.onInput config.tagger


{-| Internal. Transforms the `Validation` status into an Html.Attribute `class`.
-}
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


{-| Internal. Applies the `pristine/touched` visual state to the component.
-}
pristineAttribute : model -> TextArea model msg -> Html.Attribute msg
pristineAttribute model ((TextArea config) as textAreaModel) =
    let
        options =
            computeOptions textAreaModel
    in
    if Value (config.reader model) == options.defaultValue then
        Attrs.class "is-pristine"

    else
        Attrs.class "is-touched"


{-| Internal. Applies all the customizations and returns the internal `Options` type.
-}
computeOptions : TextArea model msg -> Options model msg
computeOptions (TextArea config) =
    List.foldl applyOption defaultOptions config.options


{-| Internal. Transforms all the customizations into a list of valid Html.Attribute(s).
-}
buildAttributes : model -> TextArea model msg -> List (Html.Attribute msg)
buildAttributes model textAreaModel =
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
        |> (::) (H.classesAttribute options.classes)
        |> (::) (readerAttribute model textAreaModel)
        |> (::) (taggerAttribute textAreaModel)
        |> (::) (sizeAttribute options.size)
        |> (::) (validationAttribute model textAreaModel)


{-|


## Renders the `TextArea`.

    import Html
    import Prima.Pyxis.Form.TextArea as TextArea
    import Prima.Pyxis.Form.Validation as Validation

    ...

    type Msg =
        OnInput String

    type alias Model =
        { note: Maybe String }

    ...

    view : Html Msg
    view =
        Html.div
            []
            (TextArea.textArea .note OnInput
                |> Input.withClass "my-custom-class"
                |> Input.withValidation (Maybe.andThen validate << .note)
            )

    validate : String -> Validation.Type
    validate str =
        if String.isEmpty str then
            Just <| Validation.ErrorWithMessage "Note is empty".
        else
            Nothing

-}
render : model -> TextArea model msg -> List (Html msg)
render model textAreaModel =
    renderTextArea model textAreaModel :: renderValidationMessages model textAreaModel


{-| Internal. Renders the `Input` alone.
-}
renderTextArea : model -> TextArea model msg -> Html msg
renderTextArea model textAreaModel =
    Html.textarea
        (buildAttributes model textAreaModel)
        []


{-| Internal. Renders the list of errors if present. Renders the list of warnings if not.
-}
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
