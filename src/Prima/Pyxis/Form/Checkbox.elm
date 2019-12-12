module Prima.Pyxis.Form.Checkbox exposing
    ( Checkbox
    , checkbox
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


type Checkbox model msg
    = Checkbox (CheckboxConfig model msg)


type alias CheckboxConfig model msg =
    { options : List (CheckboxOption model msg)
    , reader : model -> Maybe Bool
    , writer : Bool -> msg
    , id : String
    }


type CheckboxOption model msg
    = Attribute (Html.Attribute msg)
    | Disabled Bool
    | Label (Label msg)
    | Name String
    | OnFocus msg
    | OnBlur msg
    | Validation (model -> Maybe Validation.Type)


checkbox : (model -> Maybe Bool) -> (Bool -> msg) -> String -> Checkbox model msg
checkbox reader writer id =
    Checkbox <| CheckboxConfig [] reader writer id


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


withLabel : Label msg -> Checkbox model msg -> Checkbox model msg
withLabel label =
    addOption (Label label)


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


applyOption : CheckboxOption model msg -> Options model msg -> Options model msg
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


readerAttribute : model -> Checkbox model msg -> Html.Attribute msg
readerAttribute model (Checkbox config) =
    (Attrs.checked << Maybe.withDefault False << config.reader) model


writerAttribute : model -> Checkbox model msg -> Html.Attribute msg
writerAttribute model (Checkbox config) =
    model
        |> config.reader
        |> Maybe.withDefault False
        |> not
        |> config.writer
        |> Events.onClick


validationAttribute : model -> Checkbox model msg -> Html.Attribute msg
validationAttribute model checkboxModel =
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


buildAttributes : model -> Checkbox model msg -> List (Html.Attribute msg)
buildAttributes model ((Checkbox config) as checkboxModel) =
    let
        options =
            computeOptions checkboxModel
    in
    [ Maybe.map Attrs.name options.name
    , Maybe.map Attrs.disabled options.disabled
    , Maybe.map Events.onBlur options.onBlur
    , Maybe.map Events.onFocus options.onFocus
    ]
        |> List.filterMap identity
        |> (++) options.attributes
        |> (::) (readerAttribute model checkboxModel)
        |> (::) (writerAttribute model checkboxModel)
        |> (::) (validationAttribute model checkboxModel)
        |> (::) (Attrs.type_ "checkbox")
        |> (::) (Attrs.id config.id)


render : model -> Checkbox model msg -> List (Html msg)
render model ((Checkbox config) as checkboxModel) =
    Html.div
        [ Attrs.class "a-form-field__checkbox-options" ]
        [ renderCheckboxChoice model checkboxModel ]
        :: renderValidationMessages model checkboxModel


renderCheckboxChoice : model -> Checkbox model msg -> Html msg
renderCheckboxChoice model ((Checkbox config) as checkboxModel) =
    let
        options =
            computeOptions checkboxModel
    in
    Html.div
        [ Attrs.class "a-form-field__checkbox-options__item" ]
        [ Html.input
            (buildAttributes model checkboxModel)
            []
        , options.label
            |> Maybe.withDefault (Label.labelWithHtml [])
            |> Label.withFor config.id
            |> Label.withOverridingClass "a-form-field__checkbox-options__item__label"
            |> Label.render
        ]


renderValidationMessages : model -> Checkbox model msg -> List (Html msg)
renderValidationMessages model checkboxModel =
    let
        options =
            computeOptions checkboxModel

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
computeOptions : Checkbox model msg -> Options model msg
computeOptions (Checkbox config) =
    List.foldl applyOption defaultOptions config.options
