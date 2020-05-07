module Prima.Pyxis.Form.Autocomplete exposing
    ( Autocomplete, State, Msg, AutocompleteChoice
    , autocomplete, init, update, autocompleteChoice
    , render
    , selectedValue, filterValue, subscription
    , withAttribute, withClass, withDefaultValue, withDisabled, withId, withName, withMediumSize, withSmallSize, withLargeSize, withPlaceholder, withThreshold, withOverridingClass
    , withOnBlur, withOnFocus
    , withValidation
    )

{-|


## Configuration

@docs Autocomplete, State, Msg, AutocompleteChoice


## Configuration Methods

@docs autocomplete, init, update, autocompleteChoice


## Rendering

@docs render


## Methods

@docs selectedValue, filterValue, subscription


## Options

@docs withAttribute, withClass, withDefaultValue, withDisabled, withId, withName, withMediumSize, withSmallSize, withLargeSize, withPlaceholder, withThreshold, withOverridingClass


## Event Options

@docs withOnBlur, withOnFocus


## Validation

@docs withValidation

-}

import Array
import Browser.Events
import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Events as Events
import Json.Decode
import Prima.Pyxis.Form.Commons.KeyboardEvents as KeyboardEvents
import Prima.Pyxis.Form.Validation as Validation
import Prima.Pyxis.Helpers as H


{-| Represents the Msg of the `Autocomplete`.
-}
type Msg
    = OnKeyPress (Maybe KeyboardEvents.KeyCode)
    | OnFilter String
    | OnSelect String
    | OnReset


{-| Represent the opaque `Autocomplete` configuration.
-}
type Autocomplete model
    = Autocomplete (AutocompleteConfig model)


{-| Internal. Represent the `Autocomplete` configuration.
-}
type alias AutocompleteConfig model =
    List (AutocompleteOption model)


{-| The `State` of the `Autocomplete`
-}
type State
    = State StateConfig


{-| Internal.
The configuration of the `Autocomplete`'s `State`.
-}
type alias StateConfig =
    { focused : Maybe String
    , selected : Maybe String
    , filter : Maybe String
    , isMenuOpen : Bool
    , choices : List AutocompleteChoice
    }


{-| Initializes the `Autocomplete`'s `State`.
-}
init : List AutocompleteChoice -> State
init choices =
    State <| StateConfig Nothing Nothing Nothing False choices


{-| Updates the `Autocomplete`'s `State`.
-}
update : Msg -> State -> State
update msg ((State state) as stateModel) =
    case msg of
        OnFilter value ->
            updateOnFilter (Just value) stateModel

        OnSelect value ->
            updateOnSelect (Just value) stateModel

        OnReset ->
            updateOnReset stateModel

        OnKeyPress (Just KeyboardEvents.UpKey) ->
            updateOnKeyUp stateModel

        OnKeyPress (Just KeyboardEvents.DownKey) ->
            updateOnKeyDown stateModel

        OnKeyPress (Just KeyboardEvents.EnterKey) ->
            updateOnSelect state.focused stateModel

        OnKeyPress Nothing ->
            stateModel


{-| Internal.
-}
updateOnFilter : Maybe String -> State -> State
updateOnFilter value (State state) =
    State { state | filter = value, isMenuOpen = True }


{-| Internal.
-}
updateOnSelect : Maybe String -> State -> State
updateOnSelect value (State state) =
    State { state | selected = value, isMenuOpen = False }


{-| Internal.
-}
updateOnReset : State -> State
updateOnReset (State state) =
    State { state | filter = Nothing, selected = Nothing, isMenuOpen = False }


{-| Internal.
-}
updateOnKeyUp : State -> State
updateOnKeyUp ((State state) as stateModel) =
    let
        focusedItemIndex =
            pickFocusedItemIndex stateModel
    in
    State
        { state
            | focused =
                stateModel
                    |> pickChoiceByIndex
                        (if KeyboardEvents.wentTooHigh focusedItemIndex then
                            focusedItemIndex

                         else
                            focusedItemIndex - 1
                        )
                    |> Maybe.map .value
        }


{-| Internal.
-}
updateOnKeyDown : State -> State
updateOnKeyDown ((State state) as stateModel) =
    let
        focusedItemIndex =
            pickFocusedItemIndex stateModel

        thereIsNoFocusedItem =
            Nothing == state.focused

        wentTooLow =
            KeyboardEvents.wentTooLow focusedItemIndex (filterChoices stateModel)
    in
    State
        { state
            | focused =
                stateModel
                    |> pickChoiceByIndex
                        (if thereIsNoFocusedItem || wentTooLow then
                            0

                         else
                            focusedItemIndex + 1
                        )
                    |> Maybe.map .value
        }


{-| Returns the current `AutocompleteChoice.value` selected by the user.
-}
selectedValue : State -> Maybe String
selectedValue (State stateConfig) =
    stateConfig.selected


{-| Returns the current filter inserted by the user.
-}
filterValue : State -> Maybe String
filterValue (State stateConfig) =
    stateConfig.filter


{-| Creates an autocomplete.
-}
autocomplete : Autocomplete model
autocomplete =
    Autocomplete []


{-| Represent the `AutocompleteChoice` configuration.
-}
type alias AutocompleteChoice =
    { value : String
    , label : String
    }


{-| Create the AutocompleteChoice configuration.
-}
autocompleteChoice : String -> String -> AutocompleteChoice
autocompleteChoice value label =
    AutocompleteChoice value label


{-| Internal. Represent the possible modifiers for an `Autocomplete`.
-}
type AutocompleteOption model
    = Attribute (Html.Attribute Msg)
    | Class String
    | DefaultValue (Maybe String)
    | Disabled Bool
    | Id String
    | Name String
    | OnBlur Msg
    | OnFocus Msg
    | OverridingClass String
    | Placeholder String
    | Size AutocompleteSize
    | Threshold Int
    | Validation (model -> Maybe Validation.Type)


{-| Internal. The default value in order to represent the `pristine/touched` state.
-}
type DefaultValue
    = Indeterminate
    | Value (Maybe String)


{-| Represent the `Autocomplete` size.
-}
type AutocompleteSize
    = Small
    | Medium
    | Large


isSmall : AutocompleteSize -> Bool
isSmall =
    (==) Small


isMedium : AutocompleteSize -> Bool
isMedium =
    (==) Medium


isLarge : AutocompleteSize -> Bool
isLarge =
    (==) Large


{-| Adds a generic Html.Attribute to the `Autocomplete`.
-}
withAttribute : Html.Attribute Msg -> Autocomplete model -> Autocomplete model
withAttribute attribute =
    addOption (Attribute attribute)


{-| Adds a `class` to the `Autocomplete`.
-}
withClass : String -> Autocomplete model -> Autocomplete model
withClass class_ =
    addOption (Class class_)


{-| Adds a default value to the `Input`.
Useful to teach the component about it's `pristine/touched` state.
-}
withDefaultValue : Maybe String -> Autocomplete model -> Autocomplete model
withDefaultValue value =
    addOption (DefaultValue value)


{-| Adds a `disabled` Html.Attribute to the `Autocomplete`.
-}
withDisabled : Bool -> Autocomplete model -> Autocomplete model
withDisabled disabled =
    addOption (Disabled disabled)


{-| Adds an `id` Html.Attribute to the `Autocomplete`.
-}
withId : String -> Autocomplete model -> Autocomplete model
withId id =
    addOption (Id id)


{-| Adds a `name` Html.Attribute to the `Autocomplete`.
-}
withName : String -> Autocomplete model -> Autocomplete model
withName name =
    addOption (Name name)


{-| Attaches the `onBlur` event to the `Autocomplete`.
-}
withOnBlur : Msg -> Autocomplete model -> Autocomplete model
withOnBlur tagger =
    addOption (OnBlur tagger)


{-| Attaches the `onFocus` event to the `Autocomplete`.
-}
withOnFocus : Msg -> Autocomplete model -> Autocomplete model
withOnFocus tagger =
    addOption (OnFocus tagger)


{-| Adds a `class` to the `Autocomplete` which overrides all the previous.
-}
withOverridingClass : String -> Autocomplete model -> Autocomplete model
withOverridingClass class =
    addOption (OverridingClass class)


{-| Adds a `placeholder` Html.Attribute to the `Autocomplete`.
-}
withPlaceholder : String -> Autocomplete model -> Autocomplete model
withPlaceholder placeholder =
    addOption (Placeholder placeholder)


{-| Adds a `size` of `Large` to the `Autocomplete`.
-}
withLargeSize : Autocomplete model -> Autocomplete model
withLargeSize =
    addOption (Size Large)


{-| Adds a `size` of `Medium` to the `Autocomplete`.
-}
withMediumSize : Autocomplete model -> Autocomplete model
withMediumSize =
    addOption (Size Medium)


{-| Adds a `size` of `Small` to the `Autocomplete`.
-}
withSmallSize : Autocomplete model -> Autocomplete model
withSmallSize =
    addOption (Size Small)


{-| Adds a `threshold` on the filter to the `Autocomplete`.
-}
withThreshold : Int -> Autocomplete model -> Autocomplete model
withThreshold threshold =
    addOption (Threshold threshold)


{-| Adds a `Validation` rule to the `Autocomplete`.
-}
withValidation : (model -> Maybe Validation.Type) -> Autocomplete model -> Autocomplete model
withValidation validation =
    addOption (Validation validation)


{-| Internal. Adds a generic option to the `Autocomplete`.
-}
addOption : AutocompleteOption model -> Autocomplete model -> Autocomplete model
addOption option (Autocomplete options) =
    Autocomplete <| options ++ [ option ]


{-| Internal. Represent the list of customizations for the `Autocomplete` component.
-}
type alias Options model =
    { attributes : List (Html.Attribute Msg)
    , disabled : Maybe Bool
    , defaultValue : DefaultValue
    , classes : List String
    , id : Maybe String
    , name : Maybe String
    , onFocus : Maybe Msg
    , onBlur : Maybe Msg
    , placeholder : Maybe String
    , size : AutocompleteSize
    , threshold : Int
    , validations : List (model -> Maybe Validation.Type)
    }


{-| Internal. Represent the initial state of the list of customizations for the `Autocomplete` component.
-}
defaultOptions : Options model
defaultOptions =
    { attributes = []
    , defaultValue = Indeterminate
    , disabled = Nothing
    , classes = [ "form-input form-autocomplete__input" ]
    , id = Nothing
    , name = Nothing
    , onFocus = Nothing
    , onBlur = Nothing
    , placeholder = Nothing
    , size = Medium
    , threshold = 1
    , validations = []
    }


{-| Internal. Applies the customizations made by end user to the `Autocomplete` component.
-}
applyOption : AutocompleteOption model -> Options model -> Options model
applyOption modifier options =
    case modifier of
        Attribute attribute ->
            { options | attributes = attribute :: options.attributes }

        Class class ->
            { options | classes = class :: options.classes }

        OverridingClass class ->
            { options | classes = [ class ] }

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

        Threshold threshold ->
            { options | threshold = threshold }

        Validation validation ->
            { options | validations = validation :: options.validations }


{-| Internal. Transforms the `Validation` status into an Html.Attribute `class`.
-}
validationAttribute : model -> Autocomplete model -> Html.Attribute Msg
validationAttribute model autocompleteModel =
    let
        warnings =
            warningValidations model (computeOptions autocompleteModel)

        errors =
            errorsValidations model (computeOptions autocompleteModel)
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
pristineAttribute : State -> Autocomplete model -> Html.Attribute Msg
pristineAttribute (State stateConfig) inputModel =
    let
        options =
            computeOptions inputModel
    in
    if Value stateConfig.selected == options.defaultValue then
        Attrs.class "is-pristine"

    else
        Attrs.class "is-touched"


{-| Internal. Transforms the `reader` function into a valid Html.Attribute.
-}
filterReaderAttribute : State -> Html.Attribute Msg
filterReaderAttribute (State stateConfig) =
    case
        ( stateConfig.selected
        , stateConfig.isMenuOpen
        )
    of
        ( Just currentValue, False ) ->
            stateConfig.choices
                |> List.filter ((==) currentValue << .value)
                |> List.map .label
                |> List.head
                |> Maybe.withDefault ""
                |> Attrs.value

        _ ->
            stateConfig.filter
                |> Maybe.withDefault ""
                |> Attrs.value


{-| Internal. Transforms the `tagger` function into a valid Html.Attribute.
-}
filterTaggerAttribute : Html.Attribute Msg
filterTaggerAttribute =
    Events.onInput OnFilter


{-| Renders the `Autocomplete`.
-}
render : model -> State -> Autocomplete model -> List (Html Msg)
render model ((State stateConfig) as stateModel) autocompleteModel =
    let
        options =
            computeOptions autocompleteModel

        hasSelectedAnyChoice =
            List.any (isChoiceSelected stateModel) stateConfig.choices
    in
    Html.div
        [ Attrs.classList
            [ ( "form-autocomplete", True )
            , ( "is-open", hasReachedThreshold stateModel autocompleteModel && stateConfig.isMenuOpen )
            , ( "has-selected-choice", hasSelectedAnyChoice )
            , ( "is-small", isSmall options.size )
            , ( "is-medium", isMedium options.size )
            , ( "is-large", isLarge options.size )
            ]
        , validationAttribute model autocompleteModel
        , pristineAttribute stateModel autocompleteModel
        ]
        [ Html.input
            (buildAttributes model stateModel autocompleteModel)
            []
        , Html.i
            [ Attrs.class "form-autocomplete__search-icon" ] []
        , Html.ul
            [ Attrs.class "form-autocomplete__list" ]
            (if List.length (filterChoices stateModel) > 0 then
                stateModel
                    |> filterChoices
                    |> List.map (renderAutocompleteChoice stateModel)

             else
                renderAutocompleteNoResults
            )
        , renderResetIcon
            |> H.renderIf hasSelectedAnyChoice
        ]
        :: renderValidationMessages model autocompleteModel


renderAutocompleteChoice : State -> AutocompleteChoice -> Html Msg
renderAutocompleteChoice stateModel choice =
    Html.li
        [ Attrs.classList
            [ ( "form-autocomplete__list__item", True )
            , ( "is-selected", isChoiceSelected stateModel choice || isChoiceFocused stateModel choice )
            ]
        , (Events.onClick << OnSelect) choice.value
        ]
        [ Html.text choice.label ]


{-| Internal. Renders the `AutocompleteChoice` list without results.
-}
renderAutocompleteNoResults : List (Html Msg)
renderAutocompleteNoResults =
    [ Html.li
        [ Attrs.class "form-autocomplete__list--no-results" ]
        [ Html.text "Nessun risultato." ]
    ]


{-| Internal. Renders the reset icon.
-}
renderResetIcon : Html Msg
renderResetIcon =
    Html.i
        [ Attrs.class "form-autocomplete__reset-icon"
        , Events.onClick OnReset
        ]
        []


{-| Internal. Renders the list of errors if present. Renders the list of warnings if not.
-}
renderValidationMessages : model -> Autocomplete model -> List (Html Msg)
renderValidationMessages model autocompleteModel =
    let
        warnings =
            warningValidations model (computeOptions autocompleteModel)

        errors =
            errorsValidations model (computeOptions autocompleteModel)
    in
    case ( errors, warnings ) of
        ( [], _ ) ->
            List.map Validation.render warnings

        ( _, _ ) ->
            List.map Validation.render errors


{-| Internal. Transforms all the customizations into a list of valid Html.Attribute(s).
-}
buildAttributes : model -> State -> Autocomplete model -> List (Html.Attribute Msg)
buildAttributes model stateModel autocompleteModel =
    let
        options =
            computeOptions autocompleteModel
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
        |> (::) (validationAttribute model autocompleteModel)
        |> (::) (pristineAttribute stateModel autocompleteModel)
        |> (::) (filterReaderAttribute stateModel)
        |> (::) filterTaggerAttribute


{-| Internal. Applies all the customizations and returns the internal `Options` type.
-}
computeOptions : Autocomplete model -> Options model
computeOptions (Autocomplete options) =
    List.foldl applyOption defaultOptions options


{-| Internal. Returns a list of warnings.
-}
warningValidations : model -> Options model -> List Validation.Type
warningValidations model options =
    options.validations
        |> List.filterMap (H.flip identity model)
        |> List.filter Validation.isWarning


{-| Internal. Returns a list of errors.
-}
errorsValidations : model -> Options model -> List Validation.Type
errorsValidations model options =
    options.validations
        |> List.filterMap (H.flip identity model)
        |> List.filter Validation.isError


{-| Internal. Filter `AutocompleteChoice`s by the current filter.
-}
filterChoices : State -> List AutocompleteChoice
filterChoices (State { choices, filter }) =
    choices
        |> List.filter
            (.label
                >> String.toLower
                >> String.contains
                    (filter
                        |> Maybe.map String.toLower
                        |> Maybe.withDefault ""
                    )
            )


{-| Internal. Checks if the min amount of chars has been reached.
-}
hasReachedThreshold : State -> Autocomplete model -> Bool
hasReachedThreshold (State { filter }) autocompleteModel =
    let
        options =
            computeOptions autocompleteModel
    in
    filter
        |> Maybe.map String.length
        |> Maybe.withDefault 0
        |> (<=) options.threshold


isChoiceSelected : State -> AutocompleteChoice -> Bool
isChoiceSelected (State stateConfig) choice =
    Just choice.value == stateConfig.selected


isChoiceFocused : State -> AutocompleteChoice -> Bool
isChoiceFocused (State stateConfig) choice =
    Just choice.value == stateConfig.focused


{-| Internal. Returns the focusedItem index or zero.
-}
pickFocusedItemIndex : State -> Int
pickFocusedItemIndex ((State { focused }) as stateModel) =
    stateModel
        |> filterChoices
        |> List.indexedMap Tuple.pair
        |> List.filter ((==) focused << Just << .value << Tuple.second)
        |> List.head
        |> Maybe.map Tuple.first
        |> Maybe.withDefault 0


{-| Internal. Returns the `AutocompleteChoice` found by index.
-}
pickChoiceByIndex : Int -> State -> Maybe AutocompleteChoice
pickChoiceByIndex index =
    filterChoices
        >> Array.fromList
        >> Array.get index


{-| Needed to wire keyboard events to the `Autocomplete`.
-}
subscription : Sub Msg
subscription =
    Events.keyCode
        |> Json.Decode.map KeyboardEvents.toKeyCode
        |> Json.Decode.map OnKeyPress
        |> Browser.Events.onKeyDown
