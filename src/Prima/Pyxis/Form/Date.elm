module Prima.Pyxis.Form.Date exposing
    ( Date, date
    , withAttribute, withClass, withDisabled, withId, withName, withPlaceholder
    , withRegularSize, withSmallSize, withLargeSize
    , withDatePicker, withDatePickerVisibility
    , withOnBlur, withOnFocus
    , withValidation
    , render
    )

{-|


## Types and Configuration

@docs Date, date


## Generic modifiers

@docs withAttribute, withClass, withDisabled, withId, withName, withPlaceholder


## Size modifiers

@docs withRegularSize, withSmallSize, withLargeSize


## DatePicker modifiers

@docs withDatePicker, withDatePickerVisibility


## Events

@docs withOnBlur, withOnFocus


## Validations

@docs withValidation


## Rendering

@docs render

-}

import Date
import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Events as Events
import Json.Decode
import Prima.Pyxis.Form.DatePicker as DatePicker
import Prima.Pyxis.Form.Validation as Validation
import Prima.Pyxis.Helpers as H


{-| Represents the opaque `Date` configuration.
-}
type Date model msg
    = Date (DateConfig model msg)


{-| Represents the `Date` configuration.
-}
type alias DateConfig model msg =
    { options : List (DateOption model msg)
    , reader : model -> DatePicker.Date
    , tagger : DatePicker.Date -> msg
    }


{-| Creates an `input[type="date"]` with the default options.
-}
date : (model -> DatePicker.Date) -> (DatePicker.Date -> msg) -> Date model msg
date reader tagger =
    Date <| DateConfig [] reader tagger


{-| Represents the possibile modifiers of an `Date`.
-}
type DateOption model msg
    = Attribute (Html.Attribute msg)
    | Class String
    | DatePicker (DatePicker.Msg -> msg) (model -> Maybe DatePicker.Model)
    | DatePickerVisibility (model -> Bool)
    | Disabled Bool
    | Id String
    | Name String
    | OnBlur msg
    | OnFocus msg
    | Placeholder String
    | Size DateSize
    | Validation (model -> Maybe Validation.Type)


{-| Represents the `Date` size.
-}
type DateSize
    = Small
    | Regular
    | Large


{-| Sets an `attribute` to the `Date config`.
-}
withAttribute : Html.Attribute msg -> Date model msg -> Date model msg
withAttribute attribute =
    addOption (Attribute attribute)


{-| Sets a `class` to the `Date config`.
-}
withClass : String -> Date model msg -> Date model msg
withClass class_ =
    addOption (Class class_)


withDatePicker : (DatePicker.Msg -> msg) -> (model -> Maybe DatePicker.Model) -> Date model msg -> Date model msg
withDatePicker tagger model =
    addOption (DatePicker tagger model)


withDatePickerVisibility : (model -> Bool) -> Date model msg -> Date model msg
withDatePickerVisibility reader =
    addOption (DatePickerVisibility reader)


{-| Sets a `disabled` to the `Date config`.
-}
withDisabled : Bool -> Date model msg -> Date model msg
withDisabled disabled =
    addOption (Disabled disabled)


{-| Sets an `id` to the `Date config`.
-}
withId : String -> Date model msg -> Date model msg
withId id =
    addOption (Id id)


{-| Sets a `size` to the `Date config`.
-}
withLargeSize : Date model msg -> Date model msg
withLargeSize =
    addOption (Size Large)


{-| Sets a `name` to the `Date config`.
-}
withName : String -> Date model msg -> Date model msg
withName name =
    addOption (Name name)


{-| Sets an `onBlur event` to the `Date config`.
-}
withOnBlur : msg -> Date model msg -> Date model msg
withOnBlur tagger =
    addOption (OnBlur tagger)


{-| Sets an `onFocus event` to the `Date config`.
-}
withOnFocus : msg -> Date model msg -> Date model msg
withOnFocus tagger =
    addOption (OnFocus tagger)


{-| Sets a `placeholder` to the `Date config`.
-}
withPlaceholder : String -> Date model msg -> Date model msg
withPlaceholder placeholder =
    addOption (Placeholder placeholder)


{-| Sets a `size` to the `Date config`.
-}
withRegularSize : Date model msg -> Date model msg
withRegularSize =
    addOption (Size Regular)


{-| Sets a `size` to the `Date config`.
-}
withSmallSize : Date model msg -> Date model msg
withSmallSize =
    addOption (Size Small)


withValidation : (model -> Maybe Validation.Type) -> Date model msg -> Date model msg
withValidation validation =
    addOption (Validation validation)


{-| Renders the `Date config`.
-}
render : model -> Date model msg -> List (Html msg)
render model dateModel =
    if shouldShowDatePicker model dateModel then
        [ renderGroup
            (renderAppendGroup dateModel
                [ renderDatePickerIcon
                ]
                :: renderDate model dateModel
                :: renderDatePicker model dateModel
                :: renderValidationMessages model dateModel
            )
        ]

    else
        renderDate model dateModel :: renderValidationMessages model dateModel


renderDate : model -> Date model msg -> Html msg
renderDate model dateModel =
    Html.input
        (buildAttributes model dateModel)
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
    Html.i [ Attrs.class "a-icon a-icon-calendar" ] []


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
        options =
            computeOptions dateModel

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


shouldShowDatePicker : model -> Date model msg -> Bool
shouldShowDatePicker model dateModel =
    let
        { datePickerTagger, datePickerReader } =
            computeOptions dateModel
    in
    case ( datePickerTagger, datePickerReader model ) of
        ( Just _, Just _ ) ->
            True

        _ ->
            False


{-| Internal.
-}
addOption : DateOption model msg -> Date model msg -> Date model msg
addOption option (Date inputConfig) =
    Date { inputConfig | options = inputConfig.options ++ [ option ] }


{-| Represents the options a user can choose to modify
the `Date` default behaviour.
-}
type alias Options model msg =
    { appendGroup : Maybe (List (Html msg))
    , attributes : List (Html.Attribute msg)
    , datePickerReader : model -> Maybe DatePicker.Model
    , datePickerTagger : Maybe (DatePicker.Msg -> msg)
    , datePickerVisibility : model -> Bool
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
    , disabled = Nothing
    , classes = [ "a-form-field__input", "a-form-field__datepicker" ]
    , groupClasses = []
    , id = Nothing
    , name = Nothing
    , onFocus = Nothing
    , onBlur = Nothing
    , placeholder = Nothing
    , prependGroup = Nothing
    , size = Regular
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

        DatePicker tagger reader ->
            { options | datePickerTagger = Just tagger, datePickerReader = reader }

        DatePickerVisibility reader ->
            { options | datePickerVisibility = reader }

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


{-| Transforms a `List` of `Class`(es) into a valid `Html.Attribute`.
-}
classesAttribute : List String -> Html.Attribute msg
classesAttribute =
    Attrs.class << String.join " "


{-| Transforms an `DateSize` into a valid `Html.Attribute`.
-}
sizeAttribute : DateSize -> Html.Attribute msg
sizeAttribute size =
    Attrs.class
        (case size of
            Small ->
                "is-small"

            Regular ->
                "is-medium"

            Large ->
                "is-large"
        )


readerAttribute : model -> Date model msg -> Html.Attribute msg
readerAttribute model (Date config) =
    case config.reader model of
        DatePicker.ParsedDate parsedDate ->
            parsedDate
                |> Date.format "dd/MM/yyyy"
                |> Attrs.value

        DatePicker.PartialDate partialDate ->
            partialDate
                |> Maybe.withDefault ""
                |> Attrs.value


taggerAttribute : Date model msg -> Html.Attribute msg
taggerAttribute (Date config) =
    Events.targetValue
        |> Json.Decode.map (config.tagger << stringToDate)
        |> Json.Decode.map (\any -> ( any, True ))
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


validationAttribute : model -> Date model msg -> Html.Attribute msg
validationAttribute model dateModel =
    let
        options =
            computeOptions dateModel

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
buildAttributes : model -> Date model msg -> List (Html.Attribute msg)
buildAttributes model dateModel =
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
        |> (::) (classesAttribute options.classes)
        |> (::) (readerAttribute model dateModel)
        |> (::) (taggerAttribute dateModel)
        |> (::) (sizeAttribute options.size)
        |> (::) (validationAttribute model dateModel)
        |> (::) (Attrs.type_ "text")


{-| Internal
-}
computeOptions : Date model msg -> Options model msg
computeOptions (Date config) =
    List.foldl applyOption defaultOptions config.options
