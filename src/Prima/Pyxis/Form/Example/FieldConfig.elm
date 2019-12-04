module Prima.Pyxis.Form.Example.FieldConfig exposing (..)

import Html exposing (Html, text)
import Html.Attributes exposing (class, id)
import Prima.Pyxis.Form.Checkbox as Checkbox
import Prima.Pyxis.Form.Example.Model exposing (Field(..), FormData, Model, Msg(..))
import Prima.Pyxis.Form.Field as Field
import Prima.Pyxis.Form.Input as Input
import Prima.Pyxis.Form.Label as Label
import Prima.Pyxis.Form.Radio as Radio
import Prima.Pyxis.Form.Select as Select
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


privacyConfig : Model -> Field.FormField FormData Msg
privacyConfig { formData } =
    let
        slug =
            "privacy"
    in
    Checkbox.checkbox
        |> Checkbox.withValue (checkboxStatus formData.privacy)
        |> Checkbox.withId slug
        |> Checkbox.withOnCheck (OnCheck Privacy)
        |> Checkbox.addLabel (Label.labelWithHtml [ Label.for slug ] privacyLabel)
        |> Field.checkbox
        |> Field.addLabel (Label.label [ Label.for slug ] "Privacy")


checkboxStatus : Maybe Bool -> Checkbox.CheckboxValue
checkboxStatus flag =
    if Just True == flag then
        Checkbox.Checked

    else
        Checkbox.NotChecked


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
        [ id "guide-type" ]
        [ ( "expert", "Esperta" ), ( "free", "Libera" ), ( "exclusive", "Esclusiva" ) ]
        |> Radio.withValue .guideType
        |> Radio.withOnInput (OnInput GuideTypeField)
        |> Field.radio
        |> Field.addLabel (Label.label [] "Tipo di guida")


powerSource : Field.FormField FormData Msg
powerSource =
    let
        slug =
            "powerSource"
    in
    Select.select
        [ ( "petrol", "Benzina" ), ( "diesel", "Diesel" ) ]
        |> Select.withValue (Just << .powerSource)
        |> Select.withId slug
        |> Select.withOnInput (OnInput PowerSource)
        |> Field.select
        |> Field.addLabel (Label.label [ Label.for slug ] "Alimentazione")
