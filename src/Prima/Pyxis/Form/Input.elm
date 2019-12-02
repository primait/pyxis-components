module Prima.Pyxis.Form.Input exposing
    ( Input, text, password, date, number, email
    , withId, withName, withAttributes, withPlaceholder, withDisabled, withSmallSize, withRegularSize, withLargeSize, withValue
    , withOnInput, withOnBlur, withOnFocus
    , render
    )

{-|


## Types

@docs Input, text, password, date, number, email


## Modifiers

@docs withId, withName, withAttributes, withPlaceholder, withDisabled, withSmallSize, withRegularSize, withLargeSize, withValue


## Events

@docs withOnInput, withOnBlur, withOnFocus


## Render

@docs render

-}

import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Events as Events


{-| Represents the configuration of an Input type.
-}
type Input msg
    = Input (InputConfig msg)


{-| Internal.
-}
type alias InputConfig msg =
    { type_ : InputType
    , options : List (InputOption msg)
    }


{-| Internal.
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
input type_ =
    Input <| InputConfig type_ []


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


{-| Internal.
-}
type InputOption msg
    = Id String
    | Name String
    | Size InputSize
    | Placeholder String
    | Disabled Bool
    | Value String
    | Attributes (List (Html.Attribute msg))
    | OnInput (String -> msg)
    | OnBlur msg
    | OnFocus msg


{-| Internal.
-}
type InputSize
    = Small
    | Regular
    | Large


{-| Internal.
-}
addOption : InputOption msg -> Input msg -> Input msg
addOption option (Input inputConfig) =
    Input { inputConfig | options = inputConfig.options ++ [ option ] }


{-| Sets an `id` to the `Input config`.
-}
withId : String -> Input msg -> Input msg
withId id =
    addOption (Id id)


{-| Sets a `name` to the `Input config`.
-}
withName : String -> Input msg -> Input msg
withName name =
    addOption (Name name)


{-| Sets a `placeholder` to the `Input config`.
-}
withPlaceholder : String -> Input msg -> Input msg
withPlaceholder placeholder =
    addOption (Placeholder placeholder)


{-| Sets a `disabled` to the `Input config`.
-}
withDisabled : Bool -> Input msg -> Input msg
withDisabled disabled =
    addOption (Disabled disabled)


{-| Sets a list of `attributes` to the `Input config`.
-}
withAttributes : List (Html.Attribute msg) -> Input msg -> Input msg
withAttributes attributes =
    addOption (Attributes attributes)


{-| Sets a `size` to the `Input config`.
-}
withSmallSize : Input msg -> Input msg
withSmallSize =
    addOption (Size Small)


{-| Sets a `size` to the `Input config`.
-}
withRegularSize : Input msg -> Input msg
withRegularSize =
    addOption (Size Regular)


{-| Sets a `size` to the `Input config`.
-}
withLargeSize : Input msg -> Input msg
withLargeSize =
    addOption (Size Large)


{-| Sets a `value` to the `Input config`.
-}
withValue : String -> Input msg -> Input msg
withValue value =
    addOption (Value value)


{-| Sets an `onInput event` to the `Input config`.
-}
withOnInput : (String -> msg) -> Input msg -> Input msg
withOnInput tagger =
    addOption (OnInput tagger)


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


{-| Internal.
-}
type alias Options msg =
    { type_ : InputType
    , id : Maybe String
    , name : Maybe String
    , size : InputSize
    , disabled : Maybe Bool
    , value : Maybe String
    , placeholder : Maybe String
    , attributes : List (Html.Attribute msg)
    , onInput : Maybe (String -> msg)
    , onFocus : Maybe msg
    , onBlur : Maybe msg
    }


{-| Internal.
-}
defaultOptions : Options msg
defaultOptions =
    { type_ = Text
    , id = Nothing
    , name = Nothing
    , size = Large
    , disabled = Nothing
    , value = Nothing
    , placeholder = Nothing
    , attributes = [ Attrs.class "a-form-field__input" ]
    , onInput = Nothing
    , onFocus = Nothing
    , onBlur = Nothing
    }


{-| Internal.
-}
applyOption : InputOption msg -> Options msg -> Options msg
applyOption modifier options =
    case modifier of
        Id id_ ->
            { options | id = Just id_ }

        Name name_ ->
            { options | name = Just name_ }

        Size size_ ->
            { options | size = size_ }

        Placeholder placeholder_ ->
            { options | placeholder = Just placeholder_ }

        Disabled disabled_ ->
            { options | disabled = Just disabled_ }

        Value value_ ->
            { options | value = Just value_ }

        Attributes attributes_ ->
            { options | attributes = options.attributes ++ attributes_ }

        OnInput onInput_ ->
            { options | onInput = Just onInput_ }

        OnBlur onBlur_ ->
            { options | onBlur = Just onBlur_ }

        OnFocus onFocus_ ->
            { options | onFocus = Just onFocus_ }


{-| Internal.
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


{-| Internal.
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


{-| Internal.
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
        |> (::) (typeAttribute options.type_)
        |> (::) (sizeAttribute options.size)


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
