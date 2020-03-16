module Prima.Pyxis.Button exposing
    ( Config, Emphasis, ColorScheme(..), callOut, primary, secondary, tertiary
    , withColorScheme, withSize
    , withAttribute, withClass, withClassList, withDisabled, withIcon, withId, withTabIndex, withTitle
    , withOnClick, withOnMouseDown, withOnMouseUp, withOnMouseEnter, withOnMouseLeave, withOnMouseOver, withOnMouseOut
    , render
    )

{-| Create a `Button` using predefined Html syntax.


## Configuration

@docs Config, Emphasis, ColorScheme, callOut, primary, secondary, tertiary


## Size and ColorScheme

@docs withColorScheme, withSize


## Options

@docs withAttribute, withClass, withClassList, withDisabled, withIcon, withId, withTabIndex, withTitle


## Events

@docs withOnClick, withOnMouseDown, withOnMouseUp, withOnMouseEnter, withOnMouseLeave, withOnMouseOver, withOnMouseOut


# Render

@docs render

-}

import Html exposing (Html, button, span, text)
import Html.Attributes as Attrs
import Html.Events as Events
import Prima.Pyxis.Helpers as H


{-| Represent the configuration of the button.
-}
type Config msg
    = Config (ButtonConfig msg)


type alias ButtonConfig msg =
    { emphasis : Emphasis
    , color : ColorScheme
    , size : Size
    , label : String
    , icon : Maybe String
    , options : List (ButtonOption msg)
    }


{-| Represent the visual weight of the button.
-}
type Emphasis
    = CallOut
    | Primary
    | Secondary
    | Tertiary


isCallOut : Emphasis -> Bool
isCallOut =
    (==) CallOut


isPrimary : Emphasis -> Bool
isPrimary =
    (==) Primary


isSecondary : Emphasis -> Bool
isSecondary =
    (==) Secondary


isTertiary : Emphasis -> Bool
isTertiary =
    (==) Tertiary


{-| Internal. Represents the list of customizations for the `Button` component.
-}
type alias Options msg =
    { classes : List String
    , classList : List ( String, Bool )
    , events : List (Html.Attribute msg)
    , attributes : List (Html.Attribute msg)
    , disabled : Maybe Bool
    , id : Maybe String
    , tabIndex : Maybe Int
    , title : Maybe String
    }


{-| Internal. Represents the possible modifiers for a `Button`.
-}
type ButtonOption msg
    = Class String
    | ClassList (List ( String, Bool ))
    | Event (Html.Attribute msg)
    | Disabled Bool
    | Id String
    | TabIndex Int
    | Title String
    | Attribute (Html.Attribute msg)


{-| Internal. Represents the initial state of the list of customizations for the `Button` component.
-}
defaultOptions : Options msg
defaultOptions =
    { classes = []
    , classList = []
    , events = []
    , disabled = Nothing
    , id = Nothing
    , tabIndex = Nothing
    , title = Nothing
    , attributes = []
    }


{-| Internal. Applies the customizations made by end user to the `Button` component.
-}
applyOption : ButtonOption msg -> Options msg -> Options msg
applyOption modifier options =
    case modifier of
        Class class ->
            { options | classes = class :: options.classes }

        ClassList list ->
            { options | classList = List.append list options.classList }

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


{-| Internal. Applies all the customizations and returns the internal `Options` type.
-}
computeOptions : Config msg -> Options msg
computeOptions (Config config) =
    List.foldl applyOption defaultOptions config.options


{-| Internal. Adds a generic option to the `Button`.
-}
addOption : ButtonOption msg -> Config msg -> Config msg
addOption option (Config buttonConfig) =
    Config { buttonConfig | options = buttonConfig.options ++ [ option ] }


{-| Represent the color scheme used to render the button.
-}
type ColorScheme
    = Brand
    | BrandDark


{-| Internal. Checks if button is dark themed
-}
isDark : ColorScheme -> Bool
isDark =
    (==) BrandDark


type Size
    = Normal
    | Small


{-| Internal. Checks if button is `Normal` sized
-}
isNormal : Size -> Bool
isNormal =
    (==) Normal


{-| Internal. Checks if button is `Small` sized
-}
isSmall : Size -> Bool
isSmall =
    (==) Small


{-| Create a button with a `callOut` visual weight and a `default size`.

    --

    import Prima.Pyxis.Button as Button

    type Msg =
        Clicked

    ...

    myBtn : Button.Config Msg
    myBtn =
        Button.primary "Click me!"
            |> Button.withOnClick Clicked

-}
callOut : String -> Config msg
callOut label =
    Config (ButtonConfig CallOut Brand Normal label Nothing [])


{-| Create a button with a `Primary` visual weight and a `default size`.
-}
primary : String -> Config msg
primary label =
    Config (ButtonConfig Primary Brand Normal label Nothing [])


{-| Create a button with a `Secondary` visual weight and a `default size`.
-}
secondary : String -> Config msg
secondary label =
    Config (ButtonConfig Secondary Brand Normal label Nothing [])


{-| Create a button with a `Tertiary` visual weight and a `default size`.
-}
tertiary : String -> Config msg
tertiary label =
    Config (ButtonConfig Tertiary Brand Normal label Nothing [])


{-| Changes the size of the `Button`.
-}
withSize : Size -> Config msg -> Config msg
withSize size (Config buttonConfig) =
    Config { buttonConfig | size = size }


{-| Changes the color scheme of the `Button`.
-}
withColorScheme : ColorScheme -> Config msg -> Config msg
withColorScheme color (Config buttonConfig) =
    Config { buttonConfig | color = color }


{-| Adds an `icon` to the `Button`.
-}
withIcon : String -> Config msg -> Config msg
withIcon icon (Config buttonConfig) =
    Config { buttonConfig | icon = Just icon }


{-| Adds a `class` to the `Button`.
-}
withClass : String -> Config msg -> Config msg
withClass class_ =
    addOption (Class class_)


{-| Adds classes to the `classList` of the `Button`.
-}
withClassList : List ( String, Bool ) -> Config msg -> Config msg
withClassList classList =
    addOption (ClassList classList)


{-| Adds a `disabled` Html.Attribute to the `Button`.
-}
withDisabled : Bool -> Config msg -> Config msg
withDisabled isDisabled =
    addOption (Disabled isDisabled)


{-| Adds an `id` Html.Attribute to the `Button`.
-}
withId : String -> Config msg -> Config msg
withId id =
    addOption (Id id)


{-| Adds a `tabIndex` Html.Attribute to the `Button`.
-}
withTabIndex : Int -> Config msg -> Config msg
withTabIndex index =
    addOption (TabIndex index)


{-| Adds a `title` Html.Attribute to the `Button`.
-}
withTitle : String -> Config msg -> Config msg
withTitle title =
    addOption (Title title)


{-| Adds an `onClick` Html.Event to the `Button`.
-}
withOnClick : msg -> Config msg -> Config msg
withOnClick tagger =
    addOption (Event (Events.onClick tagger))


{-| Adds an `onMouseDown` Html.Event to the `Button`.
-}
withOnMouseDown : msg -> Config msg -> Config msg
withOnMouseDown tagger =
    addOption (Event (Events.onMouseDown tagger))


{-| Adds an `onMouseUp` Html.Event to the `Button`.
-}
withOnMouseUp : msg -> Config msg -> Config msg
withOnMouseUp tagger =
    addOption (Event (Events.onMouseUp tagger))


{-| Adds an `onMouseEnter` Html.Event to the `Button`.
-}
withOnMouseEnter : msg -> Config msg -> Config msg
withOnMouseEnter tagger =
    addOption (Event (Events.onMouseEnter tagger))


{-| Adds an `onMouseLeave` Html.Event to the `Button`.
-}
withOnMouseLeave : msg -> Config msg -> Config msg
withOnMouseLeave tagger =
    addOption (Event (Events.onMouseLeave tagger))


{-| Adds an `onMouseOver` Html.Event to the `Button`.
-}
withOnMouseOver : msg -> Config msg -> Config msg
withOnMouseOver tagger =
    addOption (Event (Events.onMouseOver tagger))


{-| Adds an `onMouseOut` Html.Event to the `Button`.
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

    import Prima.Pyxis.Button as Button

    type Msg =
        Clicked

    ...

    myBtn : Button.Config Msg
    myBtn =
        Button.callOut "Click me!"
            |> Button.withDisabled False
            |> Button.withOnClick Clicked

    ...

    view : Html Msg
    view =
        Button.render myBtn

-}
render : Config msg -> Html msg
render ((Config { label, icon }) as config) =
    button
        (buildAttributes config)
        [ span [] [ text label ]
        , icon
            |> Maybe.map renderIcon
            |> Maybe.withDefault (text "")
        ]


{-| Internal. Renders the icon
-}
renderIcon : String -> Html msg
renderIcon icon =
    Html.i
        [ Attrs.classList
            [ ( "a-icon", True )
            , ( "a-icon-" ++ icon, True )
            ]
        ]
        []


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
        |> (::) (buildClassList buttonConfig options)
        |> List.append options.attributes
        |> List.append options.events


{-| Internal. Merges the component configuration and options to a classList attribute.
-}
buildClassList : Config msg -> Options msg -> Html.Attribute msg
buildClassList (Config { emphasis, size, color }) options =
    [ ( "a-btn", True )
    , ( "a-btn--callout", isCallOut emphasis )
    , ( "a-btn--primary", isPrimary emphasis )
    , ( "a-btn--secondary", isSecondary emphasis )
    , ( "a-btn--tertiary", isTertiary emphasis )
    , ( "a-btn--small", isSmall size )
    , ( "a-btn--normal", isNormal size )
    , ( "a-btn--dark", isDark color )
    ]
        |> List.append options.classList
        |> List.append (List.map (H.flip Tuple.pair True) options.classes)
        |> Attrs.classList
