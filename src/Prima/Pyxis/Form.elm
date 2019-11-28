module Prima.Pyxis.Form exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Prima.Pyxis.Form.Checkbox as Checkbox
import Prima.Pyxis.Form.Grid as Grid
import Prima.Pyxis.Form.Input as Input
import Prima.Pyxis.Form.Label as Label
import Prima.Pyxis.Helpers as H


type Form msg
    = Form (FormConfig msg)


type alias FormConfig msg =
    { state : FormState
    , validationVisibilityPolicy : ValidationVisibilityPolicy
    , fields : List (List (FormField msg))
    }


init : ValidationVisibilityPolicy -> Form msg
init validationVisibilityPolicy =
    Form (FormConfig Pristine validationVisibilityPolicy [])


type FormState
    = Pristine
    | Touched
    | Submitted


type ValidationVisibilityPolicy
    = Always
    | WhenSubmitted


type FormField msg
    = InputField (InputFieldConfig msg)
    | CheckboxField (CheckboxFieldConfig msg)


hasLabel : FormField msg -> Bool
hasLabel formField =
    case formField of
        InputField { label } ->
            H.isJust label

        CheckboxField { label } ->
            H.isJust label


pickLabel : FormField msg -> Maybe (Label.Label msg)
pickLabel formField =
    case formField of
        InputField { label } ->
            label

        CheckboxField { label } ->
            label


type alias InputFieldConfig msg =
    { config : Input.Input msg
    , label : Maybe (Label.Label msg)
    }


input : Input.Input msg -> FormField msg
input config =
    InputField <| InputFieldConfig config Nothing


type alias CheckboxFieldConfig msg =
    { config : Checkbox.Checkbox msg
    , label : Maybe (Label.Label msg)
    }


checkbox : Checkbox.Checkbox msg -> FormField msg
checkbox config =
    CheckboxField <| CheckboxFieldConfig config Nothing


addLabel : Label.Label msg -> FormField msg -> FormField msg
addLabel lbl formField =
    case formField of
        InputField fieldConfig ->
            InputField { fieldConfig | label = Just lbl }

        CheckboxField fieldConfig ->
            CheckboxField { fieldConfig | label = Just lbl }


addFieldsInRow : List (FormField msg) -> Form msg -> Form msg
addFieldsInRow fields (Form formConfig) =
    Form { formConfig | fields = formConfig.fields ++ [ fields ] }


render : Form msg -> Html msg
render (Form formConfig) =
    let
        formGrid =
            Grid.create
    in
    div
        [ class "m-form" ]
        (formConfig.fields
            |> List.map
                (\fields ->
                    let
                        row =
                            Grid.createRow
                    in
                    fields
                        |> addGridRow
                        |> H.flip Grid.addRow formGrid
                )
            |> List.map Grid.render
        )


addGridRow : List (FormField msg) -> Grid.Row msg
addGridRow fields =
    case fields of
        first :: second :: [] ->
            case ( hasLabel first, hasLabel second ) of
                ( _, True ) ->
                    [ first
                        |> pickLabel
                        |> Maybe.map (List.singleton << Label.render)
                        |> Maybe.withDefault []
                        |> Grid.createCol
                    , first
                        |> renderField
                        |> Grid.createCol
                    , second
                        |> pickLabel
                        |> Maybe.map (List.singleton << Label.render)
                        |> Maybe.withDefault []
                        |> Grid.createCol
                    , second
                        |> renderField
                        |> Grid.createCol
                    ]
                        |> H.flip Grid.addCols Grid.createRow

                ( _, False ) ->
                    [ first
                        |> pickLabel
                        |> Maybe.map (List.singleton << Label.render)
                        |> Maybe.withDefault []
                        |> Grid.createCol
                    , first
                        |> renderField
                        |> Grid.createCol
                    , second
                        |> renderField
                        |> Grid.createCol
                    ]
                        |> H.flip Grid.addCols Grid.createRow

        first :: [] ->
            [ first
                |> pickLabel
                |> Maybe.map (List.singleton << Label.render)
                |> Maybe.withDefault []
                |> Grid.createCol
            , first
                |> renderField
                |> Grid.createCol
            ]
                |> H.flip Grid.addCols Grid.createRow

        _ ->
            Grid.createRow


renderLabel : FormField msg -> Html msg
renderLabel formField =
    formField
        |> pickLabel
        |> Maybe.map Label.render
        |> Maybe.withDefault (text "")


renderField : FormField msg -> List (Html msg)
renderField formField =
    case formField of
        InputField { config } ->
            [ Input.render config ]

        CheckboxField { config } ->
            Checkbox.render config


validateColsOfRowConfiguration : Grid.Row msg -> Bool
validateColsOfRowConfiguration =
    always True


type alias ColsOfRowConfiguration =
    List Int


validColsOfRowConfigurations : List ColsOfRowConfiguration
validColsOfRowConfigurations =
    [ [ 4, 4, 4, 4 ]
    , [ 4, 4, 0, 0 ]
    ]
