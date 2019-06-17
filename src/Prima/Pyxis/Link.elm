module Prima.Pyxis.Link exposing
    ( Config
    , Icon
    , iconChevronDown
    , iconDownload
    , iconEdit
    , iconEmail
    , iconPhone
    , render
    )

import Html exposing (Html, a, i, text)
import Html.Attributes exposing (class, classList, href)
import Prima.Pyxis.Helpers as Helpers


type Config
    = Config Configuration


type alias Configuration =
    { label : String
    , path : String
    , icon : Maybe Icon
    }


simple : String -> String -> Config
simple label path =
    Config (Configuration label path Nothing)


withIcon : String -> String -> Icon -> Config
withIcon label path icon =
    Config (Configuration label path (Just icon))


type Icon
    = ArrowRight
    | ChevronDown
    | Download
    | Edit
    | Email
    | Phone


iconChevronDown : Icon
iconChevronDown =
    ChevronDown


iconDownload : Icon
iconDownload =
    Download


iconEdit : Icon
iconEdit =
    Edit


iconEmail : Icon
iconEmail =
    Email


iconPhone : Icon
iconPhone =
    Phone


render : Config -> Html msg
render (Config config) =
    a
        [ classList
            [ ( "a-link", True )
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
            ]
        ]
        []
