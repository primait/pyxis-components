module Prima.Pyxis.Form.Label exposing
    ( Label
    , attributes
    , for
    , label
    , labelWithHtml
    , render
    )

import Html exposing (Html, label, text)
import Html.Attributes as Attrs


type Label msg
    = Label (LabelConfig msg)


type alias LabelConfig msg =
    { children : List (Html msg)
    , options : List (LabelOption msg)
    }


label : String -> List (LabelOption msg) -> Label msg
label str =
    Label << LabelConfig [ text str ]


labelWithHtml : List (Html msg) -> List (LabelOption msg) -> Label msg
labelWithHtml children options =
    Label <| LabelConfig children options


type LabelOption msg
    = Attributes (List (Html.Attribute msg))
    | For String


attributes : List (Html.Attribute msg) -> LabelOption msg
attributes =
    Attributes


for : String -> LabelOption msg
for =
    For


type alias Options msg =
    { attributes : List (Html.Attribute msg)
    , for : Maybe String
    }


defaultOptions : Options msg
defaultOptions =
    { attributes = []
    , for = Nothing
    }


applyOption : LabelOption msg -> Options msg -> Options msg
applyOption modifier options =
    case modifier of
        Attributes attributes_ ->
            { options | attributes = options.attributes ++ attributes_ }

        For for_ ->
            { options | for = Just for_ }


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


render : Label msg -> Html msg
render (Label labelConfig) =
    Html.label
        (buildAttributes labelConfig.options)
        labelConfig.children
