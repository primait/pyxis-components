module Prima.Pyxis.Form.Date exposing
    ( Date
    , date
    , render
    , withAttribute, withClass, withDefaultValue, withDisabled, withId, withMediumSize, withSmallSize, withLargeSize, withName, withPlaceholder
    , withDatePicker, withDatePickerVisibility
    , withOnBlur, withOnFocus
    , withValidation
    )

{-|


## Configuration

@docs Date


## Configuration Methods

@docs date


## Rendering

@docs render


## Options

@docs withAttribute, withClass, withDefaultValue, withDisabled, withId, withMediumSize, withSmallSize, withLargeSize, withName, withPlaceholder


## DatePicker Options

@docs withDatePicker, withDatePickerVisibility


## Event Options

@docs withOnBlur, withOnFocus


## Validation

@docs withValidation

-}

import Date
import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Events as Events
import Json.Decode
import Prima.Pyxis.Form.DatePicker as DatePicker
import Prima.Pyxis.Form.Validation as Validation
import Prima.Pyxis.Helpers as H


{-| Represent the opaque `Date` configuration.
-}
type Date model msg
    = Date (DateConfig model msg)


{-| Represent the `Date` configuration.
-}
type alias DateConfig model msg =
    { options : List (DateOption model msg)
    , reader : model -> DatePicker.Date
    , tagger : DatePicker.Date -> msg
    }


{-| Internal. Defines the mode in which the input will be rendered. }
This is needed because of we want an Input Text in desktop view, and an Input Date in mobile view.
The Input Date alone cannot be used because of Firefox skin is not customizable.
-}
type Mode
    = InputDate
    | InputText


{-| Create an `input[type="date"]` with the default options.
-}
date : (model -> DatePicker.Date) -> (DatePicker.Date -> msg) -> Date model msg
date reader tagger =
    Date <| DateConfig [] reader tagger


{-| Represent the possibile modifiers of an `Date`.
-}
type DateOption model msg
    = Attribute (Html.Attribute msg)
    | Class String
    | DatePicker (model -> Maybe DatePicker.Model) (DatePicker.Msg -> msg)
    | DatePickerVisibility (model -> Bool)
    | DefaultValue DatePicker.Date
    | Disabled Bool
    | Id String
    | Name String
    | OnBlur msg
    | OnFocus msg
    | Placeholder String
    | Size DateSize
    | Validation (model -> Maybe Validation.Type)


type Default
    = Indeterminate
    | Value DatePicker.Date


{-| Represent the `Date` size.
-}
type DateSize
    = Small
    | Medium
    | Large


{-| Sets an `attribute` to the `Date`.
-}
withAttribute : Html.Attribute msg -> Date model msg -> Date model msg
withAttribute attribute =
    addOption (Attribute attribute)


{-| Sets a `class` to the `Date`.
-}
withClass : String -> Date model msg -> Date model msg
withClass class_ =
    addOption (Class class_)


{-| Adds a default value to the `Date`.
Useful to teach the component about it's `pristine/touched` state.
-}
withDefaultValue : DatePicker.Date -> Date model msg -> Date model msg
withDefaultValue value =
    addOption (DefaultValue value)


{-| Adds a DatePicker to the `Date`.
Remember to add the visibility policy with `withDatePickerVisibility`.
-}
withDatePicker : (model -> Maybe DatePicker.Model) -> (DatePicker.Msg -> msg) -> Date model msg -> Date model msg
withDatePicker reader tagger =
    addOption (DatePicker reader tagger)


{-| Adds a visibility policy to the DatePicker built via `withDatePicker`.
-}
withDatePickerVisibility : (model -> Bool) -> Date model msg -> Date model msg
withDatePickerVisibility reader =
    addOption (DatePickerVisibility reader)


{-| Sets a `disabled` to the `Date`.
-}
withDisabled : Bool -> Date model msg -> Date model msg
withDisabled disabled =
    addOption (Disabled disabled)


{-| Sets an `id` to the `Date`.
-}
withId : String -> Date model msg -> Date model msg
withId id =
    addOption (Id id)


{-| Sets a `size` to the `Date`.
-}
withLargeSize : Date model msg -> Date model msg
withLargeSize =
    addOption (Size Large)


{-| Sets a `name` to the `Date`.
-}
withName : String -> Date model msg -> Date model msg
withName name =
    addOption (Name name)


{-| Sets an `onBlur event` to the `Date`.
-}
withOnBlur : msg -> Date model msg -> Date model msg
withOnBlur tagger =
    addOption (OnBlur tagger)


{-| Sets an `onFocus event` to the `Date`.
-}
withOnFocus : msg -> Date model msg -> Date model msg
withOnFocus tagger =
    addOption (OnFocus tagger)


{-| Sets a `placeholder` to the `Date`.
-}
withPlaceholder : String -> Date model msg -> Date model msg
withPlaceholder placeholder =
    addOption (Placeholder placeholder)


{-| Sets a `size` to the `Date`.
-}
withMediumSize : Date model msg -> Date model msg
withMediumSize =
    addOption (Size Medium)


{-| Sets a `size` to the `Date`.
-}
withSmallSize : Date model msg -> Date model msg
withSmallSize =
    addOption (Size Small)


{-| Adds a `Validation` rule to the `Date`.
-}
withValidation : (model -> Maybe Validation.Type) -> Date model msg -> Date model msg
withValidation validation =
    addOption (Validation validation)


{-| Renders the `Date`.
-}
render : model -> Date model msg -> List (Html msg)
render model dateModel =
    let
        options =
            computeOptions dateModel
    in
    if shouldShowDatePicker model dateModel then
        [ renderGroup
            (renderAppendGroup dateModel
                [ renderDatePickerIcon <| Maybe.withDefault "" options.id
                ]
                :: renderInput InputDate model dateModel
                :: renderInput InputText model dateModel
                :: renderDatePicker model dateModel
                :: renderValidationMessages model dateModel
            )
        ]

    else
        renderInput InputDate model dateModel
            :: renderInput InputText model dateModel
            :: renderValidationMessages model dateModel


renderInput : Mode -> model -> Date model msg -> Html msg
renderInput mode model dateModel =
    Html.input
        (buildAttributes mode model dateModel)
        []


renderDatePicker : model -> Date model msg -> Html msg
renderDatePicker model dateModel =
    let
        { datePickerVisibility, datePickerTagger, datePickerReader } =
            computeOptions dateModel
    in
    case ( datePickerVisibility model, datePickerReader model, datePickerTagger ) of
        ( True, Just dpModel, Just dpTagger ) ->
            dpModel
                |> DatePicker.render
                |> Html.map dpTagger

        _ ->
            Html.text ""


renderDatePickerIcon : String -> Html msg
renderDatePickerIcon fieldId =
    Html.label [ Attrs.class "a-icon a-icon-calendar", Attrs.for fieldId ] []


renderGroup : List (Html msg) -> Html msg
renderGroup =
    Html.div
        [ Attrs.class "m-form-input-group m-form-input-group--datepicker" ]


renderAppendGroup : Date model msg -> List (Html msg) -> Html msg
renderAppendGroup dateModel =
    let
        options =
            computeOptions dateModel
    in
    Html.div
        [ Attrs.class "m-form-input-group__append"
        , Attrs.class <| String.join " " options.groupClasses
        ]


renderValidationMessages : model -> Date model msg -> List (Html msg)
renderValidationMessages model dateModel =
    let
        warnings =
            warningValidations model (computeOptions dateModel)

        errors =
            errorsValidations model (computeOptions dateModel)
    in
    case ( errors, warnings ) of
        ( [], _ ) ->
            List.map Validation.render warnings

        ( _, _ ) ->
            List.map Validation.render errors


shouldShowDatePicker : model -> Date model msg -> Bool
shouldShowDatePicker model dateModel =
    let
        { datePickerTagger, datePickerReader } =
            computeOptions dateModel
    in
    model
        |> datePickerReader
        |> Maybe.map2 (\_ _ -> True) datePickerTagger
        |> Maybe.withDefault False


{-| Internal.
-}
addOption : DateOption model msg -> Date model msg -> Date model msg
addOption option (Date inputConfig) =
    Date { inputConfig | options = inputConfig.options ++ [ option ] }


{-| Represent the options a user can choose to modify
the `Date` default behaviour.
-}
type alias Options model msg =
    { appendGroup : Maybe (List (Html msg))
    , attributes : List (Html.Attribute msg)
    , datePickerReader : model -> Maybe DatePicker.Model
    , datePickerTagger : Maybe (DatePicker.Msg -> msg)
    , datePickerVisibility : model -> Bool
    , defaultValue : Default
    , disabled : Maybe Bool
    , classes : List String
    , groupClasses : List String
    , id : Maybe String
    , name : Maybe String
    , onFocus : Maybe msg
    , onBlur : Maybe msg
    , placeholder : Maybe String
    , prependGroup : Maybe (List (Html msg))
    , size : DateSize
    , validations : List (model -> Maybe Validation.Type)
    }


{-| Internal.
-}
defaultOptions : Options model msg
defaultOptions =
    { appendGroup = Nothing
    , attributes = []
    , datePickerReader = always Nothing
    , datePickerTagger = Nothing
    , datePickerVisibility = always False
    , defaultValue = Indeterminate
    , disabled = Nothing
    , classes = [ "a-form-input", "a-form-datepicker" ]
    , groupClasses = []
    , id = Nothing
    , name = Nothing
    , onFocus = Nothing
    , onBlur = Nothing
    , placeholder = Nothing
    , prependGroup = Nothing
    , size = Medium
    , validations = []
    }


{-| Internal.
-}
applyOption : DateOption model msg -> Options model msg -> Options model msg
applyOption modifier options =
    case modifier of
        Attribute attribute ->
            { options | attributes = attribute :: options.attributes }

        Class class ->
            { options | classes = class :: options.classes }

        DatePicker reader tagger ->
            { options | datePickerTagger = Just tagger, datePickerReader = reader }

        DatePickerVisibility reader ->
            { options | datePickerVisibility = reader }

        DefaultValue value ->
            { options | defaultValue = Value value }

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

        Placeholder placeholder ->
            { options | placeholder = Just placeholder }

        Size size ->
            { options | size = size }

        Validation validation ->
            { options | validations = validation :: options.validations }


{-| Transforms an `DateSize` into a valid `Html.Attribute`.
-}
sizeAttribute : DateSize -> Html.Attribute msg
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


readerAttribute : Mode -> model -> Date model msg -> Html.Attribute msg
readerAttribute mode model (Date config) =
    let
        format =
            case mode of
                InputDate ->
                    "yyyy-MM-dd"

                InputText ->
                    "dd/MM/yyyy"
    in
    case config.reader model of
        DatePicker.ParsedDate parsedDate ->
            parsedDate
                |> Date.format format
                |> Attrs.value

        DatePicker.PartialDate partialDate ->
            partialDate
                |> Maybe.withDefault ""
                |> Attrs.value


taggerAttribute : Date model msg -> Html.Attribute msg
taggerAttribute (Date config) =
    Events.targetValue
        |> Json.Decode.map (config.tagger << stringToDate)
        |> Json.Decode.map (H.flip Tuple.pair True)
        |> Events.stopPropagationOn "input"


stringToDate : String -> DatePicker.Date
stringToDate str =
    case
        str
            |> toIsoFormat
            |> Date.fromIsoString
    of
        Ok parsedDate ->
            DatePicker.ParsedDate parsedDate

        Err _ ->
            (DatePicker.PartialDate << Just) str


toIsoFormat : String -> String
toIsoFormat str =
    str
        |> String.split "/"
        |> List.reverse
        |> String.join "-"


typeAttribute : Mode -> Html.Attribute msg
typeAttribute mode =
    case mode of
        InputDate ->
            Attrs.type_ "date"

        InputText ->
            Attrs.type_ "text"


validationAttribute : model -> Date model msg -> Html.Attribute msg
validationAttribute model dateModel =
    let
        warnings =
            warningValidations model (computeOptions dateModel)

        errors =
            errorsValidations model (computeOptions dateModel)
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
pristineAttribute : model -> Date model msg -> Html.Attribute msg
pristineAttribute model ((Date config) as dateModel) =
    let
        options =
            computeOptions dateModel
    in
    if Value (config.reader model) == options.defaultValue then
        Attrs.class "is-pristine"

    else
        Attrs.class "is-touched"


{-| Composes all the modifiers into a set of `Html.Attribute`(s).
-}
buildAttributes : Mode -> model -> Date model msg -> List (Html.Attribute msg)
buildAttributes mode model dateModel =
    let
        options =
            computeOptions dateModel
    in
    [ options.id
        |> Maybe.map Attrs.id
    , options.name
        |> Maybe.map Attrs.name
    , options.disabled
        |> Maybe.map Attrs.disabled
    , options.placeholder
        |> Maybe.map Attrs.placeholder
    , options.onBlur
        |> Maybe.map Events.onBlur
    , options.onFocus
        |> Maybe.map Events.onFocus
    ]
        |> List.filterMap identity
        |> (++) options.attributes
        |> (::) (H.classesAttribute options.classes)
        |> (::) (readerAttribute mode model dateModel)
        |> (::) (taggerAttribute dateModel)
        |> (::) (sizeAttribute options.size)
        |> (::) (validationAttribute model dateModel)
        |> (::) (pristineAttribute model dateModel)
        |> (::) (typeAttribute mode)


{-| Internal
-}
computeOptions : Date model msg -> Options model msg
computeOptions (Date config) =
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
