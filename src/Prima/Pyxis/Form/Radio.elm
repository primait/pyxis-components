module Prima.Pyxis.Form.Radio exposing
    ( Radio
    , withId, withName, withAttribute, withDisabled
    , withValidation
    , render
    , radio, radioChoice, withClass, withOnBlur, withOnFocus
    )

{-|


## Types

@docs Radio


## Modifiers

@docs withId, withName, withChecked, withAttribute, withDisabled


## Events

@docs withOnChange


## Validation

@docs withValidation


## Render

@docs render

-}

import Html exposing (Attribute, Html, div)
import Html.Attributes as Attrs
import Html.Events as Events exposing (on)
import Prima.Pyxis.Form.Label as Label
import Prima.Pyxis.Form.Validation as Validation
import Prima.Pyxis.Helpers as H


{-| Represents the configuration of an Change type.
-}
type Radio model msg
    = Radio (RadioConfig model msg)


{-| Internal.
-}
type alias RadioConfig model msg =
    { options : List (RadioOption model msg)
    , reader : model -> Maybe String
    , writer : String -> msg
    , radioChoices : List RadioChoice
    }


radio : (model -> Maybe String) -> (String -> msg) -> List RadioChoice -> Radio model msg
radio reader writer =
    Radio << RadioConfig [] reader writer


type alias RadioChoice =
    { value : String
    , label : String
    }


radioChoice : String -> String -> RadioChoice
radioChoice value label =
    RadioChoice value label


{-| Internal.
-}
type RadioOption model msg
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
    , class = [ "a-form-field__radio" ]
    , disabled = Nothing
    , id = Nothing
    , name = Nothing
    , onFocus = Nothing
    , onBlur = Nothing
    , validations = []
    }


{-| Internal.
-}
addOption : RadioOption model msg -> Radio model msg -> Radio model msg
addOption option (Radio radioConfig) =
    Radio { radioConfig | options = radioConfig.options ++ [ option ] }


{-| Sets an `attribute` to the `Radio config`.
-}
withAttribute : Html.Attribute msg -> Radio model msg -> Radio model msg
withAttribute attribute =
    addOption (Attribute attribute)


{-| Sets a `disabled` to the `Radio config`.
-}
withDisabled : Bool -> Radio model msg -> Radio model msg
withDisabled disabled =
    addOption (Disabled disabled)


{-| Sets a `class` to the `Radio config`.
-}
withClass : String -> Radio model msg -> Radio model msg
withClass class_ =
    addOption (Class class_)


{-| Sets an `id` to the `Radio config`.
-}
withId : String -> Radio model msg -> Radio model msg
withId id =
    addOption (Id id)


{-| Sets a `name` to the `Radio config`.
-}
withName : String -> Radio model msg -> Radio model msg
withName name =
    addOption (Name name)


{-| Sets an `onBlur event` to the `Radio config`.
-}
withOnBlur : msg -> Radio model msg -> Radio model msg
withOnBlur tagger =
    addOption (OnBlur tagger)


{-| Sets an `onFocus event` to the `Radio config`.
-}
withOnFocus : msg -> Radio model msg -> Radio model msg
withOnFocus tagger =
    addOption (OnFocus tagger)


withValidation : (model -> Maybe Validation.Type) -> Radio model msg -> Radio model msg
withValidation validation =
    addOption (Validation validation)


{-| Internal.
-}
applyOption : RadioOption model msg -> Options model msg -> Options model msg
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


readerAttribute : model -> Radio model msg -> RadioChoice -> Html.Attribute msg
readerAttribute model (Radio config) choice =
    model
        |> config.reader
        |> (==) (Just choice.value)
        |> Attrs.checked


writerAttribute : Radio model msg -> RadioChoice -> Html.Attribute msg
writerAttribute (Radio config) choice =
    choice.value
        |> config.writer
        |> Events.onClick


validationAttribute : model -> Radio model msg -> Html.Attribute msg
validationAttribute model radioModel =
    let
        options =
            computeOptions radioModel

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
buildAttributes : model -> Radio model msg -> RadioChoice -> List (Html.Attribute msg)
buildAttributes model ((Radio config) as radioModel) choice =
    let
        options =
            computeOptions radioModel
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
        |> (::) (readerAttribute model radioModel choice)
        |> (::) (writerAttribute radioModel choice)
        |> (::) (validationAttribute model radioModel)
        |> (::) (Attrs.type_ "radio")
        |> (::) (Attrs.value choice.value)


{-| Renders the `Radio config`.

    import Prima.Pyxis.Form.Radio as Radio

    view : List (Html Msg)
    view =
        [ radioChoice "option_1" "Option 1"
        , radioChoice "option_2" "Option 2"
        ]
            |> Radio.radio
            |> Radio.render

-}
render : model -> Radio model msg -> List (Html msg)
render model ((Radio config) as radioModel) =
    Html.div
        [ Attrs.class "a-form-field__radio-options" ]
        (List.map (renderRadioChoice model radioModel) config.radioChoices)
        :: renderValidationMessages model radioModel


renderRadioChoice : model -> Radio model msg -> RadioChoice -> Html msg
renderRadioChoice model ((Radio config) as radioModel) choice =
    Html.div
        [ Attrs.class "a-form-field__radio-options__item" ]
        [ Html.input
            (buildAttributes model radioModel choice)
            []
        , choice.label
            |> Label.label
            |> Label.withOnClick (config.writer choice.value)
            |> Label.withFor choice.value
            |> Label.withOverridingClass "a-form-field__radio-options__item__label"
            |> Label.render
        ]


renderValidationMessages : model -> Radio model msg -> List (Html msg)
renderValidationMessages model radioModel =
    let
        options =
            computeOptions radioModel

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


{-| Internal
-}
computeOptions : Radio model msg -> Options model msg
computeOptions (Radio config) =
    List.foldl applyOption defaultOptions config.options
