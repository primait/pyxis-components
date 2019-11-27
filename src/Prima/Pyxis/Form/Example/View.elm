module Prima.Pyxis.Form.Example.View exposing (view)

import Prima.Pyxis.Form as Form
import Prima.Pyxis.Form.Example.Model exposing (Model, Msg(..))


view : Model -> Browser.Document Msg
view model =
    Browser.Document "Atr Table component" (appBody model)


formConfig : Model -> Form Msg
formConfig model =
    model.form
        |> addField ()


appBody : Model -> List (Html Msg)
appBody model =
    [ Helpers.pyxisStyle
    , Container.default
        [ Form.render model.form
        ]
    ]
