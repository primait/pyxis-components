module Prima.Pyxis.Form.RadioButton exposing
    ( RadioButton, radioButton, radioButtonChoice, radioButtonChoiceWithSubtitle
    , withId, withAttribute, withClass
    , withOnBlur, withOnFocus
    , withValidation
    , render
    )

{-|


## Types

@docs RadioButton, radioButton, radioButtonChoice, radioButtonChoiceWithSubtitle


## Modifiers

@docs withId, withAttribute, withClass


## Events

@docs withOnBlur, withOnFocus


## Validation

@docs withValidation


## Render

@docs render

-}

import Html exposing (Attribute, Html)
import Html.Attributes as Attrs
import Html.Events as Events
import Prima.Pyxis.Form.Validation as Validation
import Prima.Pyxis.Helpers as H


{-| Represents the opaque `RadioButton` configuration.
-}
type RadioButton model msg
    = RadioButton (RadioConfig model msg)


{-| Internal. Represents the `RadioButton` configuration.
-}
type alias RadioConfig model msg =
    { options : List (RadioButtonOption model msg)
    , reader : model -> Maybe String
    , tagger : String -> msg
    , choices : List RadioButtonChoice
    }


{-| Create a radioButton.
-}
radioButton : (model -> Maybe String) -> (String -> msg) -> List RadioButtonChoice -> RadioButton model msg
radioButton reader tagger =
    RadioButton << RadioConfig [] reader tagger


{-| Represents the `RadioButtonChoice` configuration.
-}
type alias RadioButtonChoice =
    { value : String
    , title : String
    , subtitle : Maybe String
    }


{-| Creates the 'RadioButtonChoice' configuration.
-}
radioButtonChoice : String -> String -> RadioButtonChoice
radioButtonChoice value title =
    RadioButtonChoice value title Nothing


{-| Creates the 'radioButtonChoiceWithSubtitle' configuration.
-}
radioButtonChoiceWithSubtitle : String -> String -> String -> RadioButtonChoice
radioButtonChoiceWithSubtitle value title subtitle =
    RadioButtonChoice value title (Just subtitle)


{-| Internal. Represents the possible modifiers for an `RadioButton`.
-}
type RadioButtonOption model msg
    = Attribute (Html.Attribute msg)
    | Class String
    | Id String
    | OnFocus msg
    | OnBlur msg
    | Validation (model -> Maybe Validation.Type)


{-| Internal. Represents the list of customizations for the `RadioButton` component.
-}
type alias Options model msg =
    { attributes : List (Html.Attribute msg)
    , class : List String
    , id : Maybe String
    , onFocus : Maybe msg
    , onBlur : Maybe msg
    , validations : List (model -> Maybe Validation.Type)
    }


{-| Internal. Represents the initial state of the list of customizations for the `RadioButton` component.
-}
defaultOptions : Options model msg
defaultOptions =
    { attributes = []
    , class = [ "a-form-field__radio-button-options__item" ]
    , id = Nothing
    , onFocus = Nothing
    , onBlur = Nothing
    , validations = []
    }


{-| Internal. Adds a generic option to the `RadioButton`.
-}
addOption : RadioButtonOption model msg -> RadioButton model msg -> RadioButton model msg
addOption option (RadioButton radioButtonConfig) =
    RadioButton { radioButtonConfig | options = radioButtonConfig.options ++ [ option ] }


{-| Adds a generic Html.Attribute to the `RadioButton`.
-}
withAttribute : Html.Attribute msg -> RadioButton model msg -> RadioButton model msg
withAttribute attribute =
    addOption (Attribute attribute)


{-| Adds a `class` to the `RadioButton`.
-}
withClass : String -> RadioButton model msg -> RadioButton model msg
withClass class_ =
    addOption (Class class_)


{-| Adds an `id` Html.Attribute to the `RadioButton`.
-}
withId : String -> RadioButton model msg -> RadioButton model msg
withId id =
    addOption (Id id)


{-| Attaches the `onBlur` event to the `RadioButton`.
-}
withOnBlur : msg -> RadioButton model msg -> RadioButton model msg
withOnBlur tagger =
    addOption (OnBlur tagger)


{-| Attaches the `onFocus` event to the `RadioButton`.
-}
withOnFocus : msg -> RadioButton model msg -> RadioButton model msg
withOnFocus tagger =
    addOption (OnFocus tagger)


{-| Internal. Applies the customizations made by end user to the `RadioButton` component.
-}
applyOption : RadioButtonOption model msg -> Options model msg -> Options model msg
applyOption modifier options =
    case modifier of
        Attribute attribute ->
            { options | attributes = attribute :: options.attributes }

        Class class ->
            { options | class = class :: options.class }

        Id id ->
            { options | id = Just id }

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


{-| Internal. Transforms the `reader` function into a valid Html.Attribute.
-}
readerAttribute : model -> RadioButton model msg -> RadioButtonChoice -> Html.Attribute msg
readerAttribute model (RadioButton config) choice =
    if
        model
            |> config.reader
            |> (==) (Just choice.value)
    then
        Attrs.class "is-selected"

    else
        Attrs.class ""


{-| Internal. Transforms the `tagger` function into a valid Html.Attribute.
-}
taggerAttribute : RadioButton model msg -> RadioButtonChoice -> Html.Attribute msg
taggerAttribute (RadioButton config) choice =
    choice.value
        |> config.tagger
        |> Events.onClick


{-| Internal. Checks RadioButton has subtitle
-}
hasSubtitleAttribute : RadioButtonChoice -> Html.Attribute msg
hasSubtitleAttribute choice =
    if H.isJust choice.subtitle then
        Attrs.class "has-subtitle"

    else
        Attrs.class ""


{-| Adds a `Validation` rule to the `RadioButton`.
-}
withValidation : (model -> Maybe Validation.Type) -> RadioButton model msg -> RadioButton model msg
withValidation validation =
    addOption (Validation validation)


{-| Internal. Transforms the `Validation` status into an Html.Attribute `class`.
-}
validationAttribute : model -> RadioButton model msg -> Html.Attribute msg
validationAttribute model ((RadioButton _) as inputModel) =
    let
        options =
            computeOptions inputModel

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


{-| Internal. Transforms all the customizations into a list of valid Html.Attribute(s).
-}
buildAttributes : model -> RadioButton model msg -> RadioButtonChoice -> List (Html.Attribute msg)
buildAttributes model radioButtonModel choice =
    let
        options =
            computeOptions radioButtonModel
    in
    [ options.id
        |> Maybe.map Attrs.id
    , options.onFocus
        |> Maybe.map Events.onFocus
    , options.onBlur
        |> Maybe.map Events.onBlur
    ]
        |> List.filterMap identity
        |> (++) options.attributes
        |> (::) (classAttribute options.class)
        |> (::) (readerAttribute model radioButtonModel choice)
        |> (::) (taggerAttribute radioButtonModel choice)
        |> (::) (validationAttribute model radioButtonModel)
        |> (::) (hasSubtitleAttribute choice)


{-| Renders the `RadioButton config`.

    import Prima.Pyxis.Form.RadioButton as RadioButton

    view : List (Html Msg)
    view =
        [ radioButtonChoice "option_1" "Option 1"
        , radioButtonChoice "option_2" "Option 2"
        ]
            |> RadioButton.radioButton
            |> RadioButton.render

-}


{-|


## Renders the `Input`.

    import Html
    import Prima.Pyxis.Form.RadioButton as RadioButton
    import Prima.Pyxis.Form.Validation as Validation

    ...

    type Msg =
        OnChange String


    type alias Model =
        { tipoPolizza: Maybe String }

    ...

    view : Html Msg
    view =
        Html.div
            []
            (Input.email .tipoPolizza OnInput
                |> Input.withClass "my-custom-class"
                |> Input.withValidation (Maybe.andThen validate << .tipoPolizza)
            )

    validate : String -> Validation.Type
    validate str =
        if String.isEmpty str then
            Just <| Validation.ErrorWithMessage "Tipo di polizza is empty".
        else
            Nothing

-}
render : model -> RadioButton model msg -> List (Html msg)
render model ((RadioButton config) as radioButtonModel) =
    Html.div
        [ Attrs.class "a-form-field__radio-button-options" ]
        (List.map (renderRadioButtonChoice model radioButtonModel) config.choices)
        :: renderValidationMessages model radioButtonModel


{-| Internal. Renders the `RadioButton` alone.
-}
renderRadioButtonChoice : model -> RadioButton model msg -> RadioButtonChoice -> Html msg
renderRadioButtonChoice model ((RadioButton _) as radioButtonModel) ({ title, subtitle } as choice) =
    Html.div
        (buildAttributes model radioButtonModel choice)
        [ renderTitle title
        , H.renderMaybe <| Maybe.map renderSubtitle subtitle
        ]


{-| Internal. Renders the list of errors if present. Renders the list of warnings if not.
-}
renderValidationMessages : model -> RadioButton model msg -> List (Html msg)
renderValidationMessages model radioButtonModel =
    let
        options =
            computeOptions radioButtonModel

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


{-| Internal. Renders the title element.
-}
renderTitle : String -> Html msg
renderTitle title =
    Html.strong
        [ Attrs.class "a-form-field__radio-button__title" ]
        [ Html.text title ]


{-| Internal. Renders the subtitle element.
-}
renderSubtitle : String -> Html msg
renderSubtitle subtitle =
    Html.p
        [ Attrs.class "a-form-field__radio-button__subtitle" ]
        [ Html.text subtitle ]


{-| Internal. Applies all the customizations and returns the internal `Options` type.
-}
computeOptions : RadioButton model msg -> Options model msg
computeOptions (RadioButton config) =
    List.foldl applyOption defaultOptions config.options
