module Prima.Pyxis.Form.Example.FieldConfig exposing (..)

import Html exposing (Html, text)
import Prima.Pyxis.Form.Autocomplete as Autocomplete
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


privacyConfig : Field.FormField FormData Msg
privacyConfig =
    let
        slug =
            "privacy"
    in
    [ privacyLabel
        |> Label.labelWithHtml
        |> Label.withFor slug
        |> Just
        |> Checkbox.checkboxChoice "privacy"
    ]
        |> Checkbox.checkbox .privacy (OnCheck Privacy)
        |> Field.checkbox
        |> Field.addLabel
            ("Privacy"
                |> Label.label
                |> Label.withFor slug
            )


privacyLabel : List (Html Msg)
privacyLabel =
    [ text "Dichiaro di accettare i termini e condizioni della "
    , Link.render <| Link.simple "http://prima.it" "Prima.it"
    , text " privacy."
    ]


guideTypeConfig : Field.FormField FormData Msg
guideTypeConfig =
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


powerSourceConfig : Field.FormField FormData Msg
powerSourceConfig =
    let
        slug =
            "powerSource"
    in
    [ Select.selectChoice "diesel" "Diesel"
    , Select.selectChoice "petrol" "Benzina"
    , Select.selectChoice "hybrid" "Benzina / Elettrico"
    ]
        |> Select.select .powerSource (OnInput PowerSource) (.powerSourceSelectOpened << .uiState) (OnToggle PowerSource)
        |> Select.withId slug
        |> Field.select
        |> Field.addLabel
            ("Alimentazione"
                |> Label.label
                |> Label.withFor slug
            )


countryConfig : Field.FormField FormData Msg
countryConfig =
    let
        slug =
            "country"
    in
    [ Autocomplete.autocompleteChoice "italy" "Italy"
    , Autocomplete.autocompleteChoice "france" "France"
    , Autocomplete.autocompleteChoice "spain" "Spain"
    , Autocomplete.autocompleteChoice "usa" "U.S.A."
    , Autocomplete.autocompleteChoice "germany" "Germany"
    , Autocomplete.autocompleteChoice "uk" "U.K."
    ]
        |> Autocomplete.autocomplete .country (OnInput Country) .countryFilter (OnFilter Country) (.countryAutocompleteOpened << .uiState)
        |> Field.autocomplete
        |> Field.addLabel
            ("Paese di nascita"
                |> Label.label
                |> Label.withFor slug
            )
