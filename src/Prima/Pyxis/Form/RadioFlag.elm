module Prima.Pyxis.Form.RadioFlag exposing
    ( RadioFlag
    , radioFlagLight, radioFlagDark
    , render
    , withAttribute, withClass, withDisabled, withId, withName
    , withOnBlur, withOnFocus
    , withValidation
    )

{-|


## Configuration

@docs RadioFlag


## Configuration Methods

@docs radioFlagLight, radioFlagDark


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


{-| Represents the configuration choice for the `RadioFlag`.
-}
type RadioFlag model msg
    = RadioFlag (RadioFlagConfig model msg)


{-| Internal.
-}
type alias RadioFlagConfig model msg =
    { options : List (RadioFlagOption model msg)
    , reader : model -> Maybe Bool
    , tagger : Bool -> msg
    , skin : Skin
    , radioChoices : List RadioFlagChoice
    }


type Skin
    = Light
    | Dark


isLight : Skin -> Bool
isLight =
    (==) Light


isDark : Skin -> Bool
isDark =
    (==) Dark


{-| Creates the `RadioFlag` with a light skin.
-}
radioFlagLight : (model -> Maybe Bool) -> (Bool -> msg) -> RadioFlag model msg
radioFlagLight reader tagger =
    [ radioFlagChoice True "Sì"
    , radioFlagChoice False "No"
    ]
        |> RadioFlagConfig [] reader tagger Light
        |> RadioFlag


{-| Creates the `RadioFlag` with a dark skin.
-}
radioFlagDark : (model -> Maybe Bool) -> (Bool -> msg) -> RadioFlag model msg
radioFlagDark reader tagger =
    [ RadioFlagChoice True "Sì"
    , RadioFlagChoice False "No"
    ]
        |> RadioFlagConfig [] reader tagger Dark
        |> RadioFlag


{-| Represents a choice for the `RadioFlag`.
-}
type alias RadioFlagChoice =
    { value : Bool
    , label : String
    }


{-| Creates a choice for the `RadioFlag`.
-}
radioFlagChoice : Bool -> String -> RadioFlagChoice
radioFlagChoice value label =
    RadioFlagChoice value label


{-| Internal.
-}
type RadioFlagOption model msg
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
    , class = [ "a-form-radio-flag__input" ]
    , disabled = Nothing
    , id = Nothing
    , name = Nothing
    , onFocus = Nothing
    , onBlur = Nothing
    , validations = []
    }


{-| Internal.
-}
addOption : RadioFlagOption model msg -> RadioFlag model msg -> RadioFlag model msg
addOption option (RadioFlag radioConfig) =
    RadioFlag { radioConfig | options = radioConfig.options ++ [ option ] }


{-| Sets an `attribute` to the `Radio config`.
-}
withAttribute : Html.Attribute msg -> RadioFlag model msg -> RadioFlag model msg
withAttribute attribute =
    addOption (Attribute attribute)


{-| Sets a `disabled` to the `Radio config`.
-}
withDisabled : Bool -> RadioFlag model msg -> RadioFlag model msg
withDisabled disabled =
    addOption (Disabled disabled)


{-| Sets a `class` to the `Radio config`.
-}
withClass : String -> RadioFlag model msg -> RadioFlag model msg
withClass class_ =
    addOption (Class class_)


{-| Sets an `id` to the `Radio config`.
-}
withId : String -> RadioFlag model msg -> RadioFlag model msg
withId id =
    addOption (Id id)


{-| Sets a `name` to the `Radio config`.
-}
withName : String -> RadioFlag model msg -> RadioFlag model msg
withName name =
    addOption (Name name)


{-| Sets an `onBlur event` to the `Radio config`.
-}
withOnBlur : msg -> RadioFlag model msg -> RadioFlag model msg
withOnBlur tagger =
    addOption (OnBlur tagger)


{-| Sets an `onFocus event` to the `Radio config`.
-}
withOnFocus : msg -> RadioFlag model msg -> RadioFlag model msg
withOnFocus tagger =
    addOption (OnFocus tagger)


{-| Adds a validation rule to the `RadioFlag`.
-}
withValidation : (model -> Maybe Validation.Type) -> RadioFlag model msg -> RadioFlag model msg
withValidation validation =
    addOption (Validation validation)


{-| Internal.
-}
applyOption : RadioFlagOption model msg -> Options model msg -> Options model msg
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


readerAttribute : model -> RadioFlag model msg -> RadioFlagChoice -> Html.Attribute msg
readerAttribute model (RadioFlag config) choice =
    model
        |> config.reader
        |> (==) (Just choice.value)
        |> Attrs.checked


taggerAttribute : RadioFlag model msg -> RadioFlagChoice -> Html.Attribute msg
taggerAttribute (RadioFlag config) choice =
    choice.value
        |> config.tagger
        |> Events.onClick


validationAttribute : model -> RadioFlag model msg -> Html.Attribute msg
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
buildAttributes : model -> RadioFlag model msg -> RadioFlagChoice -> List (Html.Attribute msg)
buildAttributes model radioModel choice =
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
        |> (::) (Attrs.value (boolToValue choice.value))


{-| Renders the `RadioFlag`.
-}
render : model -> RadioFlag model msg -> List (Html msg)
render model ((RadioFlag { radioChoices }) as radioModel) =
    Html.div
        [ Attrs.class "a-form-radio-flag-options" ]
        (List.map (renderRadioChoice model radioModel) radioChoices)
        :: renderValidationMessages model radioModel


renderRadioChoice : model -> RadioFlag model msg -> RadioFlagChoice -> Html msg
renderRadioChoice model ((RadioFlag { tagger, skin }) as radioModel) ({ value, label } as choice) =
    Html.div
        [ Attrs.classList
            [ ( "a-form-radio-flag", True )
            , ( "a-form-radio-flag--light", isLight skin )
            , ( "a-form-radio-flag--dark", isDark skin )
            ]
        ]
        [ Html.input
            (buildAttributes model radioModel choice)
            []
        , label
            |> Label.label
            |> Label.withOnClick (tagger value)
            |> Label.withFor (boolToValue value)
            |> Label.withOverridingClass "a-form-radio-flag__label"
            |> Label.render
        ]


renderValidationMessages : model -> RadioFlag model msg -> List (Html msg)
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
computeOptions : RadioFlag model msg -> Options model msg
computeOptions (RadioFlag { options }) =
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


boolToValue : Bool -> String
boolToValue flag =
    if flag then
        "si"

    else
        "no"
