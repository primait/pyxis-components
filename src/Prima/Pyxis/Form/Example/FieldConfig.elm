module Prima.Pyxis.Form.Example.FieldConfig exposing (..)

import Html exposing (Html, text)
import Prima.Pyxis.Form as Form
import Prima.Pyxis.Form.Checkbox as Checkbox
import Prima.Pyxis.Form.Example.Model exposing (Field(..), Model, Msg(..))
import Prima.Pyxis.Form.Input as Input
import Prima.Pyxis.Form.Label as Label
import Prima.Pyxis.Link as Link


usernameConfig : Model -> Form.FormField Msg
usernameConfig { formData } =
    let
        slug =
            "username"
    in
    Input.text
        |> Input.withId slug
        |> Input.withValue formData.username
        |> Input.withOnInput (OnInput Username)
        |> Form.input
        |> Form.addLabel (Label.label [ Label.for slug ] "Username")


passwordConfig : Model -> Form.FormField Msg
passwordConfig { formData } =
    let
        slug =
            "password"
    in
    Input.password
        |> Input.withId slug
        |> Input.withValue formData.password
        |> Input.withOnInput (OnInput Password)
        |> Form.input
        |> Form.addLabel (Label.label [ Label.for slug ] "Password")


privacyConfig : Model -> Form.FormField Msg
privacyConfig { formData } =
    let
        slug =
            "privacy"
    in
    Checkbox.checkbox
        [ checkboxStatus formData.privacy
        , Checkbox.id slug
        , Checkbox.onCheck (OnCheck Privacy)
        ]
        |> Checkbox.addLabel (Label.labelWithHtml [ Label.for slug ] privacyLabel)
        |> Form.checkbox
        |> Form.addLabel (Label.label [ Label.for slug ] "Privacy")


checkboxStatus : Maybe Bool -> Checkbox.CheckboxOption Msg
checkboxStatus flag =
    if Just True == flag then
        Checkbox.checked

    else
        Checkbox.notChecked


privacyLabel : List (Html Msg)
privacyLabel =
    [ text "Dichiaro di accettare i termini e condizioni della "
    , Link.render <| Link.simple "http://prima.it" "Prima.it"
    , text " privacy."
    ]
