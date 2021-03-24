module Prima.Pyxis.Form.Input exposing
    ( Input
    , text, password, date, number, email
    , render
    , withAttribute, withClass, withDefaultValue, withDisabled, withId, withName, withMediumSize, withSmallSize, withLargeSize, withPlaceholder, withOverridingClass, withIsSubmitted
    , withPrependGroup, withAppendGroup, withGroupClass
    , withOnBlur, withOnFocus
    , withValidation
    )

{-|


## Configuration

@docs Input


## Configuration Methods

@docs text, password, date, number, email


## Rendering

@docs render


## Options

@docs withAttribute, withClass, withDefaultValue, withDisabled, withId, withName, withMediumSize, withSmallSize, withLargeSize, withPlaceholder, withOverridingClass, withIsSubmitted


## Group Options

@docs withPrependGroup, withAppendGroup, withGroupClass


## Event Options

@docs withOnBlur, withOnFocus


## Validation

@docs withValidation

-}

import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Events as Events
import Prima.Pyxis.Form.Validation as Validation
import Prima.Pyxis.Helpers as H


{-| Represent the opaque `Input` configuration.
-}
type Input model msg
    = Input (InputConfig model msg)


{-| Internal. Represent the `Input` configuration.
-}
type alias InputConfig model msg =
    { options : List (InputOption model msg)
    , type_ : InputType
    , reader : model -> Maybe String
    , tagger : String -> msg
    }


{-| Internal. Represent the `Input` type.
-}
type InputType
    = Text
    | Password
    | Date
    | Number
    | Email


{-| Internal. Create the configuration.
-}
input : InputType -> (model -> Maybe String) -> (String -> msg) -> Input model msg
input type_ reader tagger =
    Input <| InputConfig [] type_ reader tagger


{-| Create an `input[type="text"]`.
-}
text : (model -> Maybe String) -> (String -> msg) -> Input model msg
text reader tagger =
    input Text reader tagger


{-| Create an `input[type="password"]`.
-}
password : (model -> Maybe String) -> (String -> msg) -> Input model msg
password reader tagger =
    input Password reader tagger


{-| Create an `input[type="date"]`.
-}
date : (model -> Maybe String) -> (String -> msg) -> Input model msg
date reader tagger =
    input Date reader tagger


{-| Create an `input[type="number"]`.
-}
number : (model -> Maybe String) -> (String -> msg) -> Input model msg
number reader tagger =
    input Number reader tagger


{-| Create an `input[type="email"]`.
-}
email : (model -> Maybe String) -> (String -> msg) -> Input model msg
email reader tagger =
    input Email reader tagger


{-| Internal. Represent the possible modifiers for an `Input`.
-}
type InputOption model msg
    = AppendGroup (List (Html msg))
    | Attribute (Html.Attribute msg)
    | Class String
    | DefaultValue (Maybe String)
    | Disabled Bool
    | GroupClass String
    | Id String
    | IsSubmitted (model -> Bool)
    | Name String
    | OnBlur msg
    | OnFocus msg
    | OverridingClass String
    | Placeholder String
    | PrependGroup (List (Html msg))
    | Size InputSize
    | Validation (model -> Maybe Validation.Type)


type Default
    = Indeterminate
    | Value (Maybe String)


{-| Internal. Represent the `Input` size.
-}
type InputSize
    = Small
    | Medium
    | Large


{-| Appends an `InputGroup` with custom `Html`.
-}
withAppendGroup : List (Html msg) -> Input model msg -> Input model msg
withAppendGroup html =
    addOption (AppendGroup html)


{-| Adds a generic Html.Attribute to the `Input`.
-}
withAttribute : Html.Attribute msg -> Input model msg -> Input model msg
withAttribute attribute =
    addOption (Attribute attribute)


{-| Adds a `class` to the `Input`.
-}
withClass : String -> Input model msg -> Input model msg
withClass class_ =
    addOption (Class class_)


{-| Adds a default value to the `Input`.
Useful to teach the component about it's `pristine/touched` state.
-}
withDefaultValue : Maybe String -> Input model msg -> Input model msg
withDefaultValue value =
    addOption (DefaultValue value)


{-| Adds a `disabled` Html.Attribute to the `Input`.
-}
withDisabled : Bool -> Input model msg -> Input model msg
withDisabled disabled =
    addOption (Disabled disabled)


{-| Adds a `class` to the `InputGroup` which wraps the `Input`.
-}
withGroupClass : String -> Input model msg -> Input model msg
withGroupClass class =
    addOption (GroupClass class)


{-| Adds an `id` Html.Attribute to the `Input`.
-}
withId : String -> Input model msg -> Input model msg
withId id =
    addOption (Id id)


{-| Adds an `isSubmitted` predicate to the `Input`.
-}
withIsSubmitted : (model -> Bool) -> Input model msg -> Input model msg
withIsSubmitted isSubmitted =
    addOption (IsSubmitted isSubmitted)


{-| Adds a `name` Html.Attribute to the `Input`.
-}
withName : String -> Input model msg -> Input model msg
withName name =
    addOption (Name name)


{-| Attaches the `onBlur` event to the `Input`.
-}
withOnBlur : msg -> Input model msg -> Input model msg
withOnBlur tagger =
    addOption (OnBlur tagger)


{-| Attaches the `onFocus` event to the `Input`.
-}
withOnFocus : msg -> Input model msg -> Input model msg
withOnFocus tagger =
    addOption (OnFocus tagger)


{-| Adds a `class` to the `Input` which overrides all the previous.
-}
withOverridingClass : String -> Input model msg -> Input model msg
withOverridingClass class =
    addOption (OverridingClass class)


{-| Adds a `placeholder` Html.Attribute to the `Input`.
-}
withPlaceholder : String -> Input model msg -> Input model msg
withPlaceholder placeholder =
    addOption (Placeholder placeholder)


{-| Prepends an `InputGroup` with custom `Html`.
-}
withPrependGroup : List (Html msg) -> Input model msg -> Input model msg
withPrependGroup html =
    addOption (PrependGroup html)


{-| Adds a `size` of `Large` to the `Input`.
-}
withLargeSize : Input model msg -> Input model msg
withLargeSize =
    addOption (Size Large)


{-| Adds a `size` of `Medium` to the `Input`.
-}
withMediumSize : Input model msg -> Input model msg
withMediumSize =
    addOption (Size Medium)


{-| Sets a `size` of `Small` to the `Input`.
-}
withSmallSize : Input model msg -> Input model msg
withSmallSize =
    addOption (Size Small)


{-| Adds a `Validation` rule to the `Input`.
-}
withValidation : (model -> Maybe Validation.Type) -> Input model msg -> Input model msg
withValidation validation =
    addOption (Validation validation)


{-| Internal. Adds a generic option to the `Input`.
-}
addOption : InputOption model msg -> Input model msg -> Input model msg
addOption option (Input inputConfig) =
    Input { inputConfig | options = inputConfig.options ++ [ option ] }


{-| Internal. Represent the list of customizations for the `Input` component.
-}
type alias Options model msg =
    { appendGroup : Maybe (List (Html msg))
    , attributes : List (Html.Attribute msg)
    , defaultValue : Default
    , disabled : Maybe Bool
    , classes : List String
    , groupClasses : List String
    , id : Maybe String
    , isSubmitted : model -> Bool
    , name : Maybe String
    , onFocus : Maybe msg
    , onBlur : Maybe msg
    , placeholder : Maybe String
    , prependGroup : Maybe (List (Html msg))
    , size : InputSize
    , validations : List (model -> Maybe Validation.Type)
    }


{-| Internal. Represent the initial state of the list of customizations for the `Input` component.
-}
defaultOptions : Options model msg
defaultOptions =
    { appendGroup = Nothing
    , attributes = []
    , defaultValue = Indeterminate
    , disabled = Nothing
    , classes = [ "form-input" ]
    , groupClasses = []
    , id = Nothing
    , isSubmitted = always True
    , name = Nothing
    , onFocus = Nothing
    , onBlur = Nothing
    , placeholder = Nothing
    , prependGroup = Nothing
    , size = Medium
    , validations = []
    }


{-| Internal. Applies the customizations made by end user to the `Input` component.
-}
applyOption : InputOption model msg -> Options model msg -> Options model msg
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

        DefaultValue value ->
            { options | defaultValue = Value value }

        Disabled disabled ->
            { options | disabled = Just disabled }

        GroupClass class ->
            { options | groupClasses = class :: options.groupClasses }

        Id id ->
            { options | id = Just id }

        IsSubmitted predicate ->
            { options | isSubmitted = predicate }

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


{-| Internal. Transforms an `InputType` into a valid Html.Attribute.
-}
typeAttribute : InputType -> Html.Attribute msg
typeAttribute type_ =
    Attrs.type_
        (case type_ of
            Text ->
                "text"

            Password ->
                "password"

            Email ->
                "email"

            Date ->
                "date"

            Number ->
                "number"
        )


{-| Internal. Transforms an `InputSize` into a valid Html.Attribute.
-}
sizeAttribute : InputSize -> Html.Attribute msg
sizeAttribute size =
    Attrs.class
        (case size of
            Small ->
                "is-small"

            Medium ->
                "is-medium"

            Large ->
                "is-large"
        )


{-| Internal. Transforms the `reader` function into a valid Html.Attribute.
-}
readerAttribute : model -> Input model msg -> Html.Attribute msg
readerAttribute model (Input config) =
    (Attrs.value << Maybe.withDefault "" << config.reader) model


{-| Internal. Transforms the `tagger` function into a valid Html.Attribute.
-}
taggerAttribute : Input model msg -> Html.Attribute msg
taggerAttribute (Input config) =
    Events.onInput config.tagger


{-| Internal. Transforms the `Validation` status into an Html.Attribute `class`.
-}
validationAttribute : model -> Input model msg -> Html.Attribute msg
validationAttribute model inputModel =
    let
        warnings =
            warningValidations model (computeOptions inputModel)

        errors =
            errorsValidations model (computeOptions inputModel)
    in
    case ( errors, warnings ) of
        ( [], [] ) ->
            Attrs.class "is-valid"

        ( [], _ ) ->
            Attrs.class "has-warning"

        ( _, _ ) ->
            Attrs.class "has-error"


isPristine : model -> Input model msg -> Bool
isPristine model ((Input config) as inputModel) =
    let
        options =
            computeOptions inputModel
    in
    case ( Value (config.reader model) == options.defaultValue, config.reader model ) of
        ( True, _ ) ->
            True

        ( False, Nothing ) ->
            True

        ( False, Just _ ) ->
            False


{-| Internal. Applies the `pristine/touched` visual state to the component.
-}
pristineAttribute : model -> Input model msg -> Html.Attribute msg
pristineAttribute model inputModel =
    if isPristine model inputModel then
        Attrs.class "is-pristine"

    else
        Attrs.class "is-touched"


{-| Internal. Applies all the customizations and returns the internal `Options` type.
-}
computeOptions : Input model msg -> Options model msg
computeOptions (Input config) =
    List.foldl applyOption defaultOptions config.options


{-| Internal. Determines whether the field should be validated or not.
-}
shouldBeValidated : model -> Input model msg -> Options model msg -> Bool
shouldBeValidated model inputModel options =
    (not <| isPristine model inputModel) || options.isSubmitted model


{-| Internal. Transforms all the customizations into a list of valid Html.Attribute(s).
-}
buildAttributes : model -> Input model msg -> List (Html.Attribute msg)
buildAttributes model ((Input config) as inputModel) =
    let
        options : Options model msg
        options =
            computeOptions inputModel
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
        |> (::) (readerAttribute model inputModel)
        |> (::) (taggerAttribute inputModel)
        |> (::) (typeAttribute config.type_)
        |> (::) (sizeAttribute options.size)
        |> H.addIf (shouldBeValidated model inputModel options) (validationAttribute model inputModel)
        |> (::) (pristineAttribute model inputModel)


{-|


## Renders the `Input`.

    import Html
    import Prima.Pyxis.Form.Input as Input
    import Prima.Pyxis.Form.Validation as Validation

    ...

    type Msg =
        OnInput String

    type alias Model =
        { username : Maybe String
        , isSubmitted : Bool
        }

    ...

    view : Html Msg
    view =
        Html.div
            []
            (Input.email .username OnInput
                |> Input.withClass "my-custom-class"
                |> Input.withValidation (Maybe.andThen validate << .username)
                |> Input.withIsSubmitted .isSubmitted
            )

    validate : String -> Validation.Type
    validate str =
        if String.isEmpty str then
            Just <| Validation.ErrorWithMessage "Username is empty".
        else
            Nothing

-}
render : model -> Input model msg -> List (Html msg)
render model inputModel =
    let
        options =
            computeOptions inputModel

        hasValidations =
            shouldBeValidated model inputModel options
    in
    case ( options.prependGroup, options.appendGroup ) of
        ( Just html, _ ) ->
            [ renderGroup
                (renderPrependGroup inputModel html
                    :: renderInput model inputModel
                    :: renderValidationMessages model inputModel hasValidations
                )
            ]

        ( _, Just html ) ->
            [ renderGroup
                (renderAppendGroup inputModel html
                    :: renderInput model inputModel
                    :: renderValidationMessages model inputModel hasValidations
                )
            ]

        _ ->
            renderInput model inputModel :: renderValidationMessages model inputModel hasValidations


{-| Internal. Renders the `Input` alone.
-}
renderInput : model -> Input model msg -> Html msg
renderInput model inputModel =
    Html.input
        (buildAttributes model inputModel)
        []


{-| Internal. Renders the `InputGroup` which wraps the `Input`.
-}
renderGroup : List (Html msg) -> Html msg
renderGroup =
    Html.div
        [ Attrs.class "form-input-group" ]


{-| Internal. Renders the `InputGroup` which wraps the `Input`.
-}
renderAppendGroup : Input model msg -> List (Html msg) -> Html msg
renderAppendGroup inputModel =
    let
        options =
            computeOptions inputModel
    in
    Html.div
        [ Attrs.class "form-input-group__append"
        , Attrs.class <| String.join " " options.groupClasses
        ]


{-| Internal. Renders the `InputGroup` which wraps the `Input`.
-}
renderPrependGroup : Input model msg -> List (Html msg) -> Html msg
renderPrependGroup inputModel =
    let
        options =
            computeOptions inputModel
    in
    Html.div
        [ Attrs.class "form-input-group__prepend"
        , Attrs.class <| String.join " " options.groupClasses
        ]


{-| Internal. Renders the list of errors if present. Renders the list of warnings if not.
-}
renderValidationMessages : model -> Input model msg -> Bool -> List (Html msg)
renderValidationMessages model inputModel showValidation =
    let
        warnings =
            warningValidations model (computeOptions inputModel)

        errors =
            errorsValidations model (computeOptions inputModel)
    in
    case ( showValidation, errors, warnings ) of
        ( True, [], _ ) ->
            List.map Validation.render warnings

        ( True, _, _ ) ->
            List.map Validation.render errors

        ( False, _, _ ) ->
            []


warningValidations : model -> Options model msg -> List Validation.Type
warningValidations model options =
    options.validations
        |> List.filterMap (H.flip identity model)
        |> List.filter Validation.isWarning


errorsValidations : model -> Options model msg -> List Validation.Type
errorsValidations model options =
    options.validations
        |> List.filterMap (H.flip identity model)
        |> List.filter Validation.isError
