module Prima.Pyxis.Form.Example.FieldValidations exposing (..)

import Prima.Pyxis.Form.Example.Model exposing (FormData, Model)
import Prima.Pyxis.Form.Validation as Validation
import Prima.Pyxis.Helpers as H


notEmptyValidation : (FormData -> Maybe a) -> FormData -> Maybe Validation.Type
notEmptyValidation mapper formData =
    if (H.isNothing << mapper) formData then
        Just <| Validation.ErrorWithMessage "Cannot be empty"

    else
        Nothing


atLeastTwoCharsValidation : (FormData -> Maybe String) -> FormData -> Maybe Validation.Type
atLeastTwoCharsValidation mapper formData =
    if (Maybe.withDefault False << Maybe.map ((>) 2 << String.length) << mapper) formData then
        Just <| Validation.ErrorWithMessage "Insert at least 2 characters."

    else
        Nothing


privacyValidation : FormData -> Maybe Validation.Type
privacyValidation { privacy } =
    if Maybe.withDefault True <| Maybe.map not privacy then
        Just <| Validation.ErrorWithMessage "You must accept the privacy."

    else
        Nothing


powerSourceNotDieselValidation : FormData -> Maybe Validation.Type
powerSourceNotDieselValidation { powerSource } =
    if Maybe.withDefault False <| Maybe.map ((==) "diesel") powerSource then
        Just <| Validation.ErrorWithMessage "Cannot be Diesel"

    else
        Nothing


countryNotItalyValidation : FormData -> Maybe Validation.Type
countryNotItalyValidation { country } =
    if Maybe.withDefault False <| Maybe.map (not << (==) "italy") country then
        Just <| Validation.ErrorWithMessage "You must choose Italy"

    else
        Nothing


countryVisitedEmptyValidation : FormData -> Maybe Validation.Type
countryVisitedEmptyValidation { countryVisited } =
    if List.isEmpty countryVisited then
        Just <| Validation.ErrorWithMessage "The field is empty"

    else
        Nothing
