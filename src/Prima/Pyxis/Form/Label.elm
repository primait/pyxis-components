module Prima.Pyxis.Form.Label exposing
    ( Label, label, labelWithHtml
    , withAttributes, withClass, withExclusiveClass, withFor
    , render
    , addOption
    )

{-|


## Types and Configuration

@docs Label, label, labelWithHtml


## Generic modifiers

@docs withAttributes, withClass, withExclusiveClass, withFor


## Rendering

@docs render

-}

import Html exposing (Html, label, text)
import Html.Attributes as Attrs


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
label : List (LabelOption msg) -> String -> Label msg
label options str =
    Label <| LabelConfig options [ text str ]


{-| Creates a label with html content.
-}
labelWithHtml : List (LabelOption msg) -> List (Html msg) -> Label msg
labelWithHtml options children =
    Label <| LabelConfig options children


{-| Represents the possibile modifiers of a `Label`.
-}
type LabelOption msg
    = Attributes (List (Html.Attribute msg))
    | Class String
    | For String
    | ExclusiveClass String


{-| Represents the options a user can choose to modify
the `Label` default behaviour.
-}
type alias Options msg =
    { attributes : List (Html.Attribute msg)
    , classes : List String
    , for : Maybe String
    }


{-| Internal
-}
defaultOptions : Options msg
defaultOptions =
    { attributes = []
    , classes = [ "a-form-field__label" ]
    , for = Nothing
    }


{-| Internal
-}
addOption : LabelOption msg -> Label msg -> Label msg
addOption option (Label labelConfig) =
    Label { labelConfig | options = option :: labelConfig.options }


{-| Sets a list of `attributes` to the `Label config`.
-}
withAttributes : List (Html.Attribute msg) -> Label msg -> Label msg
withAttributes attributes_ =
    addOption (Attributes attributes_)


{-| Sets a class which will override the others to the `Label config`.
-}
withExclusiveClass : String -> Label msg -> Label msg
withExclusiveClass class_ =
    addOption (ExclusiveClass class_)


{-| Sets a class to the `Label config`.
-}
withClass : String -> Label msg -> Label msg
withClass class_ =
    addOption (Class class_)


{-| Sets a for to the `Label config`.
-}
withFor : String -> Label msg -> Label msg
withFor for_ =
    addOption (For for_)


{-| Internal
-}
applyOption : LabelOption msg -> Options msg -> Options msg
applyOption modifier options =
    case modifier of
        Attributes attributes_ ->
            { options | attributes = options.attributes ++ attributes_ }

        For for_ ->
            { options | for = Just for_ }

        Class class_ ->
            { options | classes = class_ :: options.classes }

        ExclusiveClass class_ ->
            { options | classes = [ class_ ] }


{-| Internal
-}
buildAttributes : List (LabelOption msg) -> List (Html.Attribute msg)
buildAttributes modifiers =
    let
        options =
            List.foldl applyOption defaultOptions modifiers
    in
    [ Maybe.map Attrs.for options.for
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

    import Prima.Pyxis.Form.Label as FormLabel

    view : Html msg
    view =
        FormLabel.label
            [ FormLabel.for "myForId"
            ]
            |> FormLabel.render

-}
render : Label msg -> Html msg
render (Label labelConfig) =
    Html.label
        (buildAttributes labelConfig.options)
        labelConfig.children
