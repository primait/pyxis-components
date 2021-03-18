module Prima.Pyxis.Form.FilterableSelect exposing
    ( FilterableSelect, State, Msg(..)
    , filterableSelect, init, initWithDefault, update, filterableSelectChoice
    , render
    , selectedValue, filterValue, subscription, open, close, isOpen, toggle, reset
    , withAttribute, withClass, withDefaultValue, withDisabled, withId, withName, withMediumSize, withSmallSize, withLargeSize, withPlaceholder, withOverridingClass, withThreshold, withIsSubmitted
    , withOnBlur, withOnFocus
    , withValidation
    )

{-|


## Configuration

@docs FilterableSelect, State, Msg


## Configuration Methods

@docs filterableSelect, init, initWithDefault, update, filterableSelectChoice


## Rendering

@docs render


## Methods

@docs selectedValue, filterValue, subscription, open, close, isOpen, toggle, reset


## Options

@docs withAttribute, withClass, withDefaultValue, withDisabled, withId, withName, withMediumSize, withSmallSize, withLargeSize, withPlaceholder, withOverridingClass, withThreshold, withIsSubmitted


## Event Options

@docs withOnBlur, withOnFocus


## Validation

@docs withValidation

-}

import Html exposing (Html)
import Prima.Pyxis.Form.Autocomplete as Autocomplete
import Prima.Pyxis.Form.Validation as Validation


{-| Represents the Msg of the `FilterableSelect`.
-}
type Msg
    = FilterableSelectMsg Autocomplete.Msg


{-| Represent the opaque `FilterableSelect` configuration.
-}
type alias FilterableSelect model =
    Autocomplete.Autocomplete model


{-| The `State` of the `FilterableSelect`
-}
type alias State =
    { autocompleteState : Autocomplete.State
    , choices : List FilterableSelectChoice
    }


{-| Represent the `FilterableSelectChoice` configuration.
-}
type alias FilterableSelectChoice =
    Autocomplete.AutocompleteChoice


{-| Creates an select with a filter input.
-}
filterableSelect : FilterableSelect model
filterableSelect =
    Autocomplete.autocomplete


{-| Initializes the `FilterableSelect`'s `State`.
-}
init : List FilterableSelectChoice -> State
init choices =
    { choices = choices
    , autocompleteState = Autocomplete.init
    }


{-| Initializes the `Autocomplete`'s `State` with a default selected value.
-}
initWithDefault : String -> String -> List FilterableSelectChoice -> State
initWithDefault defaultSelectedLabel defaultSelectedValue choices =
    { choices = choices
    , autocompleteState = Autocomplete.initWithDefault defaultSelectedLabel defaultSelectedValue
    }


{-| Updates the `FilterableSelect`'s `State`.
-}
update : Msg -> State -> State
update msg state =
    case msg of
        FilterableSelectMsg autocompleteMsg ->
            let
                ( autocompleteState, _, _ ) =
                    Autocomplete.update autocompleteMsg state.autocompleteState
            in
            state
                |> updateAutocompleteState autocompleteState
                |> updateChoices


{-| Show the available options for the filterable select.
-}
open : State -> State
open ({ autocompleteState } as state) =
    { state | autocompleteState = Autocomplete.open autocompleteState }


{-| Hide the available options for the filterable select.
-}
close : State -> State
close ({ autocompleteState } as state) =
    { state | autocompleteState = Autocomplete.close autocompleteState }


{-| Toggle the menu openness.
-}
toggle : State -> State
toggle state =
    { state | autocompleteState = Autocomplete.toggle state.autocompleteState }


{-| Reset selected value.
-}
reset : State -> State
reset state =
    { state | autocompleteState = Autocomplete.reset state.autocompleteState }


{-| Returns whether the menu is open or not.
-}
isOpen : State -> Bool
isOpen { autocompleteState } =
    Autocomplete.isOpen autocompleteState


{-| Internal. Check if the choice contains the string.
-}
choiceContainsFilter : Maybe String -> FilterableSelectChoice -> Bool
choiceContainsFilter maybeFilter { value, label } =
    maybeFilter
        |> Maybe.map (\filter -> String.contains (String.toLower filter) (String.toLower label) || String.contains filter value)
        |> Maybe.withDefault True


{-| Internal. Filter the choices using the filter string
-}
filterChoices : State -> List FilterableSelectChoice
filterChoices { choices, autocompleteState } =
    choices
        |> List.filter (choiceContainsFilter (filterValue autocompleteState))


{-| Update the `FilterableSelectChoice` inside `Autocomplete`'s state
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


{-| Create the FilterableSelectChoice configuration.
-}
filterableSelectChoice : String -> String -> FilterableSelectChoice
filterableSelectChoice =
    Autocomplete.autocompleteChoice


{-| Returns the current `FilterableSelectChoice.value` selected by the user.
-}
selectedValue : State -> Maybe String
selectedValue { autocompleteState } =
    Autocomplete.selectedValue autocompleteState


{-| Returns the current filter inserted by the user.
-}
filterValue : Autocomplete.State -> Maybe String
filterValue =
    Autocomplete.filterValue


{-| Needed to wire keyboard events to the `FilterableSelect`.
-}
subscription : Autocomplete.State -> Sub Autocomplete.Msg
subscription =
    Autocomplete.subscription


{-| Adds a generic Html.Attribute to the `FilterableSelect`.
-}
withAttribute : Html.Attribute Autocomplete.Msg -> Autocomplete.Autocomplete model -> FilterableSelect model
withAttribute =
    Autocomplete.withAttribute


{-| Adds a `class` to the `FilterableSelect`.
-}
withClass : String -> FilterableSelect model -> FilterableSelect model
withClass =
    Autocomplete.withClass


{-| Adds a default value to the `Input`.
Useful to teach the component about it's `pristine/touched` state.
-}
withDefaultValue : Maybe String -> FilterableSelect model -> FilterableSelect model
withDefaultValue =
    Autocomplete.withDefaultValue


{-| Adds a `disabled` Html.Attribute to the `FilterableSelect`.
-}
withDisabled : Bool -> FilterableSelect model -> FilterableSelect model
withDisabled =
    Autocomplete.withDisabled


{-| Adds an `id` Html.Attribute to the `FilterableSelect`.
-}
withId : String -> FilterableSelect model -> FilterableSelect model
withId =
    Autocomplete.withId


{-| Adds an `isSubmitted` predicate to the `Autocomplete`.
-}
withIsSubmitted : (model -> Bool) -> FilterableSelect model -> FilterableSelect model
withIsSubmitted =
    Autocomplete.withIsSubmitted


{-| Adds a `name` Html.Attribute to the `FilterableSelect`.
-}
withName : String -> FilterableSelect model -> FilterableSelect model
withName =
    Autocomplete.withName


{-| Adds a `size` of `Medium` to the `FilterableSelect`.
-}
withMediumSize : FilterableSelect model -> FilterableSelect model
withMediumSize =
    Autocomplete.withMediumSize


{-| Adds a `size` of `Small` to the `FilterableSelect`.
-}
withSmallSize : FilterableSelect model -> FilterableSelect model
withSmallSize =
    Autocomplete.withSmallSize


{-| Adds a `size` of `Large` to the `FilterableSelect`.
-}
withLargeSize : FilterableSelect model -> FilterableSelect model
withLargeSize =
    Autocomplete.withLargeSize


{-| Adds a `placeholder` Html.Attribute to the `FilterableSelect`.
-}
withPlaceholder : String -> FilterableSelect model -> FilterableSelect model
withPlaceholder =
    Autocomplete.withPlaceholder


{-| Adds a `class` to the `FilterableSelect` which overrides all the previous.
-}
withOverridingClass : String -> FilterableSelect model -> FilterableSelect model
withOverridingClass =
    Autocomplete.withOverridingClass


{-| Renders the `FilterableSelect`.
-}
render : model -> Autocomplete.State -> Autocomplete.Autocomplete model -> List (Html Msg)
render model autocompleteState autocompleteModel =
    Autocomplete.render model autocompleteState autocompleteModel
        |> List.map (Html.map (\msg -> FilterableSelectMsg msg))


{-| Attaches the `onBlur` event to the `FilterableSelect`.
-}
withOnBlur : Autocomplete.Msg -> FilterableSelect model -> FilterableSelect model
withOnBlur =
    Autocomplete.withOnBlur


{-| Attaches the `onFocus` event to the `FilterableSelect`.
-}
withOnFocus : Autocomplete.Msg -> FilterableSelect model -> FilterableSelect model
withOnFocus =
    Autocomplete.withOnFocus


{-| Adds a `Validation` rule to the `FilterableSelect`.
-}
withValidation : (model -> Maybe Validation.Type) -> FilterableSelect model -> FilterableSelect model
withValidation =
    Autocomplete.withValidation


{-| Changes the threshold value
-}
withThreshold : Int -> State -> State
withThreshold threshold ({ autocompleteState } as state) =
    { state | autocompleteState = Autocomplete.withThreshold threshold autocompleteState }
