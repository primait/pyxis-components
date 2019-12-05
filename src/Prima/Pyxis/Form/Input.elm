module Prima.Pyxis.Form.Input exposing
    ( Input, text, password, date, number, email
    , withAttributes, withClass, withDisabled, withId, withName, withPlaceholder
    , withRegularSize, withSmallSize, withLargeSize
    , withOnBlur, withOnFocus
    , render
    )

{-|


## Types and Configuration

@docs Input, text, password, date, number, email


## Generic modifiers

@docs withAttributes, withClass, withDisabled, withId, withName, withPlaceholder


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
    = Attributes (List (Html.Attribute msg))
    | Class String
    | Disabled Bool
    | Id String
    | Name String
    | OnBlur msg
    | OnFocus msg
    | Placeholder String
    | Size InputSize


{-| Represents the `Input` size.
-}
type InputSize
    = Small
    | Regular
    | Large


{-| Sets a list of `attributes` to the `Input config`.
-}
withAttributes : List (Html.Attribute msg) -> Input model msg -> Input model msg
withAttributes attributes =
    addOption (Attributes attributes)


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


{-| Sets a `placeholder` to the `Input config`.
-}
withPlaceholder : String -> Input model msg -> Input model msg
withPlaceholder placeholder =
    addOption (Placeholder placeholder)


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


{-| Renders the `Input config`.

    import Prima.Pyxis.Form.Input as FormInput

    type Msg
        = OnInput String
        | OnBlur
        | OnFocus

    view : Html Msg
    view =
        FormInput.text
            [ FormInput.id "myId"
            , FormInput.onInput OnInput
            , FormInput.onBlur OnBlur
            ]
            |> FormInput.render

-}
render : model -> Input model msg -> List (Html msg)
render model inputModel =
    [ Html.input
        (buildAttributes model inputModel)
        []
    ]


{-| Internal.
-}
addOption : InputOption model msg -> Input model msg -> Input model msg
addOption option (Input inputConfig) =
    Input { inputConfig | options = inputConfig.options ++ [ option ] }


{-| Represents the options a user can choose to modify
the `Input` default behaviour.
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
    , size : InputSize
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
    }


{-| Internal.
-}
applyOption : InputOption model msg -> Options msg -> Options msg
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

        Name name_ ->
            { options | name = Just name_ }

        OnBlur onBlur_ ->
            { options | onBlur = Just onBlur_ }

        OnFocus onFocus_ ->
            { options | onFocus = Just onFocus_ }

        Placeholder placeholder_ ->
            { options | placeholder = Just placeholder_ }

        Size size_ ->
            { options | size = size_ }


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


{-| Composes all the modifiers into a set of `Html.Attribute`(s).
-}
buildAttributes : model -> Input model msg -> List (Html.Attribute msg)
buildAttributes model (Input config) =
    let
        options =
            List.foldl applyOption defaultOptions config.options
    in
    [ Maybe.map Attrs.id options.id
    , Maybe.map Attrs.name options.name
    , Maybe.map Attrs.disabled options.disabled
    , Maybe.map Attrs.placeholder options.placeholder
    , Maybe.map Events.onBlur options.onBlur
    , Maybe.map Events.onFocus options.onFocus
    ]
        |> List.filterMap identity
        |> (++) options.attributes
        |> (::) (classesAttribute options.classes)
        |> (::) (typeAttribute config.type_)
        |> (::) (sizeAttribute options.size)
