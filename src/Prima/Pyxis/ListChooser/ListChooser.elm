module Prima.Pyxis.ListChooser.ListChooser exposing
    ( ChooserItem
    , Config
    , Msg
    , State
    , config
    , createItem
    , init
    , render
    , update
    , viewMode
    , viewModeAll
    , viewModePartial
    )

import Html exposing (Html, a, div, li, text, ul)
import Html.Attributes exposing (attribute, class, classList)
import Html.Events exposing (onClick)


type Msg
    = Toggle Slug
    | ToggleViewMode


type Config
    = Config Configuration


type alias Configuration =
    { itemsPerView : Int
    , toggleViewAllLabel : String
    , toggleViewPartialLabel : String
    }


config : Int -> String -> String -> Config
config itemsPerView toggleViewAllLabel toggleViewPartialLabel =
    Config (Configuration itemsPerView toggleViewAllLabel toggleViewPartialLabel)


type ViewMode
    = All
    | Partial


viewModePartial : ViewMode
viewModePartial =
    Partial


viewModeAll : ViewMode
viewModeAll =
    All


viewMode : ViewMode -> State -> State
viewMode mode (State internalState) =
    State { internalState | mode = mode }


type State
    = State InternalState


type alias InternalState =
    { mode : ViewMode
    , items : List ChooserItem
    }


init : ViewMode -> List ChooserItem -> ( State, Cmd Msg )
init mode items =
    ( State (InternalState mode items), Cmd.none )


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


type ChooserItem
    = ChooserItem ChooserItemConfiguration


type alias ChooserItemConfiguration =
    { slug : Slug
    , content : String
    , isSelected : Bool
    }


createItem : Slug -> String -> Bool -> ChooserItem
createItem slug content isSelected =
    ChooserItem (ChooserItemConfiguration slug content isSelected)


type alias Slug =
    String


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
