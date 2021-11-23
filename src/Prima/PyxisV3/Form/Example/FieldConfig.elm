module Prima.PyxisV3.Form.Example.FieldConfig exposing
    ( addressWithDefaultConfig
    , birthDateCompoundConfig
    , birthDateConfig
    , checkboxConfig
    , countryAutocompleteConfig
    , countrySelectConfig
    , fiscalCodeGroupConfig
    , guideTypeConfig
    , passwordGroupConfig
    , powerSourceConfig
    , privacyConfig
    , privacyLabel
    , radioButtonConfig
    , textAreaConfig
    , userPrivacyMarketingConfig
    , userPrivacyThirdPartConfig
    , usernameGroupConfig
    , usernameWithTooltipConfig
    )

import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Events as Events
import Prima.PyxisV3.Form as Form
import Prima.PyxisV3.Form.Autocomplete as Autocomplete
import Prima.PyxisV3.Form.Checkbox as Checkbox
import Prima.PyxisV3.Form.CheckboxFlag as CheckboxFlag
import Prima.PyxisV3.Form.Date as Date
import Prima.PyxisV3.Form.DatePicker as DatePicker
import Prima.PyxisV3.Form.Example.FieldValidations as Validation
import Prima.PyxisV3.Form.Example.Model exposing (BirthDateField(..), Field(..), FormData, Msg(..))
import Prima.PyxisV3.Form.FilterableSelect as FilterableSelect
import Prima.PyxisV3.Form.Input as Input
import Prima.PyxisV3.Form.Label as Label
import Prima.PyxisV3.Form.Radio as Radio
import Prima.PyxisV3.Form.RadioButton as RadioButton
import Prima.PyxisV3.Form.RadioFlag as RadioFlag
import Prima.PyxisV3.Form.Select as Select
import Prima.PyxisV3.Form.TextArea as TextArea
import Prima.PyxisV3.Helpers as H
import Prima.PyxisV3.Link as Link
import Prima.PyxisV3.Tooltip as Tooltip


usernameGroupConfig : Form.FormField FormData Msg
usernameGroupConfig =
    let
        slug =
            "username"

        userIcon =
            Html.i [ Attrs.class "form-input-group__append__icon icon icon-people" ] []
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
            Html.i [ Attrs.class "icon icon-info fs-large", Events.onClick ToggleTooltip ] []

        tooltip =
            Tooltip.top [ Html.text H.loremIpsum ]
    in
    Input.text .username (OnInput Username)
        |> Input.withId slug
        |> Input.withDefaultValue Nothing
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
            Html.i [ Attrs.class "form-input-group__prepend__icon icon icon-lock" ] []
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


addressWithDefaultConfig : Form.FormField FormData Msg
addressWithDefaultConfig =
    let
        slug =
            "address"
    in
    Input.text .address (OnInput Address)
        |> Input.withId slug
        |> Input.withDefaultValue (Just "Address")
        |> Form.input
        |> Form.withLabel
            ("Address"
                |> Label.label
                |> Label.withFor slug
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
    CheckboxFlag.flag .privacy (OnCheck Privacy) slug
        |> CheckboxFlag.withLabel
            (privacyLabel
                |> Label.labelWithHtml
                |> Label.withFor slug
            )
        |> CheckboxFlag.withValidation Validation.privacyValidation
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


userPrivacyMarketingConfig : Form.FormField FormData Msg
userPrivacyMarketingConfig =
    RadioFlag.radioFlagLight .userPrivacyMarketing (OnCheck UserPrivacyMarketing)
        |> RadioFlag.withName "user_privacy_marketing"
        |> RadioFlag.withValidation (Validation.userPrivacyAcceptedValidation .userPrivacyMarketing)
        |> RadioFlag.withId "user-privacy-marketing"
        |> Form.radioFlag
        |> Form.withLabel
            ("Acconsento al trattamento dei miei dati personali per fini commerciali ovvero offerte speciali e informazioni promozionali relative a prodotti/servizi di Prima o di soggetti terzi anche attraverso posta cartacea, sistemi automatizzati (email, sms, fax) o tramite operatore telefonico."
                |> Label.label
            )


userPrivacyThirdPartConfig : Form.FormField FormData Msg
userPrivacyThirdPartConfig =
    RadioFlag.radioFlagDark .userPrivacyThirdPart (OnCheck UserPrivacyThirdPart)
        |> RadioFlag.withName "user_privacy_third_part"
        |> RadioFlag.withValidation (Validation.userPrivacyAcceptedValidation .userPrivacyThirdPart)
        |> RadioFlag.withId "user-privacy-third-part"
        |> Form.radioFlag
        |> Form.withLabel
            ("Acconsento al trattamento dei miei dati personali per ricerche di mercato e fini statistici e/o per la personalizzazione del marketing diretto e della pubblicità comportamentale."
                |> Label.label
            )


guideTypeConfig : Form.FormField FormData Msg
guideTypeConfig =
    [ Radio.radioChoice "expert" "Esperta"
    , Radio.radioChoice "free" "Libera"
    , Radio.radioChoice "exclusive" "Esclusiva"
    ]
        |> Radio.radio .guideType (OnInput GuideType)
        |> Radio.withName "guide_type"
        |> Radio.withValidation (Validation.notEmptyValidation .guideType)
        |> Radio.withId "guide-type"
        |> Form.radio
        |> Form.withLabel
            ("Tipo di guida"
                |> Label.label
            )


powerSourceConfig : Select.State -> Form.FormField FormData Msg
powerSourceConfig state =
    let
        slug =
            "powerSource"
    in
    Select.select
        |> Select.withId slug
        |> Select.withDefaultValue Nothing
        |> Select.withValidation (Validation.notEmptyValidation .powerSource)
        |> Select.withValidation Validation.powerSourceNotDieselValidation
        |> Form.select SelectMsg state
        |> Form.withLabel
            ("Alimentazione"
                |> Label.label
                |> Label.withFor slug
            )


countryAutocompleteConfig : Autocomplete.State -> Form.FormField FormData Msg
countryAutocompleteConfig state =
    let
        slug =
            "country-test"
    in
    Autocomplete.autocomplete
        |> Autocomplete.withLargeSize
        |> Autocomplete.withId slug
        |> Autocomplete.withValidation Validation.countryNotItalyValidation
        |> Form.autocomplete AutocompleteMsg state
        |> Form.withLabel
            ("Paese di nascita"
                |> Label.label
                |> Label.withFor slug
            )


countrySelectConfig : FilterableSelect.State -> Form.FormField FormData Msg
countrySelectConfig state =
    let
        slug =
            "country-test2"
    in
    FilterableSelect.filterableSelect
        |> FilterableSelect.withLargeSize
        |> FilterableSelect.withId slug
        |> FilterableSelect.withDefaultValue Nothing
        |> Form.filterableSelect FilterableSelectMsg state
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
        |> Checkbox.withId "country-visited"
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
        |> RadioButton.withId "insurance-type"
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
        |> TextArea.withDefaultValue Nothing
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
        |> Date.withDefaultValue (DatePicker.PartialDate (Just ""))
        |> Date.withDatePicker .birthDateDatePicker (OnDatePickerUpdate BirthDate)
        |> Date.withDatePickerVisibility (.birthDateDatePickerOpened << .uiState)
        |> Date.withOnIconClick (OnClick BirthDate)
        |> Date.withAttribute (Attrs.autocomplete False)
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
