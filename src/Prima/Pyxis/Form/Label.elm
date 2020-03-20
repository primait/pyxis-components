module Prima.Pyxis.Form.Label exposing
    ( Config, label, labelWithHtml
    , withAttribute, withClass, withOverridingClass, withFor, withOnClick, withSubtitle
    , render
    , addOption
    )

{-|


## Types and Configuration

@docs Config, label, labelWithHtml


## Generic modifiers

@docs withAttribute, withClass, withOverridingClass, withFor, withOnClick, withSubtitle


## Rendering

@docs render

-}

import Html exposing (Html, text)
import Html.Attributes as Attrs
import Html.Events as Events
import Prima.Pyxis.Helpers as H


{-| Represent the opaque `Label` configuration.
-}
type Config msg
    = Config (LabelConfig msg)


{-| Represent the `Label` configuration.
-}
type alias LabelConfig msg =
    { options : List (LabelOption msg)
    , children : List (Html msg)
    }


{-| Create a label with string content.
-}
label : String -> Config msg
label str =
    Config <| LabelConfig [] [ text str ]


{-| Create a label with html content.
-}
labelWithHtml : List (Html msg) -> Config msg
labelWithHtml children =
    Config <| LabelConfig [] children


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
    , classes = [ "a-form-field__label" ]
    , for = Nothing
    , onClick = Nothing
    , subLabel = Nothing
    }


{-| Internal
-}
addOption : LabelOption msg -> Config msg -> Config msg
addOption option (Config labelConfig) =
    Config { labelConfig | options = option :: labelConfig.options }


{-| Sets an `attribute` to the `Label config`.
-}
withAttribute : Html.Attribute msg -> Config msg -> Config msg
withAttribute attribute =
    addOption (Attribute attribute)


{-| Sets a class which will override the others to the `Label config`.
-}
withOverridingClass : String -> Config msg -> Config msg
withOverridingClass class =
    addOption (OverridingClass class)


{-| Sets a class to the `Label config`.
-}
withClass : String -> Config msg -> Config msg
withClass class =
    addOption (Class class)


{-| Sets a for to the `Label config`.
-}
withFor : String -> Config msg -> Config msg
withFor for =
    addOption (For for)


{-| Sets an `onClick` to the `Label config`.
-}
withOnClick : msg -> Config msg -> Config msg
withOnClick onClick =
    addOption (OnClick onClick)


{-| Sets a `subLabel` to the `Label config`.
-}
withSubtitle : String -> Config msg -> Config msg
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
buildAttributes : Config msg -> List (Html.Attribute msg)
buildAttributes ((Config _) as labelModel) =
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
render : Config msg -> Html msg
render ((Config config) as labelModel) =
    Html.label
        (buildAttributes labelModel)
        (config.children ++ [ renderSubtitle labelModel ])


renderSubtitle : Config msg -> Html msg
renderSubtitle ((Config _) as labelModel) =
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
computeOptions : Config msg -> Options msg
computeOptions (Config config) =
    List.foldl applyOption defaultOptions config.options
