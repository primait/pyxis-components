module Prima.Pyxis.Form.Date exposing
    ( Date
    , date
    , render
    , withAttribute, withClass, withDefaultValue, withDisabled, withId, withMediumSize, withSmallSize, withLargeSize, withName, withPlaceholder, withIsSubmitted
    , withDatePicker, withDatePickerVisibility
    , withOnBlur, withOnFocus, withOnIconClick
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

@docs withAttribute, withClass, withDefaultValue, withDisabled, withId, withMediumSize, withSmallSize, withLargeSize, withName, withPlaceholder, withIsSubmitted


## DatePicker Options

@docs withDatePicker, withDatePickerVisibility


## Event Options

@docs withOnBlur, withOnFocus, withOnIconClick


## Validation

@docs withValidation

-}

import Date
import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Events as Events
import Json.Decode
import Maybe.Extra as ME
import Prima.Pyxis.Form.DatePicker as DatePicker
import Prima.Pyxis.Form.Validation as Validation
import Prima.Pyxis.Helpers as H
import String.Extra as SE


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
    | IsSubmitted (model -> Bool)
    | Name String
    | OnBlur msg
    | OnFocus msg
    | OnIconClick msg
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


{-| Adds an `isSubmitted` predicate to the `Date`.
-}
withIsSubmitted : (model -> Bool) -> Date model msg -> Date model msg
withIsSubmitted isSubmitted =
    addOption (IsSubmitted isSubmitted)


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


{-| Sets an `onClick event` to the `Date icon`.
-}
withOnIconClick : msg -> Date model msg -> Date model msg
withOnIconClick tagger =
    addOption (OnIconClick tagger)


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

        hasValidations : Bool
        hasValidations =
            shouldBeValidated model dateModel options
    in
    if shouldShowDatePicker model dateModel then
        [ renderGroup
            (renderAppendGroup dateModel
                [ renderDatePickerIcon
                ]
                :: renderInput InputDate model dateModel
                :: renderInput InputText model dateModel
                :: renderDatePicker model dateModel
                :: renderValidationMessages model dateModel hasValidations
            )
        ]

    else
        renderInput InputDate model dateModel
            :: renderInput InputText model dateModel
            :: renderValidationMessages model dateModel hasValidations


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


renderDatePickerIcon : Html msg
renderDatePickerIcon =
    Html.i [ Attrs.class "form-input-group--datepicker__icon" ] []


renderGroup : List (Html msg) -> Html msg
renderGroup =
    Html.div
        [ Attrs.class "form-input-group form-input-group--datepicker" ]


renderAppendGroup : Date model msg -> List (Html msg) -> Html msg
renderAppendGroup dateModel =
    let
        { onIconClick, groupClasses } =
            computeOptions dateModel

        groupAttrs : List (Html.Attribute msg)
        groupAttrs =
            [ Attrs.class "form-input-group__append"
            , Attrs.class <| String.join " " groupClasses
            ]
                ++ ME.unwrap [] (Events.onClick >> List.singleton) onIconClick
    in
    Html.div groupAttrs


renderValidationMessages : model -> Date model msg -> Bool -> List (Html msg)
renderValidationMessages model dateModel showValidation =
    let
        warnings =
            warningValidations model (computeOptions dateModel)

        errors =
            errorsValidations model (computeOptions dateModel)
    in
    case ( showValidation, errors, warnings ) of
        ( True, [], _ ) ->
            List.map Validation.render warnings

        ( True, _, _ ) ->
            List.map Validation.render errors

        ( False, _, _ ) ->
            []


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
    , isSubmitted : model -> Bool
    , name : Maybe String
    , onFocus : Maybe msg
    , onBlur : Maybe msg
    , onIconClick : Maybe msg
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
    , classes = [ "form-input", "form-datepicker" ]
    , groupClasses = []
    , id = Nothing
    , isSubmitted = always True
    , name = Nothing
    , onFocus = Nothing
    , onBlur = Nothing
    , onIconClick = Nothing
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

        IsSubmitted predicate ->
            { options | isSubmitted = predicate }

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

        OnIconClick onIconClick ->
            { options | onIconClick = Just onIconClick }


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


interpolateWithSlash : String -> String
interpolateWithSlash =
    SE.insertAt "/" 2
        >> SE.insertAt "/" 5


{-| Guess internal functions
Try to guess a Date from user input

    guess8Chars 04/04/61 -> 04/04/1961

    guess8Chars 04041961 -> 04/04/1961

    guess6Chars 040461 -> 04/04/1961

    guess6Chars 040419 -> 040419 (Not parsed because 19 is Century)

    guess6Chars 040420 -> 040420 (Not parsed because 20 is Century)

-}
guess8Chars : String -> String
guess8Chars str =
    case ( String.contains "/" str, String.length str ) of
        ( True, 8 ) ->
            str
                |> String.replace "/" ""
                |> guess6Chars interpolateWithSlash

        ( False, 8 ) ->
            String.join "/" [ String.slice 0 2 str, String.slice 2 4 str, String.slice 4 8 str ]

        _ ->
            str


guess6Chars : (String -> String) -> String -> String
guess6Chars mapper str =
    let
        year : String
        year =
            String.slice 4 6 str

        startsWithCentury : Bool
        startsWithCentury =
            String.startsWith "19" year || String.startsWith "20" year
    in
    if startsWithCentury then
        mapper str

    else
        String.join "/" [ String.slice 0 2 str, String.slice 2 4 str, guessedYear year ]


guessedYear : String -> String
guessedYear year =
    if String.length year == 2 then
        year
            |> String.toInt
            |> Maybe.map
                (\y ->
                    if y <= 25 then
                        "20" ++ year

                    else
                        "19" ++ year
                )
            |> Maybe.withDefault year

    else
        year


guessDate : String -> String
guessDate str =
    case String.length str of
        6 ->
            guess6Chars identity str

        8 ->
            guess8Chars str

        _ ->
            str


stringToDate : String -> DatePicker.Date
stringToDate str =
    let
        guessedDate =
            guessDate str
    in
    case
        ( String.length guessedDate
        , guessedDate
            |> toIsoFormat
            |> Date.fromIsoString
        )
    of
        ( 8, Ok parsedDate ) ->
            DatePicker.ParsedDate parsedDate

        ( 10, Ok parsedDate ) ->
            DatePicker.ParsedDate parsedDate

        ( _, _ ) ->
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
            Attrs.attribute "type" "date"

        InputText ->
            Attrs.attribute "type" "text"


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


isPristine : model -> Date model msg -> Bool
isPristine model ((Date config) as dateModel) =
    let
        options =
            computeOptions dateModel

        sameDefault : Bool
        sameDefault =
            Value (config.reader model) == options.defaultValue
    in
    case ( sameDefault, config.reader model ) of
        ( True, _ ) ->
            True

        ( False, DatePicker.PartialDate _ ) ->
            True

        ( False, DatePicker.ParsedDate _ ) ->
            False


{-| Internal. Applies the `pristine/touched` visual state to the component.
-}
pristineAttribute : model -> Date model msg -> Html.Attribute msg
pristineAttribute model dateModel =
    if isPristine model dateModel then
        Attrs.class "is-pristine"

    else
        Attrs.class "is-touched"


{-| Internal. Determines whether the field should be validated or not.
-}
shouldBeValidated : model -> Date model msg -> Options model msg -> Bool
shouldBeValidated model dateModel options =
    (not <| isPristine model dateModel) || options.isSubmitted model


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
        |> H.addIf (shouldBeValidated model dateModel options) (validationAttribute model dateModel)
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
