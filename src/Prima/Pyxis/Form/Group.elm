module Prima.Pyxis.Form.Group exposing
    ( Group
    , group
    , groupInput
    , groupSelect
    , render
    , withAppendGroup
    , withAttribute
    , withClass
    , withId
    , withPrependGroup
    )

import Html exposing (Html)
import Html.Attributes as Attrs
import Prima.Pyxis.Form.Input as Input
import Prima.Pyxis.Form.Select as Select


type Group model msg
    = Group (GroupConfig model msg)


type alias GroupConfig model msg =
    { options : List (GroupOption msg)
    , fields : List (GroupField model msg)
    }


type GroupField model msg
    = InputGroupField (Input.Input model msg)
    | SelectGroupField (Select.Select model msg)
    | HtmlGroupField (List (Html msg))


groupInput : Input.Input model msg -> GroupField model msg
groupInput =
    InputGroupField


groupSelect : Select.Select model msg -> GroupField model msg
groupSelect =
    SelectGroupField


groupHtml : List (Html msg) -> GroupField model msg
groupHtml =
    HtmlGroupField


group : List (GroupField model msg) -> Group model msg
group =
    Group << GroupConfig []


type GroupOption msg
    = Attribute (Html.Attribute msg)
    | Class String
    | Id String
    | Type (GroupType msg)


type alias Options msg =
    { attributes : List (Html.Attribute msg)
    , classes : List String
    , id : Maybe String
    , type_ : GroupType msg
    }


defaultOptions : Options msg
defaultOptions =
    { attributes = []
    , classes = [ "m-form-input-group" ]
    , id = Nothing
    , type_ = Wrap
    }


type GroupType msg
    = Append (List (Html msg))
    | Prepend (List (Html msg))
    | Wrap


{-| Internal.
-}
applyOption : GroupOption msg -> Options msg -> Options msg
applyOption modifier options =
    case modifier of
        Attribute attribute ->
            { options | attributes = attribute :: options.attributes }

        Class class ->
            { options | classes = class :: options.classes }

        Id id ->
            { options | id = Just id }

        Type type_ ->
            { options | type_ = type_ }


{-| Internal
-}
computeOptions : Group model msg -> Options msg
computeOptions (Group config) =
    List.foldl applyOption defaultOptions config.options


{-| Internal.
-}
addOption : GroupOption msg -> Group model msg -> Group model msg
addOption option (Group groupConfig) =
    Group { groupConfig | options = groupConfig.options ++ [ option ] }


withAttribute : Html.Attribute msg -> Group model msg -> Group model msg
withAttribute attribute =
    addOption (Attribute attribute)


withAppendGroup : List (Html msg) -> Group model msg -> Group model msg
withAppendGroup content =
    addOption (Type <| Append content)


withClass : String -> Group model msg -> Group model msg
withClass class =
    addOption (Class class)


withId : String -> Group model msg -> Group model msg
withId id =
    addOption (Id id)


withPrependGroup : List (Html msg) -> Group model msg -> Group model msg
withPrependGroup content =
    addOption (Type <| Prepend content)


{-| Transforms a `List` of `Class`(es) into a valid `Html.Attribute`.
-}
classesAttribute : List String -> Html.Attribute msg
classesAttribute =
    Attrs.class << String.join " "


{-| Composes all the modifiers into a set of `Html.Attribute`(s).
-}
buildAttributes : Group model msg -> List (Html.Attribute msg)
buildAttributes ((Group config) as inputModel) =
    let
        options =
            computeOptions inputModel
    in
    [ options.id
        |> Maybe.map Attrs.id
    ]
        |> List.filterMap identity
        |> (::) (classesAttribute options.classes)


render : model -> Group model msg -> Html msg
render model ((Group config) as groupModel) =
    let
        options =
            computeOptions groupModel
    in
    Html.div
        (buildAttributes groupModel)
        (case options.type_ of
            Append appendableContent ->
                Html.div
                    [ Attrs.class "m-form-input-group__append"
                    ]
                    appendableContent
                    :: (config.fields
                            |> List.map (renderField model)
                            |> List.concat
                       )

            Prepend prependableContent ->
                Html.div
                    [ Attrs.class "m-form-input-group__prepend"
                    ]
                    prependableContent
                    :: (config.fields
                            |> List.map (renderField model)
                            |> List.concat
                       )

            Wrap ->
                config.fields
                    |> List.map (renderField model)
                    |> List.concat
        )


renderField : model -> GroupField model msg -> List (Html msg)
renderField model field =
    case field of
        InputGroupField fieldConfig ->
            Input.render model fieldConfig

        SelectGroupField fieldConfig ->
            Select.render model fieldConfig

        HtmlGroupField html ->
            html
