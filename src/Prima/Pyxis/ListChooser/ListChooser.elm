module Prima.Pyxis.ListChooser.ListChooser exposing
    ( ChooserItem
    , Config
    , State
    , createItem
    , multipleSelectionConfig
    , render
    , singleSelectionConfig
    , state
    )

import Html exposing (Html, div, li, text, ul)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)


type Config
    = Config Configuration


singleSelectionConfig : Int -> Config
singleSelectionConfig itemsPerView =
    Config (Configuration SingleSelection itemsPerView)


multipleSelectionConfig : Int -> Config
multipleSelectionConfig itemsPerView =
    Config (Configuration MultipleSelection itemsPerView)


type alias Configuration =
    { mode : Mode
    , itemsPerView : Int
    }


type Mode
    = SingleSelection
    | MultipleSelection


type State
    = State InternalState


state : List ChooserItem -> State
state items =
    State (InternalState items)


type alias InternalState =
    { items : List ChooserItem
    }


type ChooserItem
    = ChooserItem String


createItem : Slug -> ChooserItem
createItem slug =
    ChooserItem slug


type alias Slug =
    String


render : State -> Config -> Html msg
render (State internalState) (Config config) =
    div
        [ class "m-list-chooser" ]
        [ renderList internalState.items
        ]


renderList : List ChooserItem -> Html msg
renderList items =
    ul [ class "m-list-chooser__list noListStyle noMargin noPadding" ] (List.map renderItem items)


renderItem : ChooserItem -> Html msg
renderItem (ChooserItem content) =
    li [ class "m-list-chooser__item" ] [ text content ]
