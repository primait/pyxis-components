module Prima.Pyxis.Modal exposing
    ( Config, config
    , small, medium, large, defaultHeader, customHeader, emptyFooter, withButtonsFooter, customFooter
    , render
    )

{-| Create a `Modal` using predefined Html syntax.


# Configuration

@docs Config, config


## Options

@docs small, medium, large, defaultHeader, customHeader, emptyFooter, withButtonsFooter, customFooter


# Render

@docs render

-}

import Html exposing (Html, div, h3, i, text)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import Json.Decode
import Prima.Pyxis.Helpers as H


{-| Represent the configuration of a Modal component.
The Modal will trigger a "closed" Msg when the overlay is clicked.
Is up to you to intercept and manage this Msg.
-}
type Config msg
    = Config (Configuration msg)


type alias Configuration msg =
    { size : ModalSize
    , header : ModalHeader msg
    , content : List (Html msg)
    , footer : ModalFooter msg
    , closeTagger : msg
    }


{-| Create a Modal.Config.

    --
    import Prima.Pyxis.Modal as Modal
    import Html exposing (Html, p, text)

    ...

    type Msg =
        ModalClosed

    ...

    myModalConfig : Modal.Config
    myModalConfig =
        let
            modalHeader : Modal.ModalHeader Msg
            modalHeader =
                Modal.defaultHeader "My modal title"

            modalFooter : Modal.ModalFooter Msg
            modalFooter =
                Modal.emptyFooter

            modalContent : List (Html Msg)
            modalContent =
                p [] [ text "Lorem ipsum dolor sit amet."]
        in
        Modal.config Modal.medium modalHeader modalContent modalFooter ModalClosed

-}
config : ModalSize -> ModalHeader msg -> List (Html msg) -> ModalFooter msg -> msg -> Config msg
config size header content footer closeTagger =
    Config <| Configuration size header content footer closeTagger


{-| Represent the Modal size.
-}
type ModalSize
    = SmallModalSize
    | MediumModalSize
    | LargeModalSize


{-| Create a Small ModalSize
-}
small : ModalSize
small =
    SmallModalSize


{-| Create a Medium ModalSize
-}
medium : ModalSize
medium =
    MediumModalSize


{-| Create a Large ModalSize
-}
large : ModalSize
large =
    LargeModalSize


isSmallModalSize : ModalSize -> Bool
isSmallModalSize =
    (==) SmallModalSize


isMediumModalSize : ModalSize -> Bool
isMediumModalSize =
    (==) MediumModalSize


isLargeModalSize : ModalSize -> Bool
isLargeModalSize =
    (==) LargeModalSize


{-| Represent the Header configuration of a Modal.
-}
type ModalHeader msg
    = ModalHeaderDefault String
    | ModalHeaderCustom (List (Html msg))


{-| Create a Header config with a simple title.
-}
defaultHeader : String -> ModalHeader msg
defaultHeader =
    ModalHeaderDefault


{-| Create a Header config with custom Html content.
-}
customHeader : List (Html msg) -> ModalHeader msg
customHeader =
    ModalHeaderCustom


{-| Represent the Footer configuration of a Modal.
-}
type ModalFooter msg
    = ModalFooterEmpty
    | ModalFooterButtons (List (Html msg))
    | ModalFooterCustom (List (Html msg))


{-| Represent a Footer without content.
-}
emptyFooter : ModalFooter msg
emptyFooter =
    ModalFooterEmpty


{-| Represent a Footer with a list of Prima.Pyxis.Button instances.
All the buttons will be wrapper in a btnGroup, so no more than 4 buttons are allowed.
-}
withButtonsFooter : List (Html msg) -> ModalFooter msg
withButtonsFooter =
    ModalFooterButtons


{-| Represent a Footer with custom Html content.
-}
customFooter : List (Html msg) -> ModalFooter msg
customFooter =
    ModalFooterCustom


{-| Renders the Modal by passing isVisible flag and a Modal.Config

    --
    import Prima.Pyxis.Modal as Modal
    import Html exposing (Html, p, text)

    ...

    type Msg =
        ModalClosed

    ...

    myModalConfig : Modal.Config
    myModalConfig =
        let
            modalHeader : Modal.ModalHeader Msg
            modalHeader =
                Modal.defaultHeader "My modal title"

            modalFooter : Modal.ModalFooter Msg
            modalFooter =
                Modal.emptyFooter

            modalContent : List (Html Msg)
            modalContent =
                p [] [ text "Lorem ipsum dolor sit amet."]
        in
        Modal.config Modal.medium modalHeader  modalContent modalFooter ModalClosed

    renderModal : Html Msg
    renderModal =
        let
            isVisible =
                True
        in
        Modal.render isVisible myModalConfig

-}
render : Bool -> Config msg -> Html msg
render isVisible (Config modalConfig) =
    if isVisible then
        div
            [ classList [ ( "a-overlay", True ) ]
            , Html.Events.on "click" <| overlayClickInterceptor modalConfig.closeTagger
            ]
            [ modal modalConfig
            ]

    else
        text ""


{-| Internal. See:
<https://github.com/rundis/elm-bootstrap/blob/5.2.0/src/Bootstrap/Modal.elm>
<https://github.com/rundis/elm-bootstrap/blob/5.2.0/src/Bootstrap/Utilities/DomHelper.elm>
-}
overlayClickInterceptor : msg -> Json.Decode.Decoder msg
overlayClickInterceptor action =
    decodeClassName
        |> decodeTarget
        |> Json.Decode.andThen (overlayClickInterceptorDecodeOrFail action)


{-| Internal. Interceptor zone on click event
-}
overlayClickInterceptorDecodeOrFail : msg -> String -> Json.Decode.Decoder msg
overlayClickInterceptorDecodeOrFail action className =
    if String.contains "a-overlay" className then
        Json.Decode.succeed action

    else
        Json.Decode.fail "ignoring"


{-| Internal.
-}
decodeTarget : Json.Decode.Decoder any -> Json.Decode.Decoder any
decodeTarget decoder =
    Json.Decode.field "target" decoder


{-| Internal.
-}
decodeClassName : Json.Decode.Decoder String
decodeClassName =
    Json.Decode.at [ "className" ] Json.Decode.string


{-| Internal. Design modal from its configuration
-}
modal : Configuration msg -> Html msg
modal { size, footer, content, header, closeTagger } =
    div
        [ classList
            [ ( "o-modal", True )
            , ( "o-modal--small", isSmallModalSize size )
            , ( "o-modal--medium", isMediumModalSize size )
            , ( "o-modal--large", isLargeModalSize size )
            ]
        ]
        [ modalHeader header closeTagger
        , modalContent content
        , modalFooter footer
        ]


{-| Internal. Building header
-}
modalHeader : ModalHeader msg -> msg -> Html msg
modalHeader header action =
    div
        [ class "o-modal__header" ]
        (case header of
            ModalHeaderDefault title ->
                [ modalTitle title
                , modalClose action
                ]

            ModalHeaderCustom content ->
                content
        )


{-| Internal. Building content
-}
modalContent : List (Html msg) -> Html msg
modalContent =
    div
        [ class "o-modal__content" ]


{-| Internal. Building footer
-}
modalFooter : ModalFooter msg -> Html msg
modalFooter footer =
    div
        [ class "o-modal__footer" ]
        (case footer of
            ModalFooterEmpty ->
                []

            ModalFooterButtons buttons ->
                [ H.btnGroup buttons ]

            ModalFooterCustom content ->
                content
        )


{-| Internal. Building title
-}
modalTitle : String -> Html msg
modalTitle title =
    h3
        [ class "o-modal__title" ]
        [ text title ]


{-| Internal. Icon for closing modal
-}
modalClose : msg -> Html msg
modalClose action =
    i
        [ class "a-icon a-icon-close o-modal__close"
        , onClick action
        ]
        []
