module Prima.Pyxis.Form.Checkbox exposing (..)

import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Events as Events
import Prima.Pyxis.Form.Label as Label exposing (Label)


type Checkbox model msg
    = Checkbox (CheckboxConfig model msg)


type alias CheckboxConfig model msg =
    { optionLabel : Maybe (Label msg)
    , options : List (CheckboxOption model msg)
    }


type CheckboxOption model msg
    = Type
    | Id String
    | Name String
    | State CheckboxState
    | Disabled Bool
    | Attributes (List (Html.Attribute msg))
    | OnCheck (Bool -> msg)
    | OnFocus msg
    | OnBlur msg


type CheckboxState
    = Checked
    | NotChecked
    | Indeterminate


checkbox : List (CheckboxOption model msg) -> Checkbox model msg
checkbox =
    Checkbox << CheckboxConfig Nothing


addLabel : Label msg -> Checkbox model msg -> Checkbox model msg
addLabel lbl (Checkbox config) =
    let
        addPyxisClass =
            [ Attrs.class "a-form-field__checkbox__label" ]
                |> Label.attributes
                |> Label.addOption
    in
    Checkbox { config | optionLabel = (Just << addPyxisClass) lbl }


checked : CheckboxOption model msg
checked =
    State Checked


notChecked : CheckboxOption model msg
notChecked =
    State NotChecked


id : String -> CheckboxOption model msg
id =
    Id


onCheck : (Bool -> msg) -> CheckboxOption model msg
onCheck =
    OnCheck


onBlur : msg -> CheckboxOption model msg
onBlur =
    OnBlur


onFocus : msg -> CheckboxOption model msg
onFocus =
    OnFocus


disabled : Bool -> CheckboxOption model msg
disabled =
    Disabled


attributes : List (Html.Attribute msg) -> CheckboxOption model msg
attributes =
    Attributes


name : String -> CheckboxOption model msg
name =
    Name


type alias Options msg =
    { type_ : String
    , id : Maybe String
    , name : Maybe String
    , label : Maybe (Label msg)
    , disabled : Maybe Bool
    , state : Maybe CheckboxState
    , attributes : List (Html.Attribute msg)
    , onCheck : Maybe (Bool -> msg)
    , onFocus : Maybe msg
    , onBlur : Maybe msg
    }


defaultOptions : Options msg
defaultOptions =
    { type_ = "checkbox"
    , id = Nothing
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
        Type ->
            options

        Id id_ ->
            { options | id = Just id_ }

        Name name_ ->
            { options | name = Just name_ }

        Disabled disabled_ ->
            { options | disabled = Just disabled_ }

        State state_ ->
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
    [ Just <| Attrs.type_ options.type_
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


stateAttribute : CheckboxState -> Html.Attribute msg
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
