module Prima.Pyxis.Modal exposing
    ( Config
    , small, medium, large, smallAlt, mediumAlt, largeAlt
    , render
    , hide, show, toggle
    , withAttribute, withClass, withClassList, withId, withStyle, withTitleAttribute
    , withCloseOnOverlayClick, withOverlayStyle, withOverlayAttribute, withOverlayClass, withOverlayClassList
    , withHeaderAttribute, withHeaderClass, withHeaderClassList, withHeaderContent, withHeaderContentOnly, withHeaderStyle, withHeaderTitle, withHeaderTitleOnly
    , withBodyAttribute, withBodyClass, withBodyClassList, withBodyContent, withBodyStyle
    , withFooterAttribute, withFooterClass, withFooterClassList, withFooterContent, withFooterStyle
    )

{-|


## Configuration

@docs Config


## Configuration Methods

@docs small, medium, large, smallAlt, mediumAlt, largeAlt


## Rendering

@docs render


## Methods

@docs hide, show, toggle


## Options

@docs withAttribute, withClass, withClassList, withId, withStyle, withTitleAttribute


## Overlay Options

@docs withCloseOnOverlayClick, withOverlayStyle, withOverlayAttribute, withOverlayClass, withOverlayClassList


## Header Options

@docs withHeaderAttribute, withHeaderClass, withHeaderClassList, withHeaderContent, withHeaderContentOnly, withHeaderStyle, withHeaderTitle, withHeaderTitleOnly


## Body Options

@docs withBodyAttribute, withBodyClass, withBodyClassList, withBodyContent, withBodyStyle


## Footer Options

@docs withFooterAttribute, withFooterClass, withFooterClassList, withFooterContent, withFooterStyle

-}

import Html exposing (Html)
import Html.Attributes as HtmlAttributes
import Prima.Pyxis.Commons.InterceptedEvents as InterceptedEvents
import Prima.Pyxis.Commons.Interceptor as Interceptor
import Prima.Pyxis.Helpers as H


{-| Represent the configuration of a `Modal`.
This type can't be created directly and is Opaque.
You must use Configuration constructors instead
-}
type Config msg
    = Config (ModalConfig msg)


{-| Internal.
Represent the Modal configuration record
-}
type alias ModalConfig msg =
    { closeEvent : msg
    , options : Options msg
    , size : Size
    , kind : Kind
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


type Kind
    = Light
    | Dark


isLightKind : Kind -> Bool
isLightKind =
    (==) Light


isDarkKind : Kind -> Bool
isDarkKind =
    (==) Dark


{-| Internal.
Opaque ModalOptions constructor
-}
type Options msg
    = Options (ModalOptions msg)


{-| Internal.
Represents the optional configurations of a Modal
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


{-| Internal.
modal options at construction instants
-}
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


{-| Internal.
Options specific for modal body section (content in css context)
-}
type alias BodyOptions msg =
    { attributes : List (Html.Attribute msg)
    , class : Maybe (Html.Attribute msg)
    , classList : Maybe (Html.Attribute msg)
    , content : List (Html msg)
    , styles : List (Html.Attribute msg)
    }


{-| Internal.
body options at construction instants
-}
initialBodyOptions : BodyOptions msg
initialBodyOptions =
    { attributes = []
    , class = Nothing
    , content = []
    , classList = Nothing
    , styles = []
    }


{-| Internal.
Options specific for modal header section
-}
type alias HeaderOptions msg =
    { attributes : List (Html.Attribute msg)
    , class : Maybe (Html.Attribute msg)
    , classList : Maybe (Html.Attribute msg)
    , content : List (Html msg)
    , styles : List (Html.Attribute msg)
    }


{-| Internal.
header options at construction instants
-}
initialHeaderOptions : msg -> HeaderOptions msg
initialHeaderOptions closeEvent =
    { attributes = []
    , class = Nothing
    , classList = Nothing
    , content = [ headerCloseButton closeEvent ]
    , styles = []
    }


{-| Internal.
Options specific for modal overlay section
-}
type alias OverlayOptions msg =
    { attributes : List (Html.Attribute msg)
    , class : Maybe (Html.Attribute msg)
    , classList : Maybe (Html.Attribute msg)
    , events : List (Html.Attribute msg)
    , styles : List (Html.Attribute msg)
    }


{-| Internal.
overlay options at construction instants
-}
initialOverlayOptions : OverlayOptions msg
initialOverlayOptions =
    { class = Nothing
    , classList = Nothing
    , attributes = []
    , events = []
    , styles = []
    }


{-| Internal.
Options specific for modal footer section
-}
type alias FooterOptions msg =
    { attributes : List (Html.Attribute msg)
    , class : Maybe (Html.Attribute msg)
    , classList : Maybe (Html.Attribute msg)
    , content : List (Html msg)
    , styles : List (Html.Attribute msg)
    }


{-| Internal.
body options at construction instants
-}
initialFooterOptions : FooterOptions msg
initialFooterOptions =
    { class = Nothing
    , classList = Nothing
    , attributes = []
    , content = []
    , styles = []
    }


{-| Small size modal constructor.
Modal by default is printed with a close button on header
Requires initial visibility state, and the event that should be emitted
when user interacts with close button


## eg.

    --
    type Msg
        = HideYourModal

    type alias Model =
        { field1 : FieldType
        , isModalVisible : Bool
        }
    ...
    -- Somewhere in your views

    yourModal : Model -> Html Msg
    yourModal { isModalVisible } =
        Modal.small isModalVisible HideYourModal
            |> Modal.render

-}
small : Bool -> msg -> Config msg
small initialVisibility closeEvent =
    Config
        { closeEvent = closeEvent
        , options = Options (initialModalOptions closeEvent)
        , size = Small
        , kind = Light
        , visible = initialVisibility
        }


{-| Small size modal constructor with Dark style.
-}
smallAlt : Bool -> msg -> Config msg
smallAlt initialVisibility closeEvent =
    Config
        { closeEvent = closeEvent
        , options = Options (initialModalOptions closeEvent)
        , size = Small
        , kind = Dark
        , visible = initialVisibility
        }


{-| Medium modal configuration constructor.
Modal by default is printed with a close button on header
Requires initial visibility state, and the event that should be emitted
when user interacts with close button


## eg.

    --
    type Msg
        = HideYourModal

    type alias Model =
        { field1 : FieldType
        , isModalVisible : Bool
        }
    ...
    -- Somewhere in your views

    yourModal : Model -> Html Msg
    yourModal { isModalVisible } =
        Modal.medium isModalVisible HideYourModal
            |> Modal.render

-}
medium : Bool -> msg -> Config msg
medium initialVisibility closeEvent =
    Config
        { closeEvent = closeEvent
        , options = Options (initialModalOptions closeEvent)
        , size = Medium
        , kind = Light
        , visible = initialVisibility
        }


{-| Medium size modal constructor with Dark style.
-}
mediumAlt : Bool -> msg -> Config msg
mediumAlt initialVisibility closeEvent =
    Config
        { closeEvent = closeEvent
        , options = Options (initialModalOptions closeEvent)
        , size = Medium
        , kind = Dark
        , visible = initialVisibility
        }


{-| Large modal configuration constructor.
Modal by default is printed with a close button on header
Requires initial visibility state, and the event that should be emitted
when user interacts with close button


## eg.

    --
    type Msg
        = HideYourModal

    type alias Model =
        { field1 : FieldType
        , isModalVisible : Bool
        }
    ...
    -- Somewhere in your views

    yourModal : Model -> Html Msg
    yourModal { isModalVisible } =
        Modal.large isModalVisible HideYourModal
            |> Modal.render

-}
large : Bool -> msg -> Config msg
large initialVisibility closeEvent =
    Config
        { closeEvent = closeEvent
        , options = Options (initialModalOptions closeEvent)
        , size = Large
        , kind = Light
        , visible = initialVisibility
        }


{-| Large size modal constructor with Dark style.
-}
largeAlt : Bool -> msg -> Config msg
largeAlt initialVisibility closeEvent =
    Config
        { closeEvent = closeEvent
        , options = Options (initialModalOptions closeEvent)
        , size = Large
        , kind = Dark
        , visible = initialVisibility
        }


{-| Utility that shows a modal.
If you need to hold modal config in your model you
can avoid visibility state duplication and simply use
this helper in your update to show the modal when you need


## eg.

    --
    type Msg
        = HideYourModal
        | ShowModal

    type alias Model =
        { ...
        , myModal : Modal.Config Msg
        }

    model: Model
    model =
       { ...
       , myModal = Modal.small False HideYourModal
       }
    ...
    -- Somewhere in your views

    yourModal : Model -> Html Msg
    yourModal { myModal } =
        myModal
            |> Modal.render

    -- Somewhere in your update
    case msg of
        ShowModal ->
            model
                |> showModal
                |> withoutCmds
        HideYourModal ->
            model
                |> hideModal
                |> withoutCmds
     ...

     showModal: Model -> Model
     showModal model =
        { model
            | myModal = Modal.show model.myModal
        }

     hideModal: Model -> Model
     hideModal model =
        { model
             | myModal = Modal.hide model.myModal
        }

-}
show : Config msg -> Config msg
show (Config modalConfig) =
    { modalConfig
        | visible = True
    }
        |> Config


{-| Utility that hides a modal.
If you need to hold modal config in your model you
can avoid visibility state duplication and simply use
this helper in your update to hide the modal when you need


## eg.

    --
    type Msg
        = HideYourModal
        | ShowModal

    type alias Model =
        { ...
        , myModal : Modal.Config Msg
        }

    model: Model
    model =
       { ...
       , myModal = Modal.small False HideYourModal
       }
    ...
    -- Somewhere in your views

    yourModal : Model -> Html Msg
    yourModal { myModal } =
        myModal
            |> Modal.render

    -- Somewhere in your update
    case msg of
        ShowModal ->
            model
                |> showModal
                |> withoutCmds
        HideYourModal ->
            model
                |> hideModal
                |> withoutCmds
     ...

     showModal: Model -> Model
     showModal model =
        { model
            | myModal = Modal.show model.myModal
        }

     hideModal: Model -> Model
     hideModal model =
        { model
             | myModal = Modal.hide model.myModal
        }

-}
hide : Config msg -> Config msg
hide (Config modalConfig) =
    { modalConfig
        | visible = False
    }
        |> Config


{-| Utility that toggle modal visibility.
If you need to hold modal config in your model you
can avoid visibility state duplication and simply use
this helper in your update to toggle the modal when you need


## eg.

    --
    type Msg
        = ToggleYourModal

    type alias Model =
        { ...
        , myModal : Modal.Config Msg
        }

    model: Model
    model =
       { ...
       , myModal = Modal.small False HideYourModal
       }
    ...
    -- Somewhere in your views

    yourModal : Model -> Html Msg
    yourModal { myModal } =
        myModal
            |> Modal.render

    -- Somewhere in your update
    case msg of
        ToggleModal ->
            model
                |> toggleModal
                |> withoutCmds
     ...

     toggleModal: Model -> Model
     toggleModal model =
        { model
            | myModal = Modal.toggle model.myModal
        }

-}
toggle : Config msg -> Config msg
toggle (Config modalConfig) =
    { modalConfig
        | visible = not modalConfig.visible
    }
        |> Config


{-| Internal.
extract modal options record
-}
deObfuscateModalOptions : Options msg -> ModalOptions msg
deObfuscateModalOptions (Options modalOptions) =
    modalOptions


{-| Internal.
pick modal options record from modal config
-}
pickModalOptions : ModalConfig msg -> ModalOptions msg
pickModalOptions =
    .options >> deObfuscateModalOptions


{-| Internal.
pick overlay options from modal config
-}
pickOverlayOptions : ModalConfig msg -> OverlayOptions msg
pickOverlayOptions =
    pickModalOptions >> .overlayOptions


{-| Internal.
update modal options
-}
updateModalOptions : (ModalOptions msg -> ModalOptions msg) -> ModalConfig msg -> ModalConfig msg
updateModalOptions modalOptionsMapper modalConfig =
    { modalConfig | options = Options <| modalOptionsMapper <| pickModalOptions modalConfig }


{-| Internal.
update body options
-}
updateBodyOptions : (BodyOptions msg -> BodyOptions msg) -> ModalOptions msg -> ModalOptions msg
updateBodyOptions contentOptionsMapper modalOptions =
    { modalOptions | bodyOptions = contentOptionsMapper modalOptions.bodyOptions }


{-| Internal.
update footer options
-}
updateFooterOptions : (FooterOptions msg -> FooterOptions msg) -> ModalOptions msg -> ModalOptions msg
updateFooterOptions footerOptionsMapper modalOptions =
    { modalOptions | footerOptions = footerOptionsMapper modalOptions.footerOptions }


{-| Internal.
update header options
-}
updateHeaderOptions : (HeaderOptions msg -> HeaderOptions msg) -> ModalOptions msg -> ModalOptions msg
updateHeaderOptions headerOptionsMapper modalOptions =
    { modalOptions | headerOptions = headerOptionsMapper modalOptions.headerOptions }


{-| Internal.
update overlay options
-}
updateOverlayOptions : (OverlayOptions msg -> OverlayOptions msg) -> ModalOptions msg -> ModalOptions msg
updateOverlayOptions headerOptionsMapper modalOptions =
    { modalOptions | overlayOptions = headerOptionsMapper modalOptions.overlayOptions }


{-| Renders the modal config
(note that modal is not rendered until visible
-}
render : Config msg -> Html msg
render (Config modalConfig) =
    H.renderIf modalConfig.visible <|
        overlay modalConfig
            [ modal (pickModalOptions modalConfig) ]


{-| Internal.
renders overlay
-}
overlay : ModalConfig msg -> List (Html msg) -> Html msg
overlay modalConfig renderedModal =
    Html.div
        (overlayAttributes modalConfig)
        renderedModal


{-| Internal.
constructs overlay attribute list from overlay options
-}
overlayAttributes : ModalConfig msg -> List (Html.Attribute msg)
overlayAttributes modalConfig =
    let
        overlayOptions =
            pickOverlayOptions modalConfig
    in
    [ HtmlAttributes.id overlayId
    ]
        |> List.append overlayOptions.attributes
        |> H.maybeCons overlayOptions.class
        |> H.maybeCons overlayOptions.classList
        |> (::)
            (HtmlAttributes.classList
                [ ( "modal", True )
                , ( "modal--small", isSmallSize modalConfig.size )
                , ( "modal--medium", isMediumSize modalConfig.size )
                , ( "modal--large", isLargeSize modalConfig.size )
                , ( "modal--light", isLightKind modalConfig.kind )
                , ( "modal--dark", isDarkKind modalConfig.kind )
                ]
            )
        |> List.append overlayOptions.events
        |> List.append overlayOptions.styles


{-| Modifier
The modal closes if overlay is clicked
-}
withCloseOnOverlayClick : Config msg -> Config msg
withCloseOnOverlayClick (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (updateOverlayOptions
                (\overlayOptions ->
                    { overlayOptions
                        | events = onOverlayClick modalConfig.closeEvent :: overlayOptions.events
                    }
                )
            )
        |> Config


{-| Internal.
Intercepted overlay click
-}
onOverlayClick : msg -> Html.Attribute msg
onOverlayClick =
    InterceptedEvents.onClick (Interceptor.targetWithId overlayId)
        >> InterceptedEvents.withStopPropagation
        >> InterceptedEvents.toHtmlAttribute


{-| Internal.
Overlay id. Is used to intercept overlay events
-}
overlayId : String
overlayId =
    "modalOverlay"


{-| Modifier
Adds class attribute to overlay
-}
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


{-| Modifier
Adds classList attribute to overlay
-}
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


{-| Modifier
Adds a generic attribute to overlay.
If you are planning to add a custom event listener you may
take a look to InterceptedEvents and Interceptor modules to avoid
undesired bubbling and onOverlayClick function in this module.
-}
withOverlayAttribute : Html.Attribute msg -> Config msg -> Config msg
withOverlayAttribute attribute (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (updateOverlayOptions
                (\overlayOptions ->
                    { overlayOptions
                        | attributes = attribute :: overlayOptions.attributes
                    }
                )
            )
        |> Config



-- Missing some events on overlay


{-| Modifier
Adds a style attribute to overlay.
It can be used several times
-}
withOverlayStyle : String -> String -> Config msg -> Config msg
withOverlayStyle property value (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (updateOverlayOptions
                (\overlayOptions ->
                    { overlayOptions
                        | styles = HtmlAttributes.style property value :: overlayOptions.styles
                    }
                )
            )
        |> Config


{-| Internal.
renders modal
-}
modal : ModalOptions msg -> Html msg
modal modalOptions =
    Html.div
        (modalAttributes modalOptions)
        [ header modalOptions.headerOptions
        , body modalOptions.bodyOptions
        , footer modalOptions.footerOptions
        ]


{-| Internal.
Builds modal attribute list
-}
modalAttributes : ModalOptions msg -> List (Html.Attribute msg)
modalAttributes modalOptions =
    []
        |> List.append modalOptions.attributes
        |> H.maybeCons modalOptions.classList
        |> H.maybeCons modalOptions.class
        |> (::) (HtmlAttributes.class "modal__wrapper")
        |> List.append modalOptions.events
        |> H.maybeCons modalOptions.id
        |> List.append modalOptions.styles
        |> H.maybeCons modalOptions.title


{-| Modifier
Adds generic attribute to modal.
It can be used several times
-}
withAttribute : Html.Attribute msg -> Config msg -> Config msg
withAttribute attribute (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (\modalOptions ->
                { modalOptions
                    | attributes = attribute :: modalOptions.attributes
                }
            )
        |> Config


{-| Modifier
Adds style attribute to modal.
It can be used several times
-}
withStyle : String -> String -> Config msg -> Config msg
withStyle property value (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (\modalOptions ->
                { modalOptions
                    | styles = HtmlAttributes.style property value :: modalOptions.styles
                }
            )
        |> Config


{-| Modifier
Adds class attribute to modal.
-}
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


{-| Modifier
Adds classList attribute to modal.
-}
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


{-| Modifier
Adds id attribute to modal.
-}
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


{-| Modifier
Adds title attribute to modal.
-}
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


{-| Internal.
Renders modal header
-}
header : HeaderOptions msg -> Html msg
header headerOptions =
    Html.div
        (headerAttributes headerOptions)
        headerOptions.content


{-| Internal.
Builds modal header attribute list
-}
headerAttributes : HeaderOptions msg -> List (Html.Attribute msg)
headerAttributes headerOptions =
    []
        |> List.append headerOptions.attributes
        |> H.maybeCons headerOptions.classList
        |> H.maybeCons headerOptions.class
        |> (::) (HtmlAttributes.class "modal__header")
        |> List.append headerOptions.styles


{-| Modifier
Adds generic attribute to modal header.
It can be used several times
-}
withHeaderAttribute : Html.Attribute msg -> Config msg -> Config msg
withHeaderAttribute headerAttribute (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (updateHeaderOptions
                (\headerOptions ->
                    { headerOptions
                        | attributes = headerAttribute :: headerOptions.attributes
                    }
                )
            )
        |> Config


{-| Modifier
Adds class attribute to modal header.
-}
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


{-| Modifier
Adds classList attribute to modal header.
-}
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


{-| Modifier
Prints given string in modal title section with close button
-}
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


{-| Modifier
Prints given string in modal title section without close button
-}
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


{-| Modifier
Adds a custom html content in modal header with close button
-}
withHeaderContent : List (Html msg) -> Config msg -> Config msg
withHeaderContent customContent (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (updateHeaderOptions
                (\headerOptions ->
                    { headerOptions
                        | content =
                            headerCloseButton modalConfig.closeEvent :: customContent
                    }
                )
            )
        |> Config


{-| Modifier
Adds a custom html content in modal header without close button
-}
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


{-| Modifier
Adds a style attribute to header.
It can be used several times
-}
withHeaderStyle : String -> String -> Config msg -> Config msg
withHeaderStyle attribute value (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (updateHeaderOptions
                (\headerOptions ->
                    { headerOptions
                        | styles = HtmlAttributes.style attribute value :: headerOptions.styles
                    }
                )
            )
        |> Config


{-| Internal.
Prints predefined modal title in its own markup
-}
headerTitle : String -> Html msg
headerTitle title =
    Html.h3 [ HtmlAttributes.class "modal__header__title" ]
        [ Html.text title ]


{-| Internal.
Renders modal body
-}
body : BodyOptions msg -> Html msg
body bodyOptions =
    Html.div (bodyAttributes bodyOptions)
        bodyOptions.content


{-| Internal.
Consucts modal body attribute list
-}
bodyAttributes : BodyOptions msg -> List (Html.Attribute msg)
bodyAttributes bodyOptions =
    []
        |> List.append bodyOptions.attributes
        |> H.maybeCons bodyOptions.classList
        |> H.maybeCons bodyOptions.class
        |> (::) (HtmlAttributes.class "modal__content")
        |> List.append bodyOptions.styles


{-| Modifier
Adds a generic attribute to modal body.
It can be used several times
-}
withBodyAttribute : Html.Attribute msg -> Config msg -> Config msg
withBodyAttribute attribute (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (updateBodyOptions
                (\bodyOptions ->
                    { bodyOptions
                        | attributes =
                            attribute :: bodyOptions.attributes
                    }
                )
            )
        |> Config


{-| Modifier
Adds a class attribute to modal body.
-}
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


{-| Modifier
Adds a classList attribute to modal body.
-}
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


{-| Modifier
Adds a content to modal body.
-}
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


{-| Modifier
Adds a style attribute to modal body.
It can be used several times
-}
withBodyStyle : String -> String -> Config msg -> Config msg
withBodyStyle attribute value (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (updateBodyOptions
                (\bodyOptions ->
                    { bodyOptions
                        | styles = HtmlAttributes.style attribute value :: bodyOptions.styles
                    }
                )
            )
        |> Config


{-| Internal.
Render footer
-}
footer : FooterOptions msg -> Html msg
footer footerOptions =
    Html.div
        (footerAttributes footerOptions)
        footerOptions.content


{-| Internal.
Builds footer attribute list
-}
footerAttributes : FooterOptions msg -> List (Html.Attribute msg)
footerAttributes footerOptions =
    []
        |> List.append footerOptions.attributes
        |> H.maybeCons footerOptions.classList
        |> H.maybeCons footerOptions.class
        |> (::) (HtmlAttributes.class "modal__footer")
        |> List.append footerOptions.styles


{-| Modifier
Adds a generic attribute to modal footer.
It can be used several times
-}
withFooterAttribute : Html.Attribute msg -> Config msg -> Config msg
withFooterAttribute attribute (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (updateFooterOptions
                (\footerOptions ->
                    { footerOptions
                        | attributes = attribute :: footerOptions.attributes
                    }
                )
            )
        |> Config


{-| Modifier
Adds a class attribute to modal footer.
-}
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


{-| Modifier
Adds classList attribute to modal footer.
-}
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


{-| Modifier
Adds a content to modal footer.
-}
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


{-| Modifier
Adds a style attribute to modal footer.
It can be used several times
-}
withFooterStyle : String -> String -> Config msg -> Config msg
withFooterStyle attribute value (Config modalConfig) =
    modalConfig
        |> updateModalOptions
            (updateFooterOptions
                (\footerOptions ->
                    { footerOptions
                        | styles = HtmlAttributes.style attribute value :: footerOptions.styles
                    }
                )
            )
        |> Config


{-| Internal.
Icon for closing modal
-}
headerCloseButton : msg -> Html msg
headerCloseButton closeEvent =
    Html.i
        [ HtmlAttributes.class "modal__header__close"
        , HtmlAttributes.id headerCloseButtonId
        , onCloseButtonClick closeEvent
        ]
        []


{-| Internal.
Modal X button id
-}
headerCloseButtonId : String
headerCloseButtonId =
    "modalHeaderCloseButton"


{-| Internal.
Intercepted X button click event
-}
onCloseButtonClick : msg -> Html.Attribute msg
onCloseButtonClick =
    InterceptedEvents.onClick
        (Interceptor.targetWithId headerCloseButtonId)
        >> InterceptedEvents.withStopPropagation
        >> InterceptedEvents.toHtmlAttribute
