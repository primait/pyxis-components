module Prima.Pyxis.Form.Radio exposing
    ( Config
    , withId, withName, withAttribute, withDisabled
    , withValidation
    , render
    , radio, radioChoice, withClass, withOnBlur, withOnFocus
    )

{-|


## Types and Configuration

@docs Config


## Modifiers

@docs withId, withName, withChecked, withAttribute, withDisabled


## Events

@docs withOnChange


## Validation

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


{-| Represent the configuration of an Change type.
-}
type Config model msg
    = Config (RadioConfig model msg)


{-| Internal.
-}
type alias RadioConfig model msg =
    { options : List (RadioOption model msg)
    , reader : model -> Maybe String
    , tagger : String -> msg
    , radioChoices : List RadioChoice
    }


radio : (model -> Maybe String) -> (String -> msg) -> List RadioChoice -> Config model msg
radio reader tagger =
    Config << RadioConfig [] reader tagger


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
addOption : RadioOption model msg -> Config model msg -> Config model msg
addOption option (Config radioConfig) =
    Config { radioConfig | options = radioConfig.options ++ [ option ] }


{-| Sets an `attribute` to the `Radio config`.
-}
withAttribute : Html.Attribute msg -> Config model msg -> Config model msg
withAttribute attribute =
    addOption (Attribute attribute)


{-| Sets a `disabled` to the `Radio config`.
-}
withDisabled : Bool -> Config model msg -> Config model msg
withDisabled disabled =
    addOption (Disabled disabled)


{-| Sets a `class` to the `Radio config`.
-}
withClass : String -> Config model msg -> Config model msg
withClass class_ =
    addOption (Class class_)


{-| Sets an `id` to the `Radio config`.
-}
withId : String -> Config model msg -> Config model msg
withId id =
    addOption (Id id)


{-| Sets a `name` to the `Radio config`.
-}
withName : String -> Config model msg -> Config model msg
withName name =
    addOption (Name name)


{-| Sets an `onBlur event` to the `Radio config`.
-}
withOnBlur : msg -> Config model msg -> Config model msg
withOnBlur tagger =
    addOption (OnBlur tagger)


{-| Sets an `onFocus event` to the `Radio config`.
-}
withOnFocus : msg -> Config model msg -> Config model msg
withOnFocus tagger =
    addOption (OnFocus tagger)


withValidation : (model -> Maybe Validation.Type) -> Config model msg -> Config model msg
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


readerAttribute : model -> Config model msg -> RadioChoice -> Html.Attribute msg
readerAttribute model (Config config) choice =
    model
        |> config.reader
        |> (==) (Just choice.value)
        |> Attrs.checked


taggerAttribute : Config model msg -> RadioChoice -> Html.Attribute msg
taggerAttribute (Config config) choice =
    choice.value
        |> config.tagger
        |> Events.onClick


validationAttribute : model -> Config model msg -> Html.Attribute msg
validationAttribute model radioModel =
    let
        warnings =
            warningValidations model (computeOptions radioModel)

        errors =
            errorsValidations model (computeOptions radioModel)
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
buildAttributes : model -> Config model msg -> RadioChoice -> List (Html.Attribute msg)
buildAttributes model ((Config _) as radioModel) choice =
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
        |> (::) (H.classesAttribute options.class)
        |> (::) (readerAttribute model radioModel choice)
        |> (::) (taggerAttribute radioModel choice)
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
render : model -> Config model msg -> List (Html msg)
render model ((Config { radioChoices }) as radioModel) =
    Html.div
        [ Attrs.class "a-form-field__radio-options" ]
        (List.map (renderRadioChoice model radioModel) radioChoices)
        :: renderValidationMessages model radioModel


renderRadioChoice : model -> Config model msg -> RadioChoice -> Html msg
renderRadioChoice model ((Config { tagger }) as radioModel) ({ value, label } as choice) =
    Html.div
        [ Attrs.class "a-form-field__radio-options__item" ]
        [ Html.input
            (buildAttributes model radioModel choice)
            []
        , label
            |> Label.label
            |> Label.withOnClick (tagger value)
            |> Label.withFor value
            |> Label.withOverridingClass "a-form-field__radio-options__item__label"
            |> Label.render
        ]


renderValidationMessages : model -> Config model msg -> List (Html msg)
renderValidationMessages model radioModel =
    let
        warnings =
            warningValidations model (computeOptions radioModel)

        errors =
            errorsValidations model (computeOptions radioModel)
    in
    case ( errors, warnings ) of
        ( [], _ ) ->
            List.map Validation.render warnings

        ( _, _ ) ->
            List.map Validation.render errors


{-| Internal
-}
computeOptions : Config model msg -> Options model msg
computeOptions (Config { options }) =
    List.foldl applyOption defaultOptions options


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
