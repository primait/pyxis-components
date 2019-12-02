module Prima.Pyxis.Form.Input exposing
    ( Input, text, password, date, number, email
    , withAttributes, withClass, withDisabled, withId, withName, withPlaceholder, withValue
    , withRegularSize, withSmallSize, withLargeSize
    , withOnInput, withOnBlur, withOnFocus
    , render
    )

{-|


## Types and Configuration

@docs Input, text, password, date, number, email


## Generic modifiers

@docs withAttributes, withClass, withDisabled, withId, withName, withPlaceholder, withValue


## Size modifiers

@docs withRegularSize, withSmallSize, withLargeSize


## Events

@docs withOnInput, withOnBlur, withOnFocus


## Rendering

@docs render

-}

import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Events as Events


{-| Represents the opaque `Input` configuration.
-}
type Input msg
    = Input (InputConfig msg)


{-| Represents the `Input` configuration.
-}
type alias InputConfig msg =
    { options : List (InputOption msg)
    , type_ : InputType
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
input : InputType -> Input msg
input =
    Input << InputConfig []


{-| Creates an `input[type="text"]` with the default options.
-}
text : Input msg
text =
    input Text


{-| Creates an `input[type="password"]` with the default options.
-}
password : Input msg
password =
    input Password


{-| Creates an `input[type="date"]` with the default options.
-}
date : Input msg
date =
    input Date


{-| Creates an `input[type="number"]` with the default options.
-}
number : Input msg
number =
    input Number


{-| Creates an `input[type="email"]` with the default options.
-}
email : Input msg
email =
    input Email


{-| Represents the possibile modifiers of an `Input`.
-}
type InputOption msg
    = Attributes (List (Html.Attribute msg))
    | Class String
    | Disabled Bool
    | Id String
    | Name String
    | OnBlur msg
    | OnFocus msg
    | OnInput (String -> msg)
    | Placeholder String
    | Size InputSize
    | Value String


{-| Represents the `Input` size.
-}
type InputSize
    = Small
    | Regular
    | Large


{-| Sets a list of `attributes` to the `Input config`.
-}
withAttributes : List (Html.Attribute msg) -> Input msg -> Input msg
withAttributes attributes =
    addOption (Attributes attributes)


{-| Sets a `class` to the `Input config`.
-}
withClass : String -> Input msg -> Input msg
withClass class_ =
    addOption (Class class_)


{-| Sets a `disabled` to the `Input config`.
-}
withDisabled : Bool -> Input msg -> Input msg
withDisabled disabled =
    addOption (Disabled disabled)


{-| Sets an `id` to the `Input config`.
-}
withId : String -> Input msg -> Input msg
withId id =
    addOption (Id id)


{-| Sets a `size` to the `Input config`.
-}
withLargeSize : Input msg -> Input msg
withLargeSize =
    addOption (Size Large)


{-| Sets a `name` to the `Input config`.
-}
withName : String -> Input msg -> Input msg
withName name =
    addOption (Name name)


{-| Sets an `onBlur event` to the `Input config`.
-}
withOnBlur : msg -> Input msg -> Input msg
withOnBlur tagger =
    addOption (OnBlur tagger)


{-| Sets an `onFocus event` to the `Input config`.
-}
withOnFocus : msg -> Input msg -> Input msg
withOnFocus tagger =
    addOption (OnFocus tagger)


{-| Sets an `onInput event` to the `Input config`.
-}
withOnInput : (String -> msg) -> Input msg -> Input msg
withOnInput tagger =
    addOption (OnInput tagger)


{-| Sets a `placeholder` to the `Input config`.
-}
withPlaceholder : String -> Input msg -> Input msg
withPlaceholder placeholder =
    addOption (Placeholder placeholder)


{-| Sets a `size` to the `Input config`.
-}
withRegularSize : Input msg -> Input msg
withRegularSize =
    addOption (Size Regular)


{-| Sets a `size` to the `Input config`.
-}
withSmallSize : Input msg -> Input msg
withSmallSize =
    addOption (Size Small)


{-| Sets a `value` to the `Input config`.
-}
withValue : String -> Input msg -> Input msg
withValue value =
    addOption (Value value)


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
render : Input msg -> Html msg
render (Input config) =
    Html.input
        (buildAttributes config.options)
        []


{-| Internal.
-}
addOption : InputOption msg -> Input msg -> Input msg
addOption option (Input inputConfig) =
    Input { inputConfig | options = inputConfig.options ++ [ option ] }


{-| Internal.
-}
type alias Options msg =
    { attributes : List (Html.Attribute msg)
    , disabled : Maybe Bool
    , classes : List String
    , id : Maybe String
    , name : Maybe String
    , onInput : Maybe (String -> msg)
    , onFocus : Maybe msg
    , onBlur : Maybe msg
    , placeholder : Maybe String
    , size : InputSize
    , type_ : InputType
    , value : Maybe String
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
    , onInput = Nothing
    , onFocus = Nothing
    , onBlur = Nothing
    , placeholder = Nothing
    , size = Regular
    , type_ = Text
    , value = Nothing
    }


{-| Internal.
-}
applyOption : InputOption msg -> Options msg -> Options msg
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

        OnInput onInput_ ->
            { options | onInput = Just onInput_ }

        OnBlur onBlur_ ->
            { options | onBlur = Just onBlur_ }

        OnFocus onFocus_ ->
            { options | onFocus = Just onFocus_ }

        Placeholder placeholder_ ->
            { options | placeholder = Just placeholder_ }

        Size size_ ->
            { options | size = size_ }

        Value value_ ->
            { options | value = Just value_ }


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


{-| Composes all the modifiers into a set of `Html.Attribute`(s).
-}
buildAttributes : List (InputOption msg) -> List (Html.Attribute msg)
buildAttributes modifiers =
    let
        options =
            List.foldl applyOption defaultOptions modifiers
    in
    [ Maybe.map Attrs.id options.id
    , Maybe.map Attrs.name options.name
    , Maybe.map Attrs.disabled options.disabled
    , Maybe.map Attrs.value options.value
    , Maybe.map Attrs.placeholder options.placeholder
    , Maybe.map Events.onInput options.onInput
    , Maybe.map Events.onBlur options.onBlur
    , Maybe.map Events.onFocus options.onFocus
    ]
        |> List.filterMap identity
        |> (++) options.attributes
        |> (::) (classesAttribute options.classes)
        |> (::) (typeAttribute options.type_)
        |> (::) (sizeAttribute options.size)
