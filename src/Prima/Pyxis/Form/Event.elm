module Prima.Pyxis.Form.Event exposing
    ( Event
    , onAutocompleteFilter
    , onAutocompleteFilterAttribute
    , onBlur
    , onBlurAttribute
    , onCheck
    , onCheckAttribute
    , onFocus
    , onFocusAttribute
    , onInput
    , onInputAttribute
    , onSelect
    , onSelectAttribute
    , onToggle
    , onToggleAttribute
    )

{-| Allows to control events of the `Form` package.

    # Configuration
    @docs Event, onInput, onSelect, onCheck, onAutocompleteFilter, onFocus, onBlur, onToggle

    # Helpers
    @docs onInputAttribute, onSelectAttribute, onCheckAttribute, onAutocompleteFilterAttribute, onFocusAttribute, onBlurAttribute, onToggleAttribute

-}

import Html exposing (Attribute, Html)
import Html.Events as Events


type alias Slug =
    String


type alias Value =
    String


{-| Represents an Event listener over a field.
-}
type Event msg
    = Input (Maybe Value -> msg)
    | Focus msg
    | Blur msg
    | Toggle msg
    | Select (Maybe Value -> msg)
    | Check (( Slug, Bool ) -> msg)
    | AutocompleteFilter (Maybe Value -> msg)


normalizeInput : String -> Maybe String
normalizeInput str =
    if String.isEmpty str then
        Nothing

    else
        Just str


{-| Creates an onFocus listener. Can be used by almost any field.
-}
onFocus : msg -> Event msg
onFocus =
    Focus


{-| Creates an onBlur listener. Can be used by almost any field.
-}
onBlur : msg -> Event msg
onBlur =
    Blur


{-| Creates an onInput and onKeyDown listener. Can be used to intercept keydown on text fields.
For instance is used under the hood by the text component to write into the field.
-}
onInput : (Maybe Value -> msg) -> Event msg
onInput =
    Input


{-| Creates an onChange listener. Can be used to intercept click on various items.
For instance is used under the hood by the autocomplete component to select an option.
-}
onSelect : (Maybe Value -> msg) -> Event msg
onSelect =
    Select


{-| Creates an onChange listener. Can be used to intercept checkbox option selection.
Works on checkbox component only.
-}
onCheck : (( Slug, Bool ) -> msg) -> Event msg
onCheck =
    Check


{-| Can be used to intercept select component opening and closing.
Works on select component only.
-}
onToggle : msg -> Event msg
onToggle =
    Toggle


{-| Creates an onInput, onKeyDown listener. Can be used to intercept autocomplete filtering.
Works on autocomplete component only.
-}
onAutocompleteFilter : (Maybe Value -> msg) -> Event msg
onAutocompleteFilter =
    AutocompleteFilter


{-| Returns an appendable version of the listener
-}
onInputAttribute : List (Event msg) -> List (Attribute msg)
onInputAttribute events =
    events
        |> List.filterMap
            (\e ->
                case e of
                    Input tagger ->
                        Just tagger

                    _ ->
                        Nothing
            )
        |> List.head
        |> Maybe.map (\tagger -> [ Events.onInput (tagger << normalizeInput) ])
        |> Maybe.withDefault []


{-| Returns an appendable version of the listener
-}
onFocusAttribute : List (Event msg) -> List (Attribute msg)
onFocusAttribute events =
    events
        |> List.filterMap
            (\e ->
                case e of
                    Focus tagger ->
                        Just tagger

                    _ ->
                        Nothing
            )
        |> List.head
        |> Maybe.map (\tagger -> [ Events.onFocus tagger ])
        |> Maybe.withDefault []


{-| Returns an appendable version of the listener
-}
onBlurAttribute : List (Event msg) -> List (Attribute msg)
onBlurAttribute events =
    events
        |> List.filterMap
            (\e ->
                case e of
                    Blur tagger ->
                        Just tagger

                    _ ->
                        Nothing
            )
        |> List.head
        |> Maybe.map (\tagger -> [ Events.onBlur tagger ])
        |> Maybe.withDefault []


{-| Returns an appendable version of the listener
-}
onSelectAttribute : Slug -> List (Event msg) -> List (Attribute msg)
onSelectAttribute slug events =
    events
        |> List.filterMap
            (\e ->
                case e of
                    Select tagger ->
                        Just tagger

                    _ ->
                        Nothing
            )
        |> List.head
        |> Maybe.map (\tagger -> [ (Events.onClick << tagger << normalizeInput) slug ])
        |> Maybe.withDefault []


{-| Returns an appendable version of the listener
-}
onCheckAttribute : Slug -> Bool -> List (Event msg) -> List (Attribute msg)
onCheckAttribute slug isChecked events =
    events
        |> List.filterMap
            (\e ->
                case e of
                    Check tagger ->
                        Just tagger

                    _ ->
                        Nothing
            )
        |> List.head
        |> Maybe.map (\tagger -> [ (Events.onClick << tagger) ( slug, isChecked ) ])
        |> Maybe.withDefault []


{-| Returns an appendable version of the listener
-}
onToggleAttribute : List (Event msg) -> List (Attribute msg)
onToggleAttribute events =
    events
        |> List.filterMap
            (\e ->
                case e of
                    Toggle tagger ->
                        Just tagger

                    _ ->
                        Nothing
            )
        |> List.head
        |> Maybe.map (\tagger -> [ Events.onClick tagger ])
        |> Maybe.withDefault []


{-| Returns an appendable version of the listener
-}
onAutocompleteFilterAttribute : List (Event msg) -> List (Attribute msg)
onAutocompleteFilterAttribute events =
    events
        |> List.filterMap
            (\e ->
                case e of
                    AutocompleteFilter tagger ->
                        Just tagger

                    _ ->
                        Nothing
            )
        |> List.head
        |> Maybe.map (\tagger -> [ Events.onInput (tagger << normalizeInput) ])
        |> Maybe.withDefault []
