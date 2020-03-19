module Prima.Pyxis.Modal exposing (Config, hide, large, medium, render, show, small, toggle, withAttribute, withBodyAttribute, withBodyClass, withBodyClassList, withBodyContent, withBodyStyle, withClass, withClassList, withCloseOnOverlayClick, withFooterAttribute, withFooterClass, withFooterClassList, withFooterContent, withFooterStyle, withHeaderAttribute, withHeaderClass, withHeaderClassList, withHeaderContent, withHeaderContentOnly, withHeaderStyle, withHeaderTitle, withHeaderTitleOnly, withId, withOverlayAttribute, withOverlayClass, withOverlayClassList, withStyle, withTitleAttribute)

import Html exposing (Html)
import Html.Attributes as HtmlAttributes
import Prima.Pyxis.Helpers as H
import Prima.Pyxis.Shared.InterceptedEvents as InterceptedEvents
import Prima.Pyxis.Shared.Interceptor as Interceptor


{-| Represent the configuration of a `Container`.
This type can't be created directly and is Opaque.
You must use Configuration constructors instead
-}
type Config msg
    = Config (ModalConfig msg)


{-| Internal.
Represent the Container configuration record
-}
type alias ModalConfig msg =
    { closeEvent : msg
    , options : Options msg
    , size : Size
    , visible : Bool
    }


type Size
    = Small
    | Medium
    | Large


isSmallSize : Size -> Bool
isSmallSize =
    (==) Small


isMediumSize : Size -> Bool
isMediumSize =
    (==) Medium


isLargeSize : Size -> Bool
isLargeSize =
    (==) Large


{-| Internal.
Opaque ModalOptions constructor
-}
type Options msg
    = Options (ModalOptions msg)


{-| Internal.
Represents the optional configurations of a Container
-}
type alias ModalOptions msg =
    { attributes : List (Html.Attribute msg)
    , bodyOptions : BodyOptions msg
    , class : Maybe (Html.Attribute msg)
    , classList : Maybe (Html.Attribute msg)
    , events : List (Html.Attribute msg)
    , footerOptions : FooterOptions msg
    , headerOptions : HeaderOptions msg
    , id : Maybe (Html.Attribute msg)
    , overlayOptions : OverlayOptions msg
    , styles : List (Html.Attribute msg)
    , title : Maybe (Html.Attribute msg)
    }


initialModalOptions : msg -> ModalOptions msg
initialModalOptions closeEvent =
    { attributes = []
    , bodyOptions = initialBodyOptions
    , class = Nothing
    , classList = Nothing
    , events = []
    , footerOptions = initialFooterOptions
    , headerOptions = initialHeaderOptions closeEvent
    , id = Nothing
    , overlayOptions = initialOverlayOptions
    , styles = []
    , title = Nothing
    }


type alias BodyOptions msg =
    { attributes : List (Html.Attribute msg)
    , class : Maybe (Html.Attribute msg)
    , classList : Maybe (Html.Attribute msg)
    , content : List (Html msg)
    , styles : List (Html.Attribute msg)
    }


initialBodyOptions : BodyOptions msg
initialBodyOptions =
    { attributes = []
    , class = Nothing
    , content = []
    , classList = Nothing
    , styles = []
    }


type alias HeaderOptions msg =
    { attributes : List (Html.Attribute msg)
    , class : Maybe (Html.Attribute msg)
    , classList : Maybe (Html.Attribute msg)
    , content : List (Html msg)
    , styles : List (Html.Attribute msg)
    }


initialHeaderOptions : msg -> HeaderOptions msg
initialHeaderOptions closeEvent =
    { attributes = []
    , class = Nothing
    , classList = Nothing
    , content = [ headerCloseButton closeEvent ]
    , styles = []
    }


type alias OverlayOptions msg =
    { attributes : List (Html.Attribute msg)
    , class : Maybe (Html.Attribute msg)
    , classList : Maybe (Html.Attribute msg)
    , events : List (Html.Attribute msg)
    , styles : List (Html.Attribute msg)
    }


initialOverlayOptions : OverlayOptions msg
initialOverlayOptions =
    { class = Nothing
    , classList = Nothing
    , attributes = []
    , events = []
    , styles = []
    }


type alias FooterOptions msg =
    { attributes : List (Html.Attribute msg)
    , class : Maybe (Html.Attribute msg)
    , classList : Maybe (Html.Attribute msg)
    , content : List (Html msg)
    , styles : List (Html.Attribute msg)
    }


initialFooterOptions : FooterOptions msg
initialFooterOptions =
    { class = Nothing
    , classList = Nothing
    , attributes = []
    , content = []
    , styles = []
    }


small : Bool -> msg -> Config msg
small initialVisibility closeEvent =
    Config
        { closeEvent = closeEvent
        , options = Options (initialModalOptions closeEvent)
        , size = Small
        , visible = initialVisibility
        }


medium : Bool -> msg -> Config msg
medium initialVisibility closeEvent =
    Config
        { closeEvent = closeEvent
        , options = Options (initialModalOptions closeEvent)
        , size = Medium
        , visible = initialVisibility
        }


large : Bool -> msg -> Config msg
large initialVisibility closeEvent =
    Config
        { closeEvent = closeEvent
        , options = Options (initialModalOptions closeEvent)
        , size = Large
        , visible = initialVisibility
        }


show : Config msg -> Config msg
show (Config modalConfig) =
    { modalConfig
        | visible = True
    }
        |> Config


hide : Config msg -> Config msg
hide (Config modalConfig) =
    { modalConfig
        | visible = False
    }
        |> Config


toggle : Config msg -> Config msg
toggle (Config modalConfig) =
    { modalConfig
        | visible = not modalConfig.visible
    }
        |> Config


deObfuscateModalOptions : Options msg -> ModalOptions msg
deObfuscateModalOptions (Options modalOptions) =
    modalOptions


pickModalOptions : ModalConfig msg -> ModalOptions msg
pickModalOptions =
    .options >> deObfuscateModalOptions


pickOverlayOptions : ModalConfig msg -> OverlayOptions msg
pickOverlayOptions =
    pickModalOptions >> .overlayOptions


render : Config msg -> Html msg
render (Config modalConfig) =
    H.renderIf modalConfig.visible <|
        overlay (.overlayOptions <| pickModalOptions modalConfig)
            [ modal (pickModalOptions modalConfig) modalConfig ]


overlay : OverlayOptions msg -> List (Html msg) -> Html msg
overlay overlayOptions renderedModal =
    Html.div
        (overlayAttributes overlayOptions)
        renderedModal


overlayAttributes : OverlayOptions msg -> List (Html.Attribute msg)
overlayAttributes overlayOptions =
    [ HtmlAttributes.id overlayId
    ]
        |> List.append overlayOptions.attributes
        |> List.append (H.maybeSingleton overlayOptions.class)
        |> List.append (H.maybeSingleton overlayOptions.classList)
        |> List.append [ HtmlAttributes.class "a-overlay" ]
        |> List.append overlayOptions.events
        |> List.append overlayOptions.styles


updateModalOptions : (ModalOptions msg -> ModalOptions msg) -> ModalConfig msg -> ModalConfig msg
updateModalOptions modalOptionsMapper modalConfig =
    { modalConfig | options = Options <| modalOptionsMapper <| pickModalOptions modalConfig }


updateBodyOptions : (BodyOptions msg -> BodyOptions msg) -> ModalOptions msg -> ModalOptions msg
updateBodyOptions contentOptionsMapper modalOptions =
    { modalOptions | bodyOptions = contentOptionsMapper modalOptions.bodyOptions }


updateFooterOptions : (FooterOptions msg -> FooterOptions msg) -> ModalOptions msg -> ModalOptions msg
updateFooterOptions footerOptionsMapper modalOptions =
    { modalOptions | footerOptions = footerOptionsMapper modalOptions.footerOptions }


updateHeaderOptions : (HeaderOptions msg -> HeaderOptions msg) -> ModalOptions msg -> ModalOptions msg
updateHeaderOptions headerOptionsMapper modalOptions =
    { modalOptions | headerOptions = headerOptionsMapper modalOptions.headerOptions }


updateOverlayOptions : (OverlayOptions msg -> OverlayOptions msg) -> ModalOptions msg -> ModalOptions msg
updateOverlayOptions headerOptionsMapper modalOptions =
    { modalOptions | overlayOptions = headerOptionsMapper modalOptions.overlayOptions }


withCloseOnOverlayClick : Config msg -> Config msg
withCloseOnOverlayClick (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (updateOverlayOptions
                (\overlayOptions ->
                    { overlayOptions
                        | events = overlayOptions.events ++ [ onOverlayClick modalConfig.closeEvent ]
                    }
                )
            )
        |> Config


onOverlayClick : msg -> Html.Attribute msg
onOverlayClick =
    InterceptedEvents.onClick (Interceptor.targetWithId overlayId)
        >> InterceptedEvents.withStopPropagation
        >> InterceptedEvents.event


withOverlayClass : String -> Config msg -> Config msg
withOverlayClass class (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (updateOverlayOptions
                (\overlayOptions ->
                    { overlayOptions
                        | class = Just (HtmlAttributes.class class)
                    }
                )
            )
        |> Config


withOverlayClassList : List ( String, Bool ) -> Config msg -> Config msg
withOverlayClassList classList (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (updateOverlayOptions
                (\overlayOptions ->
                    { overlayOptions
                        | classList = Just (HtmlAttributes.classList classList)
                    }
                )
            )
        |> Config


withOverlayAttribute : Html.Attribute msg -> Config msg -> Config msg
withOverlayAttribute attribute (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (updateOverlayOptions
                (\overlayOptions ->
                    { overlayOptions
                        | attributes = overlayOptions.attributes ++ [ attribute ]
                    }
                )
            )
        |> Config



-- Missing some events on overlay


withOverlayStyle : String -> String -> Config msg -> Config msg
withOverlayStyle property value (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (updateOverlayOptions
                (\overlayOptions ->
                    { overlayOptions
                        | styles = overlayOptions.styles ++ [ HtmlAttributes.style property value ]
                    }
                )
            )
        |> Config


modal : ModalOptions msg -> ModalConfig msg -> Html msg
modal modalOptions modalConfig =
    Html.div
        (modalAttributes modalOptions modalConfig)
        [ header modalOptions.headerOptions
        , body modalOptions.bodyOptions
        , footer modalOptions.footerOptions
        ]


modalAttributes : ModalOptions msg -> ModalConfig msg -> List (Html.Attribute msg)
modalAttributes modalOptions modalConfig =
    []
        |> List.append modalOptions.attributes
        |> List.append (H.maybeSingleton modalOptions.class)
        |> List.append (H.maybeSingleton modalOptions.classList)
        |> List.append
            [ HtmlAttributes.classList
                [ ( "o-modal", True )
                , ( "o-modal--small", isSmallSize modalConfig.size )
                , ( "o-modal--medium", isMediumSize modalConfig.size )
                , ( "o-modal--large", isLargeSize modalConfig.size )
                ]
            ]
        |> List.append modalOptions.events
        |> List.append (H.maybeSingleton modalOptions.id)
        |> List.append modalOptions.styles
        |> List.append (H.maybeSingleton modalOptions.title)


withAttribute : Html.Attribute msg -> Config msg -> Config msg
withAttribute attribute (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (\modalOptions ->
                { modalOptions
                    | attributes = modalOptions.attributes ++ [ attribute ]
                }
            )
        |> Config


withStyle : String -> String -> Config msg -> Config msg
withStyle property value (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (\modalOptions ->
                { modalOptions
                    | styles = modalOptions.styles ++ [ HtmlAttributes.style property value ]
                }
            )
        |> Config


withClass : String -> Config msg -> Config msg
withClass class (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (\modalOptions ->
                { modalOptions
                    | class = Just (HtmlAttributes.class class)
                }
            )
        |> Config


withClassList : List ( String, Bool ) -> Config msg -> Config msg
withClassList classList (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (\modalOptions ->
                { modalOptions
                    | classList = Just (HtmlAttributes.classList classList)
                }
            )
        |> Config


withId : String -> Config msg -> Config msg
withId id (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (\modalOptions ->
                { modalOptions
                    | id = Just (HtmlAttributes.id id)
                }
            )
        |> Config


withTitleAttribute : String -> Config msg -> Config msg
withTitleAttribute title (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (\modalOptions ->
                { modalOptions
                    | title = Just (HtmlAttributes.title title)
                }
            )
        |> Config


header : HeaderOptions msg -> Html msg
header headerOptions =
    Html.div
        (headerAttributes headerOptions)
        headerOptions.content


headerAttributes : HeaderOptions msg -> List (Html.Attribute msg)
headerAttributes headerOptions =
    []
        |> List.append headerOptions.attributes
        |> List.append (H.maybeSingleton headerOptions.class)
        |> List.append (H.maybeSingleton headerOptions.classList)
        |> List.append [ HtmlAttributes.class "o-modal__header" ]
        |> List.append headerOptions.styles


withHeaderAttribute : Html.Attribute msg -> Config msg -> Config msg
withHeaderAttribute headerAttribute (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (updateHeaderOptions
                (\headerOptions ->
                    { headerOptions
                        | attributes = headerOptions.attributes ++ [ headerAttribute ]
                    }
                )
            )
        |> Config


withHeaderClass : String -> Config msg -> Config msg
withHeaderClass class (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (updateHeaderOptions
                (\headerOptions ->
                    { headerOptions
                        | class = Just (HtmlAttributes.class class)
                    }
                )
            )
        |> Config


withHeaderClassList : List ( String, Bool ) -> Config msg -> Config msg
withHeaderClassList classList (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (updateHeaderOptions
                (\headerOptions ->
                    { headerOptions
                        | classList = Just (HtmlAttributes.classList classList)
                    }
                )
            )
        |> Config


withHeaderTitle : String -> Config msg -> Config msg
withHeaderTitle title (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (updateHeaderOptions
                (\headerOptions ->
                    { headerOptions
                        | content =
                            [ headerTitle title
                            , headerCloseButton modalConfig.closeEvent
                            ]
                    }
                )
            )
        |> Config


withHeaderTitleOnly : String -> Config msg -> Config msg
withHeaderTitleOnly title (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (updateHeaderOptions
                (\headerOptions ->
                    { headerOptions
                        | content =
                            [ headerTitle title
                            ]
                    }
                )
            )
        |> Config


withHeaderContent : List (Html msg) -> Config msg -> Config msg
withHeaderContent customContent (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (updateHeaderOptions
                (\headerOptions ->
                    { headerOptions
                        | content =
                            customContent ++ [ headerCloseButton modalConfig.closeEvent ]
                    }
                )
            )
        |> Config


withHeaderContentOnly : List (Html msg) -> Config msg -> Config msg
withHeaderContentOnly customContent (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (updateHeaderOptions
                (\headerOptions ->
                    { headerOptions
                        | content = customContent
                    }
                )
            )
        |> Config


withHeaderStyle : String -> String -> Config msg -> Config msg
withHeaderStyle attribute value (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (updateHeaderOptions
                (\headerOptions ->
                    { headerOptions
                        | styles = headerOptions.styles ++ [ HtmlAttributes.style attribute value ]
                    }
                )
            )
        |> Config


headerTitle : String -> Html msg
headerTitle title =
    Html.h3 [ HtmlAttributes.class "o-modal__title" ]
        [ Html.text title ]


body : BodyOptions msg -> Html msg
body bodyOptions =
    Html.div (bodyAttributes bodyOptions)
        bodyOptions.content


bodyAttributes : BodyOptions msg -> List (Html.Attribute msg)
bodyAttributes bodyOptions =
    []
        |> List.append bodyOptions.attributes
        |> List.append (H.maybeSingleton bodyOptions.class)
        |> List.append (H.maybeSingleton bodyOptions.classList)
        |> List.append [ HtmlAttributes.class "o-modal__content" ]
        |> List.append bodyOptions.styles


withBodyAttribute : Html.Attribute msg -> Config msg -> Config msg
withBodyAttribute attribute (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (updateBodyOptions
                (\bodyOptions ->
                    { bodyOptions
                        | attributes =
                            bodyOptions.attributes
                                ++ [ attribute
                                   ]
                    }
                )
            )
        |> Config


withBodyClass : String -> Config msg -> Config msg
withBodyClass class (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (updateBodyOptions
                (\bodyOptions ->
                    { bodyOptions
                        | class = Just (HtmlAttributes.class class)
                    }
                )
            )
        |> Config


withBodyClassList : List ( String, Bool ) -> Config msg -> Config msg
withBodyClassList classList (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (updateBodyOptions
                (\bodyOptions ->
                    { bodyOptions
                        | classList = Just (HtmlAttributes.classList classList)
                    }
                )
            )
        |> Config


withBodyContent : List (Html msg) -> Config msg -> Config msg
withBodyContent content (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (updateBodyOptions
                (\bodyOptions ->
                    { bodyOptions
                        | content = content
                    }
                )
            )
        |> Config


withBodyStyle : String -> String -> Config msg -> Config msg
withBodyStyle attribute value (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (updateBodyOptions
                (\bodyOptions ->
                    { bodyOptions
                        | styles = bodyOptions.styles ++ [ HtmlAttributes.style attribute value ]
                    }
                )
            )
        |> Config


footer : FooterOptions msg -> Html msg
footer footerOptions =
    Html.div
        (footerAttributes footerOptions)
        footerOptions.content


footerAttributes : FooterOptions msg -> List (Html.Attribute msg)
footerAttributes footerOptions =
    []
        |> List.append footerOptions.attributes
        |> List.append (H.maybeSingleton footerOptions.class)
        |> List.append (H.maybeSingleton footerOptions.classList)
        |> List.append [ HtmlAttributes.class "o-modal__footer" ]
        |> List.append footerOptions.styles


withFooterAttribute : Html.Attribute msg -> Config msg -> Config msg
withFooterAttribute attribute (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (updateFooterOptions
                (\footerOptions ->
                    { footerOptions
                        | attributes =
                            footerOptions.attributes
                                ++ [ attribute
                                   ]
                    }
                )
            )
        |> Config


withFooterClass : String -> Config msg -> Config msg
withFooterClass class (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (updateFooterOptions
                (\footerOptions ->
                    { footerOptions
                        | class = Just (HtmlAttributes.class class)
                    }
                )
            )
        |> Config


withFooterClassList : List ( String, Bool ) -> Config msg -> Config msg
withFooterClassList classList (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (updateFooterOptions
                (\footerOptions ->
                    { footerOptions
                        | classList = Just (HtmlAttributes.classList classList)
                    }
                )
            )
        |> Config


withFooterContent : List (Html msg) -> Config msg -> Config msg
withFooterContent content (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (updateFooterOptions
                (\footerOptions ->
                    { footerOptions
                        | content = content
                    }
                )
            )
        |> Config


withFooterStyle : String -> String -> Config msg -> Config msg
withFooterStyle attribute value (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (updateFooterOptions
                (\footerOptions ->
                    { footerOptions
                        | styles = footerOptions.styles ++ [ HtmlAttributes.style attribute value ]
                    }
                )
            )
        |> Config


{-| Internal. Icon for closing modal
-}
headerCloseButton : msg -> Html msg
headerCloseButton closeEvent =
    Html.i
        [ HtmlAttributes.class "a-icon a-icon-close o-modal__close"
        , HtmlAttributes.id headerCloseButtonId
        , onCloseButtonClick closeEvent
        ]
        []


headerCloseButtonId : String
headerCloseButtonId =
    "modalHeaderCloseButton"


onCloseButtonClick : msg -> Html.Attribute msg
onCloseButtonClick =
    InterceptedEvents.onClick (Interceptor.targetWithId headerCloseButtonId)
        >> InterceptedEvents.withStopPropagation
        >> InterceptedEvents.event


overlayId : String
overlayId =
    "modalOverlay"
