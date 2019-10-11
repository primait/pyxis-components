module Prima.Pyxis.Form.Examples.View exposing (view)

import Browser
import Html exposing (Html, button, div, i, text)
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
appBody ({ data, formConfig } as model) =
    let
        renderModel =
            [ ( Form.renderField formConfig data, [ Config.username, Config.password (Form.isFormSubmitted <| Form.state formConfig) ] )
            , ( Form.renderField formConfig data, [ Config.note ] )
            , ( Form.renderField formConfig data, [ Config.gender ] )
            , ( Form.renderField formConfig data, [ Config.visitedCountries data ] )
            , ( Form.renderField formConfig data, [ Config.city data.isOpenCity ] )
            , ( Form.renderField formConfig data, [ Config.country data ] )
            , ( Form.renderFieldWithGroup formConfig data <| Form.appendInputGroup [ datePickerIcon ], [ Config.dateOfBirth data ] )
            ]

        form =
            Form.addFields renderModel formConfig
    in
    [ div [ class "a-container directionColumn" ] [ Helpers.pyxisStyle, Form.render form, btnSubmit, btnReset ] ]


btnSubmit : Html Msg
btnSubmit =
    button
        [ onClick Submit ]
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
