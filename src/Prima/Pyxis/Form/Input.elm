module Prima.Pyxis.Form.Input exposing
    ( Input, text, password, date, number, email
    , id, name, attributes, placeholder, disabled, smallSize, regularSize, largeSize, value
    , onInput, onBlur, onFocus
    , render
    )

{-|


## Types

@docs Input, text, password, date, number, email


## Modifiers

@docs id, name, attributes, placeholder, disabled, smallSize, regularSize, largeSize, value


## Events

@docs onInput, onBlur, onFocus


## Render

@docs render

-}

import Html exposing (Attribute, Html)
import Html.Attributes as Attrs
import Html.Events as Events


type Input msg
    = Input (InputConfig msg)


type alias InputConfig msg =
    { type_ : InputType
    , options : List (InputOption msg)
    }


type InputType
    = Text
    | Password
    | Date
    | Number
    | Email


input : InputType -> List (InputOption msg) -> Input msg
input type_ options =
    Input <| InputConfig type_ options


text : List (InputOption msg) -> Input msg
text =
    input Text


password : List (InputOption msg) -> Input msg
password =
    input Password


date : List (InputOption msg) -> Input msg
date =
    input Date


number : List (InputOption msg) -> Input msg
number =
    input Number


email : List (InputOption msg) -> Input msg
email =
    input Email


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


type InputSize
    = Small
    | Regular
    | Large


id : String -> InputOption msg
id =
    Id


name : String -> InputOption msg
name =
    Name


placeholder : String -> InputOption msg
placeholder =
    Placeholder


disabled : Bool -> InputOption msg
disabled =
    Disabled


attributes : List (Html.Attribute msg) -> InputOption msg
attributes =
    Attributes


smallSize : InputOption msg
smallSize =
    Size Small


regularSize : InputOption msg
regularSize =
    Size Regular


largeSize : InputOption msg
largeSize =
    Size Large


value : String -> InputOption msg
value =
    Value


onInput : (String -> msg) -> InputOption msg
onInput =
    OnInput


onBlur : msg -> InputOption msg
onBlur =
    OnBlur


onFocus : msg -> InputOption msg
onFocus =
    OnFocus


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


{-|

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
