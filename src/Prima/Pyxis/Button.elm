module Prima.Pyxis.Button exposing
    ( Config
    , callOut, primary, secondary, tertiary, loading, primaryAlt, secondaryAlt, tertiaryAlt
    , render
    , withAttribute, withClass, withDisabled, withIcon, withId, withMediumSize, withSmallSize, withTinySize, withTabIndex, withTargetBlank, withTargetParent, withTargetSelf, withTargetTop, withTitle, withTypeButton, withTypeReset, withTypeSubmit, withLoading
    , withOnClick, withOnMouseDown, withOnMouseUp, withOnMouseEnter, withOnMouseLeave, withOnMouseOver, withOnMouseOut
    )

{-|


## Configuration

@docs Config


## Configuration Methods

@docs callOut, primary, secondary, tertiary, loading, primaryAlt, secondaryAlt, tertiaryAlt


## Rendering

@docs render


## Options

@docs withAttribute, withClass, withDisabled, withIcon, withId, withMediumSize, withSmallSize, withTinySize, withTabIndex, withTargetBlank, withTargetParent, withTargetSelf, withTargetTop, withTitle, withTypeButton, withTypeReset, withTypeSubmit, withLoading


## Event Options

@docs withOnClick, withOnMouseDown, withOnMouseUp, withOnMouseEnter, withOnMouseLeave, withOnMouseOver, withOnMouseOut

-}

import Html exposing (Html, button, span, text)
import Html.Attributes as Attrs
import Html.Events as Events
import Maybe.Extra as ME


{-| Represent the configuration of the `Button`.
-}
type Config msg
    = Config (ButtonConfig msg)


type alias ButtonConfig msg =
    { emphasis : Emphasis
    , isLoadingState : Bool
    , size : Size
    , label : String
    , icon : Maybe String
    , options : List (ButtonOption msg)
    }


{-| Represent the visual weight of the `Button`.
-}
type Emphasis
    = CallOut
    | Primary
    | PrimaryAlt
    | Secondary
    | SecondaryAlt
    | Tertiary
    | TertiaryAlt
    | Loading


isCallOut : Emphasis -> Bool
isCallOut =
    (==) CallOut


isPrimary : Emphasis -> Bool
isPrimary =
    (==) Primary


isPrimaryAlt : Emphasis -> Bool
isPrimaryAlt =
    (==) PrimaryAlt


isSecondary : Emphasis -> Bool
isSecondary =
    (==) Secondary


isSecondaryAlt : Emphasis -> Bool
isSecondaryAlt =
    (==) SecondaryAlt


isTertiary : Emphasis -> Bool
isTertiary =
    (==) Tertiary


isTertiaryAlt : Emphasis -> Bool
isTertiaryAlt =
    (==) TertiaryAlt


isLoading : Emphasis -> Bool
isLoading =
    (==) Loading


{-| Represents a `Button` type.
-}
type Type_
    = Button
    | Submit
    | Reset


{-| Represents a `Button` target.
-}
type Target
    = Blank
    | Self
    | Parent
    | Top


{-| Internal. Represents the list of customizations for the `Button` component.
-}
type alias Options msg =
    { classes : List String
    , events : List (Html.Attribute msg)
    , attributes : List (Html.Attribute msg)
    , disabled : Maybe Bool
    , id : Maybe String
    , tabIndex : Maybe Int
    , title : Maybe String
    , type_ : Type_
    , target : Target
    }


{-| Internal. Represents the possible modifiers for a `Button`.
-}
type ButtonOption msg
    = Class String
    | Event (Html.Attribute msg)
    | Disabled Bool
    | Id String
    | TabIndex Int
    | Title String
    | Attribute (Html.Attribute msg)
    | Type_ Type_
    | FormTarget Target


{-| Internal. Represents the initial state of the list of customizations for the `Button` component.
-}
defaultOptions : Options msg
defaultOptions =
    { classes = []
    , events = []
    , disabled = Nothing
    , id = Nothing
    , tabIndex = Nothing
    , title = Nothing
    , attributes = []
    , type_ = Button
    , target = Self
    }


{-| Internal. Applies the customizations made by end user to the `Button` component.
-}
applyOption : ButtonOption msg -> Options msg -> Options msg
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

        Type_ type_ ->
            { options | type_ = type_ }

        FormTarget target ->
            { options | target = target }


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


type Size
    = Medium
    | Small
    | Tiny


{-| Internal. Checks if button is `Normal` sized
-}
isMedium : Size -> Bool
isMedium =
    (==) Medium


{-| Internal. Checks if button is `Small` sized
-}
isSmall : Size -> Bool
isSmall =
    (==) Small


{-| Internal. Checks if button is `Tiny` sized
-}
isTiny : Size -> Bool
isTiny =
    (==) Tiny


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
    Config (ButtonConfig CallOut False Medium label Nothing [])


{-| Create a button with a `Primary` visual weight and a `default size`.
-}
primary : String -> Config msg
primary label =
    Config (ButtonConfig Primary False Medium label Nothing [])


{-| Create a button with a `Primary Alt` visual weight and a `default size`.
-}
primaryAlt : String -> Config msg
primaryAlt label =
    Config (ButtonConfig PrimaryAlt False Medium label Nothing [])


{-| Create a button with a `Secondary` visual weight and a `default size`.
-}
secondary : String -> Config msg
secondary label =
    Config (ButtonConfig Secondary False Medium label Nothing [])


{-| Create a button with a `Secondary Alt` visual weight and a `default size`.
-}
secondaryAlt : String -> Config msg
secondaryAlt label =
    Config (ButtonConfig SecondaryAlt False Medium label Nothing [])


{-| Create a button with a `Tertiary` visual weight and a `default size`.
-}
tertiary : String -> Config msg
tertiary label =
    Config (ButtonConfig Tertiary False Medium label Nothing [])


{-| Create a button with a `Tertiary Alt` visual weight and a `default size`.
-}
tertiaryAlt : String -> Config msg
tertiaryAlt label =
    Config (ButtonConfig TertiaryAlt False Medium label Nothing [])


{-| Create a button with a `Loading` visual weight and a `default size`.
-}
loading : String -> Config msg
loading label =
    Config (ButtonConfig Loading False Medium label Nothing [])


{-| Sets a size of `Tiny` to the `Button`.
-}
withTinySize : Config msg -> Config msg
withTinySize (Config buttonConfig) =
    Config { buttonConfig | size = Tiny }


{-| Sets a size of `Small` to the `Button`.
-}
withSmallSize : Config msg -> Config msg
withSmallSize (Config buttonConfig) =
    Config { buttonConfig | size = Small }


{-| Sets a size of `Medium` to the `Button`.
-}
withMediumSize : Config msg -> Config msg
withMediumSize (Config buttonConfig) =
    Config { buttonConfig | size = Medium }


{-| Adds an `icon` to the `Button`.
-}
withIcon : String -> Config msg -> Config msg
withIcon icon (Config buttonConfig) =
    Config { buttonConfig | icon = Just icon }


{-| Adds classes to the `classes` of the `Button`.
-}
withClass : String -> Config msg -> Config msg
withClass class =
    addOption (Class class)


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


{-| Adds a `type` Html.Attribute to the `Button`.
-}
withTypeButton : Config msg -> Config msg
withTypeButton =
    addOption (Type_ Button)


{-| Adds a `type` Html.Attribute to the `Button`.
-}
withTypeSubmit : Config msg -> Config msg
withTypeSubmit =
    addOption (Type_ Submit)


{-| Adds a `type` Html.Attribute to the `Button`.
-}
withTypeReset : Config msg -> Config msg
withTypeReset =
    addOption (Type_ Reset)


{-| Adds a `target` Html.Attribute to the `Button`.
-}
withTargetBlank : Config msg -> Config msg
withTargetBlank =
    addOption (FormTarget Blank)


{-| Adds a `target` Html.Attribute to the `Button`.
-}
withTargetSelf : Config msg -> Config msg
withTargetSelf =
    addOption (FormTarget Self)


{-| Adds a `target` Html.Attribute to the `Button`.
-}
withTargetParent : Config msg -> Config msg
withTargetParent =
    addOption (FormTarget Parent)


{-| Adds a `target` Html.Attribute to the `Button`.
-}
withTargetTop : Config msg -> Config msg
withTargetTop =
    addOption (FormTarget Top)


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


{-| Sets a emphasis of `Loading` to the `Button`.
-}
withLoading : Bool -> Config msg -> Config msg
withLoading checkLoading (Config buttonConfig) =
    Config { buttonConfig | isLoadingState = checkLoading }


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
        [ span [ Attrs.class "btn__text" ] [ text label ]
        , ME.unwrap (text "") renderIcon icon
        ]


{-| Internal. Renders the icon
-}
renderIcon : String -> Html msg
renderIcon icon =
    Html.i
        [ Attrs.classList
            [ ( "icon", True )
            , ( "icon-" ++ icon, True )
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
        |> (::) (buildType options)
        |> (::) (buildFormTarget options)
        |> (++) (buildClasses buttonConfig options)
        |> List.append options.attributes
        |> List.append options.events


{-| Internal. Constructs the `type` attribute from the `Button` options.
-}
buildType : Options msg -> Html.Attribute msg
buildType options =
    case options.type_ of
        Button ->
            Attrs.type_ "button"

        Submit ->
            Attrs.type_ "submit"

        Reset ->
            Attrs.type_ "reset"


{-| Internal. Constructs the `formtarget` attribute from the `Button` options.
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
buildClasses : Config msg -> Options msg -> List (Html.Attribute msg)
buildClasses (Config { emphasis, size, isLoadingState }) options =
    [ Attrs.classList
        [ ( "btn", True )
        , ( "btn--callout", isCallOut emphasis )
        , ( "btn--primary", isPrimary emphasis )
        , ( "btn--primary-alt", isPrimaryAlt emphasis )
        , ( "btn--secondary", isSecondary emphasis )
        , ( "btn--secondary-alt", isSecondaryAlt emphasis )
        , ( "btn--tertiary", isTertiary emphasis )
        , ( "btn--tertiary-alt", isTertiaryAlt emphasis )
        , ( "btn--loading", isLoading emphasis )
        , ( "btn--small", isSmall size )
        , ( "btn--tiny", isTiny size )
        , ( "btn--medium", isMedium size )
        , ( "is-loading", not (isLoading emphasis) && isLoadingState )
        ]
    , options.classes
        |> String.join " "
        |> Attrs.class
    ]
