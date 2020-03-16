module Prima.Pyxis.Container.Example.Update exposing (update)

import Prima.Pyxis.Container.Example.Model as ContainerModel
import Prima.Pyxis.Helpers as H


update : ContainerModel.Msg -> ContainerModel.Model -> ( ContainerModel.Model, Cmd ContainerModel.Msg )
update msg model =
    case msg of
        ContainerModel.OnClick ->
            model
                |> ContainerModel.updateMessage "You Clicked Me!"
                |> H.withoutCmds

        ContainerModel.OnDoubleClick ->
            model
                |> ContainerModel.updateMessage "You Double Clicked Me!"
                |> H.withoutCmds

        ContainerModel.OnMouseEnter ->
            model
                |> ContainerModel.updateMessage "Mouse pointer is entered!"
                |> H.withoutCmds

        ContainerModel.OnMouseLeave ->
            model
                |> ContainerModel.updateMessage "Mouse pointer is leaving!"
                |> H.withoutCmds

        ContainerModel.OnMouseOver ->
            model
                |> ContainerModel.updateMessage "Your mouse is over me"
                |> H.withoutCmds

        ContainerModel.OnMouseOut ->
            model
                |> ContainerModel.updateMessage "Your mouse is out of me"
                |> H.withoutCmds

        ContainerModel.OnBlur ->
            model
                |> ContainerModel.updateMessage "You Blur Me!"
                |> H.withoutCmds

        ContainerModel.OnFocus ->
            model
                |> ContainerModel.updateMessage "You Focus Me!"
                |> H.withoutCmds
