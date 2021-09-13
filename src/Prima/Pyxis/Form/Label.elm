module Prima.Pyxis.Form.Label exposing
    ( Label
    , label, labelWithHtml
    , render
    , withAttribute, withClass, withConditionallyFor, withFor, withOverridingClass, withSubtitle
    , withOnClick
    )

{-|


## Configuration

@docs Label


## Configuration Methods

@docs label, labelWithHtml


## Rendering

@docs render


## Options

@docs withAttribute, withClass, withConditionallyFor, withFor, withOverridingClass, withSubtitle


## Event Options

@docs withOnClick

-}

import Html exposing (Html, text)
import Html.Attributes as Attrs
import Html.Events as Events
import Prima.Pyxis.Helpers as H


{-| Represent the opaque `Label` configuration.
-}
type Label msg
    = Label (LabelConfig msg)


{-| Represent the `Label` configuration.
-}
type alias LabelConfig msg =
    { options : List (LabelOption msg)
    , children : List (Html msg)
    }


{-| Create a label with string content.
-}
label : String -> Label msg
label str =
    Label <| LabelConfig [] [ text str ]


{-| Create a label with html content.
-}
labelWithHtml : List (Html msg) -> Label msg
labelWithHtml children =
    Label <| LabelConfig [] children


{-| Represent the possibile modifiers of a `Label`.
-}
type LabelOption msg
    = Attribute (Html.Attribute msg)
    | Class String
    | For String
    | OnClick msg
    | OverridingClass String
    | Subtitle String


{-| Represent the options a user can choose to modify
the `Label` default behaviour.
-}
type alias Options msg =
    { attributes : List (Html.Attribute msg)
    , classes : List String
    , for : Maybe String
    , onClick : Maybe msg
    , subLabel : Maybe String
    }


{-| Internal
-}
defaultOptions : Options msg
defaultOptions =
    { attributes = []
    , classes = [ "form-label" ]
    , for = Nothing
    , onClick = Nothing
    , subLabel = Nothing
    }


{-| Internal.
-}
addOption : LabelOption msg -> Label msg -> Label msg
addOption option (Label labelConfig) =
    Label { labelConfig | options = option :: labelConfig.options }


{-| Sets an `attribute` to the `Label config`.
-}
withAttribute : Html.Attribute msg -> Label msg -> Label msg
withAttribute attribute =
    addOption (Attribute attribute)


{-| Sets a class which will override the others to the `Label config`.
-}
withOverridingClass : String -> Label msg -> Label msg
withOverridingClass class =
    addOption (OverridingClass class)


{-| Sets a class to the `Label config`.
-}
withClass : String -> Label msg -> Label msg
withClass class =
    addOption (Class class)


{-| Sets a for to the `Label config`.
-}
withFor : String -> Label msg -> Label msg
withFor for =
    addOption (For for)


{-| Sets a for to the `Label config` if the maybeFor argument has a value,
otherwise it leaves the `Label config` unchanged.
-}
withConditionallyFor : Maybe String -> Label msg -> Label msg
withConditionallyFor maybeFor =
    maybeFor
        |> Maybe.map withFor
        |> Maybe.withDefault identity


{-| Sets an `onClick` to the `Label config`.
-}
withOnClick : msg -> Label msg -> Label msg
withOnClick onClick =
    addOption (OnClick onClick)


{-| Sets a `subLabel` to the `Label config`.
-}
withSubtitle : String -> Label msg -> Label msg
withSubtitle lbl =
    addOption (Subtitle lbl)


{-| Internal
-}
applyOption : LabelOption msg -> Options msg -> Options msg
applyOption modifier options =
    case modifier of
        Attribute attribute ->
            { options | attributes = attribute :: options.attributes }

        For for ->
            { options | for = Just for }

        Class class ->
            { options | classes = class :: options.classes }

        OnClick msg ->
            { options | onClick = Just msg }

        OverridingClass class ->
            { options | classes = [ class ] }

        Subtitle lbl ->
            { options | subLabel = Just lbl }


{-| Internal
-}
buildAttributes : Label msg -> List (Html.Attribute msg)
buildAttributes ((Label _) as labelModel) =
    let
        options =
            computeOptions labelModel
    in
    [ options.for
        |> Maybe.map Attrs.for
    , options.onClick
        |> Maybe.map Events.onClick
    ]
        |> List.filterMap identity
        |> (++) options.attributes
        |> (::) (H.classesAttribute options.classes)


{-| Renders a `Label config`.

    import Prima.Pyxis.Form.Label as Label

    view : List (Html msg)
    view =
        "My Label"
            |> Label.label
            |> Label.withId "myForId"
            |> Label.render

-}
render : Label msg -> Html msg
render ((Label config) as labelModel) =
    Html.label
        (buildAttributes labelModel)
        (config.children ++ [ renderSubtitle labelModel ])


renderSubtitle : Label msg -> Html msg
renderSubtitle ((Label _) as labelModel) =
    let
        options =
            computeOptions labelModel
    in
    case options.subLabel of
        Nothing ->
            Html.text ""

        Just lbl ->
            Html.span
                [ Attrs.class "form-label__subtitle" ]
                [ text lbl ]


{-| Internal
-}
computeOptions : Label msg -> Options msg
computeOptions (Label config) =
    List.foldl applyOption defaultOptions config.options
