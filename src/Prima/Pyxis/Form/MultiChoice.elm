module Prima.Pyxis.Form.MultiChoice exposing
    ( MultiChoice
    , withId, withName, withAttribute, withDisabled
    , withValidation
    , render
    , multiChoice, multiChoiceChoice, withClass, withOnBlur, withOnFocus
    )

{-|


## Types

@docs MultiChoice


## Modifiers

@docs withId, withName, withChecked, withAttribute, withDisabled


## Events

@docs withOnChange


## Validations

@docs withValidation


## Render

@docs render

-}

import Html exposing (Attribute, Html)
import Html.Attributes as Attrs
import Html.Events as Events
import Prima.Pyxis.Form.Label as Label
import Prima.Pyxis.Form.Validation as Validation
import Prima.Pyxis.Helpers as H


{-| Represents the configuration of an Change type.
-}
type MultiChoice model msg
    = MultiChoice (MultiChoiceConfig model msg)


{-| Internal.
-}
type alias MultiChoiceConfig model msg =
    { options : List (MultiChoiceOption model msg)
    , reader : model -> List String
    , writer : String -> msg
    , choices : List MultiChoiceChoice
    }


multiChoice : (model -> List String) -> (String -> msg) -> List MultiChoiceChoice -> MultiChoice model msg
multiChoice reader writer =
    MultiChoice << MultiChoiceConfig [] reader writer


{-| Internal.
-}
type MultiChoiceOption model msg
    = Attribute (Html.Attribute msg)
    | Class String
    | Disabled Bool
    | Id String
    | Name String
    | OnFocus msg
    | OnBlur msg
    | Validation (model -> Maybe Validation.Type)


{-| Internal.
-}
type alias MultiChoiceChoice =
    { value : String
    , label : String
    }


multiChoiceChoice : String -> String -> MultiChoiceChoice
multiChoiceChoice value label =
    MultiChoiceChoice value label


{-| Internal.
-}
type alias Options model msg =
    { attributes : List (Html.Attribute msg)
    , class : List String
    , disabled : Maybe Bool
    , id : Maybe String
    , name : Maybe String
    , onFocus : Maybe msg
    , onBlur : Maybe msg
    , validations : List (model -> Maybe Validation.Type)
    }


defaultOptions : Options model msg
defaultOptions =
    { attributes = []
    , class = [ "a-form-field__checkbox" ]
    , disabled = Nothing
    , id = Nothing
    , name = Nothing
    , onFocus = Nothing
    , onBlur = Nothing
    , validations = []
    }


{-| Internal.
-}
addOption : MultiChoiceOption model msg -> MultiChoice model msg -> MultiChoice model msg
addOption option (MultiChoice multiChoiceConfig) =
    MultiChoice { multiChoiceConfig | options = multiChoiceConfig.options ++ [ option ] }


{-| Sets an `attribute` to the `MultiChoice config`.
-}
withAttribute : Html.Attribute msg -> MultiChoice model msg -> MultiChoice model msg
withAttribute attribute =
    addOption (Attribute attribute)


{-| Sets a `disabled` to the `MultiChoice config`.
-}
withDisabled : Bool -> MultiChoice model msg -> MultiChoice model msg
withDisabled disabled =
    addOption (Disabled disabled)


{-| Sets a `class` to the `MultiChoice config`.
-}
withClass : String -> MultiChoice model msg -> MultiChoice model msg
withClass class_ =
    addOption (Class class_)


{-| Sets an `id` to the `MultiChoice config`.
-}
withId : String -> MultiChoice model msg -> MultiChoice model msg
withId id =
    addOption (Id id)


{-| Sets a `name` to the `MultiChoice config`.
-}
withName : String -> MultiChoice model msg -> MultiChoice model msg
withName name =
    addOption (Name name)


{-| Sets an `onBlur event` to the `MultiChoice config`.
-}
withOnBlur : msg -> MultiChoice model msg -> MultiChoice model msg
withOnBlur tagger =
    addOption (OnBlur tagger)


{-| Sets an `onFocus event` to the `MultiChoice config`.
-}
withOnFocus : msg -> MultiChoice model msg -> MultiChoice model msg
withOnFocus tagger =
    addOption (OnFocus tagger)


withValidation : (model -> Maybe Validation.Type) -> MultiChoice model msg -> MultiChoice model msg
withValidation validation =
    addOption (Validation validation)


{-| Internal.
-}
applyOption : MultiChoiceOption model msg -> Options model msg -> Options model msg
applyOption modifier options =
    case modifier of
        Attribute attribute ->
            { options | attributes = attribute :: options.attributes }

        Class class ->
            { options | class = class :: options.class }

        Disabled disabled ->
            { options | disabled = Just disabled }

        Id id ->
            { options | id = Just id }

        Name name ->
            { options | name = Just name }

        OnBlur onBlur ->
            { options | onBlur = Just onBlur }

        OnFocus onFocus ->
            { options | onFocus = Just onFocus }

        Validation validation ->
            { options | validations = validation :: options.validations }


{-| Transforms a `List` of `Class`(es) into a valid `Html.Attribute`.
-}
classAttribute : List String -> Html.Attribute msg
classAttribute =
    Attrs.class << String.join " "


{-| Internal
-}
readerAttribute : model -> MultiChoice model msg -> String -> Html.Attribute msg
readerAttribute model (MultiChoice config) choice =
    model
        |> config.reader
        |> List.member choice
        |> Attrs.checked


{-| Internal
-}
writerAttribute : MultiChoice model msg -> String -> Html.Attribute msg
writerAttribute (MultiChoice config) choice =
    choice
        |> config.writer
        |> Events.onClick


{-| Composes all the modifiers into a set of `Html.Attribute`(s).
-}
buildAttributes : model -> MultiChoice model msg -> String -> List (Html.Attribute msg)
buildAttributes model ((MultiChoice config) as multiChoiceModel) choice =
    let
        options =
            computeOptions multiChoiceModel
    in
    [ options.id
        |> Maybe.map Attrs.id
    , options.name
        |> Maybe.map Attrs.name
    , options.disabled
        |> Maybe.map Attrs.disabled
    , options.onFocus
        |> Maybe.map Events.onFocus
    , options.onBlur
        |> Maybe.map Events.onBlur
    ]
        |> List.filterMap identity
        |> (++) options.attributes
        |> (::) (classAttribute options.class)
        |> (::) (readerAttribute model multiChoiceModel choice)
        |> (::) (writerAttribute multiChoiceModel choice)
        |> (::) (Attrs.type_ "checkbox")
        |> (::) (Attrs.value choice)
        |> (::) (validationAttribute model multiChoiceModel)


validationAttribute : model -> MultiChoice model msg -> Html.Attribute msg
validationAttribute model ((MultiChoice config) as multiChoiceModel) =
    let
        options =
            computeOptions multiChoiceModel

        errors =
            options.validations
                |> List.filterMap (H.flip identity model)
                |> List.filter Validation.isError

        warnings =
            options.validations
                |> List.filterMap (H.flip identity model)
                |> List.filter Validation.isWarning
    in
    case ( errors, warnings ) of
        ( [], [] ) ->
            Attrs.class "is-valid"

        ( [], _ ) ->
            Attrs.class "has-warning"

        ( _, _ ) ->
            Attrs.class "has-error"


{-| Renders the `MultiChoice config`.

    import Prima.Pyxis.Form.MultiChoice as MultiChoice

    view : List (Html Msg)
    view =
        [ buildMultiChoiceItem "option_1" "Option 1"
        , buildMultiChoiceItem "option_2" "Option 2"
        ]
            |> MultiChoice.multiChoice
            |> MultiChoice.render

-}
render : model -> MultiChoice model msg -> List (Html msg)
render model ((MultiChoice config) as multiChoiceModel) =
    let
        options =
            computeOptions multiChoiceModel

        errors =
            options.validations
                |> List.filterMap (H.flip identity model)
                |> List.filter Validation.isError

        warnings =
            options.validations
                |> List.filterMap (H.flip identity model)
                |> List.filter Validation.isWarning
    in
    [ Html.div
        [ Attrs.classList
            [ ( "a-form-field__checkbox-options", True )
            ]
        , validationAttribute model multiChoiceModel
        ]
        (List.map (renderMultiChoice model multiChoiceModel) config.choices)
    ]


{-| Internal
-}
renderMultiChoice : model -> MultiChoice model msg -> MultiChoiceChoice -> Html msg
renderMultiChoice model ((MultiChoice config) as multiChoiceModel) multiChoiceItem =
    Html.div
        [ Attrs.class "a-form-field__checkbox-options__item" ]
        [ Html.input
            (buildAttributes model multiChoiceModel multiChoiceItem.value)
            []
        , multiChoiceItem.label
            |> Label.label
            |> Label.withOnClick (config.writer multiChoiceItem.value)
            |> Label.withFor multiChoiceItem.value
            |> Label.withOverridingClass "a-form-field__checkbox-options__item__label"
            |> Label.render
        ]


{-| Internal
-}
computeOptions : MultiChoice model msg -> Options model msg
computeOptions (MultiChoice config) =
    List.foldl applyOption defaultOptions config.options
