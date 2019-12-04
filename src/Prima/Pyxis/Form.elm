module Prima.Pyxis.Form exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Prima.Pyxis.Form.Checkbox as Checkbox
import Prima.Pyxis.Form.Field exposing (FormField, hasLabel, pickLabel, renderField)
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
