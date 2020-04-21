module Prima.Pyxis.Form.Example.Update exposing (update)

import Date
import Prima.Pyxis.Form.DatePicker as DatePicker
import Prima.Pyxis.Form.Example.Model exposing (BirthDateField(..), Field(..), FormData, Model, Msg(..), UIState)
import Prima.Pyxis.Helpers as H


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnCheck Privacy value ->
            model
                |> updatePrivacy value
                |> H.withoutCmds

        OnInput Username value ->
            model
                |> updateUsername (Just value)
                |> H.withoutCmds

        OnInput Password value ->
            model
                |> updatePassword (Just value)
                |> H.withoutCmds

        OnInput GuideType value ->
            model
                |> updateGuideType value
                |> H.withoutCmds

        OnInput PowerSource value ->
            model
                |> updatePowerSource value
                |> closePowerSourceSelect
                |> H.withoutCmds

        OnInput FiscalCode value ->
            model
                |> updateFiscalCode (Just value)
                |> H.withoutCmds

        OnInput Country value ->
            model
                |> updateCountry (Just value)
                |> updateCountryFilter Nothing
                |> closeCountryAutocomplete
                |> H.withoutCmds

        OnInput (BirthDateCompound field) value ->
            model
                |> updateBirthDateCompound field (Just value)
                |> H.withoutCmds

        OnDateInput BirthDate value ->
            model
                |> updateBirthDate value
                |> H.withoutCmds

        OnFilter Country value ->
            model
                |> updateCountryFilter (Just value)
                |> updateCountry Nothing
                |> openCountryAutocomplete
                |> H.withoutCmds

        OnToggle PowerSource ->
            model
                |> togglePowerSourceSelect
                |> H.withoutCmds

        OnChange VisitedCountries value ->
            model
                |> updateCountryVisited value
                |> H.withoutCmds

        OnDatePickerUpdate BirthDate ((DatePicker.SelectDay _) as dpMsg) ->
            model
                |> updateBirthDateDatePicker dpMsg
                |> closeBirthDateDatePicker
                |> H.withoutCmds

        OnDatePickerUpdate BirthDate dpMsg ->
            model
                |> updateBirthDateDatePicker dpMsg
                |> H.withoutCmds

        OnTodayDateReceived today ->
            { model | today = Just today }
                |> updateFormData (\fd -> { fd | birthDateDatePicker = Just <| DatePicker.init today ( Date.add Date.Years -1 today, Date.add Date.Years 1 today ) })
                |> H.withoutCmds

        OnFocus BirthDate ->
            model
                |> openBirthDateDatePicker
                |> H.withoutCmds

        OnChange InsuranceType value ->
            model
                |> updateInsurancePolicyType value
                |> H.withoutCmds

        OnInput Note value ->
            model
                |> updateNote (Just value)
                |> H.withoutCmds

        _ ->
            H.withoutCmds model


updateUsername : Maybe String -> Model -> Model
updateUsername value =
    updateFormData (\f -> { f | username = value })


updatePassword : Maybe String -> Model -> Model
updatePassword value =
    updateFormData (\f -> { f | password = value })


updatePrivacy : Bool -> Model -> Model
updatePrivacy value =
    updateFormData (\f -> { f | privacy = Just value })


updateGuideType : String -> Model -> Model
updateGuideType value =
    updateFormData (\f -> { f | guideType = Just value })


updatePowerSource : String -> Model -> Model
updatePowerSource value =
    updateFormData (\f -> { f | powerSource = Just value })


updateCountry : Maybe String -> Model -> Model
updateCountry value =
    updateFormData (\f -> { f | country = value })


updateCountryFilter : Maybe String -> Model -> Model
updateCountryFilter value =
    updateFormData (\f -> { f | countryFilter = value })


updateBirthDateCompound : BirthDateField -> Maybe String -> Model -> Model
updateBirthDateCompound field value =
    updateFormData
        (\f ->
            case field of
                Day ->
                    { f | birthDateDay = Maybe.map (String.left 2) value }

                Month ->
                    { f | birthDateMonth = Maybe.map (String.left 2) value }

                Year ->
                    { f | birthDateYear = Maybe.map (String.left 4) value }
        )


openCountryAutocomplete : Model -> Model
openCountryAutocomplete =
    updateFormData <| updateUiState (\ui -> { ui | countryAutocompleteOpened = True })


closeCountryAutocomplete : Model -> Model
closeCountryAutocomplete =
    updateFormData <| updateUiState (\ui -> { ui | countryAutocompleteOpened = False })


togglePowerSourceSelect : Model -> Model
togglePowerSourceSelect model =
    if model.formData.uiState.powerSourceSelectOpened then
        closePowerSourceSelect model

    else
        openPowerSourceSelect model


openPowerSourceSelect : Model -> Model
openPowerSourceSelect =
    updateFormData <| updateUiState (\ui -> { ui | powerSourceSelectOpened = True })


closePowerSourceSelect : Model -> Model
closePowerSourceSelect =
    updateFormData <| updateUiState (\ui -> { ui | powerSourceSelectOpened = False })


updateFiscalCode : Maybe String -> Model -> Model
updateFiscalCode value =
    updateFormData (\f -> { f | fiscalCode = value })


updateBirthDate : DatePicker.Date -> Model -> Model
updateBirthDate value =
    updateFormData (\f -> { f | birthDate = value })


updateBirthDateDatePicker : DatePicker.Msg -> Model -> Model
updateBirthDateDatePicker dpMsg model =
    model
        |> updateFormData
            (\fd ->
                { fd
                    | birthDateDatePicker =
                        fd.birthDateDatePicker
                            |> Maybe.map (DatePicker.update dpMsg)
                }
            )
        |> updateFormData
            (\fd ->
                { fd
                    | birthDate =
                        fd.birthDateDatePicker
                            |> Maybe.map DatePicker.selectedDate
                            |> Maybe.withDefault fd.birthDate
                }
            )


openBirthDateDatePicker : Model -> Model
openBirthDateDatePicker =
    updateFormData <| updateUiState (\ui -> { ui | birthDateDatePickerOpened = True })


closeBirthDateDatePicker : Model -> Model
closeBirthDateDatePicker =
    updateFormData <| updateUiState (\ui -> { ui | birthDateDatePickerOpened = False })


updateFormData : (FormData -> FormData) -> Model -> Model
updateFormData mapper model =
    { model | formData = mapper model.formData }


updateUiState : (UIState -> UIState) -> FormData -> FormData
updateUiState mapper =
    \f -> { f | uiState = mapper f.uiState }


updateCountryVisited : String -> Model -> Model
updateCountryVisited value ({ formData } as model) =
    if List.member value formData.countryVisited then
        let
            filteredCountryVisited =
                List.filter (\item -> item /= value)
                    formData.countryVisited
        in
        updateFormData
            (\f -> { f | countryVisited = filteredCountryVisited })
            model

    else
        updateFormData
            (\f -> { f | countryVisited = value :: formData.countryVisited })
            model


updateInsurancePolicyType : String -> Model -> Model
updateInsurancePolicyType value =
    updateFormData (\f -> { f | insuranceType = Just value })


updateNote : Maybe String -> Model -> Model
updateNote value =
    updateFormData (\f -> { f | note = value })
