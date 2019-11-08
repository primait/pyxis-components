module Prima.Pyxis.Link exposing
    ( Config, Icon
    , simple, standalone, simpleWithOnClick, withTargetBlank, withTargetParent, withTargetSelf, withTargetTop
    , withId, withClass, withIconArrowRight, withIconChevronDown, withIconDownload, withIconEdit, withIconEmail, withIconPhone
    , render
    )

{-| Create a `Link` using predefined Html syntax.


## Types and Configuration

@docs Config, Icon


## Options

@docs simple, standalone, simpleWithOnClick, withTargetBlank, withTargetParent, withTargetSelf, withTargetTop
@docs withId, withClass, withIconArrowRight, withIconChevronDown, withIconDownload, withIconEdit, withIconEmail, withIconPhone


## Targets Configuration Helpers

@docs targetBlank, targetParent, targetSelf, targetTop


## Icons Configuration Helpers

@docs iconArrowRight, iconChevronDown, iconDownload, iconEdit, iconEmail, iconPhone


## Render

@docs render

-}

import Html exposing (Html, a, i, text)
import Html.Attributes as Attrs
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
    { classes : List String
    , id : Maybe String
    , onClick : Maybe msg
    , target : Maybe String
    }


{-| Internal. Represents the possible modifiers for an `Link`.
-}
type LinkOption msg
    = Class String
    | Id String
    | OnClick msg
    | Target String


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


{-| Creates a simple link `a[href=""] with onClick msg`.

    --

    import Prima.Pyxis.Link as Link

    ...

    myLink : Link.Config
    myLink =
        Link.simpleWithOnClick "Visit site" OnClick

-}
simpleWithOnClick : String -> msg -> Config msg
simpleWithOnClick label msg =
    Config (Configuration Simple label Nothing Nothing []) |> addOption (OnClick msg)


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
render ((Config { label, icon, type_, href }) as config) =
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
            |> List.append
                [ Attrs.classList
                    [ ( "a-link", True )
                    , ( "a-link--standalone", isStandalone type_ )
                    , ( "a-link--with-icon", H.isJust icon )
                    ]
                ]
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
    , options.onClick
        |> Maybe.map (H.stopEvt "click")
    ]
        |> List.filterMap identity
        |> (::) (H.classesAttribute options.classes)
