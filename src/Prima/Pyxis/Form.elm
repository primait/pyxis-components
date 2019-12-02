module Prima.Pyxis.Form exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Prima.Pyxis.Form.Checkbox as Checkbox
import Prima.Pyxis.Form.Grid as Grid
import Prima.Pyxis.Form.Input as Input
import Prima.Pyxis.Form.Label as Label
import Prima.Pyxis.Helpers as H


type Form model msg
    = Form (FormConfig model msg)


type alias FormConfig model msg =
    { state : FormState
    , validationVisibilityPolicy : ValidationVisibilityPolicy
    , fields : List (List (FormField model msg))
    }


init : ValidationVisibilityPolicy -> Form model msg
init validationVisibilityPolicy =
    Form (FormConfig Pristine validationVisibilityPolicy [])


type FormState
    = Pristine
    | Touched
    | Submitted


type ValidationVisibilityPolicy
    = Always
    | WhenSubmitted


type FormField model msg
    = InputField (InputFieldConfig model msg)
    | CheckboxField (CheckboxFieldConfig model msg)


hasLabel : FormField model msg -> Bool
hasLabel formField =
    case formField of
        InputField { label } ->
            H.isJust label

        CheckboxField { label } ->
            H.isJust label


pickLabel : FormField model msg -> Maybe (Label.Label msg)
pickLabel formField =
    case formField of
        InputField { label } ->
            label

        CheckboxField { label } ->
            label


type alias InputFieldConfig model msg =
    { config : Input.Input model msg
    , label : Maybe (Label.Label msg)
    }


input : Input.Input model msg -> FormField model msg
input config =
    InputField <| InputFieldConfig config Nothing


type alias CheckboxFieldConfig model msg =
    { config : Checkbox.Checkbox model msg
    , label : Maybe (Label.Label msg)
    }


checkbox : Checkbox.Checkbox model msg -> FormField model msg
checkbox config =
    CheckboxField <| CheckboxFieldConfig config Nothing


addLabel : Label.Label msg -> FormField model msg -> FormField model msg
addLabel lbl formField =
    case formField of
        InputField fieldConfig ->
            InputField { fieldConfig | label = Just lbl }

        CheckboxField fieldConfig ->
            CheckboxField { fieldConfig | label = Just lbl }


addFieldsInRow : List (FormField model msg) -> Form model msg -> Form model msg
addFieldsInRow fields (Form formConfig) =
    Form { formConfig | fields = formConfig.fields ++ [ fields ] }


render : model -> Form model msg -> Html msg
render model (Form formConfig) =
    let
        formGrid =
            Grid.create
    in
    div
        [ class "m-form" ]
        (formConfig.fields
            |> List.map
                (\fields ->
                    fields
                        |> addGridRow model
                        |> H.flip Grid.addRow formGrid
                )
            |> List.map Grid.render
        )


addGridRow : model -> List (FormField model msg) -> Grid.Row msg
addGridRow model fields =
    case fields of
        first :: second :: [] ->
            case ( hasLabel first, hasLabel second ) of
                ( _, True ) ->
                    [ first
                        |> pickLabel
                        |> Maybe.map (List.singleton << Label.render)
                        |> Maybe.withDefault []
                        |> Grid.col
                    , first
                        |> renderField model
                        |> Grid.col
                    , second
                        |> pickLabel
                        |> Maybe.map (List.singleton << Label.render)
                        |> Maybe.withDefault []
                        |> Grid.col
                    , second
                        |> renderField model
                        |> Grid.col
                    ]
                        |> H.flip Grid.addCols Grid.row

                ( _, False ) ->
                    [ first
                        |> pickLabel
                        |> Maybe.map (List.singleton << Label.render)
                        |> Maybe.withDefault []
                        |> Grid.col
                    , first
                        |> renderField model
                        |> Grid.col
                    , second
                        |> renderField model
                        |> Grid.col
                    ]
                        |> H.flip Grid.addCols Grid.row

        first :: [] ->
            [ first
                |> pickLabel
                |> Maybe.map (List.singleton << Label.render)
                |> Maybe.withDefault []
                |> Grid.col
            , first
                |> renderField model
                |> Grid.col
            ]
                |> H.flip Grid.addCols Grid.row

        _ ->
            Grid.row


renderLabel : FormField model msg -> Html msg
renderLabel formField =
    formField
        |> pickLabel
        |> Maybe.map Label.render
        |> Maybe.withDefault (text "")


renderField : model -> FormField model msg -> List (Html msg)
renderField model formField =
    case formField of
        InputField { config } ->
            [ Input.render model config ]

        CheckboxField { config } ->
            Checkbox.render model config


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
