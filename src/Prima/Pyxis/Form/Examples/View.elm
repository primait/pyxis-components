module Prima.Pyxis.Form.Examples.View exposing (view)

import Browser
import Html exposing (Html, div, hr, i, p, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Prima.Pyxis.Button as Button
import Prima.Pyxis.Form as Form
import Prima.Pyxis.Form.Examples.FormConfig as Config
import Prima.Pyxis.Form.Examples.Model exposing (FormData, Model, Msg(..))
import Prima.Pyxis.Helpers as Helpers


view : Model -> Browser.Document Msg
view model =
    { title = "Form"
    , body = appBody model
    }


appBody : Model -> List (Html Msg)
appBody { data, formConfig } =
    [ div
        [ class "a-container directionColumn" ]
        [ Helpers.pyxisStyle
        , btnSwitchValidationMode formConfig
        , p [] [ text <| Maybe.withDefault "" <| Maybe.map ((++) "Form current state:") (formStateLabel formConfig) ]
        , p [] [ text <| formValidationPolicyLabel formConfig ]
        , formConfig
            |> Form.addField Config.username
            |> Form.addFieldList Config.passwordList
            |> Form.addField Config.note
            |> Form.addField Config.gender
            |> Form.addField (Config.visitedCountries data)
            |> Form.addField (Config.country data)
            |> Form.addField (Config.dateOfBirth data datePickerIcon)
            |> Form.addField Config.staticHtmlField
            |> Form.addCustomRow (div [] [ text "Some fancy text in the middle of your form", hr [] [] ])
            |> Form.addFieldList (Config.address data)
            |> Form.addField (Config.city data.isOpenCity)
            |> Form.render data
        , btnSubmit
        , btnReset
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
    if Form.isFormPristine form then
        Just "Pristine"

    else if Form.isFormTouched form then
        Just "Touched"

    else if Form.isFormSubmitted form then
        Just "Submitted"

    else
        Nothing


formValidationPolicyLabel : Form.Form model msg -> String
formValidationPolicyLabel form =
    case Form.pickValidationVisibilityPolicy form of
        Form.Always ->
            "Form always prints validations"

        Form.WhenSubmitted ->
            "Form validates after submit"
