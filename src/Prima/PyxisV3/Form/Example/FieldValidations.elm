module Prima.PyxisV3.Form.Example.FieldValidations exposing
    ( atLeastTwoCharsValidation
    , countryNotItalyValidation
    , countryVisitedEmptyValidation
    , notEmptyValidation
    , powerSourceNotDieselValidation
    , privacyValidation
    , userPrivacyAcceptedValidation
    )

import Maybe.Extra as ME
import Prima.PyxisV3.Form.Example.Model exposing (FormData)
import Prima.PyxisV3.Form.Validation as Validation
import Prima.PyxisV3.Helpers as H


notEmptyValidation : (FormData -> Maybe a) -> FormData -> Maybe Validation.Type
notEmptyValidation mapper formData =
    if (H.isNothing << mapper) formData then
        Just <| Validation.ErrorWithMessage "Cannot be empty"

    else
        Nothing


atLeastTwoCharsValidation : (FormData -> Maybe String) -> FormData -> Maybe Validation.Type
atLeastTwoCharsValidation mapper formData =
    if (ME.unwrap False ((>) 2 << String.length) << mapper) formData then
        Just <| Validation.ErrorWithMessage "Insert at least 2 characters."

    else
        Nothing


privacyValidation : FormData -> Maybe Validation.Type
privacyValidation { privacy } =
    if ME.unwrap True not privacy then
        Just <| Validation.ErrorWithMessage "You must accept the privacy."

    else
        Nothing


powerSourceNotDieselValidation : FormData -> Maybe Validation.Type
powerSourceNotDieselValidation { powerSource } =
    if ME.unwrap False ((==) "diesel") powerSource then
        Just <| Validation.ErrorWithMessage "Cannot be Diesel"

    else
        Nothing


countryNotItalyValidation : FormData -> Maybe Validation.Type
countryNotItalyValidation { country } =
    if ME.unwrap False (not << (==) "italy") country then
        Just <| Validation.ErrorWithMessage "You must choose Italy"

    else
        Nothing


countryVisitedEmptyValidation : FormData -> Maybe Validation.Type
countryVisitedEmptyValidation { countryVisited } =
    if List.isEmpty countryVisited then
        Just <| Validation.ErrorWithMessage "The field is empty"

    else
        Nothing


userPrivacyAcceptedValidation : (FormData -> Maybe Bool) -> FormData -> Maybe Validation.Type
userPrivacyAcceptedValidation mapper formData =
    if Just False == mapper formData then
        Just <| Validation.ErrorWithMessage "You must select \"Yes\""

    else
        Nothing
