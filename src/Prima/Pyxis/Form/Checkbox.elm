module Prima.Pyxis.Form.Checkbox exposing (..)

import Html exposing (Html)
import Html.Attributes as Attrs exposing (type_)
import Html.Events as Events
import Prima.Pyxis.Form.Label as Label exposing (Label)


type Checkbox model msg
    = Checkbox (CheckboxConfig model msg)


type alias CheckboxConfig model msg =
    { options : List (CheckboxOption msg)
    , reader : model -> Maybe Bool
    , writer : Bool -> msg
    , id : String
    }


type CheckboxOption msg
    = Attributes (List (Html.Attribute msg))
    | Disabled Bool
    | Label (Label msg)
    | Name String
    | OnFocus msg
    | OnBlur msg


checkbox : (model -> Maybe Bool) -> (Bool -> msg) -> String -> Checkbox model msg
checkbox reader writer id =
    Checkbox <| CheckboxConfig [] reader writer id


{-| Internal.
-}
addOption : CheckboxOption msg -> Checkbox model msg -> Checkbox model msg
addOption option (Checkbox checkboxConfig) =
    Checkbox { checkboxConfig | options = checkboxConfig.options ++ [ option ] }


{-| Sets a list of `attributes` to the `Input config`.
-}
withAttributes : List (Html.Attribute msg) -> Checkbox model msg -> Checkbox model msg
withAttributes attributes =
    addOption (Attributes attributes)


{-| Sets a `disabled` to the `Input config`.
-}
withDisabled : Bool -> Checkbox model msg -> Checkbox model msg
withDisabled disabled =
    addOption (Disabled disabled)


withLabel : Label msg -> Checkbox model msg -> Checkbox model msg
withLabel label =
    addOption (Label label)


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
    { attributes : List (Html.Attribute msg)
    , disabled : Maybe Bool
    , label : Maybe (Label msg)
    , name : Maybe String
    , onFocus : Maybe msg
    , onBlur : Maybe msg
    }


defaultOptions : Options msg
defaultOptions =
    { attributes = [ Attrs.class "a-form-field__checkbox" ]
    , disabled = Nothing
    , label = Nothing
    , name = Nothing
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

        Label label ->
            { options | label = Just label }

        OnBlur onBlur ->
            { options | onBlur = Just onBlur }

        OnFocus onFocus ->
            { options | onFocus = Just onFocus }


readerAttribute : model -> Checkbox model msg -> Html.Attribute msg
readerAttribute model (Checkbox config) =
    (Attrs.checked << Maybe.withDefault False << config.reader) model


writerAttribute : model -> Checkbox model msg -> Html.Attribute msg
writerAttribute model (Checkbox config) =
    model
        |> config.reader
        |> Maybe.withDefault False
        |> not
        |> config.writer
        |> Events.onClick


buildAttributes : model -> Checkbox model msg -> List (Html.Attribute msg)
buildAttributes model ((Checkbox config) as checkboxModel) =
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
        |> (::) (readerAttribute model checkboxModel)
        |> (::) (writerAttribute model checkboxModel)
        |> (::) (Attrs.type_ "checkbox")
        |> (::) (Attrs.id config.id)


render : model -> Checkbox model msg -> List (Html msg)
render model ((Checkbox config) as checkboxModel) =
    [ Html.div
        [ Attrs.class "a-form-field__checkbox-options" ]
        [ renderCheckboxChoice model checkboxModel ]
    ]


renderCheckboxChoice : model -> Checkbox model msg -> Html msg
renderCheckboxChoice model ((Checkbox config) as checkboxModel) =
    let
        options =
            List.foldl applyOption defaultOptions config.options
    in
    Html.div
        [ Attrs.class "a-form-field__checkbox-options__item" ]
        [ Html.input
            (buildAttributes model checkboxModel)
            []
        , options.label
            |> Maybe.withDefault (Label.labelWithHtml [])
            |> Label.withFor config.id
            |> Label.withOverridingClass "a-form-field__checkbox-options__item__label"
            |> Label.render
        ]
