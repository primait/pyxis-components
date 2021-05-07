module Prima.Pyxis.Form.Radio exposing
    ( Radio, RadioChoice
    , radio, radioChoice
    , render
    , withAttribute, withClass, withDisabled, withId, withName
    , withOnBlur, withOnFocus
    , withValidation
    )

{-|


## Configuration

@docs Radio, RadioChoice


## Configuration Methods

@docs radio, radioChoice


## Rendering

@docs render


## Options

@docs withAttribute, withClass, withDisabled, withId, withName


## Event Options

@docs withOnBlur, withOnFocus


## Validation

@docs withValidation

-}

import Html exposing (Attribute, Html)
import Html.Attributes as Attrs
import Html.Events as Events
import Prima.Pyxis.Form.Label as Label
import Prima.Pyxis.Form.Validation as Validation
import Prima.Pyxis.Helpers as H


{-| Represents the configuration choice for the `Radio`.
-}
type Radio model msg
    = Radio (RadioConfig model msg)


{-| Internal.
-}
type alias RadioConfig model msg =
    { options : List (RadioOption model msg)
    , reader : model -> Maybe String
    , tagger : String -> msg
    , radioChoices : List RadioChoice
    }


{-| Creates the `Radio`.
-}
radio : (model -> Maybe String) -> (String -> msg) -> List RadioChoice -> Radio model msg
radio reader tagger =
    Radio << RadioConfig [] reader tagger


{-| Represents a choice for the `Radio`.
-}
type alias RadioChoice =
    { value : String
    , label : String
    }


{-| Creates a choice for the `Radio`.
-}
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
    , class = [ "form-radio__input" ]
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


{-| Adds a validation rule to the `Radio`.
-}
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


readerAttribute : model -> Radio model msg -> RadioChoice -> Html.Attribute msg
readerAttribute model (Radio config) choice =
    model
        |> config.reader
        |> (==) (Just choice.value)
        |> Attrs.checked


taggerAttribute : Radio model msg -> RadioChoice -> Html.Attribute msg
taggerAttribute (Radio config) choice =
    choice.value
        |> config.tagger
        |> Events.onClick


validationAttribute : model -> Radio model msg -> Html.Attribute msg
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


isPristine : model -> Radio model msg -> Bool
isPristine model (Radio config) =
    case config.reader model of
        Just _ ->
            False

        Nothing ->
            True


{-| Composes all the modifiers into a set of `Html.Attribute`(s).
-}
buildAttributes : model -> Radio model msg -> RadioChoice -> List (Html.Attribute msg)
buildAttributes model ((Radio config) as radioModel) ({ label } as choice) =
    let
        options =
            computeOptions radioModel

        taggerAttrList : List (Attribute msg)
        taggerAttrList =
            if Just choice.value == config.reader model then
                []

            else
                [ taggerAttribute radioModel choice ]

        hasValidations : Bool
        hasValidations =
            (List.length options.validations > 0 && not (isPristine model radioModel)) || not (isPristine model radioModel)

        generateId : String -> String
        generateId id =
            id ++ "_" ++ H.slugify label
    in
    [ options.id
        |> Maybe.map (generateId >> Attrs.id)
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
        |> (++) taggerAttrList
        |> H.addIf hasValidations (validationAttribute model radioModel)
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
render model ((Radio { radioChoices }) as radioModel) =
    let
        id : String
        id =
            radioModel
                |> computeOptions
                |> .id
                |> Maybe.withDefault ""
                |> Debug.log "ID"
    in
    Html.div
        [ Attrs.class "form-radio-options", Attrs.id id ]
        (List.map (renderRadioChoice model radioModel) radioChoices)
        :: renderValidationMessages model radioModel


renderRadioChoice : model -> Radio model msg -> RadioChoice -> Html msg
renderRadioChoice model ((Radio { tagger, reader }) as radioModel) ({ value, label } as choice) =
    let
        conditionallyAddOnClick : Label.Label msg -> Label.Label msg
        conditionallyAddOnClick labelInstance =
            if Just choice.value == reader model then
                labelInstance

            else
                Label.withOnClick (tagger value) labelInstance
    in
    Html.div
        [ Attrs.class "form-radio" ]
        [ Html.input
            (buildAttributes model radioModel choice)
            []
        , label
            |> Label.label
            |> conditionallyAddOnClick
            |> Label.withFor value
            |> Label.withOverridingClass "form-radio__label"
            |> Label.render
        ]


renderValidationMessages : model -> Radio model msg -> List (Html msg)
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
computeOptions : Radio model msg -> Options model msg
computeOptions (Radio { options }) =
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
