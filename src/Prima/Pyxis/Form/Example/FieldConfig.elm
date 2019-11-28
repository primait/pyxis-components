module Prima.Pyxis.Form.Example.FieldConfig exposing (..)

import Prima.Pyxis.Form as Form
import Prima.Pyxis.Form.Checkbox as Checkbox
import Prima.Pyxis.Form.Example.Model exposing (Field(..), Model, Msg(..))
import Prima.Pyxis.Form.Input as Input
import Prima.Pyxis.Form.Label as Label


usernameConfig : Model -> Form.FormField Msg
usernameConfig { formData } =
    Input.text
        [ Input.slug "username"
        , Input.value formData.username
        , Input.onInput (OnInput Username)
        ]
        |> Form.input
        |> Form.addLabel (Label.label "Username" [])


passwordConfig : Model -> Form.FormField Msg
passwordConfig { formData } =
    Input.text
        [ Input.slug "password"
        , Input.value formData.password
        , Input.onInput (OnInput Password)
        ]
        |> Form.input
        |> Form.addLabel (Label.label "Password" [])


privacyConfig : Model -> Form.FormField Msg
privacyConfig { formData } =
    Checkbox.checkbox
        [ case formData.privacy of
            Just True ->
                Checkbox.checked

            _ ->
                Checkbox.notChecked
        , Checkbox.onCheck (OnCheck Privacy)
        ]
        |> Form.checkbox
        |> Form.addLabel (Label.label "Privacy" [])
