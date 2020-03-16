module Prima.Pyxis.Container exposing
    ( Config, render
    , row, column, rowFluid, columnFluid
    , withContent
    , changeSizeOnLarge, changeSizeOnMedium, changeSizeOnSmall, changeSizeOnXLarge
    , addStyle, withAccessKey, withAttribute, withClass, withClassList, withContentEditable, withDraggable, withDropZone, withHidden, withId, withTabIndex, withTitle
    , onBlur, onClick, onDoubleClick, onFocus, onMouseEnter, onMouseLeave, onMouseOut, onMouseOver
    )

{-| Create a `Container` by using predefined Html syntax.


## Ready to use

@docs Config, render


## Constructors

@docs row, column, rowFluid, columnFluid


## Modifiers


### Content modifier

@docs withContent


### Size modifiers

@docs changeSizeOnLarge, changeSizeOnMedium, changeSizeOnSmall, changeSizeOnXLarge


### Attribute modifiers

@docs addStyle, withAccessKey, withAttribute, withClass, withClassList, withContentEditable, withDraggable, withDropZone, withHidden, withId, withTabIndex, withTitle


### Events handlers

@docs onBlur, onClick, onDoubleClick, onFocus, onMouseEnter, onMouseLeave, onMouseOut, onMouseOver

-}

import Html exposing (Html, div)
import Html.Attributes as HtmlAttributes
import Html.Events as HtmlEvents
import Prima.Pyxis.Helpers as H


{-| Represent the configuration of a `Container`.
This type can't be created directly and is Opaque.
You must use Configuration constructors instead
-}
type Config msg
    = Config (ContainerConfig msg)


{-| Internal.
Represent the Container configuration record
-}
type alias ContainerConfig msg =
    { flow : FlowType
    , size : Size
    , options : Options msg
    }


{-| Internal.
Represent the Container flow direction. Row or Column
-}
type FlowType
    = DirectionRow
    | DirectionColumn


{-| Internal.
Represent the Container possible size.
Regular is the standard centered container with side empty space.
Fluid always covers 100% of page width.
-}
type Size
    = Regular
    | Fluid


{-| Internal.
Represent the breakpoints on the Container can swap his Size
-}
type BreakPoint
    = Small
    | Medium
    | Large
    | XLarge


{-| Internal.
Represent the Container sizing modifier. A container with a certain Size can swap with the other size on certain breakpoints
-}
type SizeModifier
    = RegularOn BreakPoint
    | FluidOn BreakPoint


{-| Internal.
Opaque OptionsRecord constructor
-}
type Options msg
    = Options (ContainerOptions msg)


{-| Internal.
Represents the optional configurations of a Container
-}
type alias ContainerOptions msg =
    { attributes : List (Html.Attribute msg)
    , accessKey : Maybe (Html.Attribute msg)
    , class : Maybe (Html.Attribute msg)
    , classList : Maybe (Html.Attribute msg)
    , content : List (Html msg)
    , contentEditable : Maybe (Html.Attribute msg)
    , draggable : Maybe (Html.Attribute msg)
    , dropZone : Maybe (Html.Attribute msg)
    , events : List (Html.Attribute msg)
    , hidden : Maybe (Html.Attribute msg)
    , id : Maybe (Html.Attribute msg)
    , tabIndex : Maybe (Html.Attribute msg)
    , title : Maybe (Html.Attribute msg)
    , sizeModifiers : List SizeModifier
    , styles : List (Html.Attribute msg)
    }


{-| Internal.
Represents the initial state of the list of customizations for the `Container` component.
-}
defaultOptions : Options msg
defaultOptions =
    Options
        { attributes = []
        , accessKey = Nothing
        , class = Nothing
        , classList = Nothing
        , content = []
        , contentEditable = Nothing
        , draggable = Nothing
        , dropZone = Nothing
        , events = []
        , hidden = Nothing
        , id = Nothing
        , tabIndex = Nothing
        , title = Nothing
        , sizeModifiers = []
        , styles = []
        }


deObfuscateContainerConfig : Config msg -> ContainerConfig msg
deObfuscateContainerConfig (Config configurationRecord) =
    configurationRecord


deObfuscateContainerOptions : Options msg -> ContainerOptions msg
deObfuscateContainerOptions (Options containerOptions) =
    containerOptions


pickContainerOptions : Config msg -> ContainerOptions msg
pickContainerOptions =
    deObfuscateContainerConfig
        >> .options
        >> deObfuscateContainerOptions


render : Config msg -> Html msg
render config =
    container (pickContainerOptions config) (deObfuscateContainerConfig config)


{-| Constructs an empty container with regular sizing and direction row
-}
row : Config msg
row =
    Config
        { flow = DirectionRow
        , size = Regular
        , options = defaultOptions
        }


{-| Constructs an empty container with regular sizing and direction column
-}
column : Config msg
column =
    Config
        { flow = DirectionColumn
        , size = Regular
        , options = defaultOptions
        }


{-| Constructs an empty container with fluid sizing and direction row
-}
rowFluid : Config msg
rowFluid =
    Config
        { flow = DirectionRow
        , size = Fluid
        , options = defaultOptions
        }


{-| Constructs an empty container with fluid sizing and direction column
-}
columnFluid : Config msg
columnFluid =
    Config
        { flow = DirectionColumn
        , size = Fluid
        , options = defaultOptions
        }


{-| Internal.
This is the container core-rendering function
-}
container : ContainerOptions msg -> ContainerConfig msg -> Html msg
container options configuration =
    div
        ([ containerSizeToClass configuration.size
         , flowTypeToClass configuration.flow
         ]
            ++ optionalContainerHtmlAttributes options
        )
        options.content


{-| Internal.
Helper class for container function, compute all optionals Html Attributes
-}
optionalContainerHtmlAttributes : ContainerOptions msg -> List (Html.Attribute msg)
optionalContainerHtmlAttributes options =
    []
        |> List.append (H.maybeSingleton options.accessKey)
        |> List.append (H.maybeSingleton options.class)
        |> List.append (H.maybeSingleton options.classList)
        |> List.append (H.maybeSingleton options.contentEditable)
        |> List.append options.attributes
        |> List.append (H.maybeSingleton options.draggable)
        |> List.append (H.maybeSingleton options.dropZone)
        |> List.append options.events
        |> List.append (H.maybeSingleton options.hidden)
        |> List.append (H.maybeSingleton options.id)
        |> List.append (H.maybeSingleton options.tabIndex)
        |> List.append (H.maybeSingleton options.title)
        |> List.append (List.map sizeModifierToClass options.sizeModifiers)
        |> List.append options.styles


{-| Internal.
Converts FlowType to helper class
-}
flowTypeToClass : FlowType -> Html.Attribute msg
flowTypeToClass flowType =
    case flowType of
        DirectionRow ->
            HtmlAttributes.class "directionRow"

        DirectionColumn ->
            HtmlAttributes.class "directionColumn"


{-| Internal.
Converts Size to class
-}
containerSizeToClass : Size -> Html.Attribute msg
containerSizeToClass containerSize =
    case containerSize of
        Regular ->
            HtmlAttributes.class "a-container"

        Fluid ->
            HtmlAttributes.class "a-containerFluid"


{-| Internal.
Converts SizeModifier to class
-}
sizeModifierToClass : SizeModifier -> Html.Attribute msg
sizeModifierToClass sizeModifier =
    case sizeModifier of
        RegularOn breakPoint ->
            HtmlAttributes.class <| (++) "a-containerOnBp" <| breakPointToClassSuffix breakPoint

        FluidOn breakPoint ->
            HtmlAttributes.class <| (++) "a-containerFluidOnBp" <| breakPointToClassSuffix breakPoint


{-| Internal.
Converts breakpoint to a size suffix, used by \`sizeModifierToClass
-}
breakPointToClassSuffix : BreakPoint -> String
breakPointToClassSuffix breakPoint =
    case breakPoint of
        Small ->
            "Small"

        Medium ->
            "Medium"

        Large ->
            "Large"

        XLarge ->
            "Xlarge"


{-| Internal.
Helper function to update OptionsRecord of a Container Config
-}
updateOptionsRecord : ContainerOptions msg -> Config msg -> Config msg
updateOptionsRecord containerOptions config =
    let
        containerConfig =
            deObfuscateContainerConfig config
    in
    Config { containerConfig | options = Options containerOptions }


{-| Configuration modifier. Adds withAccessKey attribute on the container
-}
withAccessKey : Char -> Config msg -> Config msg
withAccessKey key config =
    let
        containerConfig =
            pickContainerOptions config
    in
    updateOptionsRecord
        { containerConfig
            | accessKey = Just <| HtmlAttributes.accesskey key
        }
        config


{-| Configuration modifier. Adds class attribute on the container
-}
withClass : String -> Config (Options msg) -> Config (Options msg)
withClass class config =
    let
        containerConfig =
            pickContainerOptions config
    in
    updateOptionsRecord
        { containerConfig
            | class = Just <| HtmlAttributes.class class
        }
        config


{-| Configuration modifier. Adds classList attribute on the container
-}
withClassList : List ( String, Bool ) -> Config (Options msg) -> Config (Options msg)
withClassList classList config =
    let
        containerOptions =
            pickContainerOptions config
    in
    updateOptionsRecord
        { containerOptions
            | classList = Just <| HtmlAttributes.classList classList
        }
        config


{-| Adds a child content in your container

    --

    import Prima.Pyxis.Container as Container

    myFancyContainer: Html Msg
    myFancyContainer =
        Container.row
        |> withContent
            [ p [][ text "Some fancy text in your row container]
            , img [ src "my/fancy/image.png" ]
            ]
        |> Container.render

-}
withContent : List (Html msg) -> Config msg -> Config msg
withContent content config =
    let
        containerOptions =
            pickContainerOptions config
    in
    updateOptionsRecord
        { containerOptions
            | content = content
        }
        config


{-| Configuration modifier. Adds contenteditable attribute on the container
-}
withContentEditable : Bool -> Config msg -> Config msg
withContentEditable isEditable config =
    let
        containerOptions =
            pickContainerOptions config
    in
    updateOptionsRecord
        { containerOptions
            | contentEditable = Just <| HtmlAttributes.contenteditable isEditable
        }
        config


{-| Configuration modifier. Adds hidden attribute on the container
-}
withHidden : Bool -> Config msg -> Config msg
withHidden isHidden config =
    let
        containerOptions =
            pickContainerOptions config
    in
    updateOptionsRecord
        { containerOptions
            | hidden = Just <| HtmlAttributes.hidden isHidden
        }
        config


{-| Configuration modifier. Adds id attribute on the container
-}
withId : String -> Config msg -> Config msg
withId id config =
    let
        containerOptions =
            pickContainerOptions config
    in
    updateOptionsRecord
        { containerOptions
            | id = Just <| HtmlAttributes.id id
        }
        config


{-| Configuration modifier. Adds tab-index attribute on the container
-}
withTabIndex : Int -> Config msg -> Config msg
withTabIndex index config =
    let
        containerOptions =
            pickContainerOptions config
    in
    updateOptionsRecord
        { containerOptions
            | tabIndex = Just <| HtmlAttributes.tabindex index
        }
        config


{-| Configuration modifier. Adds title attribute on the container
-}
withTitle : String -> Config msg -> Config msg
withTitle title config =
    let
        containerOptions =
            pickContainerOptions config
    in
    updateOptionsRecord
        { containerOptions
            | title = Just <| HtmlAttributes.title title
        }
        config


{-| Configuration modifier. Adds draggable attribute on the container
-}
withDraggable : String -> Config msg -> Config msg
withDraggable draggable config =
    let
        containerOptions =
            pickContainerOptions config
    in
    updateOptionsRecord
        { containerOptions
            | draggable = Just <| HtmlAttributes.draggable draggable
        }
        config


{-| Configuration modifier. Adds a generic attribute on the container.
You shouldn't use this if is not strictly necessary
-}
withAttribute : Html.Attribute msg -> Config msg -> Config msg
withAttribute customAttribute config =
    let
        containerOptions =
            pickContainerOptions config
    in
    updateOptionsRecord
        { containerOptions
            | attributes = List.append containerOptions.attributes [ customAttribute ]
        }
        config


{-| Configuration modifier. Adds dropzone attribute on the container
-}
withDropZone : String -> Config msg -> Config msg
withDropZone dropZone config =
    let
        containerOptions =
            pickContainerOptions config
    in
    updateOptionsRecord
        { containerOptions
            | dropZone = Just <| HtmlAttributes.dropzone dropZone
        }
        config


{-| Configuration modifier. Adds style attribute on the container (it can be used multiple times)
-}
addStyle : String -> String -> Config msg -> Config msg
addStyle prop value config =
    let
        containerOptions =
            pickContainerOptions config
    in
    updateOptionsRecord
        { containerOptions
            | styles = List.append containerOptions.styles [ HtmlAttributes.style prop value ]
        }
        config


{-| Configuration modifier. Swap between Regular or Fluid sizing on Small breakpoint
-}
changeSizeOnSmall : Config msg -> Config msg
changeSizeOnSmall config =
    changeSizeOnBreakPoint Small config


{-| Configuration modifier. Swap between Regular or Fluid sizing on Medium breakpoint
-}
changeSizeOnMedium : Config msg -> Config msg
changeSizeOnMedium config =
    changeSizeOnBreakPoint Medium config


{-| Configuration modifier. Swap between Regular or Fluid sizing on Large breakpoint
-}
changeSizeOnLarge : Config msg -> Config msg
changeSizeOnLarge config =
    changeSizeOnBreakPoint Large config


{-| Configuration modifier. Swap between Regular or Fluid sizing on XLarge breakpoint
-}
changeSizeOnXLarge : Config msg -> Config msg
changeSizeOnXLarge config =
    changeSizeOnBreakPoint XLarge config


{-| Internal.
Generic core function for `changeSizeOn<Breakpoint>` modifiers
-}
changeSizeOnBreakPoint : BreakPoint -> Config msg -> Config msg
changeSizeOnBreakPoint breakPoint config =
    let
        containerConfig =
            deObfuscateContainerConfig config
    in
    case containerConfig.size of
        Regular ->
            addSizeModifier (FluidOn breakPoint) config

        Fluid ->
            addSizeModifier (RegularOn breakPoint) config


{-| Internal.
Generic core function for `changeSizeOnBreakPoint` that adds computed SizeModifier to Container config
-}
addSizeModifier : SizeModifier -> Config msg -> Config msg
addSizeModifier modifier config =
    let
        containerConfig =
            pickContainerOptions config
    in
    updateOptionsRecord
        { containerConfig
            | sizeModifiers = containerConfig.sizeModifiers ++ [ modifier ]
        }
        config


{-| Configuration modifier. Adds onClick event listener on Container
-}
onClick : msg -> Config msg -> Config msg
onClick msg =
    addOptionalEvent (HtmlEvents.onClick msg)


{-| Configuration modifier. Adds onDoubleClick event listener on Container
-}
onDoubleClick : msg -> Config msg -> Config msg
onDoubleClick msg =
    addOptionalEvent (HtmlEvents.onDoubleClick msg)


{-| Configuration modifier. Adds onMouseEnter event listener on Container
-}
onMouseEnter : msg -> Config msg -> Config msg
onMouseEnter msg =
    addOptionalEvent (HtmlEvents.onMouseEnter msg)


{-| Configuration modifier. Adds onMouseLeave event listener on Container
-}
onMouseLeave : msg -> Config msg -> Config msg
onMouseLeave msg =
    addOptionalEvent (HtmlEvents.onMouseLeave msg)


{-| Configuration modifier. Adds onMouseOver event listener on Container
-}
onMouseOver : msg -> Config msg -> Config msg
onMouseOver msg =
    addOptionalEvent (HtmlEvents.onMouseOver msg)


{-| Configuration modifier. Adds onMouseOut event listener on Container
-}
onMouseOut : msg -> Config msg -> Config msg
onMouseOut msg =
    addOptionalEvent (HtmlEvents.onMouseOut msg)


{-| Configuration modifier. Adds onBlur event listener on Container
-}
onBlur : msg -> Config msg -> Config msg
onBlur msg =
    addOptionalEvent (HtmlEvents.onBlur msg)


{-| Configuration modifier. Adds onFocus event listener on Container
-}
onFocus : msg -> Config msg -> Config msg
onFocus msg =
    addOptionalEvent (HtmlEvents.onFocus msg)


{-| Internal.
Core function for `on<Event>` that adds the event to config events list
-}
addOptionalEvent : Html.Attribute msg -> Config msg -> Config msg
addOptionalEvent event config =
    let
        containerConfig =
            pickContainerOptions config
    in
    updateOptionsRecord
        { containerConfig
            | events = containerConfig.events ++ [ event ]
        }
        config
