module Prima.Pyxis.Form.Select exposing
    ( Select, State, Msg(..), SelectChoice
    , select, init, initWithDefault, update, selectChoice
    , selectedValue, subscription, open, close, isOpen, toggle, reset
    , render
    , withAttribute, withId, withDefaultValue, withDisabled, withClass, withLargeSize, withMediumSize, withOverridingClass, withPlaceholder, withSmallSize, withIsSubmitted
    , withOnBlur, withOnFocus, withEventPropagation
    , withValidation
    )

{-|


## Configuration

@docs Select, State, Msg, SelectChoice


## Configuration Methods

@docs select, init, initWithDefault, update, selectChoice


## Methods

@docs selectedValue, subscription, open, close, isOpen, toggle, reset


## Rendering

@docs render


## Options

@docs withAttribute, withId, withDefaultValue, withDisabled, withClass, withLargeSize, withMediumSize, withOverridingClass, withPlaceholder, withSmallSize, withIsSubmitted


## Event Options

@docs withOnBlur, withOnFocus, withEventPropagation


## Validation

@docs withValidation

-}

import Array
import Browser.Events
import Html exposing (Attribute, Html, text)
import Html.Attributes as Attrs exposing (class, value)
import Html.Events as HtmlEvents
import Json.Decode
import Maybe.Extra as ME
import Prima.Pyxis.Commons.InterceptedEvents as InterceptedEvents
import Prima.Pyxis.Commons.Interceptor as Interceptor
import Prima.Pyxis.Form.Commons.KeyboardEvents as KeyboardEvents
import Prima.Pyxis.Form.Validation as Validation
import Prima.Pyxis.Helpers as H


{-| Represents the Msg of the `Select`.
-}
type Msg
    = OnClick String
    | OnToggleMenu
    | OnKeyPress (Maybe KeyboardEvents.KeyCode)


{-| The `State` of the `Select`
-}
type State
    = State StateConfig


{-| Internal.
The configuration of the `Select`'s `State`.
-}
type alias StateConfig =
    { focused : Maybe String
    , selected : Maybe String
    , isMenuOpen : Bool
    , choices : List SelectChoice
    }


{-| Initializes the `Select`'s `State`.
-}
init : List SelectChoice -> State
init choices =
    State <| StateConfig Nothing Nothing False choices


{-| Initializes the `Select`'s `State` with a default value.
-}
initWithDefault : String -> List SelectChoice -> State
initWithDefault defaultSelectedValue choices =
    State <| StateConfig (Just defaultSelectedValue) (Just defaultSelectedValue) False choices


{-| Updates the `Select`'s `State`.
-}
update : Msg -> State -> State
update msg ((State state) as stateModel) =
    case msg of
        OnClick value ->
            updateOnSelect (Just value) stateModel

        OnToggleMenu ->
            updateOnToggleMenu stateModel

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
updateOnSelect : Maybe String -> State -> State
updateOnSelect value (State state) =
    State { state | selected = value, isMenuOpen = False }


{-| Internal.
-}
updateOnToggleMenu : State -> State
updateOnToggleMenu (State state) =
    State { state | isMenuOpen = not state.isMenuOpen }


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
            KeyboardEvents.wentTooLow focusedItemIndex state.choices

        index =
            if thereIsNoFocusedItem || wentTooLow then
                0

            else
                focusedItemIndex + 1
    in
    State
        { state
            | focused =
                stateModel
                    |> pickChoiceByIndex index
                    |> Maybe.map .value
        }


{-| Show the available options for the select.
-}
open : State -> State
open (State state) =
    State { state | isMenuOpen = True }


{-| Hide the available options for the select.
-}
close : State -> State
close (State state) =
    State { state | isMenuOpen = False }


{-| Toggle the menu openness.
-}
toggle : State -> State
toggle (State state) =
    State { state | isMenuOpen = not state.isMenuOpen }


{-| Reset selected value.
-}
reset : State -> State
reset (State state) =
    State { state | focused = Nothing, selected = Nothing }
        |> close


{-| Returns whether the menu is open or not.
-}
isOpen : State -> Bool
isOpen (State state) =
    state.isMenuOpen


{-| Returns the current `SelectChoice.value` selected by the user.
-}
selectedValue : State -> Maybe String
selectedValue (State stateConfig) =
    stateConfig.selected


{-| Represent the opaque `Select` configuration.
-}
type Select model
    = Select (SelectConfig model)


{-| Internal. Represent the `Select` configuration.
-}
type alias SelectConfig model =
    List (SelectOption model)


{-| Creates the `Select`.
-}
select : Select model
select =
    Select []


{-| Represents an option for the `Select`.
-}
type alias SelectChoice =
    { value : String
    , label : String
    }


{-| Creates an option for the `Select`.
-}
selectChoice : String -> String -> SelectChoice
selectChoice value label =
    SelectChoice value label


{-| Internal.
-}
type SelectOption model
    = Attribute (Html.Attribute Msg)
    | Class String
    | DefaultValue (Maybe String)
    | Disabled Bool
    | Id String
    | IsSubmitted (model -> Bool)
    | OnFocus Msg
    | OnBlur Msg
    | OverridingClass String
    | Placeholder String
    | Size SelectSize
    | Validation (model -> Maybe Validation.Type)
    | PropagateEvents Bool


type Default
    = Indeterminate
    | Value (Maybe String)


{-| Represent the `Select` size.
-}
type SelectSize
    = Small
    | Medium
    | Large


{-| Internal.
-}
type alias Options model =
    { attributes : List (Html.Attribute Msg)
    , class : List String
    , defaultValue : Default
    , disabled : Maybe Bool
    , id : Maybe String
    , isSubmitted : model -> Bool
    , onFocus : Maybe Msg
    , onBlur : Maybe Msg
    , placeholder : String
    , size : SelectSize
    , validations : List (model -> Maybe Validation.Type)
    , eventsArePropagated : Bool
    }


defaultOptions : Options model
defaultOptions =
    { attributes = []
    , class = [ "form-select form-select--native" ]
    , defaultValue = Indeterminate
    , disabled = Nothing
    , id = Nothing
    , isSubmitted = always True
    , onFocus = Nothing
    , onBlur = Nothing
    , placeholder = "Seleziona"
    , size = Medium
    , validations = []
    , eventsArePropagated = True
    }


{-| Internal.
-}
addOption : SelectOption model -> Select model -> Select model
addOption option (Select options) =
    options
        ++ [ option ]
        |> Select


{-| Sets an `attribute` to the `Select`.
-}
withAttribute : Html.Attribute Msg -> Select model -> Select model
withAttribute attribute =
    addOption (Attribute attribute)


{-| Adds a default value to the `Select`.
Useful to teach the component about it's `pristine/touched` state.
-}
withDefaultValue : Maybe String -> Select model -> Select model
withDefaultValue value =
    addOption (DefaultValue value)


{-| Sets a `disabled` to the `Select`.
-}
withDisabled : Bool -> Select model -> Select model
withDisabled disabled =
    addOption (Disabled disabled)


{-| Adds a `class` to the `Select`.
-}
withClass : String -> Select model -> Select model
withClass className =
    addOption (Class className)


{-| Sets a `placeholder` to the `Select`.
-}
withPlaceholder : String -> Select model -> Select model
withPlaceholder placeholder =
    addOption (Placeholder placeholder)


{-| Sets an `id` to the `Select`.
-}
withId : String -> Select model -> Select model
withId id =
    addOption (Id id)


{-| Adds an `isSubmitted` predicate to the `Input`.
-}
withIsSubmitted : (model -> Bool) -> Select model -> Select model
withIsSubmitted isSubmitted =
    addOption (IsSubmitted isSubmitted)


{-| Sets a `Size` to the `Select`.
-}
withLargeSize : Select model -> Select model
withLargeSize =
    addOption (Size Large)


{-| Sets an `onBlur event` to the `Select`.
-}
withOnBlur : Msg -> Select model -> Select model
withOnBlur tagger =
    addOption (OnBlur tagger)


{-| Sets an `onFocus event` to the `Select`.
-}
withOnFocus : Msg -> Select model -> Select model
withOnFocus tagger =
    addOption (OnFocus tagger)


{-| Overrides the default classes of the `Select`.
-}
withOverridingClass : String -> Select model -> Select model
withOverridingClass class =
    addOption (OverridingClass class)


{-| With this on False events are blocked at parent level (native or custom select).
By default is on True (events are propagated)

This doesn't affect OnInput event on form field since it's not propagated by default

-}
withEventPropagation : Bool -> Select model -> Select model
withEventPropagation arePropagated =
    addOption (PropagateEvents arePropagated)


{-| Sets a `Size` to the `Select`.
-}
withMediumSize : Select model -> Select model
withMediumSize =
    addOption (Size Medium)


{-| Sets a `Size` to the `Select`.
-}
withSmallSize : Select model -> Select model
withSmallSize =
    addOption (Size Small)


{-| Adds a validation rule to the `Select`.
-}
withValidation : (model -> Maybe Validation.Type) -> Select model -> Select model
withValidation validation =
    addOption (Validation validation)


{-| Internal.
-}
applyOption : SelectOption model -> Options model -> Options model
applyOption modifier options =
    case modifier of
        Attribute attribute ->
            { options | attributes = attribute :: options.attributes }

        Class class ->
            { options | class = class :: options.class }

        DefaultValue value ->
            { options | defaultValue = Value value }

        Disabled disabled ->
            { options | disabled = Just disabled }

        Id id ->
            { options | id = Just id }

        IsSubmitted predicate ->
            { options | isSubmitted = predicate }

        OnFocus onFocus ->
            { options | onFocus = Just onFocus }

        OnBlur onBlur ->
            { options | onBlur = Just onBlur }

        OverridingClass class ->
            { options | class = [ class ] }

        Placeholder placeholder ->
            { options | placeholder = placeholder }

        Size size ->
            { options | size = size }

        Validation validation ->
            { options | validations = validation :: options.validations }

        PropagateEvents arePropagated ->
            { options | eventsArePropagated = arePropagated }


{-| Transforms an `SelectSize` into a valid `Html.Attribute`.
-}
sizeAttribute : SelectSize -> Html.Attribute Msg
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


validationAttribute : model -> Select model -> Html.Attribute Msg
validationAttribute model selectModel =
    let
        warnings =
            warningValidations model (computeOptions selectModel)

        errors =
            errorsValidations model (computeOptions selectModel)
    in
    case ( errors, warnings ) of
        ( [], [] ) ->
            Attrs.class "is-valid"

        ( [], _ ) ->
            Attrs.class "has-warning"

        ( _, _ ) ->
            Attrs.class "has-error"


isPristine : State -> Select model -> Bool
isPristine (State stateConfig) selectModel =
    let
        options =
            computeOptions selectModel
    in
    case ( Value stateConfig.selected == options.defaultValue, stateConfig.selected ) of
        ( True, _ ) ->
            True

        ( False, Nothing ) ->
            True

        ( False, Just _ ) ->
            False


{-| Internal. Applies the `pristine/touched` visual state to the component.
-}
pristineAttribute : State -> Select model -> Html.Attribute Msg
pristineAttribute state selectModel =
    if isPristine state selectModel then
        Attrs.class "is-pristine"

    else
        Attrs.class "is-touched"


{-| Internal. Determines whether the field should be validated or not.
-}
shouldBeValidated : model -> Select model -> State -> Options model -> Bool
shouldBeValidated model selectModel stateModel options =
    (not <| isPristine stateModel selectModel) || options.isSubmitted model


{-| Composes all the modifiers into a set of `Html.Attribute`(s).
-}
buildNativeSelectAttributes : model -> State -> Select model -> List (Html.Attribute Msg)
buildNativeSelectAttributes model stateModel selectModel =
    let
        options =
            computeOptions selectModel

        hasValidations : Bool
        hasValidations =
            shouldBeValidated model selectModel stateModel options
    in
    [ options.id
        |> Maybe.map (\id -> id ++ "-native-select" |> Attrs.id)
    , options.disabled
        |> Maybe.map Attrs.disabled
    , options.onFocus
        |> Maybe.map HtmlEvents.onFocus
    , options.onBlur
        |> Maybe.map HtmlEvents.onBlur
    ]
        |> List.filterMap identity
        |> (++) options.attributes
        |> (::) (H.classesAttribute options.class)
        |> (::) (sizeAttribute options.size)
        |> (::) inputEvent
        |> H.addIf hasValidations (validationAttribute model selectModel)
        |> (::) (pristineAttribute stateModel selectModel)


{-| Renders the `Radio config`.
-}
render : model -> State -> Select model -> List (Html Msg)
render model stateModel selectModel =
    let
        options =
            computeOptions selectModel

        hasValidations : Bool
        hasValidations =
            shouldBeValidated model selectModel stateModel options
    in
    [ renderNativeSelect model stateModel selectModel
    , renderCustomSelect model stateModel selectModel
    ]
        ++ renderValidationMessages model selectModel hasValidations


renderNativeSelect : model -> State -> Select model -> Html Msg
renderNativeSelect model ((State { choices }) as stateModel) selectModel =
    let
        options =
            computeOptions selectModel
    in
    Html.select
        (buildNativeSelectAttributes model stateModel selectModel)
        (options.placeholder
            |> SelectChoice ""
            |> H.flip (::) choices
            |> List.map (renderSelectChoice stateModel)
        )


renderSelectChoice : State -> SelectChoice -> Html Msg
renderSelectChoice (State { selected }) choice =
    Html.option
        [ Attrs.value choice.value
        , Attrs.selected (selected == Just choice.value)
        ]
        [ Html.text choice.label ]


renderCustomSelect : model -> State -> Select model -> Html Msg
renderCustomSelect model ((State { choices, isMenuOpen }) as stateModel) selectModel =
    let
        options =
            computeOptions selectModel

        hasValidations : Bool
        hasValidations =
            shouldBeValidated model selectModel stateModel options
    in
    Html.div
        (H.addIf hasValidations
            (validationAttribute model selectModel)
            [ Attrs.classList
                [ ( "form-select", True )
                , ( "is-open", isMenuOpen )
                , ( "is-disabled", Maybe.withDefault False options.disabled )
                ]
            , sizeAttribute options.size
            ]
            ++ ([ options.id
                    |> Maybe.map (\id -> id ++ "-custom-select" |> Attrs.id)
                , options.disabled
                    |> Maybe.map Attrs.disabled
                , options.onFocus
                    |> Maybe.map HtmlEvents.onFocus
                , options.onBlur
                    |> Maybe.map HtmlEvents.onBlur
                ]
                    |> List.filterMap identity
                    |> (++) options.attributes
               )
        )
        [ renderCustomSelectStatus stateModel selectModel
        , renderCustomSelectIcon
        , choices
            |> List.map (renderCustomSelectChoice options stateModel)
            |> renderCustomSelectChoiceWrapper
        ]


renderCustomSelectStatus : State -> Select model -> Html Msg
renderCustomSelectStatus (State { choices, selected }) selectModel =
    let
        options =
            computeOptions selectModel
    in
    Html.span
        [ Attrs.class "form-select__status"
        , clickEvent options OnToggleMenu
        ]
        [ choices
            |> List.filter ((==) selected << Just << .value)
            |> List.map .label
            |> List.head
            |> Maybe.withDefault options.placeholder
            |> Html.text
        ]


renderCustomSelectIcon : Html Msg
renderCustomSelectIcon =
    Html.i
        [ Attrs.class "form-select__status-icon" ]
        []


renderCustomSelectChoiceWrapper : List (Html Msg) -> Html Msg
renderCustomSelectChoiceWrapper =
    Html.ul
        [ class "form-select__list" ]


renderCustomSelectChoice : Options model -> State -> SelectChoice -> Html Msg
renderCustomSelectChoice options stateModel choice =
    Html.li
        [ Attrs.classList
            [ ( "form-select__list__item", True )
            , ( "is-selected", isChoiceSelected stateModel choice || isChoiceFocused stateModel choice )
            ]
        , clickEvent options (OnClick choice.value)
        ]
        [ text choice.label
        ]


renderValidationMessages : model -> Select model -> Bool -> List (Html Msg)
renderValidationMessages model selectModel showValidation =
    let
        warnings =
            warningValidations model (computeOptions selectModel)

        errors =
            errorsValidations model (computeOptions selectModel)
    in
    case ( showValidation, errors, warnings ) of
        ( True, [], _ ) ->
            List.map Validation.render warnings

        ( True, _, _ ) ->
            List.map Validation.render errors

        ( False, _, _ ) ->
            []


{-| Internal
-}
computeOptions : Select model -> Options model
computeOptions (Select options) =
    List.foldl applyOption defaultOptions options


warningValidations : model -> Options model -> List Validation.Type
warningValidations model options =
    options.validations
        |> List.filterMap (H.flip identity model)
        |> List.filter Validation.isWarning


errorsValidations : model -> Options model -> List Validation.Type
errorsValidations model options =
    options.validations
        |> List.filterMap (H.flip identity model)
        |> List.filter Validation.isError


isChoiceSelected : State -> SelectChoice -> Bool
isChoiceSelected (State stateConfig) choice =
    Just choice.value == stateConfig.selected


isChoiceFocused : State -> SelectChoice -> Bool
isChoiceFocused (State stateConfig) choice =
    Just choice.value == stateConfig.focused


{-| Internal. Returns the focusedItem index or zero.
-}
pickFocusedItemIndex : State -> Int
pickFocusedItemIndex (State { focused, choices }) =
    choices
        |> List.indexedMap Tuple.pair
        |> List.filter ((==) focused << Just << .value << Tuple.second)
        |> List.head
        |> ME.unwrap 0 Tuple.first


{-| Internal. Returns the `SelectChoice` found by index.
-}
pickChoiceByIndex : Int -> State -> Maybe SelectChoice
pickChoiceByIndex index (State { choices }) =
    choices
        |> Array.fromList
        |> Array.get index


{-| Needed to wire keyboard events to the `Select`.
-}
subscription : State -> Sub Msg
subscription state =
    if isOpen state then
        HtmlEvents.keyCode
            |> Json.Decode.map (OnKeyPress << KeyboardEvents.toKeyCode)
            |> Browser.Events.onKeyDown

    else
        Sub.none


clickEvent : Options model -> Msg -> Html.Attribute Msg
clickEvent options msg =
    if options.eventsArePropagated then
        HtmlEvents.onClick msg

    else
        InterceptedEvents.onClick (Interceptor.targetContainsClass "form-select") msg
            |> InterceptedEvents.withStopPropagation
            |> InterceptedEvents.toHtmlAttribute


inputEvent : Html.Attribute Msg
inputEvent =
    HtmlEvents.onInput OnClick
