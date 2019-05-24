module Prima.Pyxis.ListChooser.ListChooser exposing
    ( ChooserItem
    , Config
    , Msg
    , State
    , createItem
    , init
    , multipleSelectionConfig
    , render
    , singleSelectionConfig
    , update
    )

import Html exposing (Html, div, li, text, ul)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)


type Msg
    = Toggle Slug


type Config
    = Config Configuration


type alias Configuration =
    { mode : Mode
    , itemsPerView : Int
    }


singleSelectionConfig : Int -> Config
singleSelectionConfig itemsPerView =
    Config (Configuration SingleSelection itemsPerView)


multipleSelectionConfig : Int -> Config
multipleSelectionConfig itemsPerView =
    Config (Configuration MultipleSelection itemsPerView)


type Mode
    = SingleSelection
    | MultipleSelection


type State
    = State InternalState


type alias InternalState =
    { items : List ChooserItem
    }


init : List ChooserItem -> ( State, Cmd Msg )
init items =
    ( State (InternalState items), Cmd.none )


update : Msg -> State -> ( State, Cmd Msg, List ( String, Bool ) )
update msg (State internalState) =
    case msg of
        Toggle toggledSlug ->
            let
                updatedItems =
                    updateChooserItems toggledSlug internalState.items
            in
            ( State { internalState | items = updatedItems }
            , Cmd.none
            , List.map (\(ChooserItem { slug, isSelected }) -> ( slug, isSelected )) updatedItems
            )


updateChooserItems : Slug -> List ChooserItem -> List ChooserItem
updateChooserItems slug list =
    List.map
        (\(ChooserItem conf) ->
            if slug == conf.slug then
                ChooserItem { conf | isSelected = not conf.isSelected }

            else
                ChooserItem conf
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
render (State internalState) (Config config) =
    div
        [ class "m-list-chooser" ]
        [ renderList internalState.items
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
