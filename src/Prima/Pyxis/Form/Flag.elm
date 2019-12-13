module Prima.Pyxis.Form.Flag exposing
    ( Flag
    , flag
    , render
    , withAttribute
    , withDisabled
    , withLabel
    , withOnBlur
    , withOnFocus
    , withValidation
    )

import Html exposing (Html)
import Html.Attributes as Attrs exposing (type_)
import Html.Events as Events
import Prima.Pyxis.Form.Label as Label exposing (Label)
import Prima.Pyxis.Form.Validation as Validation
import Prima.Pyxis.Helpers as H


type Flag model msg
    = Flag (FlagConfig model msg)


type alias FlagConfig model msg =
    { options : List (FlagOption model msg)
    , reader : model -> Maybe Bool
    , writer : Bool -> msg
    , id : String
    }


type FlagOption model msg
    = Attribute (Html.Attribute msg)
    | Disabled Bool
    | Label (Label msg)
    | Name String
    | OnFocus msg
    | OnBlur msg
    | Validation (model -> Maybe Validation.Type)


flag : (model -> Maybe Bool) -> (Bool -> msg) -> String -> Flag model msg
flag reader writer id =
    Flag <| FlagConfig [] reader writer id


{-| Internal.
-}
addOption : FlagOption model msg -> Flag model msg -> Flag model msg
addOption option (Flag flagConfig) =
    Flag { flagConfig | options = flagConfig.options ++ [ option ] }


{-| Sets an `attribute` to the `Flag config`.
-}
withAttribute : Html.Attribute msg -> Flag model msg -> Flag model msg
withAttribute attribute =
    addOption (Attribute attribute)


{-| Sets a `disabled` to the `Flag config`.
-}
withDisabled : Bool -> Flag model msg -> Flag model msg
withDisabled disabled =
    addOption (Disabled disabled)


withLabel : Label msg -> Flag model msg -> Flag model msg
withLabel label =
    addOption (Label label)


{-| Sets an `onBlur event` to the `Flag config`.
-}
withOnBlur : msg -> Flag model msg -> Flag model msg
withOnBlur tagger =
    addOption (OnBlur tagger)


{-| Sets an `onFocus event` to the `Flag config`.
-}
withOnFocus : msg -> Flag model msg -> Flag model msg
withOnFocus tagger =
    addOption (OnFocus tagger)


withValidation : (model -> Maybe Validation.Type) -> Flag model msg -> Flag model msg
withValidation validation =
    addOption (Validation validation)


type alias Options model msg =
    { attributes : List (Html.Attribute msg)
    , disabled : Maybe Bool
    , label : Maybe (Label msg)
    , name : Maybe String
    , onFocus : Maybe msg
    , onBlur : Maybe msg
    , validations : List (model -> Maybe Validation.Type)
    }


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


readerAttribute : model -> Flag model msg -> Html.Attribute msg
readerAttribute model (Flag config) =
    (Attrs.checked << Maybe.withDefault False << Debug.log "reader says" << config.reader) model


writerAttribute : model -> Flag model msg -> Html.Attribute msg
writerAttribute model (Flag config) =
    model
        |> config.reader
        |> Maybe.withDefault False
        |> not
        |> config.writer
        |> Events.onClick


validationAttribute : model -> Flag model msg -> Html.Attribute msg
validationAttribute model flagModel =
    let
        options =
            computeOptions flagModel

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


buildAttributes : model -> Flag model msg -> List (Html.Attribute msg)
buildAttributes model ((Flag config) as flagModel) =
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
        |> (::) (writerAttribute model flagModel)
        |> (::) (validationAttribute model flagModel)
        |> (::) (Attrs.type_ "checkbox")
        |> (::) (Attrs.id config.id)


render : model -> Flag model msg -> List (Html msg)
render model ((Flag config) as flagModel) =
    Html.div
        [ Attrs.class "a-form-field__checkbox-options" ]
        [ renderCheckboxChoice model flagModel ]
        :: renderValidationMessages model flagModel


renderCheckboxChoice : model -> Flag model msg -> Html msg
renderCheckboxChoice model ((Flag config) as flagModel) =
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


renderValidationMessages : model -> Flag model msg -> List (Html msg)
renderValidationMessages model flagModel =
    let
        options =
            computeOptions flagModel

        warnings =
            options.validations
                |> List.filterMap (H.flip identity model)
                |> List.filter Validation.isWarning

        errors =
            options.validations
                |> List.filterMap (H.flip identity model)
                |> List.filter Validation.isError
    in
    case ( errors, warnings ) of
        ( [], _ ) ->
            List.map Validation.render warnings

        ( _, _ ) ->
            List.map Validation.render errors


{-| Internal.
-}
computeOptions : Flag model msg -> Options model msg
computeOptions (Flag config) =
    List.foldl applyOption defaultOptions config.options
