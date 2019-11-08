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
    , Container.row
        |> Container.withContent
            [ Form.render model.formData <| formConfig model
            ]
    ]


formConfig : Model -> Form.Form FormData Msg
formConfig model =
    model.form
        |> Form.withFields
            [ Config.usernameGroupConfig
            , Config.passwordGroupConfig
            ]
        |> Form.withFields
            [ Config.birthDateConfig
            ]
        |> Form.withFields
            [ Config.fiscalCodeGroupConfig
            ]
        |> Form.withFields
            [ Config.privacyConfig
            ]
        |> Form.withFields
            [ Config.guideTypeConfig
            ]
        |> Form.withFields
            [ Config.powerSourceConfig
            ]
        |> Form.withFields
            [ Config.countryConfig
            ]
        |> Form.withFields
            [ Config.checkboxConfig
            ]
        |> Form.withFields
            [ Config.radioButtonConfig
            ]
        |> Form.withFields
            [ Config.textAreaConfig
            ]
