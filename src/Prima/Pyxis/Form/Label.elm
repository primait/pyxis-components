module Prima.Pyxis.Form.Label exposing
    ( Label
    , addOption
    , attributes
    , for
    , label
    , labelWithHtml
    , render
    , withAttributes
    )

import Html exposing (Html, label, text)
import Html.Attributes as Attrs


type Label msg
    = Label (LabelConfig msg)


type alias LabelConfig msg =
    { options : List (LabelOption msg)
    , children : List (Html msg)
    }


label : List (LabelOption msg) -> String -> Label msg
label options str =
    Label <| LabelConfig options [ text str ]


labelWithHtml : List (LabelOption msg) -> List (Html msg) -> Label msg
labelWithHtml options children =
    Label <| LabelConfig options children


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
    { attributes = [ Attrs.class "a-form-field__label" ]
    , for = Nothing
    }


addOption : LabelOption msg -> Label msg -> Label msg
addOption option (Label labelConfig) =
    Label { labelConfig | options = option :: labelConfig.options }


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


withAttributes : List (Html.Attribute msg) -> Label msg -> Label msg
withAttributes attributes_ =
    addOption (Attributes attributes_)


render : Label msg -> Html msg
render (Label labelConfig) =
    Html.label
        (buildAttributes labelConfig.options)
        labelConfig.children
