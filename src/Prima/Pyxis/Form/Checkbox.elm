module Prima.Pyxis.Form.Checkbox exposing
    ( Checkbox, CheckboxChoice
    , checkbox, checkboxChoice
    , render
    , withAttribute, withDisabled, withClass, withId, withName
    , withOnFocus, withOnBlur
    , withValidation
    )

{-|


## Configuration

@docs Checkbox, CheckboxChoice


## Configuration Methods

@docs checkbox, checkboxChoice


## Rendering

@docs render


## Options

@docs withAttribute, withDisabled, withClass, withId, withName


## Event Options

@docs withOnFocus, withOnBlur


## Validation

@docs withValidation

-}

import Html exposing (Attribute, Html)
import Html.Attributes as Attrs
import Html.Events as Events
import Prima.Pyxis.Form.Label as Label
import Prima.Pyxis.Form.Validation as Validation
import Prima.Pyxis.Helpers as H


{-| Represent the opaque `Checkbox` configuration.
-}
type Checkbox model msg
    = Checkbox (CheckboxConfig model msg)


{-| Internal. Represent the `Checkbox` configuration.
-}
type alias CheckboxConfig model msg =
    { options : List (CheckboxOption model msg)
    , reader : model -> List String
    , tagger : String -> msg
    , choices : List CheckboxChoice
    }


{-| Create a checkbox.
-}
checkbox : (model -> List String) -> (String -> msg) -> List CheckboxChoice -> Checkbox model msg
checkbox reader tagger =
    Checkbox << CheckboxConfig [] reader tagger


{-| Internal. Represent the possible modifiers for an `Checkbox`.
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


{-| Represent a choice for the `Checkbox`.
-}
type alias CheckboxChoice =
    { value : String
    , label : String
    }


{-| Creates a choice for the `Checkbox`.
-}
checkboxChoice : String -> String -> CheckboxChoice
checkboxChoice value label =
    CheckboxChoice value label


{-| Internal. Represent the list of customizations for the `Checkbox` component.
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


{-| Internal. Represent the initial state of the list of customizations for the `Checkbox` component.
-}
defaultOptions : Options model msg
defaultOptions =
    { attributes = []
    , class = [ "a-form-checkbox__input" ]
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
validationAttribute : model -> Checkbox model msg -> Html.Attribute msg
validationAttribute model checkboxModel =
    let
        warnings =
            warningValidations model (computeOptions checkboxModel)

        errors =
            errorsValidations model (computeOptions checkboxModel)
    in
    case ( errors, warnings ) of
        ( [], [] ) ->
            Attrs.class "is-valid"

        ( [], _ ) ->
            Attrs.class "has-warning"

        ( _, _ ) ->
            Attrs.class "has-error"


{-| Internal. Applies all the customizations and returns the internal `Options` type.
-}
computeOptions : Checkbox model msg -> Options model msg
computeOptions (Checkbox config) =
    List.foldl applyOption defaultOptions config.options


{-| Internal. Transforms all the customizations into a list of valid Html.Attribute(s).
-}
buildAttributes : model -> Checkbox model msg -> String -> List (Html.Attribute msg)
buildAttributes model ((Checkbox _) as checkboxModel) choice =
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
        |> (::) (H.classesAttribute options.class)
        |> (::) (readerAttribute model checkboxModel choice)
        |> (::) (taggerAttribute checkboxModel choice)
        |> (::) (Attrs.type_ "checkbox")
        |> (::) (Attrs.value choice)
        |> (::) (validationAttribute model checkboxModel)


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
            [ ( "a-form-checkbox-options", True )
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
        [ Attrs.class "a-form-checkbox" ]
        [ Html.input
            (buildAttributes model checkboxModel checkboxItem.value)
            []
        , checkboxItem.label
            |> Label.label
            |> Label.withOnClick (config.tagger checkboxItem.value)
            |> Label.withFor checkboxItem.value
            |> Label.withOverridingClass "a-form-checkbox__label"
            |> Label.render
        ]


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
