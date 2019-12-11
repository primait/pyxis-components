module Prima.Pyxis.Form.Input exposing
    ( Input, text, password, date, number, email
    , withAttribute, withClass, withDisabled, withId, withName, withPlaceholder
    , withRegularSize, withSmallSize, withLargeSize
    , withPrependGroup, withAppendGroup
    , withOnBlur, withOnFocus
    , withValidation
    , render
    )

{-|


## Types and Configuration

@docs Input, text, password, date, number, email


## Generic modifiers

@docs withAttribute, withClass, withDisabled, withId, withName, withPlaceholder


## Size modifiers

@docs withRegularSize, withSmallSize, withLargeSize


## InputGroup modifiers

@docs withPrependGroup, withAppendGroup


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


{-| Represents the opaque `Input` configuration.
-}
type Input model msg
    = Input (InputConfig model msg)


{-| Represents the `Input` configuration.
-}
type alias InputConfig model msg =
    { options : List (InputOption model msg)
    , type_ : InputType
    , reader : model -> Maybe String
    , writer : String -> msg
    }


{-| Represents the `Input` type.
-}
type InputType
    = Text
    | Password
    | Date
    | Number
    | Email


{-| Internal.
-}
input : InputType -> (model -> Maybe String) -> (String -> msg) -> Input model msg
input type_ reader writer =
    Input <| InputConfig [] type_ reader writer


{-| Creates an `input[type="text"]` with the default options.
-}
text : (model -> Maybe String) -> (String -> msg) -> Input model msg
text reader writer =
    input Text reader writer


{-| Creates an `input[type="password"]` with the default options.
-}
password : (model -> Maybe String) -> (String -> msg) -> Input model msg
password reader writer =
    input Password reader writer


{-| Creates an `input[type="date"]` with the default options.
-}
date : (model -> Maybe String) -> (String -> msg) -> Input model msg
date reader writer =
    input Date reader writer


{-| Creates an `input[type="number"]` with the default options.
-}
number : (model -> Maybe String) -> (String -> msg) -> Input model msg
number reader writer =
    input Number reader writer


{-| Creates an `input[type="email"]` with the default options.
-}
email : (model -> Maybe String) -> (String -> msg) -> Input model msg
email reader writer =
    input Email reader writer


{-| Represents the possibile modifiers of an `Input`.
-}
type InputOption model msg
    = AppendGroup (List (Html msg))
    | Attribute (Html.Attribute msg)
    | Class String
    | Disabled Bool
    | Id String
    | Name String
    | OnBlur msg
    | OnFocus msg
    | OverridingClass String
    | Placeholder String
    | PrependGroup (List (Html msg))
    | Size InputSize
    | Validation (model -> Maybe Validation.Type)


{-| Represents the `Input` size.
-}
type InputSize
    = Small
    | Regular
    | Large


withAppendGroup : List (Html msg) -> Input model msg -> Input model msg
withAppendGroup html =
    addOption (AppendGroup html)


{-| Sets an `attribute` to the `Input config`.
-}
withAttribute : Html.Attribute msg -> Input model msg -> Input model msg
withAttribute attribute =
    addOption (Attribute attribute)


{-| Sets a `class` to the `Input config`.
-}
withClass : String -> Input model msg -> Input model msg
withClass class_ =
    addOption (Class class_)


{-| Sets a `disabled` to the `Input config`.
-}
withDisabled : Bool -> Input model msg -> Input model msg
withDisabled disabled =
    addOption (Disabled disabled)


{-| Sets an `id` to the `Input config`.
-}
withId : String -> Input model msg -> Input model msg
withId id =
    addOption (Id id)


{-| Sets a `size` to the `Input config`.
-}
withLargeSize : Input model msg -> Input model msg
withLargeSize =
    addOption (Size Large)


{-| Sets a `name` to the `Input config`.
-}
withName : String -> Input model msg -> Input model msg
withName name =
    addOption (Name name)


{-| Sets an `onBlur event` to the `Input config`.
-}
withOnBlur : msg -> Input model msg -> Input model msg
withOnBlur tagger =
    addOption (OnBlur tagger)


{-| Sets an `onFocus event` to the `Input config`.
-}
withOnFocus : msg -> Input model msg -> Input model msg
withOnFocus tagger =
    addOption (OnFocus tagger)


{-| Sets a `class` which overrides default classes to the `Input config`.
-}
withOverridingClass : String -> Input model msg -> Input model msg
withOverridingClass class =
    addOption (OverridingClass class)


{-| Sets a `placeholder` to the `Input config`.
-}
withPlaceholder : String -> Input model msg -> Input model msg
withPlaceholder placeholder =
    addOption (Placeholder placeholder)


withPrependGroup : List (Html msg) -> Input model msg -> Input model msg
withPrependGroup html =
    addOption (PrependGroup html)


{-| Sets a `size` to the `Input config`.
-}
withRegularSize : Input model msg -> Input model msg
withRegularSize =
    addOption (Size Regular)


{-| Sets a `size` to the `Input config`.
-}
withSmallSize : Input model msg -> Input model msg
withSmallSize =
    addOption (Size Small)


withValidation : (model -> Maybe Validation.Type) -> Input model msg -> Input model msg
withValidation validation =
    addOption (Validation validation)


{-| Renders the `Input config`.
-}
render : model -> Input model msg -> List (Html msg)
render model inputModel =
    let
        options =
            computeOptions inputModel
    in
    case ( options.prependGroup, options.appendGroup ) of
        ( Just html, _ ) ->
            [ renderGroup
                (renderPrependGroup html
                    :: renderInput model inputModel
                    :: renderValidationMessages model inputModel
                )
            ]

        ( _, Just html ) ->
            [ renderGroup
                (renderAppendGroup html
                    :: renderInput model inputModel
                    :: renderValidationMessages model inputModel
                )
            ]

        _ ->
            renderInput model inputModel :: renderValidationMessages model inputModel


renderInput : model -> Input model msg -> Html msg
renderInput model inputModel =
    Html.input
        (buildAttributes model inputModel)
        []


renderGroup : List (Html msg) -> Html msg
renderGroup =
    Html.div
        [ Attrs.class "m-form-input-group" ]


renderAppendGroup : List (Html msg) -> Html msg
renderAppendGroup =
    Html.div
        [ Attrs.class "m-form-input-group__append" ]


renderPrependGroup : List (Html msg) -> Html msg
renderPrependGroup =
    Html.div
        [ Attrs.class "m-form-input-group__prepend" ]


renderValidationMessages : model -> Input model msg -> List (Html msg)
renderValidationMessages model inputModel =
    let
        options =
            computeOptions inputModel

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
addOption : InputOption model msg -> Input model msg -> Input model msg
addOption option (Input inputConfig) =
    Input { inputConfig | options = inputConfig.options ++ [ option ] }


{-| Represents the options a user can choose to modify
the `Input` default behaviour.
-}
type alias Options model msg =
    { appendGroup : Maybe (List (Html msg))
    , attributes : List (Html.Attribute msg)
    , disabled : Maybe Bool
    , classes : List String
    , id : Maybe String
    , name : Maybe String
    , onFocus : Maybe msg
    , onBlur : Maybe msg
    , placeholder : Maybe String
    , prependGroup : Maybe (List (Html msg))
    , size : InputSize
    , validations : List (model -> Maybe Validation.Type)
    }


{-| Internal.
-}
defaultOptions : Options model msg
defaultOptions =
    { appendGroup = Nothing
    , attributes = []
    , disabled = Nothing
    , classes = [ "a-form-field__input" ]
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

        PrependGroup html ->
            { options | prependGroup = Just html }

        Size size ->
            { options | size = size }

        Validation validation ->
            { options | validations = validation :: options.validations }


{-| Transforms an `InputType` into a valid `Html.Attribute`.
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


{-| Transforms a `List` of `Class`(es) into a valid `Html.Attribute`.
-}
classesAttribute : List String -> Html.Attribute msg
classesAttribute =
    Attrs.class << String.join " "


{-| Transforms an `InputSize` into a valid `Html.Attribute`.
-}
sizeAttribute : InputSize -> Html.Attribute msg
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


readerAttribute : model -> Input model msg -> Html.Attribute msg
readerAttribute model (Input config) =
    (Attrs.value << Maybe.withDefault "" << config.reader) model


writerAttribute : Input model msg -> Html.Attribute msg
writerAttribute (Input config) =
    Events.onInput config.writer


validationAttribute : model -> Input model msg -> Html.Attribute msg
validationAttribute model ((Input config) as inputModel) =
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


{-| Composes all the modifiers into a set of `Html.Attribute`(s).
-}
buildAttributes : model -> Input model msg -> List (Html.Attribute msg)
buildAttributes model ((Input config) as inputModel) =
    let
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
        |> (::) (classesAttribute options.classes)
        |> (::) (readerAttribute model inputModel)
        |> (::) (writerAttribute inputModel)
        |> (::) (typeAttribute config.type_)
        |> (::) (sizeAttribute options.size)
        |> (::) (validationAttribute model inputModel)


{-| Internal
-}
computeOptions : Input model msg -> Options model msg
computeOptions (Input config) =
    List.foldl applyOption defaultOptions config.options
