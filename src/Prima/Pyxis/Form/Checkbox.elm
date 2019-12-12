module Prima.Pyxis.Form.Checkbox exposing
    ( Checkbox
    , withId, withName, withAttribute, withDisabled
    , withValidation
    , render
    , checkbox, checkboxChoice, withClass, withOnBlur, withOnFocus
    )

{-|


## Types

@docs Checkbox


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
type Checkbox model msg
    = Checkbox (CheckboxConfig model msg)


{-| Internal.
-}
type alias CheckboxConfig model msg =
    { options : List (CheckboxOption model msg)
    , reader : model -> List String
    , writer : String -> msg
    , choices : List CheckboxChoice
    }


checkbox : (model -> List String) -> (String -> msg) -> List CheckboxChoice -> Checkbox model msg
checkbox reader writer =
    Checkbox << CheckboxConfig [] reader writer


{-| Internal.
-}
type CheckboxOption model msg
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
type alias CheckboxChoice =
    { value : String
    , label : String
    }


checkboxChoice : String -> String -> CheckboxChoice
checkboxChoice value label =
    CheckboxChoice value label


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
addOption : CheckboxOption model msg -> Checkbox model msg -> Checkbox model msg
addOption option (Checkbox checkboxConfig) =
    Checkbox { checkboxConfig | options = checkboxConfig.options ++ [ option ] }


{-| Sets an `attribute` to the `Checkbox config`.
-}
withAttribute : Html.Attribute msg -> Checkbox model msg -> Checkbox model msg
withAttribute attribute =
    addOption (Attribute attribute)


{-| Sets a `disabled` to the `Checkbox config`.
-}
withDisabled : Bool -> Checkbox model msg -> Checkbox model msg
withDisabled disabled =
    addOption (Disabled disabled)


{-| Sets a `class` to the `Checkbox config`.
-}
withClass : String -> Checkbox model msg -> Checkbox model msg
withClass class_ =
    addOption (Class class_)


{-| Sets an `id` to the `Checkbox config`.
-}
withId : String -> Checkbox model msg -> Checkbox model msg
withId id =
    addOption (Id id)


{-| Sets a `name` to the `Checkbox config`.
-}
withName : String -> Checkbox model msg -> Checkbox model msg
withName name =
    addOption (Name name)


{-| Sets an `onBlur event` to the `Checkbox config`.
-}
withOnBlur : msg -> Checkbox model msg -> Checkbox model msg
withOnBlur tagger =
    addOption (OnBlur tagger)


{-| Sets an `onFocus event` to the `Checkbox config`.
-}
withOnFocus : msg -> Checkbox model msg -> Checkbox model msg
withOnFocus tagger =
    addOption (OnFocus tagger)


withValidation : (model -> Maybe Validation.Type) -> Checkbox model msg -> Checkbox model msg
withValidation validation =
    addOption (Validation validation)


{-| Internal.
-}
applyOption : CheckboxOption model msg -> Options model msg -> Options model msg
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
readerAttribute : model -> Checkbox model msg -> String -> Html.Attribute msg
readerAttribute model (Checkbox config) choice =
    model
        |> config.reader
        |> List.member choice
        |> Attrs.checked


{-| Internal
-}
writerAttribute : Checkbox model msg -> String -> Html.Attribute msg
writerAttribute (Checkbox config) choice =
    choice
        |> config.writer
        |> Events.onClick


{-| Composes all the modifiers into a set of `Html.Attribute`(s).
-}
buildAttributes : model -> Checkbox model msg -> String -> List (Html.Attribute msg)
buildAttributes model ((Checkbox config) as checkboxModel) choice =
    let
        options =
            computeOptions checkboxModel
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
        |> (::) (readerAttribute model checkboxModel choice)
        |> (::) (writerAttribute checkboxModel choice)
        |> (::) (Attrs.type_ "checkbox")
        |> (::) (Attrs.value choice)
        |> (::) (validationAttribute model checkboxModel)


validationAttribute : model -> Checkbox model msg -> Html.Attribute msg
validationAttribute model ((Checkbox config) as checkboxModel) =
    let
        options =
            computeOptions checkboxModel

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


{-| Renders the `Checkbox config`.

    import Prima.Pyxis.Form.Checkbox as Checkbox

    view : List (Html Msg)
    view =
        [ buildCheckboxItem "option_1" "Option 1"
        , buildCheckboxItem "option_2" "Option 2"
        ]
            |> Checkbox.checkbox
            |> Checkbox.render

-}
render : model -> Checkbox model msg -> List (Html msg)
render model ((Checkbox config) as checkboxModel) =
    [ Html.div
        [ Attrs.classList
            [ ( "a-form-field__checkbox-options", True )
            ]
        , validationAttribute model checkboxModel
        ]
        (List.map (renderCheckbox model checkboxModel) config.choices)
    ]


{-| Internal
-}
renderCheckbox : model -> Checkbox model msg -> CheckboxChoice -> Html msg
renderCheckbox model ((Checkbox config) as checkboxModel) checkboxItem =
    Html.div
        [ Attrs.class "a-form-field__checkbox-options__item" ]
        [ Html.input
            (buildAttributes model checkboxModel checkboxItem.value)
            []
        , checkboxItem.label
            |> Label.label
            |> Label.withOnClick (config.writer checkboxItem.value)
            |> Label.withFor checkboxItem.value
            |> Label.withOverridingClass "a-form-field__checkbox-options__item__label"
            |> Label.render
        ]


{-| Internal
-}
computeOptions : Checkbox model msg -> Options model msg
computeOptions (Checkbox config) =
    List.foldl applyOption defaultOptions config.options
