module Prima.Pyxis.Modal.Examples.View exposing
    ( appBody
    , view
    )

import Browser
import Html exposing (Html, p, text)
import Html.Attributes exposing (class)
import Prima.Pyxis.Button as Button
import Prima.Pyxis.Container as Container
import Prima.Pyxis.Helpers as Helpers
import Prima.Pyxis.Modal as Modal
import Prima.Pyxis.Modal.Examples.Model exposing (Msg(..))


view : Bool -> Browser.Document Msg
view isModalVisible =
    Browser.Document "Modal component" (appBody isModalVisible)


appBody : Bool -> List (Html Msg)
appBody isModalVisible =
    [ Helpers.pyxisStyle
    , Container.row
        |> Container.withContent
            [ Button.render True showModalBtn
            , renderModal isModalVisible
            ]
        |> Container.render
    ]


renderModal : Bool -> Html Msg
renderModal isModalVisible =
    Modal.config
        Modal.medium
        (Modal.defaultHeader "Hello! I'm a modal")
        modalContent
        (Modal.withButtonsFooter [ Button.render True showModalBtn, Button.render True hideModalBtn ])
        Hide
        |> Modal.render isModalVisible


modalContent : List (Html Msg)
modalContent =
    [ p [ class "fsSmall" ] [ text "Hide me clicking on the overlay!" ]
    , p [ class "fsSmall" ] [ text "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua." ]
    ]


showModalBtn : Button.Config Msg
showModalBtn =
    Button.tertiarySmall Button.Brand "Show modal" Show


hideModalBtn : Button.Config Msg
hideModalBtn =
    Button.tertiarySmall Button.Brand "Hide modal" Hide
