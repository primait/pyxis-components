module Prima.Pyxis.Form.Select exposing
    ( Select(..), select
    , withId, withAttribute, withDefaultValue, withDisabled
    , render
    , Options, SelectChoice, SelectConfig, SelectOption(..), SelectSize(..), addOption, applyOption, buildAttributes, computeOptions, defaultOptions, renderCustomSelect, renderCustomSelectChoice, renderCustomSelectChoiceWrapper, renderCustomSelectStatus, renderSelect, renderSelectChoice, renderValidationMessages, selectChoice, sizeAttribute, taggerAttribute, validationAttribute, withLargeSize, withMediumSize, withOnBlur, withOnFocus, withOverridingClass, withPlaceholder, withSmallSize, withValidation
    )

{-|


## Types and Configuration

@docs Select, select


## Modifiers

@docs withId, withName, withAttribute, withDefaultValue, withDisabled, withValue


## Events

@docs withOnSelect


## Render

@docs render

-}

import Html exposing (Attribute, Html, text)
import Html.Attributes as Attrs exposing (class, id, value)
import Html.Events as Events
import Prima.Pyxis.Form.Validation as Validation
import Prima.Pyxis.Helpers as H


{-| Represent the configuration of a Select type.
-}
type Select model msg
    = Select (SelectConfig model msg)


type alias SelectConfig model msg =
    { options : List (SelectOption model msg)
    , reader : model -> Maybe String
    , tagger : String -> msg
    , openedReader : model -> Bool
    , openedTagger : msg
    , selectChoices : List SelectChoice
    }


select : (model -> Maybe String) -> (String -> msg) -> (model -> Bool) -> msg -> List SelectChoice -> Select model msg
select reader tagger openedReader openedTagger =
    Select << SelectConfig [] reader tagger openedReader openedTagger


type alias SelectChoice =
    { value : String
    , label : String
    }


selectChoice : String -> String -> SelectChoice
selectChoice value label =
    SelectChoice value label


{-| Internal.
-}
type SelectOption model msg
    = Attribute (Html.Attribute msg)
    | Class String
    | DefaultValue (Maybe String)
    | Disabled Bool
    | Id String
    | OnFocus msg
    | OnBlur msg
    | OverridingClass String
    | Placeholder String
    | Size SelectSize
    | Validation (model -> Maybe Validation.Type)


type Default
    = Indeterminate
    | Value (Maybe String)


{-| Represent the `Select` size.
-}
type SelectSize
    = Small
    | Medium
    | Large


{-| Internal.
-}
type alias Options model msg =
    { attributes : List (Html.Attribute msg)
    , class : List String
    , defaultValue : Default
    , disabled : Maybe Bool
    , id : Maybe String
    , onFocus : Maybe msg
    , onBlur : Maybe msg
    , placeholder : String
    , size : SelectSize
    , validations : List (model -> Maybe Validation.Type)
    }


defaultOptions : Options model msg
defaultOptions =
    { attributes = []
    , class = [ "a-form-select a-form-select--native" ]
    , defaultValue = Indeterminate
    , disabled = Nothing
    , id = Nothing
    , onFocus = Nothing
    , onBlur = Nothing
    , placeholder = "Seleziona"
    , size = Medium
    , validations = []
    }


{-| Internal.
-}
addOption : SelectOption model msg -> Select model msg -> Select model msg
addOption option (Select selectConfig) =
    Select { selectConfig | options = selectConfig.options ++ [ option ] }


{-| Sets an `attribute` to the `Select config`.
-}
withAttribute : Html.Attribute msg -> Select model msg -> Select model msg
withAttribute attribute =
    addOption (Attribute attribute)


{-| Adds a default value to the `Select`.
Useful to teach the component about it's `pristine/touched` state.
-}
withDefaultValue : Maybe String -> Select model msg -> Select model msg
withDefaultValue value =
    addOption (DefaultValue value)


{-| Sets a `disabled` to the `Select config`.
-}
withDisabled : Bool -> Select model msg -> Select model msg
withDisabled disabled =
    addOption (Disabled disabled)


{-| Sets a `disabled` to the `Select config`.
-}
withPlaceholder : String -> Select model msg -> Select model msg
withPlaceholder placeholder =
    addOption (Placeholder placeholder)


{-| Sets an `id` to the `Select config`.
-}
withId : String -> Select model msg -> Select model msg
withId id =
    addOption (Id id)


{-| Sets a `size` to the `Select config`.
-}
withLargeSize : Select model msg -> Select model msg
withLargeSize =
    addOption (Size Large)


{-| Sets an `onBlur event` to the `Select config`.
-}
withOnBlur : msg -> Select model msg -> Select model msg
withOnBlur tagger =
    addOption (OnBlur tagger)


{-| Sets an `onFocus event` to the `Select config`.
-}
withOnFocus : msg -> Select model msg -> Select model msg
withOnFocus tagger =
    addOption (OnFocus tagger)


withOverridingClass : String -> Select model msg -> Select model msg
withOverridingClass class =
    addOption (OverridingClass class)


{-| Sets a `size` to the `Select config`.
-}
withMediumSize : Select model msg -> Select model msg
withMediumSize =
    addOption (Size Medium)


{-| Sets a `size` to the `Select config`.
-}
withSmallSize : Select model msg -> Select model msg
withSmallSize =
    addOption (Size Small)


withValidation : (model -> Maybe Validation.Type) -> Select model msg -> Select model msg
withValidation validation =
    addOption (Validation validation)


{-| Internal.
-}
applyOption : SelectOption model msg -> Options model msg -> Options model msg
applyOption modifier options =
    case modifier of
        Attribute attribute ->
            { options | attributes = attribute :: options.attributes }

        Class class ->
            { options | class = class :: options.class }

        DefaultValue value ->
            { options | defaultValue = Value value }

        Disabled disabled ->
            { options | disabled = Just disabled }

        Id id ->
            { options | id = Just id }

        OnFocus onFocus ->
            { options | onFocus = Just onFocus }

        OnBlur onBlur ->
            { options | onBlur = Just onBlur }

        OverridingClass class ->
            { options | class = [ class ] }

        Placeholder placeholder ->
            { options | placeholder = placeholder }

        Size size ->
            { options | size = size }

        Validation validation ->
            { options | validations = validation :: options.validations }


{-| Transforms an `SelectSize` into a valid `Html.Attribute`.
-}
sizeAttribute : SelectSize -> Html.Attribute msg
sizeAttribute size =
    Attrs.class
        (case size of
            Small ->
                "is-small"

            Medium ->
                "is-medium"

            Large ->
                "is-large"
        )


taggerAttribute : Select model msg -> Html.Attribute msg
taggerAttribute (Select config) =
    Events.onInput config.tagger


validationAttribute : model -> Select model msg -> Html.Attribute msg
validationAttribute model selectModel =
    let
        warnings =
            warningValidations model (computeOptions selectModel)

        errors =
            errorsValidations model (computeOptions selectModel)
    in
    case ( errors, warnings ) of
        ( [], [] ) ->
            Attrs.class "is-valid"

        ( [], _ ) ->
            Attrs.class "has-warning"

        ( _, _ ) ->
            Attrs.class "has-error"


{-| Internal. Applies the `pristine/touched` visual state to the component.
-}
pristineAttribute : model -> Select model msg -> Html.Attribute msg
pristineAttribute model ((Select config) as selectModel) =
    let
        options =
            computeOptions selectModel
    in
    if Value (config.reader model) == options.defaultValue then
        Attrs.class "is-pristine"

    else
        Attrs.class "is-touched"


{-| Composes all the modifiers into a set of `Html.Attribute`(s).
-}
buildAttributes : model -> Select model msg -> List (Html.Attribute msg)
buildAttributes model selectModel =
    let
        options =
            computeOptions selectModel
    in
    [ options.id
        |> Maybe.map Attrs.id
    , options.disabled
        |> Maybe.map Attrs.disabled
    , options.onFocus
        |> Maybe.map Events.onFocus
    , options.onBlur
        |> Maybe.map Events.onBlur
    ]
        |> List.filterMap identity
        |> (++) options.attributes
        |> (::) (H.classesAttribute options.class)
        |> (::) (sizeAttribute options.size)
        |> (::) (taggerAttribute selectModel)
        |> (::) (validationAttribute model selectModel)
        |> (::) (pristineAttribute model selectModel)


{-| Renders the `Radio config`.
-}
render : model -> Select model msg -> List (Html msg)
render model selectModel =
    [ renderSelect model selectModel
    , renderCustomSelect model selectModel
    ]
        ++ renderValidationMessages model selectModel


renderSelect : model -> Select model msg -> Html msg
renderSelect model ((Select config) as selectModel) =
    Html.select
        (buildAttributes model selectModel)
        (List.map (renderSelectChoice model selectModel) config.selectChoices)


renderSelectChoice : model -> Select model msg -> SelectChoice -> Html msg
renderSelectChoice model (Select config) choice =
    Html.option
        [ Attrs.value choice.value
        , Attrs.selected <| (==) choice.value <| Maybe.withDefault "" <| config.reader model
        ]
        [ Html.text choice.label ]


renderCustomSelect : model -> Select model msg -> Html msg
renderCustomSelect model ((Select config) as selectModel) =
    let
        options =
            computeOptions selectModel
    in
    Html.div
        [ Attrs.classList
            [ ( "a-form-select", True )
            , ( "is-open", config.openedReader model )
            , ( "is-disabled", Maybe.withDefault False options.disabled )
            ]
        , sizeAttribute options.size
        , validationAttribute model selectModel
        ]
        [ selectModel
            |> renderCustomSelectStatus model
        , config.selectChoices
            |> List.map (renderCustomSelectChoice model selectModel)
            |> renderCustomSelectChoiceWrapper
        ]


renderCustomSelectStatus : model -> Select model msg -> Html msg
renderCustomSelectStatus model ((Select config) as selectModel) =
    let
        options =
            computeOptions selectModel
    in
    Html.span
        [ Attrs.class "a-form-select__status"
        , Events.onClick config.openedTagger
        ]
        [ config.selectChoices
            |> List.filter ((==) (config.reader model) << Just << .value)
            |> List.map .label
            |> List.head
            |> Maybe.withDefault options.placeholder
            |> Html.text
        ]


renderCustomSelectChoiceWrapper : List (Html msg) -> Html msg
renderCustomSelectChoiceWrapper =
    Html.ul
        [ class "a-form-select__list" ]


renderCustomSelectChoice : model -> Select model msg -> SelectChoice -> Html msg
renderCustomSelectChoice model (Select config) choice =
    Html.li
        [ Attrs.classList
            [ ( "a-form-select__list__item", True )
            , ( "is-selected", ((==) (Just choice.value) << config.reader) model )
            ]
        , (Events.onClick << config.tagger) choice.value
        ]
        [ text choice.label
        ]


renderValidationMessages : model -> Select model msg -> List (Html msg)
renderValidationMessages model selectModel =
    let
        warnings =
            warningValidations model (computeOptions selectModel)

        errors =
            errorsValidations model (computeOptions selectModel)
    in
    case ( errors, warnings ) of
        ( [], _ ) ->
            List.map Validation.render warnings

        ( _, _ ) ->
            List.map Validation.render errors


{-| Internal
-}
computeOptions : Select model msg -> Options model msg
computeOptions (Select config) =
    List.foldl applyOption defaultOptions config.options


warningValidations : model -> Options model msg -> List Validation.Type
warningValidations model options =
    options.validations
        |> List.filterMap (H.flip identity model)
        |> List.filter Validation.isWarning


errorsValidations : model -> Options model msg -> List Validation.Type
errorsValidations model options =
    options.validations
        |> List.filterMap (H.flip identity model)
        |> List.filter Validation.isError
