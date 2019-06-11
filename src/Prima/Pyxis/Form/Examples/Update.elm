module Prima.Pyxis.Form.Examples.Update exposing (update)

import Date exposing (Date)
import Prima.Pyxis.DatePicker as DatePicker
import Prima.Pyxis.Form as Form exposing (Form)
import Prima.Pyxis.Form.Examples.Model as Model
    exposing
        ( FieldName(..)
        , FormData
        , Model
        , Msg(..)
        , initialFormData
        )


updateFormData : (FormData -> FormData) -> Model -> Model
updateFormData mapper model =
    { model | data = mapper model.data }


withoutCmds : Model -> ( Model, Cmd Msg )
withoutCmds model =
    ( model, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "update" msg of
        UpdateField Username value ->
            model
                |> updateFormData (\f -> { f | username = value })
                |> withoutCmds

        UpdateField Password value ->
            model
                |> updateFormData (\f -> { f | password = value })
                |> withoutCmds

        UpdateField Note value ->
            model
                |> updateFormData (\f -> { f | note = value })
                |> withoutCmds

        UpdateField Gender value ->
            model
                |> updateFormData (\f -> { f | gender = value })
                |> withoutCmds

        UpdateField City value ->
            model
                |> updateFormData (\f -> { f | city = value, isOpenCity = False })
                |> withoutCmds

        UpdateField Country value ->
            model
                |> updateFormData (\f -> { f | country = value, countryFilter = Nothing, isOpenCountry = False })
                |> withoutCmds

        UpdateField DateOfBirth value ->
            let
                unwrap : Maybe (Maybe a) -> Maybe a
                unwrap theMaybe =
                    case theMaybe of
                        Just something ->
                            something

                        Nothing ->
                            Nothing
            in
            model
                |> updateFormData
                    (\f ->
                        { f
                            | dateOfBirth = value
                            , dateOfBirthDP =
                                case (unwrap << Maybe.map (Result.toMaybe << Date.fromIsoString)) value of
                                    Just date ->
                                        DatePicker.init date ( Model.lowDate, Model.highDate )

                                    _ ->
                                        f.dateOfBirthDP
                            , isOpenCountry = False
                        }
                    )
                |> withoutCmds

        UpdateDatePicker DateOfBirth dpMsg ->
            let
                updatedInstance f =
                    DatePicker.update dpMsg f.dateOfBirthDP
            in
            model
                |> updateFormData (\f -> { f | dateOfBirthDP = updatedInstance f, dateOfBirth = (Just << Date.format "dd/MM/y" << DatePicker.selectedDate) (updatedInstance f) })
                |> withoutCmds

        UpdateAutocomplete Country value ->
            model
                |> updateFormData (\f -> { f | countryFilter = value, isOpenCountry = True })
                |> withoutCmds

        UpdateCheckbox VisitedCountries ( slug, isChecked ) ->
            model
                |> updateFormData
                    (\f ->
                        { f
                            | visitedCountries =
                                List.map
                                    (\( optLabel, optSlug, optChecked ) ->
                                        if optSlug == slug then
                                            ( optLabel, optSlug, isChecked )

                                        else
                                            ( optLabel, optSlug, optChecked )
                                    )
                                    f.visitedCountries
                        }
                    )
                |> withoutCmds

        Toggle City ->
            model
                |> updateFormData (\f -> { f | isOpenCity = not f.isOpenCity })
                |> withoutCmds

        ToggleDatePicker ->
            model
                |> updateFormData
                    (\f ->
                        { f
                            | isVisibleDP = not f.isVisibleDP
                        }
                    )
                |> withoutCmds

        OnFocus City ->
            model
                |> updateFormData (\f -> { f | isOpenCity = True, isOpenCountry = False })
                |> withoutCmds

        OnFocus Country ->
            model
                |> updateFormData
                    (\f ->
                        { f
                            | isOpenCountry = True
                            , isOpenCity = False
                        }
                    )
                |> withoutCmds

        OnFocus _ ->
            withoutCmds model

        OnBlur _ ->
            withoutCmds model

        Submit ->
            { model
                | formConfig = Form.setAsSubmitted model.formConfig
            }
                |> withoutCmds

        Reset ->
            { model
                | data = initialFormData
                , formConfig = Form.setAsPristine model.formConfig
            }
                |> withoutCmds

        _ ->
            withoutCmds model
