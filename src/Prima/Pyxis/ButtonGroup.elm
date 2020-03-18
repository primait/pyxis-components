module Prima.Pyxis.ButtonGroup exposing
    ( Config, Alignment(..), create
    , withAttribute, withAlignment, withClassList, withId
    , render
    )

{-| Create a `ButtonGroup` using predefined Html syntax.


# Types and Configuration

@docs Config, Alignment, create


## Options

@docs withAttribute, withAlignment, withClassList, withFluid, withId


# Render

@docs render

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
    { classList : List ( String, Bool )
    , attributes : List (Html.Attribute msg)
    , id : Maybe String
    , alignment : Maybe Alignment
    }


type ButtonGroupOption msg
    = ClassList (List ( String, Bool ))
    | Attribute (Html.Attribute msg)
    | Id String
    | Alignment Alignment


defaultOptions : Options msg
defaultOptions =
    { classList = []
    , attributes = []
    , id = Nothing
    , alignment = Nothing
    }


{-| Internal. Applies the customizations made by end user to the `Button` component.
-}
applyOption : ButtonGroupOption msg -> Options msg -> Options msg
applyOption modifier options =
    case modifier of
        ClassList list ->
            { options | classList = List.append list options.classList }

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


{-| Adds classes to the `classList` of the `ButtonGroup`.
-}
withAlignment : Alignment -> Config msg -> Config msg
withAlignment align =
    addOption (Alignment align)


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
buildAlignmentClass : Maybe Alignment -> ( String, Bool )
buildAlignmentClass alignment =
    case alignment of
        Just SpaceBetween ->
            ( "justify-content-between", True )

        Just SpaceEvenly ->
            ( "justify-content-evenly", True )

        Just SpaceAround ->
            ( "justify-content-around", True )

        Just Centered ->
            ( "justify-content-center", True )

        Just ContentStart ->
            ( "justify-content-start", True )

        Just ContentEnd ->
            ( "justify-content-end", True )

        Just CoverFluid ->
            ( "m-btnGroup--coverFluid", True )

        Nothing ->
            ( "", False )


{-| Internal. Merges the component configuration and options to a classList attribute.
-}
buildClassList : Options msg -> Html.Attribute msg
buildClassList options =
    [ ( "m-btnGroup", True )
    , buildAlignmentClass options.alignment
    ]
        |> List.append options.classList
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
        |> (::) (buildClassList options)
        |> List.append options.attributes
