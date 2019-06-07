module Prima.Pyxis.Form.Examples.Update exposing (update)

import Date exposing (Date)
import Prima.Pyxis.DatePicker as DatePicker
import Prima.Pyxis.Form.Examples.Model as Model
    exposing
        ( FieldName(..)
        , Model
        , Msg(..)
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "update" msg of
        UpdateField Username value ->
            ( { model
                | username = value
              }
            , Cmd.none
            )

        UpdateField Password value ->
            ( { model
                | password = value
              }
            , Cmd.none
            )

        UpdateField Note value ->
            ( { model
                | note = value
              }
            , Cmd.none
            )

        UpdateField Gender value ->
            ( { model
                | gender = value
              }
            , Cmd.none
            )

        UpdateField City value ->
            ( { model
                | city = value
                , isOpenCity = False
              }
            , Cmd.none
            )

        UpdateField Country value ->
            ( { model
                | country = value
                , countryFilter = Nothing
                , isOpenCountry = False
              }
            , Cmd.none
            )

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
            ( { model
                | dateOfBirth = value
                , dateOfBirthDP =
                    case (unwrap << Maybe.map (Result.toMaybe << Date.fromIsoString)) value of
                        Just date ->
                            DatePicker.init date ( Model.lowDate, Model.highDate )

                        _ ->
                            model.dateOfBirthDP
              }
            , Cmd.none
            )

        UpdateDatePicker DateOfBirth dpMsg ->
            let
                updatedInstance =
                    DatePicker.update dpMsg model.dateOfBirthDP
            in
            ( { model
                | dateOfBirthDP = updatedInstance
                , dateOfBirth = (Just << Date.format "dd/MM/y" << DatePicker.selectedDate) updatedInstance
              }
            , Cmd.none
            )

        UpdateAutocomplete Country value ->
            ( { model
                | countryFilter = value
                , isOpenCountry = True
              }
            , Cmd.none
            )

        UpdateCheckbox VisitedCountries ( slug, isChecked ) ->
            ( { model
                | visitedCountries =
                    List.map
                        (\( optLabel, optSlug, optChecked ) ->
                            if optSlug == slug then
                                ( optLabel, optSlug, isChecked )

                            else
                                ( optLabel, optSlug, optChecked )
                        )
                        model.visitedCountries
              }
            , Cmd.none
            )

        Toggle City ->
            ( { model
                | isOpenCity = not model.isOpenCity
              }
            , Cmd.none
            )

        ToggleDatePicker ->
            ( { model
                | isVisibleDP = not model.isVisibleDP
              }
            , Cmd.none
            )

        OnFocus City ->
            ( { model
                | isOpenCity = True
                , isOpenCountry = False
              }
            , Cmd.none
            )

        OnFocus Country ->
            ( { model
                | isOpenCountry = True
                , isOpenCity = False
              }
            , Cmd.none
            )

        OnFocus _ ->
            ( model
            , Cmd.none
            )

        OnBlur _ ->
            ( model
            , Cmd.none
            )

        _ ->
            ( model
            , Cmd.none
            )
