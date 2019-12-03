module Prima.Pyxis.Form.Example.FieldConfig exposing (..)

import Html exposing (Html, text)
import Prima.Pyxis.Form as Form
import Prima.Pyxis.Form.Checkbox as Checkbox
import Prima.Pyxis.Form.Example.Model exposing (Field(..), FormData, GuideType(..), Model, Msg(..), guideTypeToSlug)
import Prima.Pyxis.Form.Field as Field
import Prima.Pyxis.Form.Input as Input
import Prima.Pyxis.Form.Label as Label
import Prima.Pyxis.Form.Radio as Radio
import Prima.Pyxis.Link as Link


usernameConfig : Field.FormField FormData Msg
usernameConfig =
    let
        slug =
            "username"
    in
    Input.text
        |> Input.withId slug
        |> Input.withValue .username
        |> Input.withOnInput (OnInput Username)
        |> Field.input
        |> Field.addLabel (Label.label [ Label.for slug ] "Username")


passwordConfig : Field.FormField FormData Msg
passwordConfig =
    let
        slug =
            "password"
    in
    Input.password
        |> Input.withId slug
        |> Input.withValue .password
        |> Input.withOnInput (OnInput Password)
        |> Field.input
        |> Field.addLabel (Label.label [ Label.for slug ] "Password")


privacyConfig : Field.FormField FormData Msg
privacyConfig =
    let
        slug =
            "privacy"
    in
    Checkbox.checkbox
        [ checkboxStatus (Just True)
        , Checkbox.id slug
        , Checkbox.onCheck (OnCheck Privacy)
        ]
        |> Checkbox.addLabel (Label.labelWithHtml [ Label.for slug ] privacyLabel)
        |> Field.checkbox
        |> Field.addLabel (Label.label [ Label.for slug ] "Privacy")


checkboxStatus : Maybe Bool -> Checkbox.CheckboxOption FormData Msg
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


guideType : Field.FormField FormData Msg
guideType =
    Radio.radio
        "guideType"
        [ ( "expert", "Esperta" ), ( "free", "Libera" ) ]
        |> Radio.withOnInput (OnInput GuideTypeField)
        |> Field.radio
        |> Field.addLabel (Label.label [] "Tipo di guida")
