module Prima.Pyxis.Link exposing
    ( Config
    , simple, standalone
    , render
    , withAttribute, withId, withClass, withClassList, withIcon, withHref, withTargetBlank, withTargetParent, withTargetSelf, withTargetTop
    , withOnClick, withOnMouseDown, withOnMouseUp, withOnMouseEnter, withOnMouseLeave, withOnMouseOver, withOnMouseOut
    )

{-|


## Configuration

@docs Config


## Configuration Methods

@docs simple, standalone


## Rendering

@docs render


## Options

@docs withAttribute, withId, withClass, withClassList, withIcon, withHref, withTargetBlank, withTargetParent, withTargetSelf, withTargetTop


## Event Options

@docs withOnClick, withOnMouseDown, withOnMouseUp, withOnMouseEnter, withOnMouseLeave, withOnMouseOver, withOnMouseOut

-}

import Html exposing (Html, a, span, text)
import Html.Attributes as Attrs
import Html.Events as Events
import Maybe.Extra as ME
import Prima.Pyxis.Helpers as H


{-| Represent the configuration of a `Link`.
-}
type Config msg
    = Config (LinkConfig msg)


type alias LinkConfig msg =
    { type_ : LinkType
    , label : String
    , href : Maybe String
    , icon : Maybe String
    , options : List (LinkOption msg)
    }


{-| Internal. Represents the list of customizations for the `Link` component.
-}
type alias Options msg =
    { id : Maybe String
    , classes : List String
    , classList : List ( String, Bool )
    , events : List (Html.Attribute msg)
    , attributes : List (Html.Attribute msg)
    , target : Maybe String
    }


{-| Internal. Represents the possible modifiers for an `Link`.
-}
type LinkOption msg
    = Id String
    | Class String
    | ClassList (List ( String, Bool ))
    | Event (Html.Attribute msg)
    | Attribute (Html.Attribute msg)
    | Target String


{-| Internal. Represents the initial state of the list of customizations for the `Link` component.
-}
defaultOptions : Options msg
defaultOptions =
    { id = Nothing
    , classes = []
    , classList = []
    , events = []
    , attributes = []
    , target = Nothing
    }


{-| Internal. Applies the customizations made by end user to the `Link` component.
-}
applyOption : LinkOption msg -> Options msg -> Options msg
applyOption modifier options =
    case modifier of
        Id id ->
            { options | id = Just id }

        Class class ->
            { options | classes = class :: options.classes }

        ClassList list ->
            { options | classList = List.append list options.classList }

        Event action ->
            { options | events = action :: options.events }

        Attribute attr ->
            { options | attributes = attr :: options.attributes }

        Target target ->
            { options | target = Just target }


{-| Internal. Applies all the customizations and returns the internal `Options` type.
-}
computeOptions : Config msg -> Options msg
computeOptions (Config config) =
    List.foldl applyOption defaultOptions config.options


{-| Internal. Adds a generic option to the `Link`.
-}
addOption : LinkOption msg -> Config msg -> Config msg
addOption option (Config linkConfig) =
    Config { linkConfig | options = linkConfig.options ++ [ option ] }


type LinkType
    = Simple
    | Standalone


isStandalone : LinkType -> Bool
isStandalone =
    (==) Standalone


{-| Create a simple link. Used when the link itself is in a paragraph.

    --

    import Prima.Pyxis.Link as Link

    ...

    myLink : Link.Config
    myLink =
        Link.simple "Visit site" "https://www.prima.it"

-}
simple : String -> Config msg
simple label =
    Config (LinkConfig Simple label Nothing Nothing [])


{-| Create a standalone link. Used when the link itself stands alone.

    --

    import Prima.Pyxis.Link as Link

    ...

    myLink : Link.Config
    myLink =
        Link.standalone "Visit site" "https://www.prima.it"

-}
standalone : String -> Config msg
standalone label =
    Config (LinkConfig Standalone label Nothing Nothing [])


{-| Add `a[target="_top"]` attr to the `Config`.

    --

    import Prima.Pyxis.Link as Link

    ...

    myLink : Link.Config
    myLink =
      "https://www.prima.it"
        |> Link.simple "Visit site"
        |> Link.withTargetTop

-}
withTargetTop : Config msg -> Config msg
withTargetTop =
    addOption (Target "_top")


{-| Add `a[target="_self"]` attr to the `Config`.

    --

    import Prima.Pyxis.Link as Link

    ...

    myLink : Link.Config
    myLink =
      "https://www.prima.it"
        |> Link.simple "Visit site"
        |> Link.withTargetSelf

-}
withTargetSelf : Config msg -> Config msg
withTargetSelf =
    addOption (Target "_self")


{-| Add `a[target="_parent"]` attr to the `Config`.

    --

    import Prima.Pyxis.Link as Link

    ...

    myLink : Link.Config
    myLink =
      "https://www.prima.it"
        |> Link.simple "Visit site"
        |> Link.withTargetParent

-}
withTargetParent : Config msg -> Config msg
withTargetParent =
    addOption (Target "_parent")


{-| Add `a[target="_blank"]` attr to the `Config`.

    --

    import Prima.Pyxis.Link as Link

    ...

    myLink : Link.Config
    myLink =
      "https://www.prima.it"
        |> Link.simple "Visit site"
        |> Link.withTargetBlank

-}
withTargetBlank : Config msg -> Config msg
withTargetBlank =
    addOption (Target "_blank")


{-| Adds an `id` Html.Attribute to the `Link`.
-}
withId : String -> Config msg -> Config msg
withId id =
    addOption (Id id)


{-| Adds a `class` to the `Link`.
-}
withClass : String -> Config msg -> Config msg
withClass class_ =
    addOption (Class class_)


{-| Adds classes to the `classList` of the `Link`.
-}
withClassList : List ( String, Bool ) -> Config msg -> Config msg
withClassList classList =
    addOption (ClassList classList)


{-| Adds a generic attribute to the Link.
-}
withAttribute : Html.Attribute msg -> Config msg -> Config msg
withAttribute attr =
    addOption (Attribute attr)


{-| Adds an `onClick` Html.Event to the `Link`.
-}
withOnClick : msg -> Config msg -> Config msg
withOnClick tagger =
    addOption (Event (H.stopEvt "click" tagger))


{-| Adds an `onMouseDown` Html.Event to the `Link`.
-}
withOnMouseDown : msg -> Config msg -> Config msg
withOnMouseDown tagger =
    addOption (Event (Events.onMouseDown tagger))


{-| Adds an `onMouseUp` Html.Event to the `Link`.
-}
withOnMouseUp : msg -> Config msg -> Config msg
withOnMouseUp tagger =
    addOption (Event (Events.onMouseUp tagger))


{-| Adds an `onMouseEnter` Html.Event to the `Link`.
-}
withOnMouseEnter : msg -> Config msg -> Config msg
withOnMouseEnter tagger =
    addOption (Event (Events.onMouseEnter tagger))


{-| Adds an `onMouseLeave` Html.Event to the `Link`.
-}
withOnMouseLeave : msg -> Config msg -> Config msg
withOnMouseLeave tagger =
    addOption (Event (Events.onMouseLeave tagger))


{-| Adds an `onMouseOver` Html.Event to the `Link`.
-}
withOnMouseOver : msg -> Config msg -> Config msg
withOnMouseOver tagger =
    addOption (Event (Events.onMouseOver tagger))


{-| Adds an `onMouseOut` Html.Event to the `Link`.
-}
withOnMouseOut : msg -> Config msg -> Config msg
withOnMouseOut tagger =
    addOption (Event (Events.onMouseOut tagger))


{-| Creates a arrow-right icon.
-}
withIcon : String -> Config msg -> Config msg
withIcon icon (Config linkConfig) =
    Config { linkConfig | icon = Just icon }


{-| Adds href attribute to the `Link` component
-}
withHref : String -> Config msg -> Config msg
withHref href (Config linkConfig) =
    Config { linkConfig | href = Just href }


{-| Renders a link by receiving it's configuration.
-}
render : Config msg -> Html msg
render ((Config { label, icon, href }) as config) =
    let
        maybeHref : List (Html.Attribute msg)
        maybeHref =
            href
                |> Maybe.map Attrs.href
                |> List.singleton
                |> List.filterMap identity
    in
    (href
        |> Maybe.map (always a)
        |> Maybe.withDefault span
    )
        (List.append (buildAttributes config) maybeHref)
        [ ME.unwrap (text "") renderIcon icon
        , text label
        ]


{-| Internal. Renders the icon
-}
renderIcon : String -> Html msg
renderIcon icon =
    Html.i
        [ Attrs.classList
            [ ( "icon", True )
            , ( "link__icon", True )
            , ( "icon-" ++ icon, True )
            ]
        ]
        []


{-| Internal. Transforms all the customizations into a list of valid Html.Attribute(s).
-}
buildAttributes : Config msg -> List (Html.Attribute msg)
buildAttributes linkModel =
    let
        options =
            computeOptions linkModel
    in
    [ options.id
        |> Maybe.map Attrs.id
    , options.target
        |> Maybe.map Attrs.target
    ]
        |> List.filterMap identity
        |> List.append options.events
        |> List.append options.attributes
        |> (::) (H.classesAttribute options.classes)
        |> (::) (buildClassList linkModel options)


{-| Internal. Merges the component configuration and options to a classList attribute.
-}
buildClassList : Config msg -> Options msg -> Html.Attribute msg
buildClassList (Config { type_, icon }) options =
    [ ( "link", True )
    , ( "link--standalone", isStandalone type_ )
    , ( "link--with-icon", H.isJust icon )
    ]
        |> List.append options.classList
        |> List.append (List.map (H.flip Tuple.pair True) options.classes)
        |> Attrs.classList
