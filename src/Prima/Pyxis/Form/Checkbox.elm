module Prima.Pyxis.Form.Checkbox exposing (..)

import Html exposing (Html)
import Html.Attributes as Attrs exposing (type_)
import Html.Events as Events
import Prima.Pyxis.Form.Label as Label exposing (Label)


type Checkbox model msg
    = Checkbox (CheckboxConfig model msg)


type alias CheckboxConfig model msg =
    { optionLabel : Maybe (Label msg)
    , options : List (CheckboxOption model msg)
    }


type CheckboxOption model msg
    = Id String
    | Name String
    | Value CheckboxValue
    | Disabled Bool
    | Attributes (List (Html.Attribute msg))
    | OnCheck (Bool -> msg)
    | OnFocus msg
    | OnBlur msg


type CheckboxValue
    = Checked
    | NotChecked
    | Indeterminate


checked : CheckboxOption model msg
checked =
    Value Checked


notChecked : CheckboxOption model msg
notChecked =
    Value NotChecked


checkbox : Checkbox model msg
checkbox =
    Checkbox <| CheckboxConfig Nothing []


addLabel : Label msg -> Checkbox model msg -> Checkbox model msg
addLabel lbl (Checkbox config) =
    let
        addPyxisClass =
            [ Attrs.class "a-form-field__checkbox__label" ]
                |> Label.withAttributes
                |> Label.addOption
    in
    Checkbox { config | optionLabel = (Just << addPyxisClass) lbl }


{-| Internal.
-}
addOption : CheckboxOption model msg -> Checkbox model msg -> Checkbox model msg
addOption option (Checkbox checkboxConfig) =
    Checkbox { checkboxConfig | options = checkboxConfig.options ++ [ option ] }


{-| Sets an `id` to the `Input config`.
-}
withId : String -> Checkbox model msg -> Checkbox model msg
withId id_ =
    addOption (Id id_)


{-| Sets a `disabled` to the `Input config`.
-}
withValue : CheckboxValue -> Checkbox model msg -> Checkbox model msg
withValue state =
    addOption (Value state)


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


{-| Sets an `onCheck event` to the `Input config`.
-}
withOnCheck : (Bool -> msg) -> Checkbox model msg -> Checkbox model msg
withOnCheck tagger =
    addOption (OnCheck tagger)


type alias Options msg =
    { id : Maybe String
    , name : Maybe String
    , label : Maybe (Label msg)
    , disabled : Maybe Bool
    , state : Maybe CheckboxValue
    , attributes : List (Html.Attribute msg)
    , onCheck : Maybe (Bool -> msg)
    , onFocus : Maybe msg
    , onBlur : Maybe msg
    }


defaultOptions : Options msg
defaultOptions =
    { id = Nothing
    , name = Nothing
    , label = Nothing
    , disabled = Nothing
    , state = Nothing
    , attributes = [ Attrs.class "a-form-field__checkbox" ]
    , onCheck = Nothing
    , onFocus = Nothing
    , onBlur = Nothing
    }


applyOption : CheckboxOption model msg -> Options msg -> Options msg
applyOption modifier options =
    case modifier of
        Id id_ ->
            { options | id = Just id_ }

        Name name_ ->
            { options | name = Just name_ }

        Disabled disabled_ ->
            { options | disabled = Just disabled_ }

        Value state_ ->
            { options | state = Just state_ }

        Attributes attributes_ ->
            { options | attributes = options.attributes ++ attributes_ }

        OnCheck onCheck_ ->
            { options | onCheck = Just onCheck_ }

        OnBlur onBlur_ ->
            { options | onBlur = Just onBlur_ }

        OnFocus onFocus_ ->
            { options | onFocus = Just onFocus_ }


buildAttributes : List (CheckboxOption model msg) -> List (Html.Attribute msg)
buildAttributes modifiers =
    let
        options =
            List.foldl applyOption defaultOptions modifiers
    in
    [ Just <| Attrs.type_ "checkbox"
    , Maybe.map Attrs.id options.id
    , Maybe.map Attrs.name options.name
    , Maybe.map Attrs.disabled options.disabled
    , Maybe.map stateAttribute options.state
    , Maybe.map Events.onCheck options.onCheck
    , Maybe.map Events.onBlur options.onBlur
    , Maybe.map Events.onFocus options.onFocus
    ]
        |> List.filterMap identity
        |> (++) options.attributes


stateAttribute : CheckboxValue -> Html.Attribute msg
stateAttribute state =
    case state of
        Checked ->
            Attrs.checked True

        NotChecked ->
            Attrs.checked False

        Indeterminate ->
            Attrs.attribute "indeterminate-state" ""


render : model -> Checkbox model msg -> List (Html msg)
render model (Checkbox config) =
    let
        options =
            List.foldl applyOption defaultOptions config.options

        renderedCheckbox =
            Html.input
                (buildAttributes config.options)
                []
    in
    case config.optionLabel of
        Nothing ->
            [ renderedCheckbox ]

        Just labelConfig ->
            [ renderedCheckbox
            , Label.render labelConfig
            ]
