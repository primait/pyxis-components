module Prima.Pyxis.Form.Label exposing
    ( Label, label, labelWithHtml
    , withAttribute, withClass, withOverridingClass, withFor, withOnClick, withSubtitle
    , render
    , addOption
    )

{-|


## Types and Configuration

@docs Label, label, labelWithHtml


## Generic modifiers

@docs withAttribute, withClass, withOverridingClass, withFor, withOnClick, withSubtitle


## Rendering

@docs render

-}

import Html exposing (Html, label, text)
import Html.Attributes as Attrs
import Html.Events as Events


{-| Represents the opaque `Label` configuration.
-}
type Label msg
    = Label (LabelConfig msg)


{-| Represents the `Label` configuration.
-}
type alias LabelConfig msg =
    { options : List (LabelOption msg)
    , children : List (Html msg)
    }


{-| Creates a label with string content.
-}
label : String -> Label msg
label str =
    Label <| LabelConfig [] [ text str ]


{-| Creates a label with html content.
-}
labelWithHtml : List (Html msg) -> Label msg
labelWithHtml children =
    Label <| LabelConfig [] children


{-| Represents the possibile modifiers of a `Label`.
-}
type LabelOption msg
    = Attribute (Html.Attribute msg)
    | Class String
    | For String
    | OnClick msg
    | OverridingClass String
    | Subtitle String


{-| Represents the options a user can choose to modify
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
    , classes = [ "a-form-field__label" ]
    , for = Nothing
    , onClick = Nothing
    , subLabel = Nothing
    }


{-| Internal
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
buildAttributes ((Label config) as labelModel) =
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
        |> (::) (classesAttribute options.classes)


{-| Transforms a `List` of `Class`(es) into a valid `Html.Attribute`.
-}
classesAttribute : List String -> Html.Attribute msg
classesAttribute =
    Attrs.class << String.join " "


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
renderSubtitle ((Label config) as labelModel) =
    let
        options =
            computeOptions labelModel
    in
    case options.subLabel of
        Nothing ->
            Html.text ""

        Just lbl ->
            Html.span
                [ Attrs.class "a-form-field__label__subtitle" ]
                [ text lbl ]


{-| Internal
-}
computeOptions : Label msg -> Options msg
computeOptions (Label config) =
    List.foldl applyOption defaultOptions config.options
