module Prima.Pyxis.Form.Radio exposing (..)

{-|


## Types

@docs Radio


## Modifiers

@docs withId, withName, withAttributes, withDisabled, withValue


## Events

@docs withOnChange


## Render

@docs render

-}

import Html exposing (Attribute, Html, div)
import Html.Attributes as Attrs exposing (checked, class, classList, id, name, type_, value)
import Html.Events as Events exposing (on)
import Prima.Pyxis.Form.Label as Label


{-| Represents the configuration of an Change type.
-}
type Radio model msg
    = Radio (RadioConfig model msg)


{-| Internal.
-}
type alias RadioConfig model msg =
    { options : List (RadioOption model msg)
    , radioChoices : List RadioChoice
    }


radio : List RadioChoice -> Radio model msg
radio =
    Radio << RadioConfig []


type alias RadioChoice =
    { value : String
    , label : String
    }


radioChoice : String -> String -> RadioChoice
radioChoice value label =
    RadioChoice value label


{-| Internal.
-}
type RadioOption model msg
    = Attributes (List (Html.Attribute msg))
    | Class String
    | Disabled Bool
    | Id String
    | Name String
    | OnChange (String -> msg)
    | OnFocus msg
    | OnBlur msg
    | Value (model -> Maybe String)


{-| Internal.
-}
type alias Options model msg =
    { attributes : List (Html.Attribute msg)
    , classes : List String
    , disabled : Maybe Bool
    , id : Maybe String
    , name : Maybe String
    , onChange : Maybe (String -> msg)
    , onFocus : Maybe msg
    , onBlur : Maybe msg
    , value : model -> Maybe String
    }


defaultOptions : Options model msg
defaultOptions =
    { attributes = []
    , classes = [ "a-form-field__radio" ]
    , disabled = Nothing
    , id = Nothing
    , name = Nothing
    , onChange = Nothing
    , onFocus = Nothing
    , onBlur = Nothing
    , value = always Nothing
    }


{-| Internal.
-}
addOption : RadioOption model msg -> Radio model msg -> Radio model msg
addOption option (Radio radioConfig) =
    Radio { radioConfig | options = radioConfig.options ++ [ option ] }


{-| Sets a list of `attributes` to the `Radio config`.
-}
withAttributes : List (Html.Attribute msg) -> Radio model msg -> Radio model msg
withAttributes attributes =
    addOption (Attributes attributes)


{-| Sets a `disabled` to the `Radio config`.
-}
withDisabled : Bool -> Radio model msg -> Radio model msg
withDisabled disabled =
    addOption (Disabled disabled)


{-| Sets a `class` to the `Radio config`.
-}
withClass : String -> Radio model msg -> Radio model msg
withClass class_ =
    addOption (Class class_)


{-| Sets an `id` to the `Radio config`.
-}
withId : String -> Radio model msg -> Radio model msg
withId id =
    addOption (Id id)


{-| Sets an `onBlur event` to the `Radio config`.
-}
withOnBlur : msg -> Radio model msg -> Radio model msg
withOnBlur tagger =
    addOption (OnBlur tagger)


{-| Sets an `onFocus event` to the `Radio config`.
-}
withOnFocus : msg -> Radio model msg -> Radio model msg
withOnFocus tagger =
    addOption (OnFocus tagger)


{-| Sets an `onChange event` to the `Radio config`.
-}
withOnChange : (String -> msg) -> Radio model msg -> Radio model msg
withOnChange tagger =
    addOption (OnChange tagger)


{-| Sets a `value` to the `Radio config`.
-}
withValue : (model -> Maybe String) -> Radio model msg -> Radio model msg
withValue value =
    addOption (Value value)


{-| Internal.
-}
applyOption : RadioOption model msg -> Options model msg -> Options model msg
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

        OnChange onChange_ ->
            { options | onChange = Just onChange_ }

        OnFocus onFocus_ ->
            { options | onFocus = Just onFocus_ }

        Value reader ->
            { options | value = reader }


{-| Transforms a `List` of `Class`(es) into a valid `Html.Attribute`.
-}
classesAttribute : List String -> Html.Attribute msg
classesAttribute =
    Attrs.class << String.join " "


{-| Composes all the modifiers into a set of `Html.Attribute`(s).
-}
buildAttributes : model -> List (RadioOption model msg) -> List (Html.Attribute msg)
buildAttributes model modifiers =
    let
        options =
            List.foldl applyOption defaultOptions modifiers
    in
    [ Maybe.map Attrs.id options.id
    , Maybe.map Attrs.disabled options.disabled
    , Maybe.map Attrs.value (options.value model)
    , Maybe.map Events.onInput options.onChange
    , Maybe.map Events.onFocus options.onFocus
    , Maybe.map Events.onBlur options.onBlur
    ]
        |> List.filterMap identity
        |> (++) options.attributes
        |> (::) (classesAttribute options.classes)


{-| Renders the `Radio config`.

    import Prima.Pyxis.Form.Radio as Radio

    view : List (Html Msg)
    view =
        [ radioChoice "option_1" "Option 1"
        , radioChoice "option_2" "Option 2"
        ]
            |> Radio.radio
            |> Radio.render

-}
render : model -> Radio model msg -> List (Html msg)
render model ((Radio config) as radioModel) =
    [ div
        [ class "a-form-field__radio-options" ]
        (List.map (renderRadioChoice model radioModel) config.radioChoices)
    ]


renderRadioChoice : model -> Radio model msg -> RadioChoice -> Html msg
renderRadioChoice model (Radio config) choice =
    div
        [ class "a-form-field__radio-options__item" ]
        [ Html.input
            (buildAttributes model config.options)
            []
        , choice.label
            |> Label.label
            |> Label.withFor choice.value
            |> Label.withExclusiveClass "a-form-field__radio__label"
            |> Label.render
        ]
