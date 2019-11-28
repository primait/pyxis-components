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
        [ Input.id slug
        , Input.value formData.username
        , Input.onInput (OnInput Username)
        ]
        |> Form.input
        |> Form.addLabel (Label.label [ Label.for slug ] "Username")


passwordConfig : Model -> Form.FormField Msg
passwordConfig { formData } =
    let
        slug =
            "password"
    in
    Input.password
        [ Input.id slug
        , Input.value formData.password
        , Input.onInput (OnInput Password)
        ]
        |> Form.input
        |> Form.addLabel (Label.label [ Label.for slug ] "Password")


addressConfig : Model -> Form.FormField Msg
addressConfig { formData } =
    let
        slug =
            "address"
    in
    Input.text
        [ Input.id slug
        , Input.value formData.password
        , Input.onInput (OnInput Password)
        , Input.largeSize
        ]
        |> Form.input
        |> Form.addLabel (Label.label [ Label.for slug ] "Address")


addressNumberConfig : Model -> Form.FormField Msg
addressNumberConfig { formData } =
    let
        slug =
            "address_number"
    in
    Input.text
        [ Input.id slug
        , Input.value formData.password
        , Input.onInput (OnInput Password)
        , Input.smallSize
        ]
        |> Form.input
        |> Form.addLabel (Label.label [ Label.for slug ] "Address number")


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
