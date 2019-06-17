module Prima.Pyxis.Link exposing
    ( Config, Icon
    , simple, standalone, withIcon
    , iconChevronDown, iconDownload, iconEdit, iconEmail, iconPhone
    , render
    )

{-| Allows to create a `Link` using predefined Html syntax.


# Configuration

@docs Config, Icon


# Configuration Helpers

@docs simple, standalone, withIcon


# Icons Configuratiion Helpers

@docs iconChevronDown, iconDownload, iconEdit, iconEmail, iconPhone


# Rendering

@docs render

-}

import Html exposing (Html, a, i, text)
import Html.Attributes exposing (class, classList, href)
import Prima.Pyxis.Helpers as Helpers


{-| Represents the configuration of a `Link`.
-}
type Config
    = Config Configuration


type alias Configuration =
    { type_ : LinkType
    , label : String
    , path : String
    , icon : Maybe Icon
    }


type LinkType
    = Simple
    | Standalone


isStandalone : LinkType -> Bool
isStandalone =
    (==) Standalone


{-| Creates a simple link. Used when the link itself is in a paragraph.

    --

    import Prima.Pyxis.Link as Link

    ...

    myLink : Link.Config
    myLink =
        Link.simple "Visit site" "https://www.prima.it"

-}
simple : String -> String -> Config
simple label path =
    Config (Configuration Simple label path Nothing)


{-| Creates a standalone link. Used when the link itself stands alone.

    --

    import Prima.Pyxis.Link as Link

    ...

    myLink : Link.Config
    myLink =
        Link.standalone "Visit site" "https://www.prima.it"

-}
standalone : String -> String -> Config
standalone label path =
    Config (Configuration Standalone label path Nothing)


{-| Creates a simple link which holds an icon. Used when the link itself stands alone.

    --

    import Prima.Pyxis.Link as Link

    ...

    myLink : Link.Config
    myLink =
        Link.withIcon "Visit site" "https://www.prima.it" Link.iconEdit

-}
withIcon : String -> String -> Icon -> Config
withIcon label path icon =
    Config (Configuration Simple label path (Just icon))


type Icon
    = ArrowRight
    | ChevronDown
    | Download
    | Edit
    | Email
    | Phone


{-| Creates a chevron-down icon.
-}
iconChevronDown : Icon
iconChevronDown =
    ChevronDown


{-| Creates a download icon.
-}
iconDownload : Icon
iconDownload =
    Download


{-| Creates an edit icon.
-}
iconEdit : Icon
iconEdit =
    Edit


{-| Creates an email icon.
-}
iconEmail : Icon
iconEmail =
    Email


{-| Creates a phone icon.
-}
iconPhone : Icon
iconPhone =
    Phone


{-| Renders a link by receiving it's configuration.
-}
render : Config -> Html msg
render (Config config) =
    a
        [ classList
            [ ( "a-link", True )
            , ( "a-link--standalone", isStandalone config.type_ )
            , ( "a-link--with-icon", Helpers.isJust config.icon )
            ]
        , href config.path
        ]
        [ Maybe.withDefault (text "") <| Maybe.map renderIcon <| config.icon
        , text config.label
        ]


renderIcon : Icon -> Html msg
renderIcon icon =
    i
        [ classList
            [ ( "a-icon", True )
            , ( "a-link__icon", True )
            , ( "a-icon-chevron-down", icon == ChevronDown )
            , ( "a-icon-download", icon == Download )
            , ( "a-icon-edit", icon == Edit )
            , ( "a-icon-email", icon == Email )
            , ( "a-icon-phone", icon == Phone )
            ]
        ]
        []
