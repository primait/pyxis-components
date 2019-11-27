module Prima.Pyxis.Form.Checkbox exposing (..)

import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Events as Events


type Checkbox msg
    = Checkbox (CheckboxConfig msg)


type alias CheckboxConfig msg =
    { label : Maybe (Label msg)
    , options : List (CheckboxOption msg)
    }


type Label msg
    = Label (LabelConfig msg)


type alias LabelConfig msg =
    { attributes : List (Html.Attribute msg)
    , children : List (Html msg)
    }


type CheckboxOption msg
    = Type
    | State CheckboxState
    | Slug String
    | Disabled Bool
    | LabelPosition CheckboxLabelPosition
    | Attributes (List (Html.Attribute msg))
    | OnCheck (Bool -> msg)
    | OnFocus msg
    | OnBlur msg


type CheckboxLabelPosition
    = Left
    | Right


type CheckboxState
    = Checked
    | NotChecked
    | Indeterminate


checkbox : List (CheckboxOption msg) -> Checkbox msg
checkbox =
    Checkbox << CheckboxConfig Nothing


label : List (Html.Attribute msg) -> List (Html msg) -> Label msg
label attrs children =
    Label <| LabelConfig attrs children


addLabel : Label msg -> Checkbox msg -> Checkbox msg
addLabel lbl (Checkbox config) =
    Checkbox { config | label = Just lbl }


checked : CheckboxOption msg
checked =
    State Checked


notChecked : CheckboxOption msg
notChecked =
    State NotChecked


onCheck : (Bool -> msg) -> CheckboxOption msg
onCheck =
    OnCheck


onBlur : msg -> CheckboxOption msg
onBlur =
    OnBlur


onFocus : msg -> CheckboxOption msg
onFocus =
    OnFocus


disabled : Bool -> CheckboxOption msg
disabled =
    Disabled


attributes : List (Html.Attribute msg) -> CheckboxOption msg
attributes =
    Attributes


slug : String -> CheckboxOption msg
slug =
    Slug


leftLabel : CheckboxOption msg
leftLabel =
    LabelPosition Left


rightLabel : CheckboxOption msg
rightLabel =
    LabelPosition Right


type alias Options msg =
    { type_ : String
    , slug : Maybe String
    , label : Maybe (Label msg)
    , labelPosition : CheckboxLabelPosition
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
    , slug = Nothing
    , label = Nothing
    , labelPosition = Left
    , disabled = Nothing
    , state = Nothing
    , attributes = []
    , onCheck = Nothing
    , onFocus = Nothing
    , onBlur = Nothing
    }


applyOption : CheckboxOption msg -> Options msg -> Options msg
applyOption modifier options =
    case modifier of
        Type ->
            options

        Slug slug_ ->
            { options | slug = Just slug_ }

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

        LabelPosition labelPosition_ ->
            { options | labelPosition = labelPosition_ }


buildAttributes : List (CheckboxOption msg) -> List (Html.Attribute msg)
buildAttributes modifiers =
    let
        options =
            List.foldl applyOption defaultOptions modifiers
    in
    [ Just <| Attrs.type_ options.type_
    , Maybe.map Attrs.name options.slug
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


render : Checkbox msg -> List (Html msg)
render (Checkbox config) =
    let
        options =
            List.foldl applyOption defaultOptions config.options

        renderedCheckbox =
            Html.input
                (buildAttributes config.options)
                []
    in
    case ( config.label, options.labelPosition ) of
        ( Nothing, _ ) ->
            [ renderedCheckbox ]

        ( Just labelConfig, Left ) ->
            [ renderLabel labelConfig
            , renderedCheckbox
            ]

        ( Just labelConfig, Right ) ->
            [ renderedCheckbox
            , renderLabel labelConfig
            ]


renderLabel : Label msg -> Html msg
renderLabel (Label config) =
    Html.label
        config.attributes
        config.children
