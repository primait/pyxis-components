module Prima.Pyxis.Form.Example.FieldConfig exposing
    ( birthDateConfig
    , checkboxConfig
    , countryConfig
    , fiscalCodeGroupConfig
    , guideTypeConfig
    , passwordGroupConfig
    , powerSourceConfig
    , privacyConfig
    , privacyLabel
    , radioButtonConfig
    , textAreaConfig
    , usernameGroupConfig
    )

import Html exposing (Html, text)
import Html.Attributes as Attrs
import Prima.Pyxis.Form as Form
import Prima.Pyxis.Form.Autocomplete as Autocomplete
import Prima.Pyxis.Form.Checkbox as Checkbox
import Prima.Pyxis.Form.Date as Date
import Prima.Pyxis.Form.Example.Model exposing (Field(..), FormData, Msg(..))
import Prima.Pyxis.Form.Flag as Flag
import Prima.Pyxis.Form.Input as Input
import Prima.Pyxis.Form.Label as Label
import Prima.Pyxis.Form.Radio as Radio
import Prima.Pyxis.Form.RadioButton as RadioButton
import Prima.Pyxis.Form.Select as Select
import Prima.Pyxis.Form.TextArea as TextArea
import Prima.Pyxis.Form.Validation as Validation
import Prima.Pyxis.Helpers as H
import Prima.Pyxis.Link as Link


usernameGroupConfig : Form.FormField FormData Msg
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
        |> Form.input
        |> Form.withLabel
            ("Username"
                |> Label.label
                |> Label.withFor slug
            )


passwordGroupConfig : Form.FormField FormData Msg
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
        |> Form.input
        |> Form.withLabel
            ("Password"
                |> Label.label
                |> Label.withFor slug
                |> Label.withSubtitle "(opzionale)"
            )


fiscalCodeGroupConfig : Form.FormField FormData Msg
fiscalCodeGroupConfig =
    let
        slug =
            "fiscal_code"

        cta =
            Link.render <| Link.simple "Calcola" "www.prima.it"
    in
    Input.text .fiscalCode (OnInput FiscalCode)
        |> Input.withId slug
        |> Input.withLargeSize
        |> Input.withPrependGroup [ cta ]
        |> Input.withGroupClass "is-large"
        |> Form.input
        |> Form.withLabel
            ("Fiscal code"
                |> Label.label
                |> Label.withFor slug
            )


privacyConfig : Form.FormField FormData Msg
privacyConfig =
    let
        slug =
            "privacy"
    in
    Flag.flag .privacy (OnCheck Privacy) slug
        |> Flag.withLabel
            (privacyLabel
                |> Label.labelWithHtml
                |> Label.withFor slug
            )
        |> Flag.withValidation
            (\m ->
                if Maybe.withDefault True <| Maybe.map not m.privacy then
                    Just <| Validation.ErrorWithMessage "You must accept the privacy."

                else
                    Nothing
            )
        |> Form.flag
        |> Form.withLabel
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


guideTypeConfig : Form.FormField FormData Msg
guideTypeConfig =
    [ Radio.radioChoice "expert" "Esperta"
    , Radio.radioChoice "free" "Libera"
    , Radio.radioChoice "exclusive" "Esclusiva"
    ]
        |> Radio.radio .guideType (OnInput GuideType)
        |> Radio.withName "guide_type"
        |> Radio.withValidation
            (\m ->
                if H.isNothing m.guideType then
                    Just <| Validation.ErrorWithMessage "Cannot be empty"

                else
                    Nothing
            )
        |> Form.radio
        |> Form.withLabel
            ("Tipo di guida"
                |> Label.label
            )


powerSourceConfig : Form.FormField FormData Msg
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
        |> Select.withValidation
            (\m ->
                if String.isEmpty <| Maybe.withDefault "" <| m.powerSource then
                    Just <| Validation.WarningWithMessage "Cannot be empty"

                else
                    Nothing
            )
        |> Select.withValidation
            (\m ->
                if (==) "diesel" <| Maybe.withDefault "" <| m.powerSource then
                    Just <| Validation.ErrorWithMessage "Cannot be Diesel"

                else
                    Nothing
            )
        |> Form.select
        |> Form.withLabel
            ("Alimentazione"
                |> Label.label
                |> Label.withFor slug
            )


countryConfig : Form.FormField FormData Msg
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
        |> Form.autocomplete
        |> Form.withLabel
            ("Paese di nascita"
                |> Label.label
                |> Label.withFor slug
            )


checkboxConfig : Form.FormField FormData Msg
checkboxConfig =
    let
        valuesOption =
            List.map
                (\( label, value ) ->
                    Checkbox.checkboxChoice label value
                )
                [ ( "italia", "Italia" )
                , ( "francia", "Francia" )
                , ( "gb", "GB" )
                ]
    in
    valuesOption
        |> Checkbox.checkbox .countryVisited (OnChange VisitedCountries)
        |> Checkbox.withValidation
            (\m ->
                if List.isEmpty m.countryVisited then
                    Just <| Validation.ErrorWithMessage "The field is empty"

                else
                    Nothing
            )
        |> Checkbox.withName "country_visited"
        |> Form.checkbox
        |> Form.withLabel
            ("Paesi visitati"
                |> Label.label
            )


radioButtonConfig : Form.FormField FormData Msg
radioButtonConfig =
    [ RadioButton.radioButtonChoiceWithSubtitle "soloMutuo" "Solo mutuo" "Lorem ipsum dolor sit amet"
    , RadioButton.radioButtonChoiceWithSubtitle "estensioneMutuo" "Estensione mutuo" "Polizza intregativa: estende la protezione obbligatoria per mutuo."
    , RadioButton.radioButtonChoiceWithSubtitle "altreSoluzioni" "Altre soluzioni" "Offerta completa adatta a tutte le esigenze."
    ]
        |> RadioButton.radioButton .tipoPolizza (OnChange InsurancePolicyType)
        |> RadioButton.withValidation
            (\m ->
                if String.isEmpty <| Maybe.withDefault "" m.tipoPolizza then
                    Just <| Validation.ErrorWithMessage "Cannot be empty"

                else
                    Nothing
            )
        |> Form.radioButton
        |> Form.withLabel
            ("Tipo di polizza"
                |> Label.label
            )


textAreaConfig : Form.FormField FormData Msg
textAreaConfig =
    let
        slug =
            "note"
    in
    TextArea.textArea .note (OnInput Note)
        |> TextArea.withId slug
        |> TextArea.withLargeSize
        |> TextArea.withPlaceholder "Describe something happened"
        |> TextArea.withValidation
            (\m ->
                if String.isEmpty <| Maybe.withDefault "" <| m.note then
                    Just <| Validation.ErrorWithMessage "The field is empty"

                else
                    Nothing
            )
        |> TextArea.withValidation
            (\m ->
                if (==) "ciao" <| Maybe.withDefault "" <| m.note then
                    Just <| Validation.WarningWithMessage "Cannot be 'Ciao'"

                else
                    Nothing
            )
        |> Form.textArea
        |> Form.withLabel
            ("Note"
                |> Label.label
                |> Label.withFor slug
            )


birthDateConfig : Form.FormField FormData Msg
birthDateConfig =
    let
        slug =
            "birth_date"
    in
    Date.date .birthDate (OnDateInput BirthDate)
        |> Date.withId slug
        |> Date.withOnFocus (OnFocus BirthDate)
        |> Date.withDatePicker .birthDateDatePicker (OnDatePickerUpdate BirthDate)
        |> Date.withDatePickerVisibility (.birthDateDatePickerOpened << .uiState)
        |> Form.date
        |> Form.withLabel
            ("Data di nascita"
                |> Label.label
                |> Label.withFor slug
            )
