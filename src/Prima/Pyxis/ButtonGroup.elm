module Prima.Pyxis.ButtonGroup exposing
    ( Config
    , create
    , render
    , withAttribute, withAlignmentCentered, withAlignmentContentEnd, withAlignmentContentStart, withAlignmentCoverFluid, withAlignmentSpaceAround, withAlignmentSpaceBetween, withAlignmentSpaceEvenly, withClass, withId
    )

{-|


## Configuration

@docs Config


## Configuration Methods

@docs create


## Rendering

@docs render


## Options

@docs withAttribute, withAlignmentCentered, withAlignmentContentEnd, withAlignmentContentStart, withAlignmentCoverFluid, withAlignmentSpaceAround, withAlignmentSpaceBetween, withAlignmentSpaceEvenly, withClass, withId

-}

import Html exposing (Html)
import Html.Attributes as Attrs
import Prima.Pyxis.Button as B


{-| Represent the configuration of the buttonGroup.
-}
type Config msg
    = Config (ButtonGroupConfig msg)


type alias ButtonGroupConfig msg =
    { buttons : List (B.Config msg)
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
    , attributes : List (Html.Attribute msg)
    , id : Maybe String
    , alignment : Maybe Alignment
    }


type ButtonGroupOption msg
    = Class String
    | Attribute (Html.Attribute msg)
    | Id String
    | Alignment Alignment


defaultOptions : Options msg
defaultOptions =
    { classes = []
    , attributes = []
    , id = Nothing
    , alignment = Nothing
    }


{-| Internal. Applies the customizations made by end user to the `Button` component.
-}
applyOption : ButtonGroupOption msg -> Options msg -> Options msg
applyOption modifier options =
    case modifier of
        Class class ->
            { options | classes = class :: options.classes }

        Attribute attr ->
            { options | attributes = attr :: options.attributes }

        Id id ->
            { options | id = Just id }

        Alignment align ->
            { options | alignment = Just align }


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


{-| Create a button group.

    --


    import Prima.Pyxis.ButtonGroup as ButtonGroup

    myBtnGroup : ButtonGroup.Config Msg
    myBtnGroup =
        ButtonGroup.configure myButtons

-}
create : List (B.Config msg) -> Config msg
create buttons =
    Config (ButtonGroupConfig buttons [])


{-| Adds an alignment class to the `ButtonGroup`.
-}
withAlignmentSpaceBetween : Config msg -> Config msg
withAlignmentSpaceBetween =
    addOption (Alignment SpaceBetween)


{-| Adds an alignment class to the `ButtonGroup`.
-}
withAlignmentSpaceEvenly : Config msg -> Config msg
withAlignmentSpaceEvenly =
    addOption (Alignment SpaceEvenly)


{-| Adds an alignment class to the `ButtonGroup`.
-}
withAlignmentSpaceAround : Config msg -> Config msg
withAlignmentSpaceAround =
    addOption (Alignment SpaceAround)


{-| Adds an alignment class to the `ButtonGroup`.
-}
withAlignmentCentered : Config msg -> Config msg
withAlignmentCentered =
    addOption (Alignment Centered)


{-| Adds an alignment class to the `ButtonGroup`.
-}
withAlignmentContentStart : Config msg -> Config msg
withAlignmentContentStart =
    addOption (Alignment ContentStart)


{-| Adds an alignment class to the `ButtonGroup`.
-}
withAlignmentContentEnd : Config msg -> Config msg
withAlignmentContentEnd =
    addOption (Alignment ContentEnd)


{-| Adds an alignment class to the `ButtonGroup`.
-}
withAlignmentCoverFluid : Config msg -> Config msg
withAlignmentCoverFluid =
    addOption (Alignment CoverFluid)


{-| Adds a class to the `ButtonGroup`.
-}
withClass : String -> Config msg -> Config msg
withClass class =
    addOption (Class class)


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
alignmentToClass : Alignment -> String
alignmentToClass alignment =
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
            "btn-group--cover-fluid"


{-| Internal. Merges the component configuration and options to a classes attribute.
-}
buildClasses : Options msg -> List (Html.Attribute msg)
buildClasses options =
    [ Attrs.class "btn-group"
    , Attrs.class (String.join " " options.classes)
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
    , options.alignment
        |> Maybe.map (Attrs.class << alignmentToClass)
    ]
        |> List.filterMap identity
        |> (++) (buildClasses options)
        |> List.append options.attributes
