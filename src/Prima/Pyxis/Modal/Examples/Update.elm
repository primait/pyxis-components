module Prima.Pyxis.Modal.Examples.Update exposing (update)

import Prima.Pyxis.Helpers as Helpers
import Prima.Pyxis.Modal as Modal
import Prima.Pyxis.Modal.Examples.Model exposing (Modal(..), Model, Msg(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Show Medium ->
            model
                |> setModalVisibility True
                |> Helpers.withoutCmds

        Hide Medium ->
            model
                |> setModalVisibility False
                |> updateMessage ""
                |> Helpers.withoutCmds

        Show Small ->
            model
                |> updateSmallModalState Modal.show
                |> Helpers.withoutCmds

        Hide Small ->
            model
                |> updateSmallModalState Modal.hide
                |> updateMessage ""
                |> Helpers.withoutCmds

        Show Large ->
            model
                |> updateLargeModalState Modal.show
                |> Helpers.withoutCmds

        Hide Large ->
            model
                |> updateLargeModalState Modal.hide
                |> updateMessage ""
                |> Helpers.withoutCmds

        PrintMsg message ->
            model
                |> updateMessage message
                |> Helpers.withoutCmds


setModalVisibility : Bool -> Model -> Model
setModalVisibility isVisible model =
    { model | isModalVisible = isVisible }


updateSmallModalState : (Modal.Config Msg -> Modal.Config Msg) -> Model -> Model
updateSmallModalState modalMapper model =
    { model | smallModalConfig = modalMapper model.smallModalConfig }


updateLargeModalState : (Modal.Config Msg -> Modal.Config Msg) -> Model -> Model
updateLargeModalState modalMapper model =
    { model | largeModalConfig = modalMapper model.largeModalConfig }


updateMessage : String -> Model -> Model
updateMessage message model =
    { model | messageToPrint = message }
