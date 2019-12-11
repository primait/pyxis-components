module Prima.Pyxis.Form.Example.FieldConfig exposing
    ( countryConfig
    , fiscalCodeGroupConfig
    , guideTypeConfig
    , multiChoicesConfig
    , passwordConfig
    , passwordGroupConfig
    , powerSourceConfig
    , privacyConfig
    , privacyLabel
    , usernameConfig
    , usernameGroupConfig
    )

import Html exposing (Html, text)
import Html.Attributes as Attrs
import Prima.Pyxis.Form.Autocomplete as Autocomplete
import Prima.Pyxis.Form.Checkbox as Checkbox
import Prima.Pyxis.Form.Example.Model exposing (Field(..), FormData, Model, Msg(..))
import Prima.Pyxis.Form.Field as Field
import Prima.Pyxis.Form.Input as Input
import Prima.Pyxis.Form.Label as Label
import Prima.Pyxis.Form.MultiChoice as MultiChoice
import Prima.Pyxis.Form.Radio as Radio
import Prima.Pyxis.Form.Select as Select
import Prima.Pyxis.Form.Validation as Validation
import Prima.Pyxis.Link as Link


usernameConfig : Field.FormField FormData Msg
usernameConfig =
    let
        slug =
            "username"
    in
    Input.text .username (OnInput Username)
        |> Input.withId slug
        |> Input.withValidation
            (\m ->
                if String.isEmpty <| Maybe.withDefault "" <| m.username then
                    Just <| Validation.ErrorWithMessage "The field is empty"

                else
                    Nothing
            )
        |> Input.withValidation
            (\m ->
                if (==) "ciao" <| Maybe.withDefault "" <| m.username then
                    Just <| Validation.WarningWithMessage "Cannot be 'Ciao'"

                else
                    Nothing
            )
        |> Field.input
        |> Field.addLabel
            ("Username & pwd"
                |> Label.label
                |> Label.withFor slug
            )


usernameGroupConfig : Field.FormField FormData Msg
usernameGroupConfig =
    let
        slug =
            "username"

        userIcon =
            Html.i [ Attrs.class "a-icon a-icon-people" ] []
    in
    Input.text .username (OnInput Username)
        |> Input.withId slug
        |> Input.withAppendGroup [ userIcon ]
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


passwordGroupConfig : Field.FormField FormData Msg
passwordGroupConfig =
    let
        slug =
            "password"

        lockIcon =
            Html.i [ Attrs.class "a-icon a-icon-lock" ] []
    in
    Input.password .password (OnInput Password)
        |> Input.withId slug
        |> Input.withPrependGroup [ lockIcon ]
        |> Field.input
        |> Field.addLabel
            ("Password"
                |> Label.label
                |> Label.withFor slug
                |> Label.withSubtitle "(opzionale)"
            )


fiscalCodeGroupConfig : Field.FormField FormData Msg
fiscalCodeGroupConfig =
    let
        slug =
            "fiscal_code"

        cta =
            Link.render <| Link.simple "Calcola" "www.prima.it"
    in
    Input.text .fiscalCode (OnInput FiscalCode)
        |> Input.withId slug
        |> Input.withPrependGroup [ cta ]
        |> Field.input
        |> Field.addLabel
            ("Fiscal code"
                |> Label.label
                |> Label.withFor slug
            )


privacyConfig : Field.FormField FormData Msg
privacyConfig =
    let
        slug =
            "privacy"
    in
    Checkbox.checkbox .privacy (OnCheck Privacy) slug
        |> Checkbox.withLabel
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
        |> Autocomplete.withThreshold 3
        |> Autocomplete.withLargeSize
        |> Autocomplete.withId slug
        |> Autocomplete.withValidation
            (\m ->
                if (==) "italy" <| Maybe.withDefault "" <| m.country then
                    Just <| Validation.ErrorWithMessage "The field is empty"

                else
                    Nothing
            )
        |> Field.autocomplete
        |> Field.addLabel
            ("Paese di nascita"
                |> Label.label
                |> Label.withFor slug
            )


multiChoicesConfig : Field.FormField FormData Msg
multiChoicesConfig =
    let
        valuesOption =
            List.map
                (\( label, value ) ->
                    MultiChoice.multiChoiceChoice label value
                )
                [ ( "italia", "Italia" )
                , ( "francia", "Francia" )
                , ( "gb", "GB" )
                ]
    in
    valuesOption
        |> MultiChoice.multiChoice .countryVisited (OnChoice CountyVisited)
        |> MultiChoice.withValidation
            (\m ->
                if List.isEmpty m.countryVisited then
                    Just <| Validation.ErrorWithMessage "The field is empty"

                else
                    Nothing
            )
        |> MultiChoice.withName "country_visited"
        |> Field.multiChoice
        |> Field.addLabel
            ("Paesi visitati"
                |> Label.label
            )
