module Prima.Pyxis.DownloadButton exposing
    ( Config
    , download
    , render
    , withAttribute, withClass, withDisabled, withId, withTabIndex, withTargetBlank, withTargetParent, withTargetSelf, withTargetTop, withTitle, withSvgIcon
    , withOnClick, withOnMouseDown, withOnMouseUp, withOnMouseEnter, withOnMouseLeave, withOnMouseOver, withOnMouseOut
    )

{-|


## Configuration

@docs Config


## Configuration Methods

@docs download


## Rendering

@docs render


## Options

@docs withAttribute, withClass, withDisabled, withId, withTabIndex, withTargetBlank, withTargetParent, withTargetSelf, withTargetTop, withTitle, withSvgIcon


## Event Options

@docs withOnClick, withOnMouseDown, withOnMouseUp, withOnMouseEnter, withOnMouseLeave, withOnMouseOver, withOnMouseOut

-}

import Html exposing (Html, button, div, i, text)
import Html.Attributes as Attrs exposing (class)
import Html.Events as Events
import Prima.Pyxis.DownloadButton.Icons as DownloadIcon
import Prima.Pyxis.Helpers as H


{-| Represent the configuration of the `DownloadButton`.
-}
type Config msg
    = Config (DownloadButtonConfig msg)


type alias DownloadButtonConfig msg =
    { title : String
    , subtitle : String
    , options : List (DownloadButtonOption msg)
    }


{-| Represents a `DownloadButton` target.
-}
type Target
    = Blank
    | Self
    | Parent
    | Top


{-| Internal. Represents the list of customizations for the `DownloadButton` component.
-}
type alias Options msg =
    { classes : List String
    , events : List (Html.Attribute msg)
    , attributes : List (Html.Attribute msg)
    , disabled : Maybe Bool
    , id : Maybe String
    , tabIndex : Maybe Int
    , title : Maybe String
    , target : Target
    , useSvgIcon : Bool
    }


{-| Internal. Represents the possible modifiers for a `DownloadButton`.
-}
type DownloadButtonOption msg
    = Class String
    | Event (Html.Attribute msg)
    | Disabled Bool
    | Id String
    | TabIndex Int
    | Title String
    | Attribute (Html.Attribute msg)
    | FormTarget Target
    | UseSvgIcon


{-| Internal. Represents the initial state of the list of customizations for the `DownloadButton` component.
-}
defaultOptions : Options msg
defaultOptions =
    { classes = [ "btn", "btn--download" ]
    , events = []
    , disabled = Nothing
    , id = Nothing
    , tabIndex = Nothing
    , title = Nothing
    , attributes = []
    , target = Self
    , useSvgIcon = False
    }


{-| Internal. Applies the customizations made by end user to the `DownloadButton` component.
-}
applyOption : DownloadButtonOption msg -> Options msg -> Options msg
applyOption modifier options =
    case modifier of
        Class class ->
            { options | classes = class :: options.classes }

        Event action ->
            { options | events = action :: options.events }

        Disabled disabled ->
            { options | disabled = Just disabled }

        Id id ->
            { options | id = Just id }

        TabIndex index ->
            { options | tabIndex = Just index }

        Title title ->
            { options | title = Just title }

        Attribute attr ->
            { options | attributes = attr :: options.attributes }

        FormTarget target ->
            { options | target = target }

        UseSvgIcon ->
            { options | useSvgIcon = True }


{-| Internal. Applies all the customizations and returns the internal `Options` type.
-}
computeOptions : Config msg -> Options msg
computeOptions (Config config) =
    List.foldl applyOption defaultOptions config.options


{-| Internal. Adds a generic option to the `DownloadButton`.
-}
addOption : DownloadButtonOption msg -> Config msg -> Config msg
addOption option (Config buttonConfig) =
    Config { buttonConfig | options = buttonConfig.options ++ [ option ] }


{-| Create a default download button.
-}
download : String -> String -> Config msg
download title subtitle =
    Config (DownloadButtonConfig title subtitle [])


{-| Adds classes to the `classes` of the `DownloadButton`.
-}
withClass : String -> Config msg -> Config msg
withClass class =
    addOption (Class class)


{-| Adds a `disabled` Html.Attribute to the `DownloadButton`.
-}
withDisabled : Bool -> Config msg -> Config msg
withDisabled isDisabled =
    addOption (Disabled isDisabled)


{-| Adds an `id` Html.Attribute to the `DownloadButton`.
-}
withId : String -> Config msg -> Config msg
withId id =
    addOption (Id id)


{-| Adds a `tabIndex` Html.Attribute to the `DownloadButton`.
-}
withTabIndex : Int -> Config msg -> Config msg
withTabIndex index =
    addOption (TabIndex index)


{-| Adds a `title` Html.Attribute to the `DownloadButton`.
-}
withTitle : String -> Config msg -> Config msg
withTitle title =
    addOption (Title title)


{-| Adds a `target` Html.Attribute to the `DownloadButton`.
-}
withTargetBlank : Config msg -> Config msg
withTargetBlank =
    addOption (FormTarget Blank)


{-| Adds a `target` Html.Attribute to the `DownloadButton`.
-}
withTargetSelf : Config msg -> Config msg
withTargetSelf =
    addOption (FormTarget Self)


{-| Adds a `target` Html.Attribute to the `DownloadButton`.
-}
withTargetParent : Config msg -> Config msg
withTargetParent =
    addOption (FormTarget Parent)


{-| Adds a `target` Html.Attribute to the `DownloadButton`.
-}
withTargetTop : Config msg -> Config msg
withTargetTop =
    addOption (FormTarget Top)


{-| Tells the `DownloadButton` component to use SVG icons instead of Pyxis icons.
-}
withSvgIcon : Config msg -> Config msg
withSvgIcon =
    addOption UseSvgIcon


{-| Adds an `onClick` Html.Event to the `DownloadButton`.
-}
withOnClick : msg -> Config msg -> Config msg
withOnClick tagger =
    addOption (Event (Events.onClick tagger))


{-| Adds an `onMouseDown` Html.Event to the `DownloadButton`.
-}
withOnMouseDown : msg -> Config msg -> Config msg
withOnMouseDown tagger =
    addOption (Event (Events.onMouseDown tagger))


{-| Adds an `onMouseUp` Html.Event to the `DownloadButton`.
-}
withOnMouseUp : msg -> Config msg -> Config msg
withOnMouseUp tagger =
    addOption (Event (Events.onMouseUp tagger))


{-| Adds an `onMouseEnter` Html.Event to the `DownloadButton`.
-}
withOnMouseEnter : msg -> Config msg -> Config msg
withOnMouseEnter tagger =
    addOption (Event (Events.onMouseEnter tagger))


{-| Adds an `onMouseLeave` Html.Event to the `DownloadButton`.
-}
withOnMouseLeave : msg -> Config msg -> Config msg
withOnMouseLeave tagger =
    addOption (Event (Events.onMouseLeave tagger))


{-| Adds an `onMouseOver` Html.Event to the `DownloadButton`.
-}
withOnMouseOver : msg -> Config msg -> Config msg
withOnMouseOver tagger =
    addOption (Event (Events.onMouseOver tagger))


{-| Adds an `onMouseOut` Html.Event to the `DownloadButton`.
-}
withOnMouseOut : msg -> Config msg -> Config msg
withOnMouseOut tagger =
    addOption (Event (Events.onMouseOut tagger))


{-| Adds a generic attribute to the Button.
-}
withAttribute : Html.Attribute msg -> Config msg -> Config msg
withAttribute attr =
    addOption (Attribute attr)


{-| Renders the button by receiving it's configuration.

    --

    import Prima.Pyxis.DownloadButton as DownloadButtonButton

    type Msg =
        Clicked

    ...

    myBtn : DownloadButton.Config Msg
    myBtn =
        DownloadButton.default "Certificato di polizza" "Scarica .pdf"
            |> DownloadButton.withDisabled False
            |> DownloadButton.withOnClick Clicked

    ...

    view : Html Msg
    view =
        DownloadButton.render myBtn

-}
render : Config msg -> Html msg
render ((Config { title, subtitle }) as config) =
    let
        useSvg =
            config
                |> computeOptions
                |> .useSvgIcon
    in
    button
        (buildAttributes config)
        [ H.renderOrElse useSvg
            DownloadIcon.renderIconDownload
            (i
                [ class "btn--download__icon icon icon-download" ]
                []
            )
        , div
            [ class "btn--download__title" ]
            [ text title ]
        , div
            [ class "btn--download__subtitle" ]
            [ text subtitle ]
        ]


{-| Internal. Transforms all the customizations into a list of valid Html.Attribute(s).
-}
buildAttributes : Config msg -> List (Html.Attribute msg)
buildAttributes buttonConfig =
    let
        options =
            computeOptions buttonConfig
    in
    [ options.id
        |> Maybe.map Attrs.id
    , options.tabIndex
        |> Maybe.map Attrs.tabindex
    , options.disabled
        |> Maybe.map Attrs.disabled
    ]
        |> List.filterMap identity
        |> (::) (buildFormTarget options)
        |> (::) (buildClasses options)
        |> List.append options.attributes
        |> List.append options.events


{-| Internal. Constructs the `formtarget` attribute from the `DownloadButton` options.
-}
buildFormTarget : Options msg -> Html.Attribute msg
buildFormTarget options =
    case options.target of
        Self ->
            Attrs.attribute "formtarget" "_self"

        Blank ->
            Attrs.attribute "formtarget" "_blank"

        Parent ->
            Attrs.attribute "formtarget" "_parent"

        Top ->
            Attrs.attribute "formtarget" "_top"


{-| Internal. Merges the component configuration and options to a classes attribute.
-}
buildClasses : Options msg -> Html.Attribute msg
buildClasses options =
    options.classes
        |> String.join " "
        |> Attrs.class
