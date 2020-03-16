module Prima.Pyxis.Link exposing
    ( Config, Icon, simple, standalone
    , withId, withClass, withTargetBlank, withTargetParent, withTargetSelf, withTargetTop
    , withIconArrowRight, withIconChevronDown, withIconDownload, withIconEdit, withIconEmail, withIconPhone
    , withOnClick, withOnMouseDown, withOnMouseUp, withOnMouseEnter, withOnMouseLeave, withOnMouseOver, withOnMouseOut
    , render
    , withAttribute, withClassList
    )

{-|


## Types and Configuration

@docs Config, Icon, simple, standalone


## Options

@docs withId, withClass, withTargetBlank, withTargetParent, withTargetSelf, withTargetTop


## Icon Helpers

@docs withIconArrowRight, withIconChevronDown, withIconDownload, withIconEdit, withIconEmail, withIconPhone


## Events

@docs withOnClick, withOnMouseDown, withOnMouseUp, withOnMouseEnter, withOnMouseLeave, withOnMouseOver, withOnMouseOut


## Targets

@docs targetBlank, targetParent, targetSelf, targetTop


## Icons

@docs iconArrowRight, iconChevronDown, iconDownload, iconEdit, iconEmail, iconPhone


## Render

@docs render

-}

import Html exposing (Html, a, i, text)
import Html.Attributes as Attrs
import Html.Events as Events
import Prima.Pyxis.Helpers as H


{-| Represent the configuration of a `Link`.
-}
type Config msg
    = Config (Configuration msg)


type alias Configuration msg =
    { type_ : LinkType
    , label : String
    , href : Maybe String
    , icon : Maybe Icon
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
simple : String -> String -> Config msg
simple label href =
    Config (Configuration Simple label (Just href) Nothing [])


{-| Create a standalone link. Used when the link itself stands alone.

    --

    import Prima.Pyxis.Link as Link

    ...

    myLink : Link.Config
    myLink =
        Link.standalone "Visit site" "https://www.prima.it"

-}
standalone : String -> String -> Config msg
standalone label href =
    Config (Configuration Standalone label (Just href) Nothing [])


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


{-| Represent an icon from Pyxis Iconset.
-}
type Icon
    = ArrowRight
    | ChevronDown
    | Download
    | Edit
    | Email
    | Phone


{-| Creates a arrow-right icon.
-}
withIconArrowRight : Config msg -> Config msg
withIconArrowRight (Config linkConfig) =
    Config { linkConfig | icon = Just ArrowRight }


{-| Creates a chevron-down icon.
-}
withIconChevronDown : Config msg -> Config msg
withIconChevronDown (Config linkConfig) =
    Config { linkConfig | icon = Just ChevronDown }


{-| Creates a download icon.
-}
withIconDownload : Config msg -> Config msg
withIconDownload (Config linkConfig) =
    Config { linkConfig | icon = Just Download }


{-| Creates an edit icon.
-}
withIconEdit : Config msg -> Config msg
withIconEdit (Config linkConfig) =
    Config { linkConfig | icon = Just Edit }


{-| Creates an email icon.
-}
withIconEmail : Config msg -> Config msg
withIconEmail (Config linkConfig) =
    Config { linkConfig | icon = Just Email }


{-| Creates a phone icon.
-}
withIconPhone : Config msg -> Config msg
withIconPhone (Config linkConfig) =
    Config { linkConfig | icon = Just Phone }


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
    a
        (maybeHref
            |> List.append (buildAttributes config)
        )
        [ Maybe.withDefault (text "") <| Maybe.map renderIcon <| icon
        , text label
        ]


renderIcon : Icon -> Html msg
renderIcon icon =
    i
        [ Attrs.classList
            [ ( "a-icon", True )
            , ( "a-link__icon", True )
            , ( "a-icon-arrow-right", icon == ArrowRight )
            , ( "a-icon-chevron-down", icon == ChevronDown )
            , ( "a-icon-download", icon == Download )
            , ( "a-icon-edit", icon == Edit )
            , ( "a-icon-email", icon == Email )
            , ( "a-icon-phone", icon == Phone )
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
    [ ( "a-link", True )
    , ( "a-link--standalone", isStandalone type_ )
    , ( "a-link--with-icon", H.isJust icon )
    ]
        |> List.append options.classList
        |> List.append (List.map (H.flip Tuple.pair True) options.classes)
        |> Attrs.classList
