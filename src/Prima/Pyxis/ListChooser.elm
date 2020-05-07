module Prima.Pyxis.ListChooser exposing
    ( Config, State, Msg(..), ChooserItem, ViewMode(..)
    , config, init, update, createItem
    , render
    , withId, withAttribute, withItems, withItemClass, withMultipleSelection, withSelectedItemClass, withWrapperClass
    )

{-|


## Configuration

@docs Config, State, Msg, ChooserItem, ViewMode


## Configuration Methods

@docs config, init, update, createItem


## Rendering

@docs render


## Options

@docs withId, withAttribute, withItems, withItemClass, withMultipleSelection, withSelectedItemClass, withWrapperClass

-}

import Html exposing (Html, a, div, li, text, ul)
import Html.Attributes as Attrs exposing (attribute, class, classList)
import Html.Events exposing (onClick)
import Prima.Pyxis.Helpers as H


{-| Represents the messages dispatched by the ListChooser Component
-}
type Msg
    = ToggleViewMode
    | ChooseItem String


{-| Represent the configuration of the component.
-}
type Config
    = Config ListChooserConfig


type alias ListChooserConfig =
    { shownItems : Int
    , viewAllLabel : String
    , viewPartialLabel : String
    , options : List ListChooserOption
    }


{-| Internal. Represents the list of available customizations.
-}
type alias Options =
    { id : Maybe String
    , wrapperClasses : List String
    , itemClasses : List String
    , selectedItemClasses : List String
    , multipleSelection : Bool
    , attributes : List (Html.Attribute Msg)
    }


{-| Internal. Represents the possible modifiers of the component options.
-}
type ListChooserOption
    = Id String
    | WrapperClass String
    | ItemClass String
    | SelectedItemClass String
    | MultipleSelection Bool
    | Attribute (Html.Attribute Msg)


{-| Internal. Represents the initial state of the list of customizations for the component.
-}
defaultOptions : Options
defaultOptions =
    { id = Nothing
    , wrapperClasses = []
    , itemClasses = []
    , selectedItemClasses = []
    , multipleSelection = False
    , attributes = []
    }


{-| Internal. Applies the customizations made by the end user to the component.
-}
applyOption : ListChooserOption -> Options -> Options
applyOption modifier options =
    case modifier of
        Id id ->
            { options | id = Just id }

        WrapperClass class ->
            { options | wrapperClasses = class :: options.wrapperClasses }

        ItemClass class ->
            { options | itemClasses = class :: options.itemClasses }

        SelectedItemClass class ->
            { options | selectedItemClasses = class :: options.selectedItemClasses }

        MultipleSelection isMultiple ->
            { options | multipleSelection = isMultiple }

        Attribute attr ->
            { options | attributes = attr :: options.attributes }


{-| Internal. Applies all the customizations and returns the internal `Options` type.
-}
computeOptions : Config -> Options
computeOptions (Config listChooserConfig) =
    List.foldl applyOption defaultOptions listChooserConfig.options


{-| Internal. Adds a generic option to the `ListChooser`.
-}
addOption : ListChooserOption -> Config -> Config
addOption option (Config listChooserConfig) =
    Config { listChooserConfig | options = listChooserConfig.options ++ [ option ] }


{-| Create the configuration of the ListChooser.

    ...

    myConfig : ListChooser.Config
    myConfig =
        let
            shownItems =
                5

            viewAllLabel =
                "Show all"

            viewPartialLabel =
                "Show first " ++ (String.fromInt shownItems) ++ " elements"
        in
        ListChooser.config shownItems viewAllLabel viewPartialLabel

    ...

-}
config : Int -> String -> String -> Config
config shownItems viewAllLabel viewPartialLabel =
    Config (ListChooserConfig shownItems viewAllLabel viewPartialLabel [])


{-| Updates the state of the component when a Msg is received.
-}
update : Msg -> Config -> State -> State
update msg listChooserConfig listChooserState =
    case msg of
        ToggleViewMode ->
            toggleViewMode listChooserState

        ChooseItem slug ->
            selectActiveItem slug listChooserConfig listChooserState


{-| Defines the mode in which the list must be shown. It's possible to choose
between the full list of items (`viewModeAll`) or a limited set of items (viewModePartial).
In this case the number of items to be shown is expressed via `shownItems`.
-}
type ViewMode
    = All
    | Partial


{-| Internal. Sets the new ViewMode by updating the State.
-}
toggleViewMode : State -> State
toggleViewMode (State internalState) =
    State
        { internalState
            | mode =
                if internalState.mode == All then
                    Partial

                else
                    All
        }


{-| Internal. Selects the current active item(s) of the items in the list
-}
selectActiveItem : String -> Config -> State -> State
selectActiveItem slug listChooserConfig listChooserState =
    let
        options =
            computeOptions listChooserConfig
    in
    if options.multipleSelection then
        updateItems (updateSingleSelection slug) listChooserState

    else
        updateItems (updateMultipleSelection slug) listChooserState


{-| Internal. Update a list of `ChooserItems`
-}
updateItems : (ChooserItem -> ChooserItem) -> State -> State
updateItems mapper (State listChooserState) =
    State { listChooserState | items = List.map mapper listChooserState.items }


{-| Internal. Update the selected status of the item, in a ListChooser which supports only ONE selected item
-}
updateSingleSelection : String -> ChooserItem -> ChooserItem
updateSingleSelection slug (ChooserItem item) =
    ChooserItem
        { item
            | isSelected =
                if item.slug == slug then
                    not item.isSelected

                else
                    item.isSelected
        }


{-| Internal. Update the selected status of the item, in a ListChooser which supports multiple selected items
-}
updateMultipleSelection : String -> ChooserItem -> ChooserItem
updateMultipleSelection slug (ChooserItem item) =
    ChooserItem { item | isSelected = item.slug == slug }


{-| Represent the component State.
-}
type State
    = State InternalState


type alias InternalState =
    { mode : ViewMode
    , items : List ChooserItem
    }


{-| Represent a single item which can be selected via ListChooser's API.
-}
type ChooserItem
    = ChooserItem ChooserItemConfig


type alias ChooserItemConfig =
    { slug : String
    , content : String
    , isSelected : Bool
    }


{-| Adds a generic `Html.Attribute` to the `ListChooser`.
-}
withAttribute : Html.Attribute Msg -> Config -> Config
withAttribute attr =
    addOption (Attribute attr)


{-| Adds an `id` Html.Attribute to the `ListChooser`.
-}
withMultipleSelection : Bool -> Config -> Config
withMultipleSelection multiple =
    addOption (MultipleSelection multiple)


{-| Adds an `id` Html.Attribute to the `ListChooser`.
-}
withId : String -> Config -> Config
withId id =
    addOption (Id id)


{-| Adds a class for the wrapper to the `Config`.
-}
withWrapperClass : String -> Config -> Config
withWrapperClass class_ =
    addOption (WrapperClass class_)


{-| Adds a class for every item into the `Config`.
-}
withItemClass : String -> Config -> Config
withItemClass class_ =
    addOption (ItemClass class_)


{-| Adds a class for the selected items to the `Config`.
-}
withSelectedItemClass : String -> Config -> Config
withSelectedItemClass class_ =
    addOption (SelectedItemClass class_)


{-| Creates the State record of a ListChooser.
-}
init : ViewMode -> State
init mode =
    State (InternalState mode [])


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
        ListChooser.createItem (slug, content, isSelected)

    ...

-}
createItem : String -> String -> Bool -> ChooserItem
createItem slug content isSelected =
    ChooserItem { slug = slug, content = content, isSelected = isSelected }


{-| Adds items to the ListChooser instance State record.
-}
withItems : List ChooserItem -> State -> State
withItems items (State currentState) =
    State { currentState | items = items }


{-| Renders the component by receiving a State and a Config.
-}
render : State -> Config -> Html Msg
render (State { mode, items }) ((Config { shownItems }) as listChooserConfig) =
    let
        itemList =
            case mode of
                All ->
                    items

                Partial ->
                    List.take shownItems items
    in
    div
        (buildWrapperAttributes listChooserConfig)
        [ renderList itemList listChooserConfig
        , H.btnGroup [ viewModeToggler mode listChooserConfig ]
        ]


{-| Internal. Renders the list of items of the `ListChooser`
-}
renderList : List ChooserItem -> Config -> Html Msg
renderList items listChooserConfig =
    ul
        [ class "list-chooser__list" ]
        (List.map (renderItem listChooserConfig) items)


{-| Internal. Renders a single item of the `ListChooser`
-}
renderItem : Config -> ChooserItem -> Html Msg
renderItem listChooserConfig ((ChooserItem { slug, content }) as item) =
    li
        [ buildItemClassList item listChooserConfig
        , onClick (ChooseItem slug)
        ]
        [ text content ]


{-| Internal. Renders the button to toggle the `ListChooser` view mode.
-}
viewModeToggler : ViewMode -> Config -> Html Msg
viewModeToggler mode (Config { viewPartialLabel, viewAllLabel }) =
    let
        label =
            case mode of
                All ->
                    viewPartialLabel

                Partial ->
                    viewAllLabel
    in
    a
        [ onClick ToggleViewMode
        , class "link fw-heavy fs-small"
        ]
        [ text label ]


{-| Internal. Builds the `classList` of the ListChooser items based on the configuration.
-}
buildItemClassList : ChooserItem -> Config -> Html.Attribute msg
buildItemClassList (ChooserItem { isSelected }) listChooserConfig =
    let
        options =
            computeOptions listChooserConfig
    in
    [ ( "list-chooser__item", True )
    , ( "is-selected", isSelected )
    ]
        |> List.append (List.map (H.flip Tuple.pair True) options.itemClasses)
        |> List.append (List.map (H.flip Tuple.pair isSelected) options.selectedItemClasses)
        |> classList


{-| Internal. Transforms all the customizations into a list of valid Html.Attribute(s).
-}
buildWrapperAttributes : Config -> List (Html.Attribute Msg)
buildWrapperAttributes ((Config { shownItems }) as listChooserConfig) =
    let
        options =
            computeOptions listChooserConfig
    in
    [ options.id
        |> Maybe.map Attrs.id
    ]
        |> List.filterMap identity
        |> List.append [ attribute "data-max-items" <| String.fromInt shownItems ]
        |> (::) (buildClass options.wrapperClasses [ "list-chooser" ])
        |> List.append options.attributes


{-| Internal. Transforms the customized wrapperClasses into an Html.Attribute
-}
buildClass : List String -> List String -> Html.Attribute Msg
buildClass classes currentClasses =
    currentClasses
        |> List.append classes
        |> String.join " "
        |> Attrs.class
