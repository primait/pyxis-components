module Prima.Pyxis.Form.Example.FieldConfig exposing
    ( birthDateCompoundConfig
    , birthDateConfig
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
    , usernameWithTooltipConfig
    )

import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Events as Events
import Prima.Pyxis.Form as Form
import Prima.Pyxis.Form.Autocomplete as Autocomplete
import Prima.Pyxis.Form.Checkbox as Checkbox
import Prima.Pyxis.Form.Date as Date
import Prima.Pyxis.Form.Example.FieldValidations as Validation
import Prima.Pyxis.Form.Example.Model exposing (BirthDateField(..), Field(..), FormData, Msg(..))
import Prima.Pyxis.Form.Flag as Flag
import Prima.Pyxis.Form.Input as Input
import Prima.Pyxis.Form.Label as Label
import Prima.Pyxis.Form.Radio as Radio
import Prima.Pyxis.Form.RadioButton as RadioButton
import Prima.Pyxis.Form.Select as Select
import Prima.Pyxis.Form.TextArea as TextArea
import Prima.Pyxis.Helpers as H
import Prima.Pyxis.Link as Link
import Prima.Pyxis.Tooltip as Tooltip


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
        |> Input.withValidation (Validation.notEmptyValidation .username)
        |> Input.withValidation (Validation.atLeastTwoCharsValidation .username)
        |> Form.input
        |> Form.withLabel
            ("Username"
                |> Label.label
                |> Label.withFor slug
            )


usernameWithTooltipConfig : Bool -> Form.FormField FormData Msg
usernameWithTooltipConfig showTooltip =
    let
        slug =
            "username"

        icon =
            Html.i [ Attrs.class "a-icon a-icon-info", Events.onClick ToggleTooltip ] []

        tooltip =
            Tooltip.upConfig [ Html.text H.loremIpsum ]
    in
    Input.text .username (OnInput Username)
        |> Input.withId slug
        |> Form.input
        |> Form.withAppendableHtml
            [ icon
            , tooltip
                |> Tooltip.render
                |> H.renderIf showTooltip
            ]
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
        |> Input.withValidation (Validation.notEmptyValidation .password)
        |> Input.withValidation (Validation.atLeastTwoCharsValidation .password)
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
    in
    Input.text .fiscalCode (OnInput FiscalCode)
        |> Input.withId slug
        |> Input.withLargeSize
        |> Input.withPrependGroup
            ("Calcola"
                |> Link.simple
                |> Link.withHref "https://www.prima.it"
                |> Link.render
                |> List.singleton
            )
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
        |> Flag.withValidation Validation.privacyValidation
        |> Form.flag
        |> Form.withLabel
            ("Privacy"
                |> Label.label
                |> Label.withFor slug
            )


privacyLabel : List (Html Msg)
privacyLabel =
    [ Html.text "Dichiaro di accettare i termini e condizioni della "
    , Link.simple "Calcola"
        |> Link.withHref "https://www.prima.it"
        |> Link.render
    , Html.text " privacy."
    ]


guideTypeConfig : Form.FormField FormData Msg
guideTypeConfig =
    [ Radio.radioChoice "expert" "Esperta"
    , Radio.radioChoice "free" "Libera"
    , Radio.radioChoice "exclusive" "Esclusiva"
    ]
        |> Radio.radio .guideType (OnInput GuideType)
        |> Radio.withName "guide_type"
        |> Radio.withValidation (Validation.notEmptyValidation .guideType)
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
        |> Select.withValidation (Validation.notEmptyValidation .powerSource)
        |> Select.withValidation Validation.powerSourceNotDieselValidation
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
            "country-test"
    in
    [ Autocomplete.autocompleteChoice "italy" "Italy"
    , Autocomplete.autocompleteChoice "france" "France"
    , Autocomplete.autocompleteChoice "spain" "Spain"
    , Autocomplete.autocompleteChoice "usa" "U.S.A."
    , Autocomplete.autocompleteChoice "germany" "Germany"
    , Autocomplete.autocompleteChoice "uk" "U.K."
    ]
        |> Autocomplete.autocomplete .country (OnInput Country) .countryFilter (OnFilter Country) (.countryAutocompleteOpened << .uiState)
        |> Autocomplete.withLargeSize
        |> Autocomplete.withThreshold 3
        |> Autocomplete.withId slug
        |> Autocomplete.withValidation Validation.countryNotItalyValidation
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
        |> Checkbox.withValidation Validation.countryVisitedEmptyValidation
        |> Checkbox.withName "country_visited"
        |> Form.checkbox
        |> Form.withLabel
            ("Paesi visitati"
                |> Label.label
            )


radioButtonConfig : Form.FormField FormData Msg
radioButtonConfig =
    [ RadioButton.radioButtonChoiceWithSubtitle "soloMutuo" "Solo mutuo" "Lorem ipsum dolor sit amet"
    , RadioButton.radioButtonChoiceWithSubtitle "estensioneMutuo" "Estensione mutuo" "Polizza integrativa: estende la protezione obbligatoria per mutuo."
    , RadioButton.radioButtonChoiceWithSubtitle "altreSoluzioni" "Altre soluzioni" "Offerta completa adatta a tutte le esigenze."
    ]
        |> RadioButton.radioButton .insuranceType (OnChange InsuranceType)
        |> RadioButton.withValidation (Validation.notEmptyValidation .insuranceType)
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
        |> TextArea.withValidation (Validation.notEmptyValidation .note)
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


birthDateDayConfig : Input.Input FormData Msg
birthDateDayConfig =
    Input.text .birthDateDay (OnInput (BirthDateCompound Day))


birthDateMonthConfig : Input.Input FormData Msg
birthDateMonthConfig =
    Input.text .birthDateMonth (OnInput (BirthDateCompound Month))


birthDateYearConfig : Input.Input FormData Msg
birthDateYearConfig =
    Input.text .birthDateYear (OnInput (BirthDateCompound Year))


birthDateCompoundConfig : Form.FormField FormData Msg
birthDateCompoundConfig =
    [ birthDateDayConfig
    , birthDateMonthConfig
    , birthDateYearConfig
    ]
        |> List.map Input.withSmallSize
        |> Form.inputList
        |> Form.withLabel
            ("Data di nascita"
                |> Label.label
            )
