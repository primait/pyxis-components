module Prima.Pyxis.Form.Examples.View exposing (view)

import Browser
import Html exposing (Html, button, div, i, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
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
        renderModel : List (AbstractField FormData Msg)
        renderModel =
            [ Form.fieldGroup Config.formFieldGroup
            , Form.field Config.note
            , Form.field Config.gender
            , Form.field <| Config.visitedCountries data
            , Form.field <| Config.city data.isOpenCity
            , Form.field <| Config.country data
            , Form.field <| Config.dateOfBirth data
            ]

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
        , Form.render data form
        , btnSubmit
        ]
    ]


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
