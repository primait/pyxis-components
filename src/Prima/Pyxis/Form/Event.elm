module Prima.Pyxis.Form.Event exposing
    ( Event
    , normalizeInput
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

import Html exposing (Attribute, Html)
import Html.Events as Events


type alias Slug =
    String


type alias Value =
    String


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


onFocus : msg -> Event msg
onFocus =
    Focus


onBlur : msg -> Event msg
onBlur =
    Blur


onInput : (Maybe Value -> msg) -> Event msg
onInput =
    Input


onSelect : (Maybe Value -> msg) -> Event msg
onSelect =
    Select


onCheck : (( Slug, Bool ) -> msg) -> Event msg
onCheck =
    Check


onToggle : msg -> Event msg
onToggle =
    Toggle


onAutocompleteFilter : (Maybe Value -> msg) -> Event msg
onAutocompleteFilter =
    AutocompleteFilter


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
