module Prima.Pyxis.Form.SelectWithFilter exposing
    ( SelectWithFilter, State, Msg
    , init, update, selectWithFilterChoice
    , render
    , selectedValue, filterValue, subscription
    , withAttribute, withClass, withDefaultValue, withDisabled, withId, withName, withMediumSize, withSmallSize, withLargeSize, withPlaceholder, withOverridingClass
    , withOnBlur, withOnFocus
    , withValidation
    , selectWithFilter
    )

{-|


## Configuration

@docs SelectWithFilter, State, Msg, SelectWithFilterChoice


## Configuration Methods

@docs autocomplete, init, update, selectWithFilterChoice


## Rendering

@docs render


## Methods

@docs selectedValue, filterValue, subscription


## Options

@docs withAttribute, withClass, withDefaultValue, withDisabled, withId, withName, withMediumSize, withSmallSize, withLargeSize, withPlaceholder, withOverridingClass


## Event Options

@docs withOnBlur, withOnFocus


## Validation

@docs withValidation

-}

import Html exposing (Html)
import Prima.Pyxis.Form.Autocomplete as Autocomplete
import Prima.Pyxis.Form.Validation as Validation


{-| Represents the Msg of the `SelectWithFilter`.
-}
type Msg
    = SelectWithFilterMsg Autocomplete.Msg


{-| Represent the opaque `SelectWithFilter` configuration.
-}
type alias SelectWithFilter model =
    Autocomplete.Autocomplete model


{-| The `State` of the `SelectWithFilter`
-}
type alias State =
    { autocompleteState : Autocomplete.State
    , choices : List SelectWithFilterChoice
    }


{-| Represent the `SelectWithFilterChoice` configuration.
-}
type alias SelectWithFilterChoice =
    Autocomplete.AutocompleteChoice


{-| Creates an select with a filter input.
-}
selectWithFilter : SelectWithFilter model
selectWithFilter =
    Autocomplete.autocomplete


{-| Initializes the `SelectWithFilter`'s `State`.
-}
init : List SelectWithFilterChoice -> State
init choices =
    { choices = choices
    , autocompleteState = Autocomplete.init
    }


{-| Updates the `SelectWithFilter`'s `State`.
-}
update : Msg -> State -> State
update msg state =
    case msg of
        SelectWithFilterMsg autocompleteMsg ->
            let
                ( autocompleteState, _, _ ) =
                    Autocomplete.update autocompleteMsg state.autocompleteState
            in
            state
                |> updateAutocompleteState autocompleteState
                |> updateChoices


{-| Internal. Check if the choice contains the string.
-}
choiceContainsFilter : Maybe String -> SelectWithFilterChoice -> Bool
choiceContainsFilter maybeFilter { value, label } =
    maybeFilter
        |> Maybe.map (\filter -> String.contains filter label || String.contains filter value)
        |> Maybe.withDefault True


{-| Internal. Filter the choices using the filter string
-}
filterChoices : State -> List SelectWithFilterChoice
filterChoices { choices, autocompleteState } =
    choices
        |> List.filter (choiceContainsFilter (filterValue autocompleteState))


{-| Update the `SelectWithFilterChoice` inside `Autocomplete`'s state
-}
updateChoices : State -> State
updateChoices state =
    state
        |> filterChoices
        |> (\filteredChoices ->
                { state | autocompleteState = Autocomplete.updateChoices filteredChoices state.autocompleteState }
           )


{-| Update the `Autocomplete.State`
-}
updateAutocompleteState : Autocomplete.State -> State -> State
updateAutocompleteState autocompleteState state =
    { state | autocompleteState = autocompleteState }


{-| Create the SelectWithFilterChoice configuration.
-}
selectWithFilterChoice : String -> String -> SelectWithFilterChoice
selectWithFilterChoice =
    Autocomplete.autocompleteChoice


{-| Returns the current `SelectWithFilterChoice.value` selected by the user.
-}
selectedValue : State -> Maybe String
selectedValue { autocompleteState } =
    Autocomplete.selectedValue autocompleteState


{-| Returns the current filter inserted by the user.
-}
filterValue : Autocomplete.State -> Maybe String
filterValue =
    Autocomplete.filterValue


{-| Needed to wire keyboard events to the `Autocomplete`.
-}
subscription : Sub Autocomplete.Msg
subscription =
    Autocomplete.subscription


{-| Adds a generic Html.Attribute to the `SelectWithFilter`.
-}
withAttribute : Html.Attribute Autocomplete.Msg -> Autocomplete.Autocomplete model -> SelectWithFilter model
withAttribute =
    Autocomplete.withAttribute


{-| Adds a `class` to the `SelectWithFilter`.
-}
withClass : String -> SelectWithFilter model -> SelectWithFilter model
withClass =
    Autocomplete.withClass


{-| Adds a default value to the `Input`.
Useful to teach the component about it's `pristine/touched` state.
-}
withDefaultValue : Maybe String -> SelectWithFilter model -> SelectWithFilter model
withDefaultValue =
    Autocomplete.withDefaultValue


{-| Adds a `disabled` Html.Attribute to the `SelectWithFilter`.
-}
withDisabled : Bool -> SelectWithFilter model -> SelectWithFilter model
withDisabled =
    Autocomplete.withDisabled


{-| Adds an `id` Html.Attribute to the `SelectWithFilter`.
-}
withId : String -> SelectWithFilter model -> SelectWithFilter model
withId =
    Autocomplete.withId


{-| Adds a `name` Html.Attribute to the `SelectWithFilter`.
-}
withName : String -> SelectWithFilter model -> SelectWithFilter model
withName =
    Autocomplete.withName


{-| Adds a `size` of `Medium` to the `SelectWithFilter`.
-}
withMediumSize : SelectWithFilter model -> SelectWithFilter model
withMediumSize =
    Autocomplete.withMediumSize


{-| Adds a `size` of `Small` to the `SelectWithFilter`.
-}
withSmallSize : SelectWithFilter model -> SelectWithFilter model
withSmallSize =
    Autocomplete.withSmallSize


{-| Adds a `size` of `Large` to the `SelectWithFilter`.
-}
withLargeSize : SelectWithFilter model -> SelectWithFilter model
withLargeSize =
    Autocomplete.withLargeSize


{-| Adds a `placeholder` Html.Attribute to the `SelectWithFilter`.
-}
withPlaceholder : String -> SelectWithFilter model -> SelectWithFilter model
withPlaceholder =
    Autocomplete.withPlaceholder


{-| Adds a `class` to the `SelectWithFilter` which overrides all the previous.
-}
withOverridingClass : String -> SelectWithFilter model -> SelectWithFilter model
withOverridingClass =
    Autocomplete.withOverridingClass


{-| Renders the `SelectWithFilter`.
-}
render : model -> Autocomplete.State -> Autocomplete.Autocomplete model -> List (Html Msg)
render model autocompleteState autocompleteModel =
    Autocomplete.render model autocompleteState autocompleteModel
        |> List.map (Html.map (\msg -> SelectWithFilterMsg msg))


{-| Attaches the `onBlur` event to the `SelectWithFilter`.
-}
withOnBlur : Autocomplete.Msg -> SelectWithFilter model -> SelectWithFilter model
withOnBlur =
    Autocomplete.withOnBlur


{-| Attaches the `onFocus` event to the `SelectWithFilter`.
-}
withOnFocus : Autocomplete.Msg -> SelectWithFilter model -> SelectWithFilter model
withOnFocus =
    Autocomplete.withOnFocus


{-| Adds a `Validation` rule to the `SelectWithFilter`.
-}
withValidation : (model -> Maybe Validation.Type) -> SelectWithFilter model -> SelectWithFilter model
withValidation =
    Autocomplete.withValidation
