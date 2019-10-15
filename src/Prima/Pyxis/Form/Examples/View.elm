module Prima.Pyxis.Form.Examples.View exposing (view)

import Browser
import Html exposing (Html, button, div, i, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Prima.Pyxis.Button as Button
import Prima.Pyxis.Form as Form exposing (AbstractField)
import Prima.Pyxis.Form.Examples.FormConfig as Config exposing (formFieldGroup)
import Prima.Pyxis.Form.Examples.Model exposing (FormData, Model, Msg(..))
import Prima.Pyxis.Helpers as Helpers


view : Model -> Browser.Document Msg
view model =
    { title = "Form"
    , body = appBody model
    }


appBody : Model -> List (Html Msg)
appBody ({ data, formConfig } as model) =
    let
        form =
            formConfig
                |> Form.addField Config.username
                |> Form.addField (Config.password True)
                |> Form.addFieldGroup Config.formFieldGroup
                |> Form.addField Config.note
                |> Form.addField Config.gender
                |> Form.addField (Config.visitedCountries data)
                |> Form.addField (Config.city data.isOpenCity)
                |> Form.addField (Config.country data)
                |> Form.addField (Config.dateOfBirth data)
    in
    [ div
        [ class "a-container directionColumn" ]
        [ Helpers.pyxisStyle
        , text <| Maybe.withDefault "" <| Maybe.map ((++) "Form current state:") (formStateLabel form)
        , Form.render data form
        , btnSubmit
        , btnReset
        , btnSwitchValidationMode form
        ]
    ]


btnSubmit : Html Msg
btnSubmit =
    Button.callOut Button.Brand "Submit" Submit
        |> Button.render True


btnReset : Html Msg
btnReset =
    Button.secondary Button.Brand "Reset" Reset
        |> Button.render True


btnSwitchValidationMode : Form.Form model msg -> Html Msg
btnSwitchValidationMode form =
    let
        tuple =
            case Form.pickValidationVisibilityPolicy form of
                Form.Always ->
                    ( "Validate when submitted", ChangeValidationPolicy Form.WhenSubmitted )

                Form.WhenSubmitted ->
                    ( "Validate always", ChangeValidationPolicy Form.Always )

        label =
            Tuple.first tuple

        event =
            Tuple.second tuple
    in
    Button.secondary Button.Brand label event
        |> Button.render True


datePickerIcon : Html Msg
datePickerIcon =
    i
        [ class "a-icon a-icon-calendar cBrandAltDark"
        , onClick ToggleDatePicker
        ]
        []


formStateLabel : Form.Form model msg -> Maybe String
formStateLabel form =
    let
        formState =
            Form.state form
    in
    if Form.isFormPristine formState then
        Just "Pristine"

    else if Form.isFormTouched formState then
        Just "Touched"

    else if Form.isFormSubmitted formState then
        Just "Submitted"

    else
        Nothing
