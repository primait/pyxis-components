module Prima.PyxisV2.Modal exposing
    ( Config, config
    , ModalSize, small, medium, large
    , ModalHeader, defaultHeader, customHeader
    , ModalFooter, emptyFooter, withButtonsFooter, customFooter
    , view
    )

{-| Allows to create a Modal component using predefined Html syntax.


# Modal Configuration

@docs Config, config


# Modal Size

@docs ModalSize, small, medium, large


# Modal Header

@docs ModalHeader, defaultHeader, customHeader


# Modal Footer

@docs ModalFooter, emptyFooter, withButtonsFooter, customFooter


# Rendering

@docs view

-}

import Html exposing (..)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import Json.Decode
import Prima.PyxisV2.Button as Button


{-| Represents the configuration of a Modal component.
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


{-| Creates a Modal.Config.

    --
    import Prima.PyxisV2.Modal as Modal
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

-}
config : ModalSize -> ModalHeader msg -> List (Html msg) -> ModalFooter msg -> msg -> Config msg
config size header content footer closeTagger =
    Config <| Configuration size header content footer closeTagger


{-| Represents the Modal size.
-}
type ModalSize
    = SmallModalSize
    | MediumModalSize
    | LargeModalSize


{-| Creates a Small ModalSize
-}
small : ModalSize
small =
    SmallModalSize


{-| Creates a Medium ModalSize
-}
medium : ModalSize
medium =
    MediumModalSize


{-| Creates a Large ModalSize
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


{-| Represents the Header configuration of a Modal.
-}
type ModalHeader msg
    = ModalHeaderDefault String
    | ModalHeaderCustom (List (Html msg))


{-| Creates a Header config with a simple title.
-}
defaultHeader : String -> ModalHeader msg
defaultHeader =
    ModalHeaderDefault


{-| Creates a Header config with custom Html content.
-}
customHeader : List (Html msg) -> ModalHeader msg
customHeader =
    ModalHeaderCustom


{-| Represents the Footer configuration of a Modal.
-}
type ModalFooter msg
    = ModalFooterEmpty
    | ModalFooterButtons (List (Html msg))
    | ModalFooterCustom (List (Html msg))


{-| Represents a Footer without content.
-}
emptyFooter : ModalFooter msg
emptyFooter =
    ModalFooterEmpty


{-| Represents a Footer with a list of Prima.PyxisV2.Button instances.
All the buttons will be wrapper in a btnGroup, so no more than 4 buttons are allowed.
-}
withButtonsFooter : List (Html msg) -> ModalFooter msg
withButtonsFooter =
    ModalFooterButtons


{-| Represents a Footer with custom Html content.
-}
customFooter : List (Html msg) -> ModalFooter msg
customFooter =
    ModalFooterCustom


{-| Renders the Modal by passing isVisible flag and a Modal.Config

    --
    import Prima.PyxisV2.Modal as Modal
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
        Modal.view isVisible myModalConfig

-}
view : Bool -> Config msg -> Html msg
view isVisible (Config modalConfig) =
    if isVisible then
        div
            [ classList [ ( "a-overlay", True ) ]
            , Html.Events.on "click" <| overlayClickInterceptor modalConfig.closeTagger
            ]
            [ modal modalConfig
            ]

    else
        text ""


{-| Private method. See:
<https://github.com/rundis/elm-bootstrap/blob/5.2.0/src/Bootstrap/Modal.elm>
<https://github.com/rundis/elm-bootstrap/blob/5.2.0/src/Bootstrap/Utilities/DomHelper.elm>
-}
overlayClickInterceptor : msg -> Json.Decode.Decoder msg
overlayClickInterceptor action =
    decodeClassName
        |> decodeTarget
        |> Json.Decode.andThen (overlayClickInterceptorDecodeOrFail action)


{-| Private method
-}
overlayClickInterceptorDecodeOrFail : msg -> String -> Json.Decode.Decoder msg
overlayClickInterceptorDecodeOrFail action className =
    if String.contains "a-overlay" className then
        Json.Decode.succeed action

    else
        Json.Decode.fail "ignoring"


{-| Private method
-}
decodeTarget : Json.Decode.Decoder any -> Json.Decode.Decoder any
decodeTarget decoder =
    Json.Decode.field "target" decoder


{-| Private method
-}
decodeClassName : Json.Decode.Decoder String
decodeClassName =
    Json.Decode.at [ "className" ] Json.Decode.string


{-| Private method
-}
modal : Configuration msg -> Html msg
modal modalConfig =
    div
        [ classList
            [ ( "o-modal", True )
            , ( "o-modal--small", isSmallModalSize modalConfig.size )
            , ( "o-modal--medium", isMediumModalSize modalConfig.size )
            , ( "o-modal--large", isLargeModalSize modalConfig.size )
            ]
        ]
        [ modalHeader modalConfig.header modalConfig.closeTagger
        , modalContent modalConfig.content
        , modalFooter modalConfig.footer
        ]


{-| Private method
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


{-| Private method
-}
modalContent : List (Html msg) -> Html msg
modalContent =
    div
        [ class "o-modal__content" ]


{-| Private method
-}
modalFooter : ModalFooter msg -> Html msg
modalFooter footer =
    div
        [ class "o-modal__footer" ]
        (case footer of
            ModalFooterEmpty ->
                []

            ModalFooterButtons buttons ->
                [ div [ class "m-btnGroup" ] buttons ]

            ModalFooterCustom content ->
                content
        )


{-| Private method
-}
modalTitle : String -> Html msg
modalTitle title =
    h3
        [ class "o-modal__title" ]
        [ text title ]


{-| Private method
-}
modalClose : msg -> Html msg
modalClose action =
    i
        [ class "a-icon a-icon-close o-modal__close"
        , onClick action
        ]
        []
