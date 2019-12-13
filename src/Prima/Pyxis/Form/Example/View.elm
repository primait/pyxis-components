module Prima.Pyxis.Form.Example.View exposing (view)

import Browser
import Html exposing (Html)
import Prima.Pyxis.Container as Container
import Prima.Pyxis.Form as Form
import Prima.Pyxis.Form.Example.FieldConfig as Config
import Prima.Pyxis.Form.Example.Model exposing (FormData, Model, Msg(..))
import Prima.Pyxis.Helpers as Helpers


view : Model -> Browser.Document Msg
view model =
    Browser.Document "Form component" (appBody model)


appBody : Model -> List (Html Msg)
appBody model =
    [ Helpers.pyxisStyle
    , Container.default
        [ Form.render model.formData <| formConfig model
        ]
    ]


formConfig : Model -> Form.Form FormData Msg
formConfig model =
    model.form
        |> Form.addFieldsInRow
            [ Config.usernameGroupConfig
            , Config.passwordGroupConfig
            ]
        |> Form.addFieldsInRow
            [ Config.birthDateConfig
            ]
        |> Form.addFieldsInRow
            [ Config.fiscalCodeGroupConfig
            ]
        |> Form.addFieldsInRow
            [ Config.privacyConfig
            ]
        |> Form.addFieldsInRow
            [ Config.guideTypeConfig
            ]
        |> Form.addFieldsInRow
            [ Config.powerSourceConfig
            ]
        |> Form.addFieldsInRow
            [ Config.countryConfig
            ]
        |> Form.addFieldsInRow
            [ Config.checkboxConfig
            ]
        |> Form.addFieldsInRow
            [ Config.radioButtonConfig
            ]
        |> Form.addFieldsInRow
            [ Config.textAreaConfig
            ]
