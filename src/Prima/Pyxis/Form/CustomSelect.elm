module Prima.Pyxis.Form.CustomSelect exposing (..)

{-|


## Types

@docs Select


## Modifiers

@docs withId, withName, withAttributes, withDisabled, withValue


## Events

@docs withOnInput


## Render

@docs render

-}

import Html exposing (Attribute, Html, div, li, span, text, ul)
import Html.Attributes as Attrs exposing (checked, class, classList, id, name, selected, type_, value)
import Html.Events as Events exposing (on, onClick)


type CustomSelect model msg
    = CustomSelect (CustomSelectConfig model msg)


{-| Internal.
-}
type alias CustomSelectConfig model msg =
    { options : List (CustomSelectOption model msg)
    , parentAttributes : List (Html.Attribute msg)
    , selectValues : List ( String, String )
    , isOpen : Bool
    , placeHolder : String
    , value : model -> Maybe String
    , onToggle : Bool -> msg
    , onInput : Maybe String -> msg
    }


{-| Internal.
-}
customSelect :
    List (Html.Attribute msg)
    -> List ( String, String )
    -> Bool
    -> String
    -> (model -> Maybe String)
    -> (Bool -> msg)
    -> (Maybe String -> msg)
    -> CustomSelect model msg
customSelect parentAttributes selectValues isOpen placeHolder value onToggle onInput =
    CustomSelect (CustomSelectConfig [] parentAttributes selectValues isOpen placeHolder value onToggle onInput)


{-| Internal.
-}
type CustomSelectOption model msg
    = Attributes (List (Html.Attribute msg))
    | Class String
    | Disabled Bool
    | Id String
    | OnFocus msg
    | OnBlur msg
    | Size InputSize


{-| Represents the `Input` size.
-}
type InputSize
    = Small
    | Regular
    | Large


{-| Internal.
-}
type alias Options model msg =
    { attributes : List (Html.Attribute msg)
    , classes : List String
    , disabled : Maybe Bool
    , id : Maybe String
    , value : model -> Maybe String
    , onInput : Maybe (String -> msg)
    , onFocus : Maybe msg
    , onBlur : Maybe msg
    , size : InputSize
    }


defaultOptions : Options model msg
defaultOptions =
    { attributes = []
    , classes = [ "a-form__field__customSelect" ]
    , disabled = Nothing
    , id = Nothing
    , value = always Nothing
    , onInput = Nothing
    , onFocus = Nothing
    , onBlur = Nothing
    , size = Regular
    }


{-| Internal.
-}
addOption : CustomSelectOption model msg -> CustomSelect model msg -> CustomSelect model msg
addOption option (CustomSelect customSelectConfig) =
    CustomSelect { customSelectConfig | options = customSelectConfig.options ++ [ option ] }


{-| Sets an `id` to the `Input config`.
-}
withId : String -> CustomSelect model msg -> CustomSelect model msg
withId id =
    addOption (Id id)


{-| Sets a `disabled` to the `Input config`.
-}
withDisabled : Bool -> CustomSelect model msg -> CustomSelect model msg
withDisabled disabled =
    addOption (Disabled disabled)


{-| Sets a list of `attributes` to the `Input config`.
-}
withAttributes : List (Html.Attribute msg) -> CustomSelect model msg -> CustomSelect model msg
withAttributes attributes =
    addOption (Attributes attributes)


{-| Sets an `onBlur event` to the `Input config`.
-}
withOnBlur : msg -> CustomSelect model msg -> CustomSelect model msg
withOnBlur tagger =
    addOption (OnBlur tagger)


{-| Sets an `onFocus event` to the `Input config`.
-}
withOnFocus : msg -> CustomSelect model msg -> CustomSelect model msg
withOnFocus tagger =
    addOption (OnFocus tagger)


{-| Sets a `size` to the `Input config`.
-}
withRegularSize : CustomSelect model msg -> CustomSelect model msg
withRegularSize =
    addOption (Size Regular)


{-| Sets a `size` to the `Input config`.
-}
withSmallSize : CustomSelect model msg -> CustomSelect model msg
withSmallSize =
    addOption (Size Small)


{-| Sets a `size` to the `Input config`.
-}
withLargeSize : CustomSelect model msg -> CustomSelect model msg
withLargeSize =
    addOption (Size Large)


{-| Internal.
-}
applyOption : CustomSelectOption model msg -> Options model msg -> Options model msg
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

        OnFocus onFocus_ ->
            { options | onFocus = Just onFocus_ }

        OnBlur onBlur_ ->
            { options | onBlur = Just onBlur_ }

        Size size_ ->
            { options | size = size_ }


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
buildAttributes : model -> List (CustomSelectOption model msg) -> List (Html.Attribute msg)
buildAttributes model modifiers =
    let
        options =
            List.foldl applyOption defaultOptions modifiers
    in
    [ Maybe.map Attrs.id options.id
    , Maybe.map Attrs.disabled options.disabled
    , Maybe.map Attrs.value (options.value model)
    , Maybe.map Events.onInput options.onInput
    , Maybe.map Events.onFocus options.onFocus
    , Maybe.map Events.onBlur options.onBlur
    ]
        |> List.filterMap identity
        |> (++) options.attributes
        |> (::) (classesAttribute options.classes)
        |> (::) (sizeAttribute options.size)


{-| Renders the `CustomSelect config`.

    import Prima.Pyxis.Form.Select as Select

    view : List (Html Msg)
        view =
        let
            slug =
                "registrationMonth"
        in
        CustomSelect.customSelect
            []
            [ ( "june", "Giugno" ), ( "july", "Luglio" ) ]
            model.registrationMonthOpen
            "Mese"
            .registrationMonth
            (OnToggle RegistrationMonth)
            (OnSelect RegistrationMonth)
            |> CustomSelect.withId slug

-}
render : model -> CustomSelect model msg -> List (Html msg)
render model (CustomSelect config) =
    [ renderCustomSelect model (CustomSelect config) ]


renderCustomSelect : model -> CustomSelect model msg -> Html msg
renderCustomSelect model (CustomSelect config) =
    let
        currentValue : String
        currentValue =
            List.filter (\( slug, label ) -> slug == Maybe.withDefault "" (config.value model)) config.selectValues
                |> List.head
                |> Maybe.withDefault ( "", config.placeHolder )
                |> Tuple.second
    in
    div
        ([ classList
            [ ( "a-form-field__custom-select", True )
            , ( "is-open", config.isOpen )
            ]
         ]
            ++ buildAttributes model config.options
        )
        [ span
            [ class "a-form-field__custom-select__status"
            , onClick (config.onToggle config.isOpen)
            ]
            [ text currentValue
            ]
        , ul
            [ class "a-form-field__custom-select__list" ]
            (List.map
                (\( slug, label ) ->
                    renderCustomSelectOption (CustomSelect config) model slug label
                )
                config.selectValues
            )
        ]


renderCustomSelectOption : CustomSelect model msg -> model -> String -> String -> Html msg
renderCustomSelectOption (CustomSelect config) model slug label =
    li
        [ classList
            [ ( "a-form-field__custom-select__list__item", True )
            , ( "is-selected", config.value model == Just slug )
            ]
        , id slug
        , onClick (config.onInput <| Just slug)
        ]
        [ text label
        ]
