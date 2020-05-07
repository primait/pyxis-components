module Prima.Pyxis.Modal.Examples.View exposing
    ( appBody
    , view
    )

import Browser
import Html exposing (Html, div, h3, p, text)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Prima.Pyxis.Button as Button
import Prima.Pyxis.ButtonGroup as ButtonGroup
import Prima.Pyxis.Container as Container
import Prima.Pyxis.Helpers as Helpers
import Prima.Pyxis.Link as Link
import Prima.Pyxis.Modal as Modal
import Prima.Pyxis.Modal.Examples.Model exposing (Modal(..), Model, Msg(..))


view : Model -> Browser.Document Msg
view model =
    Browser.Document "Modal component" (appBody model)


linkContainerStyles : List (Html.Attribute Msg)
linkContainerStyles =
    [ style "display" "flex"
    , style "flex-flow" "column"
    , style "width" "500px"
    , style "margin" "200px auto auto auto"
    , style "justify-content" "center"
    ]


appBody : Model -> List (Html Msg)
appBody ({ messageToPrint } as model) =
    [ Helpers.pyxisStyle
    , Container.column
        |> Container.withContent
            (div linkContainerStyles
                [ h3 [ style "margin-bottom" "200px" ]
                    [ "Message from modal:"
                        ++ messageToPrint
                        |> text
                    ]
                , Link.simple "Medium Modal"
                    |> Link.withOnClick (Show Medium)
                    |> Link.render
                , Link.simple "Small Modal"
                    |> Link.withOnClick (Show Small)
                    |> Link.render
                , Link.simple "Large Modal"
                    |> Link.withOnClick (Show Large)
                    |> Link.render
                ]
                :: renderModals model
            )
        |> Container.render
    ]


renderModals : Model -> List (Html Msg)
renderModals { isModalVisible, smallModalConfig, largeModalConfig } =
    [ mediumModal isModalVisible
    , smallModal smallModalConfig
    , largeModal largeModalConfig
    ]


smallModal : Modal.Config Msg -> Html Msg
smallModal modalConfig =
    modalConfig
        |> Modal.withHeaderTitleOnly "Pre-config Modal"
        |> Modal.withCloseOnOverlayClick
        |> Modal.withId "preConfigModal"
        |> Modal.withBodyContent
            [ p []
                [ text "I'm pre-configurated on model and show/displayed directly in update. "
                , text "You can close me only clicking on overlay"
                ]
            , printMsgBtn "Pre-config modal message button clicked"
                |> Button.render
            ]
        |> Modal.render


mediumModal : Bool -> Html Msg
mediumModal isModalVisible =
    Modal.medium isModalVisible (Hide Medium)
        |> Modal.withHeaderTitle "Hello! I'm a modal"
        |> Modal.withCloseOnOverlayClick
        |> Modal.withBodyContent
            [ p
                [ class "fsSmall" ]
                [ text "Hide me clicking on X button or footer close button" ]
            ]
        |> Modal.withFooterContent
            [ ButtonGroup.create
                [ printMsgBtn "You clicked  a button in medium modal"
                , hideModalBtn (Hide Medium)
                ]
                |> ButtonGroup.render
            ]
        |> Modal.render


largeModal : Modal.Config Msg -> Html Msg
largeModal modalConfig =
    modalConfig
        |> Modal.withOverlayClass "heavily-custom-overlay"
        |> Modal.withOverlayClassList [ ( "test", True ) ]
        |> Modal.withHeaderTitle "Heavily custom modal"
        |> Modal.withId "eavilyCustomModal"
        |> Modal.withClass "eavily-custom-modal"
        |> Modal.withClassList
            [ ( "test", True ) ]
        |> Modal.withTitleAttribute "Heavily Custom Modal"
        |> Modal.withCloseOnOverlayClick
        |> Modal.withHeaderClass "container-fluid directionRow bgAlertBase"
        |> Modal.withHeaderClassList [ ( "test", True ) ]
        |> Modal.withHeaderContentOnly
            [ div
                [ class "bgBrandBase"
                , style "width" "40px"
                , style "height" "40px"
                , style "margin" "10px"
                , onClick (Hide Large)
                ]
                []
            , p
                []
                [ text "Some custom text in your header" ]
            ]
        |> Modal.withBodyClass "heavily-custom-body"
        |> Modal.withBodyClassList [ ( "test", True ) ]
        |> Modal.withBodyContent
            [ p
                [ class "fsSmall" ]
                [ text
                    "This modal is heavily customized with class classList and custom content stuffs."
                ]
            , p []
                [ text
                    "Hide me clicking on purple square, overlay or footer close button"
                ]
            ]
        |> Modal.withFooterClass "heavily-custom-footer"
        |> Modal.withFooterClassList [ ( "test", True ) ]
        |> Modal.withFooterContent
            [ ButtonGroup.create
                [ printMsgBtn "You clicked  a button in large modal"
                , hideModalBtn (Hide Large)
                ]
                |> ButtonGroup.render
            ]
        |> Modal.render


hideModalBtn : Msg -> Button.Config Msg
hideModalBtn closeModalMessage =
    Button.primary "Hide modal"
        |> Button.withOnClick closeModalMessage


printMsgBtn : String -> Button.Config Msg
printMsgBtn message =
    Button.callOut "Show message"
        |> Button.withOnClick (PrintMsg message)
