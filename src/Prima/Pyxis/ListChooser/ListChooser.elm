module Prima.Pyxis.ListChooser.ListChooser exposing
    ( Config, State, Msg, ChooserItem, ViewMode
    , config, init, update
    , createItem, viewMode, viewModeAll, viewModePartial
    , render
    )

{-| Creates a List of ChooserItems component.


# Configuration

@docs Config, State, Msg, ChooserItem, ViewMode


# Configuration Helpers

@docs config, init, update


# Helpers

@docs createItem, viewMode, viewModeAll, viewModePartial


# Render

@docs render

-}

import Html exposing (Html, a, div, li, text, ul)
import Html.Attributes exposing (attribute, class, classList)
import Html.Events exposing (onClick)


{-| Represents an internal Msg for the component.
-}
type Msg
    = Toggle Slug
    | ToggleViewMode


{-| Represents the configuration of the component.
-}
type Config
    = Config Configuration


type alias Configuration =
    { itemsPerView : Int
    , toggleViewAllLabel : String
    , toggleViewPartialLabel : String
    }


{-| Creates the configuration of the ListChooser.

    ...

    myConfig : ListChooser.Config
    myConfig =
        let
            itemsPerView =
                5

            viewAllLabel =
                "Show all"

            viewPartialLabel =
                "Show first " ++ (String.fromInt itemsPerView) ++ " elements"
        in
        ListChooser.config itemsPerView viewAllLabel viewPartialLabel

    ...

-}
config : Int -> String -> String -> Config
config itemsPerView toggleViewAllLabel toggleViewPartialLabel =
    Config (Configuration itemsPerView toggleViewAllLabel toggleViewPartialLabel)


{-| Defines the mode in which the list must be shown. It's possible to choose
between the full list of items (`viewModeAll`) or a limited set of items (viewModePartial).
In this case the number of items to be shown is expressed via `itemsPerView`.
-}
type ViewMode
    = All
    | Partial


{-| Retrieves the partial ViewMode constructor.
-}
viewModePartial : ViewMode
viewModePartial =
    Partial


{-| Retrieves the all ViewMode constructor.
-}
viewModeAll : ViewMode
viewModeAll =
    All


{-| Sets the new ViewMode by updating the State.
-}
viewMode : ViewMode -> State -> State
viewMode mode (State internalState) =
    State { internalState | mode = mode }


{-| Represents the component State.
-}
type State
    = State InternalState


type alias InternalState =
    { mode : ViewMode
    , items : List ChooserItem
    }


{-| Creates the first instance of a ListChooser.
-}
init : ViewMode -> List ChooserItem -> ( State, Cmd Msg )
init mode items =
    ( State (InternalState mode items), Cmd.none )


{-| Updates the State of the component. Used by the parent application to
dispatch messages to this component.
-}
update : Msg -> State -> ( State, Cmd Msg )
update msg (State internalState) =
    case msg of
        Toggle toggledSlug ->
            ( State { internalState | items = updateChooserItems toggledSlug internalState.items }
            , Cmd.none
            )

        ToggleViewMode ->
            ( State
                { internalState
                    | mode =
                        if internalState.mode == All then
                            Partial

                        else
                            All
                }
            , Cmd.none
            )


updateChooserItems : Slug -> List ChooserItem -> List ChooserItem
updateChooserItems slug list =
    List.map
        (\(ChooserItem conf) ->
            ChooserItem { conf | isSelected = slug == conf.slug }
        )
        list


{-| Represents a single item which can be selected via ListChooser's api.
-}
type ChooserItem
    = ChooserItem ChooserItemConfiguration


type alias ChooserItemConfiguration =
    { slug : Slug
    , content : String
    , isSelected : Bool
    }


{-| Creates a representation of a ChooserItem.

    ...

    myItem : ListChooser.ChooserItem
    myItem =
        let
            slug =
                "my_item_slug"

            content =
                "Lorem ipsum dolor sit amet."

            isSelected =
                False
        in
        ListChooser.createItem slug content isSelected

    ...

-}
createItem : Slug -> String -> Bool -> ChooserItem
createItem slug content isSelected =
    ChooserItem (ChooserItemConfiguration slug content isSelected)


type alias Slug =
    String


{-| Renders the component by receiving a State and a Config.
-}
render : State -> Config -> Html Msg
render (State ({ mode, items } as internalState)) (Config conf) =
    let
        itemList =
            case mode of
                All ->
                    items

                Partial ->
                    List.take conf.itemsPerView items
    in
    div
        [ class "m-list-chooser directionColumn"
        , attribute "data-max-items" <| String.fromInt conf.itemsPerView
        ]
        [ renderList itemList
        , btnGroup [ toggleViewMode mode conf ]
        ]


renderList : List ChooserItem -> Html Msg
renderList items =
    ul
        [ class "m-list-chooser__list noListStyle noMargin noPadding" ]
        (List.map renderItem items)


renderItem : ChooserItem -> Html Msg
renderItem (ChooserItem configuration) =
    li
        [ classList
            [ ( "m-list-chooser__item", True )
            , ( "is-selected", configuration.isSelected )
            ]
        , (onClick << Toggle) configuration.slug
        ]
        [ text configuration.content ]


btnGroup : List (Html Msg) -> Html Msg
btnGroup =
    div
        [ class "m-btnGroup" ]


toggleViewMode : ViewMode -> Configuration -> Html Msg
toggleViewMode mode conf =
    let
        label =
            case mode of
                All ->
                    conf.toggleViewPartialLabel

                Partial ->
                    conf.toggleViewAllLabel
    in
    a
        [ onClick ToggleViewMode
        , class "a-link fwHeavy fsSmall"
        ]
        [ text label ]
