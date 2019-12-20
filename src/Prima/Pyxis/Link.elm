module Prima.Pyxis.Link exposing
    ( Link, simple, standalone, simpleWithOnClick, standaloneWithOnClick
    , withId, withClass, withIconChevronDown, withIconDownload, withIconEdit, withIconEmail, withIconPhone, withIconArrowRight, withTargetFrameName, withTargetTop, withTargetSelf, withTargetParent, withTargetBlank
    , render
    )

{-|


## Types and LinkConfig

@docs Link, simple, standalone, simpleWithOnClick, standaloneWithOnClick


## Options

@docs withId, withClass, withIconChevronDown, withIconDownload, withIconEdit, withIconEmail, withIconPhone, withIconArrowRight, withTargetFrameName, withTargetTop, withTargetSelf, withTargetParent, withTargetBlank


## Rendering

@docs render

-}

import Html exposing (Html, a, i, text)
import Html.Attributes as Attrs
import Html.Events as Events
import Prima.Pyxis.Helpers as H


{-| Represents the opaque `Link` configuration.
-}
type Link msg
    = Link (LinkConfig msg)


{-| Internal. Represents the `Link` configuration.
-}
type alias LinkConfig msg =
    { type_ : LinkType
    , label : String
    , href : Maybe String
    , icon : Maybe Icon
    , options : List (LinkOption msg)
    }


{-| Internal. Represents the `Link` type.
-}
type LinkType
    = Simple
    | Standalone


{-| Internal. Represents the possible modifiers for an `Link`.
-}
type LinkOption msg
    = Class String
    | Id String
    | OnClick msg
    | Target String


{-| Internal. Represents the list of customizations for the `Link` component.
-}
type alias Options msg =
    { classes : List String
    , id : Maybe String
    , onClick : Maybe msg
    , target : Maybe String
    }


{-| Internal. Represents the initial state of the list of customizations for the `Link` component.
-}
defaultOptions : Options msg
defaultOptions =
    { classes = []
    , id = Nothing
    , onClick = Nothing
    , target = Nothing
    }


{-| Internal. Applies the customizations made by end user to the `Link` component.
-}
applyOption : LinkOption msg -> Options msg -> Options msg
applyOption modifier options =
    case modifier of
        Class class ->
            { options | classes = class :: options.classes }

        Id id ->
            { options | id = Just id }

        OnClick onClick ->
            { options | onClick = Just onClick }

        Target target ->
            { options | target = Just target }


{-| Internal. Applies all the customizations and returns the internal `Options` type.
-}
computeOptions : Link msg -> Options msg
computeOptions (Link config) =
    List.foldl applyOption defaultOptions config.options


{-| Internal. Check is standalone `Link`.
-}
isStandalone : LinkType -> Bool
isStandalone =
    (==) Standalone


{-| Creates a simple link `a[href=""]`.
-}
simple : String -> String -> Link msg
simple label href =
    Link (LinkConfig Simple label (Just href) Nothing [])


{-| Creates a simple link `a[href=""] with onClick msg`.
-}
simpleWithOnClick : String -> msg -> Link msg
simpleWithOnClick label msg =
    Link (LinkConfig Simple label Nothing Nothing []) |> addOption (OnClick msg)


{-| Creates a standalone link `a[href=""]`.
-}
standalone : String -> String -> Link msg
standalone label href =
    Link (LinkConfig Standalone label (Just href) Nothing [])


{-| Creates a standalone link `a[href=""] with onClick msg`.
-}
standaloneWithOnClick : String -> msg -> Link msg
standaloneWithOnClick label msg =
    Link (LinkConfig Standalone label Nothing Nothing []) |> addOption (OnClick msg)


{-| Represents an icon from Pyxis Iconset.
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
withIconArrowRight : Link msg -> Link msg
withIconArrowRight (Link linkConfig) =
    Link { linkConfig | icon = Just ArrowRight }


{-| Creates a chevron-down icon.
-}
withIconChevronDown : Link msg -> Link msg
withIconChevronDown (Link linkConfig) =
    Link { linkConfig | icon = Just ChevronDown }


{-| Creates a download icon.
-}
withIconDownload : Link msg -> Link msg
withIconDownload (Link linkConfig) =
    Link { linkConfig | icon = Just Download }


{-| Creates an edit icon.
-}
withIconEdit : Link msg -> Link msg
withIconEdit (Link linkConfig) =
    Link { linkConfig | icon = Just Edit }


{-| Creates an email icon.
-}
withIconEmail : Link msg -> Link msg
withIconEmail (Link linkConfig) =
    Link { linkConfig | icon = Just Email }


{-| Creates a phone icon.
-}
withIconPhone : Link msg -> Link msg
withIconPhone (Link linkConfig) =
    Link { linkConfig | icon = Just Phone }


{-| Adds an `id` Html.Attribute to the `Link`.
-}
withId : String -> Link msg -> Link msg
withId id =
    addOption (Id id)


{-| Adds a `class` to the `Link`.
-}
withClass : String -> Link msg -> Link msg
withClass class_ =
    addOption (Class class_)


{-| add `a[target="frameName"]` attr to the `Link`.
-}
withTargetFrameName : String -> Link msg -> Link msg
withTargetFrameName target =
    addOption (Target target)


{-| add `a[target="_top"]` attr to the `Link`.
-}
withTargetTop : Link msg -> Link msg
withTargetTop =
    addOption (Target "_top")


{-| add `a[target="_self"]` attr to the `Link`.
-}
withTargetSelf : Link msg -> Link msg
withTargetSelf =
    addOption (Target "_self")


{-| add `a[target="_parent"]` attr to the `Link`.
-}
withTargetParent : Link msg -> Link msg
withTargetParent =
    addOption (Target "_parent")


{-| add `a[target="_blank"]` attr to the `Link`.
-}
withTargetBlank : Link msg -> Link msg
withTargetBlank =
    addOption (Target "_blank")


{-| Internal. Adds a generic option to the `Link`.
-}
addOption : LinkOption msg -> Link msg -> Link msg
addOption option (Link linkConfig) =
    Link { linkConfig | options = linkConfig.options ++ [ option ] }


{-| Internal. Transforms all the customizations into a list of valid Html.Attribute(s).
-}
buildAttributes : Link msg -> List (Html.Attribute msg)
buildAttributes linkModel =
    let
        options =
            computeOptions linkModel
    in
    [ options.id
        |> Maybe.map Attrs.id
    , options.target
        |> Maybe.map Attrs.target
    , options.onClick
        |> Maybe.map Events.onClick
    ]
        |> List.filterMap identity
        |> (::) (H.classesAttribute options.classes)


{-| Renders a link by receiving it's configuration.
import Prima.Pyxis.Link as Link

    ...

    myLink : Link.Link
    myLink =
        Link.simple "Visit site" "https://www.prima.it"
            |> Link.render

    secondLink: Link.Link
    secondLink = Link.standaloneWithOnClick "Visit site" Msg
        secondLink
            |> Link.withTargetBlank
            |> Link.render

-}
render : Link msg -> Html msg
render ((Link config) as linkModel) =
    a
        ([ Attrs.classList
            [ ( "a-link", True )
            , ( "a-link--standalone", isStandalone config.type_ )
            , ( "a-link--with-icon", H.isJust config.icon )
            ]
         , Attrs.href (Maybe.withDefault "#" config.href)
         ]
            ++ buildAttributes linkModel
        )
        [ Maybe.withDefault (text "") <| Maybe.map renderIcon <| config.icon
        , text config.label
        ]


{-| Internal. Add icon class.
-}
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
