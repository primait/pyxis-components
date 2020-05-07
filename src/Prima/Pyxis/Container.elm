module Prima.Pyxis.Container exposing
    ( Config
    , row, column, rowFluid, columnFluid
    , render
    , withAccessKey, withAttribute, withChangeSizeOnLarge, withChangeSizeOnMedium, withChangeSizeOnSmall, withChangeSizeOnXLarge, withClass, withClassList, withContent, withContentEditable, withDraggable, withDropZone, withHidden, withId, withStyle, withTabIndex, withTitle
    , withOnBlur, withOnClick, withOnDoubleClick, withOnFocus, withOnMouseEnter, withOnMouseLeave, withOnMouseOut, withOnMouseOver
    )

{-|


## Configuration

@docs Config


## Configuration Methods

@docs row, column, rowFluid, columnFluid


## Rendering

@docs render


## Options

@docs withAccessKey, withAttribute, withChangeSizeOnLarge, withChangeSizeOnMedium, withChangeSizeOnSmall, withChangeSizeOnXLarge, withClass, withClassList, withContent, withContentEditable, withDraggable, withDropZone, withHidden, withId, withStyle, withTabIndex, withTitle


## Event Options

@docs withOnBlur, withOnClick, withOnDoubleClick, withOnFocus, withOnMouseEnter, withOnMouseLeave, withOnMouseOut, withOnMouseOver

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
Medium is the standard centered container with side empty space.
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
    = MediumOn BreakPoint
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


{-| Renders the `Container`.
-}
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
        |> H.maybeCons options.accessKey
        |> H.maybeCons options.classList
        |> H.maybeCons options.class
        |> H.maybeCons options.contentEditable
        |> List.append options.attributes
        |> H.maybeCons options.draggable
        |> H.maybeCons options.dropZone
        |> List.append options.events
        |> H.maybeCons options.hidden
        |> H.maybeCons options.id
        |> H.maybeCons options.tabIndex
        |> H.maybeCons options.title
        |> List.append (List.map sizeModifierToClass options.sizeModifiers)
        |> List.append options.styles


{-| Internal.
Converts FlowType to helper class
-}
flowTypeToClass : FlowType -> Html.Attribute msg
flowTypeToClass flowType =
    case flowType of
        DirectionRow ->
            HtmlAttributes.class "direction-row"

        DirectionColumn ->
            HtmlAttributes.class "direction-column"


{-| Internal.
Converts Size to class
-}
containerSizeToClass : Size -> Html.Attribute msg
containerSizeToClass containerSize =
    case containerSize of
        Regular ->
            HtmlAttributes.class "container"

        Fluid ->
            HtmlAttributes.class "container-fluid"


{-| Internal.
Converts SizeModifier to class
-}
sizeModifierToClass : SizeModifier -> Html.Attribute msg
sizeModifierToClass sizeModifier =
    case sizeModifier of
        MediumOn breakPoint ->
            HtmlAttributes.class <| (++) "container--on-bp-" <| breakPointToClassSuffix breakPoint

        FluidOn breakPoint ->
            HtmlAttributes.class <| (++) "container-fluid--on-bp-" <| breakPointToClassSuffix breakPoint


{-| Internal.
Converts breakpoint to a size suffix, used by \`sizeModifierToClass
-}
breakPointToClassSuffix : BreakPoint -> String
breakPointToClassSuffix breakPoint =
    case breakPoint of
        Small ->
            "small"

        Medium ->
            "medium"

        Large ->
            "large"

        XLarge ->
            "xlarge"


{-| Internal.
Helper function to update OptionsRecord of a Container Config
-}
updateOptionsRecord : (ContainerOptions msg -> ContainerOptions msg) -> Config msg -> Config msg
updateOptionsRecord containerOptionsMapper config =
    let
        containerConfig =
            deObfuscateContainerConfig config
    in
    Config { containerConfig | options = Options (containerOptionsMapper <| pickContainerOptions config) }


{-| Configuration modifier. Adds withAccessKey attribute on the container
-}
withAccessKey : Char -> Config msg -> Config msg
withAccessKey key config =
    updateOptionsRecord
        (\containerOptions ->
            { containerOptions
                | accessKey = Just <| HtmlAttributes.accesskey key
            }
        )
        config


{-| Configuration modifier. Adds class attribute on the container
-}
withClass : String -> Config msg -> Config msg
withClass class config =
    updateOptionsRecord
        (\containerOptions ->
            { containerOptions
                | class = Just <| HtmlAttributes.class class
            }
        )
        config


{-| Configuration modifier. Adds classList attribute on the container
-}
withClassList : List ( String, Bool ) -> Config msg -> Config msg
withClassList classList config =
    updateOptionsRecord
        (\containerOptions ->
            { containerOptions
                | classList = Just <| HtmlAttributes.classList classList
            }
        )
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
    updateOptionsRecord
        (\containerOptions ->
            { containerOptions
                | content = content
            }
        )
        config


{-| Configuration modifier.
Adds contenteditable attribute on the container
-}
withContentEditable : Bool -> Config msg -> Config msg
withContentEditable isEditable config =
    updateOptionsRecord
        (\containerOptions ->
            { containerOptions
                | contentEditable = Just <| HtmlAttributes.contenteditable isEditable
            }
        )
        config


{-| Configuration modifier.
Adds hidden attribute on the container
-}
withHidden : Bool -> Config msg -> Config msg
withHidden isHidden config =
    updateOptionsRecord
        (\containerOptions ->
            { containerOptions
                | hidden = Just <| HtmlAttributes.hidden isHidden
            }
        )
        config


{-| Configuration modifier.
Adds id attribute on the container
-}
withId : String -> Config msg -> Config msg
withId id config =
    updateOptionsRecord
        (\containerOptions ->
            { containerOptions
                | id = Just <| HtmlAttributes.id id
            }
        )
        config


{-| Configuration modifier.
Adds tab-index attribute on the container
-}
withTabIndex : Int -> Config msg -> Config msg
withTabIndex index config =
    updateOptionsRecord
        (\containerOptions ->
            { containerOptions
                | tabIndex = Just <| HtmlAttributes.tabindex index
            }
        )
        config


{-| Configuration modifier.
Adds title attribute on the container
-}
withTitle : String -> Config msg -> Config msg
withTitle title config =
    updateOptionsRecord
        (\containerOptions ->
            { containerOptions
                | title = Just <| HtmlAttributes.title title
            }
        )
        config


{-| Configuration modifier.
Adds draggable attribute on the container
-}
withDraggable : String -> Config msg -> Config msg
withDraggable draggable config =
    updateOptionsRecord
        (\containerOptions ->
            { containerOptions
                | draggable = Just <| HtmlAttributes.draggable draggable
            }
        )
        config


{-| Configuration modifier.
Adds a generic attribute on the container.
You shouldn't use this if is not strictly necessary
-}
withAttribute : Html.Attribute msg -> Config msg -> Config msg
withAttribute customAttribute config =
    updateOptionsRecord
        (\containerOptions ->
            { containerOptions
                | attributes = customAttribute :: containerOptions.attributes
            }
        )
        config


{-| Configuration modifier.
Adds dropzone attribute on the container
-}
withDropZone : String -> Config msg -> Config msg
withDropZone dropZone config =
    updateOptionsRecord
        (\containerOptions ->
            { containerOptions
                | dropZone = Just <| HtmlAttributes.dropzone dropZone
            }
        )
        config


{-| Configuration modifier.
Adds style attribute on the container (it can be used multiple times)
-}
withStyle : String -> String -> Config msg -> Config msg
withStyle prop value config =
    updateOptionsRecord
        (\containerOptions ->
            { containerOptions
                | styles = HtmlAttributes.style prop value :: containerOptions.styles
            }
        )
        config


{-| Configuration modifier.
Swap between Medium or Fluid sizing on Small breakpoint
-}
withChangeSizeOnSmall : Config msg -> Config msg
withChangeSizeOnSmall config =
    changeSizeOnBreakPoint Small config


{-| Configuration modifier.
Swap between Medium or Fluid sizing on Medium breakpoint
-}
withChangeSizeOnMedium : Config msg -> Config msg
withChangeSizeOnMedium config =
    changeSizeOnBreakPoint Medium config


{-| Configuration modifier.
Swap between Medium or Fluid sizing on Large breakpoint
-}
withChangeSizeOnLarge : Config msg -> Config msg
withChangeSizeOnLarge config =
    changeSizeOnBreakPoint Large config


{-| Configuration modifier.
Swap between Medium or Fluid sizing on XLarge breakpoint
-}
withChangeSizeOnXLarge : Config msg -> Config msg
withChangeSizeOnXLarge config =
    changeSizeOnBreakPoint XLarge config


{-| Internal.
Generic core function for `changeSizeOn<Breakpoint>` modifiers
-}
changeSizeOnBreakPoint : BreakPoint -> Config msg -> Config msg
changeSizeOnBreakPoint breakPoint config =
    case deObfuscateContainerConfig config |> .size of
        Regular ->
            addSizeModifier (FluidOn breakPoint) config

        Fluid ->
            addSizeModifier (MediumOn breakPoint) config


{-| Internal.
Generic core function for `changeSizeOnBreakPoint` that adds computed SizeModifier to Container config
-}
addSizeModifier : SizeModifier -> Config msg -> Config msg
addSizeModifier modifier config =
    updateOptionsRecord
        (\containerOptions ->
            { containerOptions
                | sizeModifiers = containerOptions.sizeModifiers ++ [ modifier ]
            }
        )
        config


{-| Configuration modifier.
Adds onClick event listener on Container
-}
withOnClick : msg -> Config msg -> Config msg
withOnClick msg =
    addOptionalEvent (HtmlEvents.onClick msg)


{-| Configuration modifier.
Adds onDoubleClick event listener on Container
-}
withOnDoubleClick : msg -> Config msg -> Config msg
withOnDoubleClick msg =
    addOptionalEvent (HtmlEvents.onDoubleClick msg)


{-| Configuration modifier.
Adds onMouseEnter event listener on Container
-}
withOnMouseEnter : msg -> Config msg -> Config msg
withOnMouseEnter msg =
    addOptionalEvent (HtmlEvents.onMouseEnter msg)


{-| Configuration modifier.
Adds onMouseLeave event listener on Container
-}
withOnMouseLeave : msg -> Config msg -> Config msg
withOnMouseLeave msg =
    addOptionalEvent (HtmlEvents.onMouseLeave msg)


{-| Configuration modifier.
Adds onMouseOver event listener on Container
-}
withOnMouseOver : msg -> Config msg -> Config msg
withOnMouseOver msg =
    addOptionalEvent (HtmlEvents.onMouseOver msg)


{-| Configuration modifier.
Adds onMouseOut event listener on Container
-}
withOnMouseOut : msg -> Config msg -> Config msg
withOnMouseOut msg =
    addOptionalEvent (HtmlEvents.onMouseOut msg)


{-| Configuration modifier.
Adds onBlur event listener on Container
-}
withOnBlur : msg -> Config msg -> Config msg
withOnBlur msg =
    addOptionalEvent (HtmlEvents.onBlur msg)


{-| Configuration modifier.
Adds onFocus event listener on Container
-}
withOnFocus : msg -> Config msg -> Config msg
withOnFocus msg =
    addOptionalEvent (HtmlEvents.onFocus msg)


{-| Internal.
Core function for `on<Event>` that adds the event to config events list
-}
addOptionalEvent : Html.Attribute msg -> Config msg -> Config msg
addOptionalEvent event config =
    updateOptionsRecord
        (\containerOptions ->
            { containerOptions
                | events = containerOptions.events ++ [ event ]
            }
        )
        config
