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

@docs withOnChange, withOnBlur, withOnFocus


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


{-| Represents the configuration of an Change type.
-}
type RadioButton model msg
    = RadioButton (RadioConfig model msg)


{-| Internal.
-}
type alias RadioConfig model msg =
    { options : List (RadioButtonOption model msg)
    , reader : model -> Maybe String
    , writer : String -> msg
    , choices : List RadioButtonChoice
    }


radioButton : (model -> Maybe String) -> (String -> msg) -> List RadioButtonChoice -> RadioButton model msg
radioButton reader writer =
    RadioButton << RadioConfig [] reader writer


type alias RadioButtonChoice =
    { value : String
    , title : String
    , subtitle : Maybe String
    }


radioButtonChoice : String -> String -> RadioButtonChoice
radioButtonChoice value title =
    RadioButtonChoice value title Nothing


radioButtonChoiceWithSubtitle : String -> String -> String -> RadioButtonChoice
radioButtonChoiceWithSubtitle value title subtitle =
    RadioButtonChoice value title (Just subtitle)


{-| Internal.
-}
type RadioButtonOption model msg
    = Attribute (Html.Attribute msg)
    | Class String
    | Id String
    | OnFocus msg
    | OnBlur msg
    | Validation (model -> Maybe Validation.Type)


{-| Internal.
-}
type alias Options model msg =
    { attributes : List (Html.Attribute msg)
    , class : List String
    , id : Maybe String
    , onFocus : Maybe msg
    , onBlur : Maybe msg
    , validations : List (model -> Maybe Validation.Type)
    }


defaultOptions : Options model msg
defaultOptions =
    { attributes = []
    , class = [ "a-form-field__radio-button-options__item" ]
    , id = Nothing
    , onFocus = Nothing
    , onBlur = Nothing
    , validations = []
    }


{-| Internal.
-}
addOption : RadioButtonOption model msg -> RadioButton model msg -> RadioButton model msg
addOption option (RadioButton radioButtonConfig) =
    RadioButton { radioButtonConfig | options = radioButtonConfig.options ++ [ option ] }


{-| Sets an `attribute` to the `RadioButton config`.
-}
withAttribute : Html.Attribute msg -> RadioButton model msg -> RadioButton model msg
withAttribute attribute =
    addOption (Attribute attribute)


{-| Sets a `class` to the `RadioButton config`.
-}
withClass : String -> RadioButton model msg -> RadioButton model msg
withClass class_ =
    addOption (Class class_)


{-| Sets an `id` to the `RadioButton config`.
-}
withId : String -> RadioButton model msg -> RadioButton model msg
withId id =
    addOption (Id id)


{-| Sets an `onBlur event` to the `RadioButton config`.
-}
withOnBlur : msg -> RadioButton model msg -> RadioButton model msg
withOnBlur tagger =
    addOption (OnBlur tagger)


{-| Sets an `onFocus event` to the `RadioButton config`.
-}
withOnFocus : msg -> RadioButton model msg -> RadioButton model msg
withOnFocus tagger =
    addOption (OnFocus tagger)


{-| Internal.
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


writerAttribute : RadioButton model msg -> RadioButtonChoice -> Html.Attribute msg
writerAttribute (RadioButton config) choice =
    choice.value
        |> config.writer
        |> Events.onClick


hasSubtitleAttribute : RadioButtonChoice -> Html.Attribute msg
hasSubtitleAttribute choice =
    if H.isJust choice.subtitle then
        Attrs.class "has-subtitle"

    else
        Attrs.class ""


withValidation : (model -> Maybe Validation.Type) -> RadioButton model msg -> RadioButton model msg
withValidation validation =
    addOption (Validation validation)


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


{-| Composes all the modifiers into a set of `Html.Attribute`(s).
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
        |> (::) (writerAttribute radioButtonModel choice)
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
render : model -> RadioButton model msg -> List (Html msg)
render model ((RadioButton config) as radioButtonModel) =
    [ Html.div
        [ Attrs.class "a-form-field__radio-button-options" ]
        (List.map (renderRadioButtonChoice model radioButtonModel) config.choices)
    ]


renderRadioButtonChoice : model -> RadioButton model msg -> RadioButtonChoice -> Html msg
renderRadioButtonChoice model ((RadioButton _) as radioButtonModel) ({ title, subtitle } as choice) =
    Html.div
        (buildAttributes model radioButtonModel choice)
        [ renderTitle title
        , H.renderMaybe <| Maybe.map renderSubtitle subtitle
        ]


renderTitle : String -> Html msg
renderTitle title =
    Html.strong
        [ Attrs.class "a-form-field__radio-button__title" ]
        [ Html.text title ]


renderSubtitle : String -> Html msg
renderSubtitle subtitle =
    Html.p
        [ Attrs.class "a-form-field__radio-button__subtitle" ]
        [ Html.text subtitle ]


{-| Internal
-}
computeOptions : RadioButton model msg -> Options model msg
computeOptions (RadioButton config) =
    List.foldl applyOption defaultOptions config.options
