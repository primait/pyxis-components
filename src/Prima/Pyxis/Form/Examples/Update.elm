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
    { model
        | data = mapper model.data
    }


setAsTouched : Model -> Model
setAsTouched model =
    if Form.isFormSubmitted model.formConfig then
        model

    else
        { model
            | formConfig = Form.setAsTouched model.formConfig
        }


withoutCmds : Model -> ( Model, Cmd Msg )
withoutCmds model =
    ( model, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateField Username value ->
            model
                |> updateFormData (\f -> { f | username = value })
                |> setAsTouched
                |> withoutCmds

        UpdateField Password value ->
            model
                |> updateFormData (\f -> { f | password = value })
                |> setAsTouched
                |> withoutCmds

        UpdateField Note value ->
            model
                |> updateFormData (\f -> { f | note = value })
                |> setAsTouched
                |> withoutCmds

        UpdateField Gender value ->
            model
                |> updateFormData (\f -> { f | gender = value })
                |> setAsTouched
                |> withoutCmds

        UpdateField City value ->
            model
                |> updateFormData (\f -> { f | city = value, isOpenCity = False })
                |> setAsTouched
                |> withoutCmds

        UpdateField Country value ->
            model
                |> updateFormData (\f -> { f | country = value, countryFilter = Nothing, isOpenCountry = False })
                |> setAsTouched
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
                |> setAsTouched
                |> withoutCmds

        UpdateDatePicker DateOfBirth dpMsg ->
            let
                updatedInstance f =
                    DatePicker.update dpMsg f.dateOfBirthDP
            in
            model
                |> updateFormData (\f -> { f | dateOfBirthDP = updatedInstance f, dateOfBirth = (Just << Date.format "dd/MM/y" << DatePicker.selectedDate) (updatedInstance f) })
                |> setAsTouched
                |> withoutCmds

        UpdateAutocomplete Country value ->
            model
                |> updateFormData (\f -> { f | countryFilter = value, isOpenCountry = True })
                |> setAsTouched
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
                |> setAsTouched
                |> withoutCmds

        Toggle City ->
            model
                |> updateFormData (\f -> { f | isOpenCity = not f.isOpenCity })
                |> setAsTouched
                |> withoutCmds

        ToggleDatePicker ->
            model
                |> updateFormData
                    (\f ->
                        { f
                            | isVisibleDP = not f.isVisibleDP
                        }
                    )
                |> setAsTouched
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
                , formConfig = Form.init Form.WhenSubmitted
            }
                |> withoutCmds

        ChangeValidationPolicy Form.Always ->
            { model
                | formConfig = Form.validateAlways model.formConfig
            }
                |> withoutCmds

        ChangeValidationPolicy Form.WhenSubmitted ->
            { model
                | formConfig = Form.validateWhenSubmitted model.formConfig
            }
                |> withoutCmds

        _ ->
            withoutCmds model
