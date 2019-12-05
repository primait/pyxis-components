module Prima.Pyxis.Form.Example.FieldConfig exposing (..)

import Html exposing (Html, text)
import Html.Attributes exposing (class, id)
import Prima.Pyxis.Form.Checkbox as Checkbox
import Prima.Pyxis.Form.CustomSelect as CustomSelect
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
    Input.text .username (OnInput Username)
        |> Input.withId slug
        |> Field.input
        |> Field.addLabel
            ("Username"
                |> Label.label
                |> Label.withFor slug
            )


passwordConfig : Field.FormField FormData Msg
passwordConfig =
    let
        slug =
            "password"
    in
    Input.password .password (OnInput Password)
        |> Input.withId slug
        |> Field.input
        |> Field.addLabel
            ("Password"
                |> Label.label
                |> Label.withFor slug
            )


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
        |> Checkbox.addLabel
            (privacyLabel
                |> Label.labelWithHtml
                |> Label.withFor slug
            )
        |> Field.checkbox
        |> Field.addLabel
            ("Privacy"
                |> Label.label
                |> Label.withFor slug
            )


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
    [ Radio.radioChoice "expert" "Esperta"
    , Radio.radioChoice "free" "Libera"
    , Radio.radioChoice "exclusive" "Esclusiva"
    ]
        |> Radio.radio .guideType (OnInput GuideType)
        |> Radio.withName "guide_type"
        |> Field.radio
        |> Field.addLabel
            ("Tipo di guida"
                |> Label.label
            )


powerSource : Field.FormField FormData Msg
powerSource =
    let
        slug =
            "powerSource"
    in
    [ Select.selectChoice "diesel" "Diesel"
    , Select.selectChoice "petrol" "Benzina"
    , Select.selectChoice "hybrid" "Benzina / Elettrico"
    ]
        |> Select.select
        |> Select.withValue .powerSource
        |> Select.withId slug
        |> Select.withOnChange (OnInput PowerSource)
        |> Field.select
        |> Field.addLabel
            ("Alimentazione"
                |> Label.label
                |> Label.withFor slug
            )
