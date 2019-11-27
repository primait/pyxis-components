module Prima.Pyxis.Form.Example.Update exposing (update)

import Prima.Pyxis.Form.Example.Model exposing (Model, Msg)
import Prima.Pyxis.Helpers as H


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnInput Username value ->
            model
                |> updateUsername value
                |> H.withoutCmd

        OnInput Password value ->
            model
                |> updatePassword value
                |> H.withoutCmd

        OnCheck Privacy value ->
            model
                |> updatePrivacy value
                |> H.withoutCmd

        _ ->
            H.withoutCmd model


updateUsername : String -> Model -> Model
updateUsername value =
    updateFormData (\f -> { f | username = value })


updatePassword : String -> Model -> Model
updatePassword value =
    updateFormData (\f -> { f | password = value })


updatePrivacy : Bool -> Model -> Model
updatePrivacy value =
    updateFormData (\f -> { f | privacy = Just value })


updateFormData : (FormData -> FormData) -> Model -> Model
updateFormData mapper model =
    { model | formData = mapper model.formData }
