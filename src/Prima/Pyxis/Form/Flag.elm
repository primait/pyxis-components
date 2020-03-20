module Prima.Pyxis.Form.Flag exposing
    ( Config, flag
    , withAttribute, withDisabled, withLabel, withName
    , withOnBlur, withOnFocus
    , withValidation
    , render
    )

{-|


## Types and Configuration

@docs Config, flag


## Options

@docs withAttribute, withDisabled, withLabel, withName


## Events

@docs withOnBlur, withOnFocus


## Validations

@docs withValidation


## Rendering

@docs render

-}

import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Events as Events
import Prima.Pyxis.Form.Label as Label
import Prima.Pyxis.Form.Validation as Validation
import Prima.Pyxis.Helpers as H


{-| Represent the opaque `Flag` configuration.
-}
type Config model msg
    = Config (FlagConfig model msg)


{-| Internal. Represent the `Flag` configuration.
-}
type alias FlagConfig model msg =
    { options : List (FlagOption model msg)
    , reader : model -> Maybe Bool
    , tagger : Bool -> msg
    , id : String
    }


{-| Internal. Represent the possible modifiers for an `Flag`.
-}
type FlagOption model msg
    = Attribute (Html.Attribute msg)
    | Disabled Bool
    | Label (Label.Config msg)
    | Name String
    | OnFocus msg
    | OnBlur msg
    | Validation (model -> Maybe Validation.Type)


{-| Create a `Flag`.
-}
flag : (model -> Maybe Bool) -> (Bool -> msg) -> String -> Config model msg
flag reader tagger id =
    Config <| FlagConfig [] reader tagger id


{-| Internal. Adds a generic option to the `Input`.
-}
addOption : FlagOption model msg -> Config model msg -> Config model msg
addOption option (Config flagConfig) =
    Config { flagConfig | options = flagConfig.options ++ [ option ] }


{-| Adds a generic Html.Attribute to the `Input`.
-}
withAttribute : Html.Attribute msg -> Config model msg -> Config model msg
withAttribute attribute =
    addOption (Attribute attribute)


{-| Sets a `disabled` to the `Flag config`.
-}
withDisabled : Bool -> Config model msg -> Config model msg
withDisabled disabled =
    addOption (Disabled disabled)


{-| Adds a `name` Html.Attribute to the `Flag`.
-}
withName : String -> Config model msg -> Config model msg
withName name =
    addOption (Name name)


{-| Adds a `Label` Html.Attribute to the `Flag`.
-}
withLabel : Label.Config msg -> Config model msg -> Config model msg
withLabel label =
    addOption (Label label)


{-| Attaches the `onBlur` event to the `Flag`.
-}
withOnBlur : msg -> Config model msg -> Config model msg
withOnBlur tagger =
    addOption (OnBlur tagger)


{-| Attaches the `onFocus` event to the `Flag`.
-}
withOnFocus : msg -> Config model msg -> Config model msg
withOnFocus tagger =
    addOption (OnFocus tagger)


{-| Adds a `Validation` rule to the `Flag`.
-}
withValidation : (model -> Maybe Validation.Type) -> Config model msg -> Config model msg
withValidation validation =
    addOption (Validation validation)


{-| Internal. Represent the list of customizations for the `Flag` component.
-}
type alias Options model msg =
    { attributes : List (Html.Attribute msg)
    , disabled : Maybe Bool
    , label : Maybe (Label.Config msg)
    , name : Maybe String
    , onFocus : Maybe msg
    , onBlur : Maybe msg
    , validations : List (model -> Maybe Validation.Type)
    }


{-| Internal. Represent the initial state of the list of customizations for the `Flag` component.
-}
defaultOptions : Options model msg
defaultOptions =
    { attributes = [ Attrs.class "a-form-field__checkbox" ]
    , disabled = Nothing
    , label = Nothing
    , name = Nothing
    , onFocus = Nothing
    , onBlur = Nothing
    , validations = []
    }


{-| Internal. Applies the customizations made by end user to the `Flag` component.
-}
applyOption : FlagOption model msg -> Options model msg -> Options model msg
applyOption modifier options =
    case modifier of
        Attribute attribute ->
            { options | attributes = attribute :: options.attributes }

        Disabled disabled ->
            { options | disabled = Just disabled }

        Name name ->
            { options | name = Just name }

        Label label ->
            { options | label = Just label }

        OnBlur onBlur ->
            { options | onBlur = Just onBlur }

        OnFocus onFocus ->
            { options | onFocus = Just onFocus }

        Validation validation ->
            { options | validations = validation :: options.validations }


{-| Internal. Transforms the `reader` function into a valid Html.Attribute.
-}
readerAttribute : model -> Config model msg -> Html.Attribute msg
readerAttribute model (Config config) =
    (Attrs.checked << Maybe.withDefault False << config.reader) model


{-| Internal. Transforms the `tagger` function into a valid Html.Attribute.
-}
taggerAttribute : model -> Config model msg -> Html.Attribute msg
taggerAttribute model (Config config) =
    model
        |> config.reader
        |> Maybe.withDefault False
        |> not
        |> config.tagger
        |> Events.onClick


{-| Internal. Transforms the `Validation` status into an Html.Attribute `class`.
-}
validationAttribute : model -> Config model msg -> Html.Attribute msg
validationAttribute model flagModel =
    let
        warnings =
            warningValidations model (computeOptions flagModel)

        errors =
            errorsValidations model (computeOptions flagModel)
    in
    case ( errors, warnings ) of
        ( [], [] ) ->
            Attrs.class "is-valid"

        ( [], _ ) ->
            Attrs.class "has-warning"

        ( _, _ ) ->
            Attrs.class "has-error"


{-| Internal. Applies all the customizations and returns the internal `Options` type.
-}
computeOptions : Config model msg -> Options model msg
computeOptions (Config config) =
    List.foldl applyOption defaultOptions config.options


{-| Internal. Transforms all the customizations into a list of valid Html.Attribute(s).
-}
buildAttributes : model -> Config model msg -> List (Html.Attribute msg)
buildAttributes model ((Config config) as flagModel) =
    let
        options =
            computeOptions flagModel
    in
    [ Maybe.map Attrs.name options.name
    , Maybe.map Attrs.disabled options.disabled
    , Maybe.map Events.onBlur options.onBlur
    , Maybe.map Events.onFocus options.onFocus
    ]
        |> List.filterMap identity
        |> (++) options.attributes
        |> (::) (readerAttribute model flagModel)
        |> (::) (taggerAttribute model flagModel)
        |> (::) (validationAttribute model flagModel)
        |> (::) (Attrs.type_ "checkbox")
        |> (::) (Attrs.id config.id)


{-|


## Renders the `Input`.

    import Html
    import Prima.Pyxis.Form.Flag as Flag
    import Prima.Pyxis.Form.Validation as Validation

    ...

    type Msg =
        OnCheck Bool

    type alias Model =
        { privacy: Maybe Bool }

    ...

    view : Html Msg
    view =
        Html.div
            []
            (Flag.flag .privacy OnInput
                |> Input.withValidation (Maybe.andThen validate << .privacy)
            )

    validate : Maybe Bool -> Validation.Type
    validate privacy=
        if isJust privacy then
            Just <| Validation.ErrorWithMessage "Privacy cannot be blank".
        else
            Nothing

-}
render : model -> Config model msg -> List (Html msg)
render model flagModel =
    Html.div
        [ Attrs.class "a-form-field__checkbox-options" ]
        [ renderFlagChoice model flagModel ]
        :: renderValidationMessages model flagModel


{-| Internal. Renders the `Flag` alone.
-}
renderFlagChoice : model -> Config model msg -> Html msg
renderFlagChoice model ((Config config) as flagModel) =
    let
        options =
            computeOptions flagModel
    in
    Html.div
        [ Attrs.class "a-form-field__checkbox-options__item" ]
        [ Html.input
            (buildAttributes model flagModel)
            []
        , options.label
            |> Maybe.withDefault (Label.labelWithHtml [])
            |> Label.withFor config.id
            |> Label.withOverridingClass "a-form-field__checkbox-options__item__label"
            |> Label.render
        ]


{-| Internal. Renders the list of errors if present. Renders the list of warnings if not.
-}
renderValidationMessages : model -> Config model msg -> List (Html msg)
renderValidationMessages model flagModel =
    let
        warnings =
            warningValidations model (computeOptions flagModel)

        errors =
            errorsValidations model (computeOptions flagModel)
    in
    case ( errors, warnings ) of
        ( [], _ ) ->
            List.map Validation.render warnings

        ( _, _ ) ->
            List.map Validation.render errors


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
