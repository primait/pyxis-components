module Prima.Pyxis.Form.Example.Update exposing (update)

import Prima.Pyxis.Form.Example.Model
    exposing
        ( Field(..)
        , FormData
        , Model
        , Msg(..)
        , UIState
        )
import Prima.Pyxis.Helpers as H


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "update" msg of
        OnCheck Privacy value ->
            model
                |> updatePrivacy value
                |> printModel
                |> H.withoutCmds

        OnInput Username value ->
            model
                |> updateUsername (Just value)
                |> printModel
                |> H.withoutCmds

        OnInput Password value ->
            model
                |> updatePassword (Just value)
                |> printModel
                |> H.withoutCmds

        OnInput GuideType value ->
            model
                |> updateGuideType value
                |> printModel
                |> H.withoutCmds

        OnInput PowerSource value ->
            model
                |> updatePowerSource value
                |> closePowerSourceSelect
                |> printModel
                |> H.withoutCmds

        OnInput Country value ->
            model
                |> updateCountry (Just value)
                |> updateCountryFilter Nothing
                |> closeCountryAutocomplete
                |> printModel
                |> H.withoutCmds

        OnFilter Country value ->
            model
                |> updateCountryFilter (Just value)
                |> updateCountry Nothing
                |> openCountryAutocomplete
                |> printModel
                |> H.withoutCmds

        _ ->
            H.withoutCmds model


printModel : Model -> Model
printModel =
    Debug.log "updatedModel is"


updateUsername : Maybe String -> Model -> Model
updateUsername value =
    updateFormData (\f -> { f | username = value })


updatePassword : Maybe String -> Model -> Model
updatePassword value =
    updateFormData (\f -> { f | password = value })


updatePrivacy : String -> Model -> Model
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


openCountryAutocomplete : Model -> Model
openCountryAutocomplete =
    updateFormData <| updateUiState (\ui -> { ui | countryAutocompleteOpened = True })


closeCountryAutocomplete : Model -> Model
closeCountryAutocomplete =
    updateFormData <| updateUiState (\ui -> { ui | countryAutocompleteOpened = False })


openPowerSourceSelect : Model -> Model
openPowerSourceSelect =
    updateFormData <| updateUiState (\ui -> { ui | powerSourceSelectOpened = True })


closePowerSourceSelect : Model -> Model
closePowerSourceSelect =
    updateFormData <| updateUiState (\ui -> { ui | powerSourceSelectOpened = False })


updateFormData : (FormData -> FormData) -> Model -> Model
updateFormData mapper model =
    { model | formData = mapper model.formData }


updateUiState : (UIState -> UIState) -> FormData -> FormData
updateUiState mapper =
    \f -> { f | uiState = mapper f.uiState }
