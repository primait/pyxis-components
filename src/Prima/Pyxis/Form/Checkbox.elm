module Prima.Pyxis.Form.Checkbox exposing
    ( Checkbox, checkbox, checkboxChoice
    , withId, withName, withAttribute, withDisabled, withClass
    , withOnFocus, withOnBlur
    , withValidation
    , render
    )

{-|


## Types and Configuration

@docs Checkbox, CheckboxChoice, checkbox, checkboxChoice


## Options

@docs withId, withName, withChecked, withAttribute, withDisabled, withClass


## Events

@docs withOnFocus, withOnBlur


## Validations

@docs withValidation


## Rendering

@docs render

-}

import Html exposing (Attribute, Html)
import Html.Attributes as Attrs
import Html.Events as Events
import Prima.Pyxis.Form.Label as Label
import Prima.Pyxis.Form.Validation as Validation
import Prima.Pyxis.Helpers as H


{-| Represents the opaque `Checkbox` configuration.
-}
type Checkbox model msg
    = Checkbox (CheckboxConfig model msg)


{-| Internal. Represents the `Checkbox` configuration.
-}
type alias CheckboxConfig model msg =
    { options : List (CheckboxOption model msg)
    , reader : model -> List String
    , tagger : String -> msg
    , choices : List CheckboxChoice
    }


{-| Creates a checkbox.
-}
checkbox : (model -> List String) -> (String -> msg) -> List CheckboxChoice -> Checkbox model msg
checkbox reader tagger =
    Checkbox << CheckboxConfig [] reader tagger


{-| Internal. Represents the possible modifiers for an `Checkbox`.
-}
type CheckboxOption model msg
    = Attribute (Html.Attribute msg)
    | Class String
    | Disabled Bool
    | Id String
    | Name String
    | OnFocus msg
    | OnBlur msg
    | Validation (model -> Maybe Validation.Type)


{-| Represents the `CheckboxChoice` configuration.
-}
type alias CheckboxChoice =
    { value : String
    , label : String
    }


{-| Creates the 'CheckboxChoice' configuration.
-}
checkboxChoice : String -> String -> CheckboxChoice
checkboxChoice value label =
    CheckboxChoice value label


{-| Internal. Represents the list of customizations for the `Checkbox` component.
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


{-| Internal. Represents the initial state of the list of customizations for the `Checkbox` component.
-}
defaultOptions : Options model msg
defaultOptions =
    { attributes = []
    , class = [ "a-form-field__checkbox" ]
    , disabled = Nothing
    , id = Nothing
    , name = Nothing
    , onFocus = Nothing
    , onBlur = Nothing
    , validations = []
    }


{-| Internal. Adds a generic option to the `Checkbox`.
-}
addOption : CheckboxOption model msg -> Checkbox model msg -> Checkbox model msg
addOption option (Checkbox checkboxConfig) =
    Checkbox { checkboxConfig | options = checkboxConfig.options ++ [ option ] }


{-| Adds a generic Html.Attribute to the `Checkbox`.
-}
withAttribute : Html.Attribute msg -> Checkbox model msg -> Checkbox model msg
withAttribute attribute =
    addOption (Attribute attribute)


{-| Adds a `disabled` Html.Attribute to the `Checkbox`.
-}
withDisabled : Bool -> Checkbox model msg -> Checkbox model msg
withDisabled disabled =
    addOption (Disabled disabled)


{-| Adds a `class` to the `Checkbox`.
-}
withClass : String -> Checkbox model msg -> Checkbox model msg
withClass class_ =
    addOption (Class class_)


{-| Adds an `id` Html.Attribute to the `Checkbox`.
-}
withId : String -> Checkbox model msg -> Checkbox model msg
withId id =
    addOption (Id id)


{-| Adds a `name` Html.Attribute to the `Checkbox`.
-}
withName : String -> Checkbox model msg -> Checkbox model msg
withName name =
    addOption (Name name)


{-| Attaches the `onBlur` event to the `Checkbox`.
-}
withOnBlur : msg -> Checkbox model msg -> Checkbox model msg
withOnBlur tagger =
    addOption (OnBlur tagger)


{-| Attaches the `onFocus` event to the `Checkbox`.
-}
withOnFocus : msg -> Checkbox model msg -> Checkbox model msg
withOnFocus tagger =
    addOption (OnFocus tagger)


{-| Adds a `Validation` rule to the `Checkbox`.
-}
withValidation : (model -> Maybe Validation.Type) -> Checkbox model msg -> Checkbox model msg
withValidation validation =
    addOption (Validation validation)


{-| Internal. Applies the customizations made by end user to the `Checkbox` component.
-}
applyOption : CheckboxOption model msg -> Options model msg -> Options model msg
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


{-| Internal. Transforms a `List` of `Class`(es) into a valid `Html.Attribute`.
-}
classAttribute : List String -> Html.Attribute msg
classAttribute =
    Attrs.class << String.join " "


{-| Internal. Transforms the `reader` function into a valid Html.Attribute.
-}
readerAttribute : model -> Checkbox model msg -> String -> Html.Attribute msg
readerAttribute model (Checkbox config) choice =
    model
        |> config.reader
        |> List.member choice
        |> Attrs.checked


{-| Internal. Transforms the `tagger` function into a valid Html.Attribute.
-}
taggerAttribute : Checkbox model msg -> String -> Html.Attribute msg
taggerAttribute (Checkbox config) choice =
    choice
        |> config.tagger
        |> Events.onClick


{-| Internal. Transforms all the customizations into a list of valid Html.Attribute(s).
-}
buildAttributes : model -> Checkbox model msg -> String -> List (Html.Attribute msg)
buildAttributes model ((Checkbox config) as checkboxModel) choice =
    let
        options =
            computeOptions checkboxModel
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
        |> (::) (readerAttribute model checkboxModel choice)
        |> (::) (taggerAttribute checkboxModel choice)
        |> (::) (Attrs.type_ "checkbox")
        |> (::) (Attrs.value choice)
        |> (::) (validationAttribute model checkboxModel)


{-| Internal. Transforms all the customizations into a list of valid Html.Attribute(s).
-}
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


{-|


## Renders the `Checkbox`.

    import Html
    import Prima.Pyxis.Form.Checkbox as Checkbox
    import Prima.Pyxis.Form.Validation as Validation

    ...

    type Msg =
        OnChange String

    type alias Model =
        { countryVisited: Maybe String }

    ...

    view : Html Msg
    view =
        Html.div
            []
            (Checkbox.checkbox .countryVisited OnChange
                |> Checkbox.withClass "my-custom-class"
                |> Checkbox.withValidation (Maybe.andThen validate << .countryVisited)
            )

    validate : List String -> Validation.Type
    validate list =
        if List.isEmpty list then
            Just <| Validation.ErrorWithMessage "Country visited is empty".
        else
            Nothing

-}
render : model -> Checkbox model msg -> List (Html msg)
render model ((Checkbox config) as checkboxModel) =
    [ Html.div
        [ Attrs.classList
            [ ( "a-form-field__checkbox-options", True )
            ]
        , validationAttribute model checkboxModel
        ]
        (List.map (renderCheckbox model checkboxModel) config.choices)
    ]


{-| Internal. Renders the `Checkbox` alone.
-}
renderCheckbox : model -> Checkbox model msg -> CheckboxChoice -> Html msg
renderCheckbox model ((Checkbox config) as checkboxModel) checkboxItem =
    Html.div
        [ Attrs.class "a-form-field__checkbox-options__item" ]
        [ Html.input
            (buildAttributes model checkboxModel checkboxItem.value)
            []
        , checkboxItem.label
            |> Label.label
            |> Label.withOnClick (config.tagger checkboxItem.value)
            |> Label.withFor checkboxItem.value
            |> Label.withOverridingClass "a-form-field__checkbox-options__item__label"
            |> Label.render
        ]


{-| Internal. Applies all the customizations and returns the internal `Options` type.
-}
computeOptions : Checkbox model msg -> Options model msg
computeOptions (Checkbox config) =
    List.foldl applyOption defaultOptions config.options
