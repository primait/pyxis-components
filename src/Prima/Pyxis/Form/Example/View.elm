module Prima.Pyxis.Form.Example.View exposing (view)

import Browser
import Html exposing (Html)
import Prima.Pyxis.Container as Container
import Prima.Pyxis.Form as Form
import Prima.Pyxis.Form.Example.FieldConfig as Config
import Prima.Pyxis.Form.Example.Model exposing (Model, Msg(..))
import Prima.Pyxis.Helpers as Helpers


view : Model -> Browser.Document Msg
view model =
    Browser.Document "Form component" (appBody model)


appBody : Model -> List (Html Msg)
appBody model =
    [ Helpers.pyxisStyle
    , Container.default
        [ Form.render <| formConfig model
        ]
    ]


formConfig : Model -> Form.Form Msg
formConfig model =
    model.form
        |> Form.addFieldsInRow
            [ Config.usernameConfig model
            , Config.passwordConfig model
            ]
        |> Form.addFieldsInRow [ Config.privacyConfig model ]
        |> Debug.log "form"
