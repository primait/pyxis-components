module Prima.Pyxis.Form.Examples.View exposing (view)

import Browser
import Html exposing (Html, button, i, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Prima.Pyxis.Form as Form
import Prima.Pyxis.Form.Examples.FormConfig as Config
import Prima.Pyxis.Form.Examples.Model exposing (Model, Msg(..))
import Prima.Pyxis.Helpers as Helpers


view : Model -> Browser.Document Msg
view model =
    { title = "Form"
    , body = appBody model
    }


appBody : Model -> List (Html Msg)
appBody ({ isOpenCity } as model) =
    let
        _ =
            Debug.log "model is" model

        renderModel =
            [ ( Form.renderField model, [ Config.username, Config.password ] )
            , ( Form.renderField model, [ Config.note ] )
            , ( Form.renderField model, [ Config.gender ] )
            , ( Form.renderField model, [ Config.visitedCountries model ] )
            , ( Form.renderField model, [ Config.city isOpenCity ] )
            , ( Form.renderField model, [ Config.country model ] )
            , ( Form.renderFieldWithGroup model <| Form.appendGroup [ datePickerIcon ], [ Config.dateOfBirth model ] )
            ]

        formConfiguration =
            Form.init renderModel
    in
    Helpers.pyxisStyle :: Form.render formConfiguration ++ [ btnSubmit formConfiguration, btnReset ]


btnSubmit : Form.Form Model Msg -> Html Msg
btnSubmit config =
    button
        [ onClick (Submit config) ]
        [ text "Submit" ]


btnReset : Html Msg
btnReset =
    button
        [ onClick Reset ]
        [ text "Reset" ]


datePickerIcon : Html Msg
datePickerIcon =
    i
        [ class "a-icon a-icon-calendar cBrandAltDark"
        , onClick ToggleDatePicker
        ]
        []
