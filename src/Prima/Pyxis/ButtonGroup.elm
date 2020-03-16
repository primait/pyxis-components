module Prima.Pyxis.ButtonGroup exposing
    ( Config, spaceBetween, spaceEvenly, spaceAround, centered, contentStart, contentEnd, coverFluid
    , withAttribute, withClass, withClassList, withId
    , render
    )

{-| Create a `ButtonGroup` using predefined Html syntax.


# Types and Configuration

@docs Config, spaceBetween, spaceEvenly, spaceAround, centered, contentStart, contentEnd, coverFluid


## Options

@docs withAttribute, withClass, withClassList, withFluid, withId


# Render

@docs render

-}

import Html exposing (Html)
import Html.Attributes as Attrs
import Prima.Pyxis.Button as B
import Prima.Pyxis.Helpers as H


{-| Represent the configuration of the buttonGroup.
-}
type Config msg
    = Config (ButtonGroupConfig msg)


type alias ButtonGroupConfig msg =
    { buttons : List (B.Config msg)
    , alignment : Alignment
    , options : List (ButtonGroupOption msg)
    }


{-| Internal. Represents the alignment of the buttons in the group.
-}
type Alignment
    = SpaceBetween
    | SpaceEvenly
    | SpaceAround
    | Centered
    | ContentStart
    | ContentEnd
    | CoverFluid


{-| Internal. Represents the list of customizations for the `ButtonGroup` component.
-}
type alias Options msg =
    { classes : List String
    , classList : List ( String, Bool )
    , attributes : List (Html.Attribute msg)
    , id : Maybe String
    }


type ButtonGroupOption msg
    = Class String
    | ClassList (List ( String, Bool ))
    | Attribute (Html.Attribute msg)
    | Id String


defaultOptions : Options msg
defaultOptions =
    { classes = []
    , classList = []
    , attributes = []
    , id = Nothing
    }


{-| Internal. Applies the customizations made by end user to the `Button` component.
-}
applyOption : ButtonGroupOption msg -> Options msg -> Options msg
applyOption modifier options =
    case modifier of
        Class class ->
            { options | classes = class :: options.classes }

        ClassList list ->
            { options | classList = List.append list options.classList }

        Attribute attr ->
            { options | attributes = attr :: options.attributes }

        Id id ->
            { options | id = Just id }


{-| Internal. Applies all the customizations and returns the internal `Options` type.
-}
computeOptions : Config msg -> Options msg
computeOptions (Config config) =
    List.foldl applyOption defaultOptions config.options


{-| Internal. Adds a generic option to the `Button`.
-}
addOption : ButtonGroupOption msg -> Config msg -> Config msg
addOption option (Config buttonGroupConfig) =
    Config { buttonGroupConfig | options = buttonGroupConfig.options ++ [ option ] }


{-| Create a button group with a `SpaceBetween` alignment.

    --


    import Prima.Pyxis.ButtonGroup as ButtonGroup

    myBtnGroup : ButtonGroup.Config Msg
    myBtnGroup =
        ButtonGroup.spaceBetween myButtons

-}
spaceBetween : List (B.Config msg) -> Config msg
spaceBetween buttons =
    Config (ButtonGroupConfig buttons SpaceBetween [])


{-| Create a button group with a `SpaceEvenly` alignment.
-}
spaceEvenly : List (B.Config msg) -> Config msg
spaceEvenly buttons =
    Config (ButtonGroupConfig buttons SpaceEvenly [])


{-| Create a button group with a `SpaceAround` alignment.
-}
spaceAround : List (B.Config msg) -> Config msg
spaceAround buttons =
    Config (ButtonGroupConfig buttons SpaceAround [])


{-| Create a button group with a `Centered` alignment.
-}
centered : List (B.Config msg) -> Config msg
centered buttons =
    Config (ButtonGroupConfig buttons Centered [])


{-| Create a button group with a `ContentStart` alignment.
-}
contentStart : List (B.Config msg) -> Config msg
contentStart buttons =
    Config (ButtonGroupConfig buttons ContentStart [])


{-| Create a button group with a `ContentEnd` alignment.
-}
contentEnd : List (B.Config msg) -> Config msg
contentEnd buttons =
    Config (ButtonGroupConfig buttons ContentEnd [])


{-| Create a button group with a `CoverFluid` alignment.
-}
coverFluid : List (B.Config msg) -> Config msg
coverFluid buttons =
    Config (ButtonGroupConfig buttons CoverFluid [])


{-| Adds a `class` to the `ButtonGroup`.
-}
withClass : String -> Config msg -> Config msg
withClass class_ =
    addOption (Class class_)


{-| Adds classes to the `classList` of the `ButtonGroup`.
-}
withClassList : List ( String, Bool ) -> Config msg -> Config msg
withClassList classList =
    addOption (ClassList classList)


{-| Adds a generic attribute to the `ButtonGroup`.
-}
withAttribute : Html.Attribute msg -> Config msg -> Config msg
withAttribute attr =
    addOption (Attribute attr)


{-| Adds an `id` Html.Attribute to the `ButtonGroup`.
-}
withId : String -> Config msg -> Config msg
withId id =
    addOption (Id id)


{-| Create a button wrapper which can hold a set of `Button`s.

    --

    import Prima.Pyxis.Button as Button
    import Prima.Pyxis.ButtonGroup as Group

    type Msg =
        Clicked

    ...

    ctaBtn : Button.Config Msg
    ctaBtn =
        Button.callOut "Click me!"
            |> Button.withOnClick Clicked
            |> Button.withDisabled True


    primaryBtn : Button.Config Msg
    primaryBtn =
        Button.primary "Click me!"
            |> Button.withOnClick Clicked

    ...

    buttonGroup : ButtonGroup.Config Msg
    buttonGroup =
        ButtonGroup.centered [ctaBtn, primaryBtn]
            |> ButtonGroup.withId "group-1"

    ...

    view : Html Msg
    view =
        ButtonGroup.render buttonGroup

-}
render : Config msg -> Html msg
render ((Config { buttons }) as config) =
    Html.div
        (buildAttributes config)
        (List.map B.render buttons)


{-| Internal. Transforms the alignment into the appropriate class.
-}
buildAlignmentClass : Alignment -> String
buildAlignmentClass alignment =
    case alignment of
        SpaceBetween ->
            "justify-content-between"

        SpaceEvenly ->
            "justify-content-evenly"

        SpaceAround ->
            "justify-content-around"

        Centered ->
            "justify-content-center"

        ContentStart ->
            "justify-content-start"

        ContentEnd ->
            "justify-content-end"

        CoverFluid ->
            "m-btnGroup--coverFluid"


{-| Internal. Merges the component configuration and options to a classList attribute.
-}
buildClassList : Options msg -> Config msg -> Html.Attribute msg
buildClassList options (Config { alignment }) =
    [ ( "m-btnGroup", True )
    , ( buildAlignmentClass alignment, True )
    ]
        |> List.append options.classList
        |> List.append (List.map (H.flip Tuple.pair True) options.classes)
        |> Attrs.classList


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
    ]
        |> List.filterMap identity
        |> (::) (buildClassList options buttonConfig)
        |> List.append options.attributes
