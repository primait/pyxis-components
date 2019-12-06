module Prima.Pyxis.Form.Checkbox exposing (..)

import Html exposing (Html)
import Html.Attributes as Attrs exposing (type_)
import Html.Events as Events
import Prima.Pyxis.Form.Label as Label exposing (Label)


type Checkbox model msg
    = Checkbox (CheckboxConfig model msg)


type alias CheckboxConfig model msg =
    { options : List (CheckboxOption msg)
    , reader : model -> Maybe String
    , writer : String -> msg
    , checkboxChoices : List (CheckboxChoice msg)
    }


type CheckboxOption msg
    = Attributes (List (Html.Attribute msg))
    | Disabled Bool
    | Name String
    | OnFocus msg
    | OnBlur msg


checkbox : (model -> Maybe String) -> (String -> msg) -> List (CheckboxChoice msg) -> Checkbox model msg
checkbox reader writer =
    Checkbox << CheckboxConfig [] reader writer


type alias CheckboxChoice msg =
    { value : String
    , label : Maybe (Label.Label msg)
    }


checkboxChoice : String -> Maybe (Label.Label msg) -> CheckboxChoice msg
checkboxChoice value label =
    CheckboxChoice value label


{-| Internal.
-}
addOption : CheckboxOption msg -> Checkbox model msg -> Checkbox model msg
addOption option (Checkbox checkboxConfig) =
    Checkbox { checkboxConfig | options = checkboxConfig.options ++ [ option ] }


{-| Sets a `disabled` to the `Input config`.
-}
withDisabled : Bool -> Checkbox model msg -> Checkbox model msg
withDisabled disabled =
    addOption (Disabled disabled)


{-| Sets a list of `attributes` to the `Input config`.
-}
withAttributes : List (Html.Attribute msg) -> Checkbox model msg -> Checkbox model msg
withAttributes attributes =
    addOption (Attributes attributes)


{-| Sets an `onBlur event` to the `Input config`.
-}
withOnBlur : msg -> Checkbox model msg -> Checkbox model msg
withOnBlur tagger =
    addOption (OnBlur tagger)


{-| Sets an `onFocus event` to the `Input config`.
-}
withOnFocus : msg -> Checkbox model msg -> Checkbox model msg
withOnFocus tagger =
    addOption (OnFocus tagger)


type alias Options msg =
    { name : Maybe String
    , label : Maybe (Label msg)
    , disabled : Maybe Bool
    , attributes : List (Html.Attribute msg)
    , onFocus : Maybe msg
    , onBlur : Maybe msg
    }


defaultOptions : Options msg
defaultOptions =
    { name = Nothing
    , label = Nothing
    , disabled = Nothing
    , attributes = [ Attrs.class "a-form-field__checkbox" ]
    , onFocus = Nothing
    , onBlur = Nothing
    }


applyOption : CheckboxOption msg -> Options msg -> Options msg
applyOption modifier options =
    case modifier of
        Attributes attributes ->
            { options | attributes = options.attributes ++ attributes }

        Disabled disabled ->
            { options | disabled = Just disabled }

        Name name ->
            { options | name = Just name }

        OnBlur onBlur ->
            { options | onBlur = Just onBlur }

        OnFocus onFocus ->
            { options | onFocus = Just onFocus }


readerAttribute : model -> Checkbox model msg -> CheckboxChoice msg -> Html.Attribute msg
readerAttribute model (Checkbox config) choice =
    (Attrs.checked << (==) (Just choice.value) << config.reader) model


writerAttribute : Checkbox model msg -> CheckboxChoice msg -> Html.Attribute msg
writerAttribute (Checkbox config) choice =
    (Events.onClick << config.writer) choice.value


buildAttributes : model -> Checkbox model msg -> CheckboxChoice msg -> List (Html.Attribute msg)
buildAttributes model ((Checkbox config) as checkboxModel) choice =
    let
        options =
            List.foldl applyOption defaultOptions config.options
    in
    [ Maybe.map Attrs.name options.name
    , Maybe.map Attrs.disabled options.disabled
    , Maybe.map Events.onBlur options.onBlur
    , Maybe.map Events.onFocus options.onFocus
    ]
        |> List.filterMap identity
        |> (++) options.attributes
        |> (::) (readerAttribute model checkboxModel choice)
        |> (::) (writerAttribute checkboxModel choice)
        |> (::) (Attrs.value choice.value)
        |> (::) (Attrs.type_ "checkbox")
        |> (::) (Attrs.id choice.value)


render : model -> Checkbox model msg -> List (Html msg)
render model ((Checkbox config) as checkboxModel) =
    [ Html.div
        [ Attrs.class "a-form-field__checkbox-options" ]
        (List.map (renderCheckboxChoice model checkboxModel) config.checkboxChoices)
    ]


renderCheckboxChoice : model -> Checkbox model msg -> CheckboxChoice msg -> Html msg
renderCheckboxChoice model ((Checkbox config) as checkboxModel) choice =
    Html.div
        [ Attrs.class "a-form-field__checkbox-options__item" ]
        [ Html.input
            (buildAttributes model checkboxModel choice)
            []
        , choice.label
            |> Maybe.map
                (Label.withOverridingClass "a-form-field__checkbox__label"
                    >> Label.withFor choice.value
                    >> Label.render
                )
            |> Maybe.withDefault (Html.text "")
        ]
