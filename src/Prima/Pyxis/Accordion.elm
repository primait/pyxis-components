module Prima.Pyxis.Accordion exposing
    ( Config, State
    , base, light, dark, state, withWrapperClass, withIconClass, withContentClass
    , open, close
    , render, renderGroup
    )

{-| Creates an Accordion component by using predefined Html syntax.


# Configuration

@docs Config, State


# Configuration Helpers

@docs base, light, dark, state, withWrapperClass, withIconClass, withContentClass


# Helpers

@docs open, close


# Render

@docs render, renderGroup

-}

import Html exposing (..)
import Html.Attributes exposing (class, classList, id)
import Html.Events exposing (onClick)


{-| Represents the static configuration of the component. Values
passed in are no more modified by the setter.
-}
type Config msg
    = Config (Configuration msg)


type alias Configuration msg =
    { type_ : AccordionType
    , slug : String
    , tagger : String -> Bool -> msg
    , options : List AccordionOption
    }


{-| Internal. Represents the type of accordion to be created
-}
type AccordionType
    = Base
    | Dark
    | Light


{-| Internal. Represents the state of the component. Values passed in are
susceptible to change.
-}
type State msg
    = State (InternalState msg)


type alias InternalState msg =
    { isOpen : Bool
    , title : String
    , content : List (Html msg)
    }


{-| Internal. Represents the list of available customizations.
-}
type alias Options =
    { wrapperClasses : List ( String, Bool )
    , iconClasses : List String
    , contentClasses : List String
    }


{-| Internal. Represents the possible modifiers.
-}
type AccordionOption
    = WrapperClass String
    | IconClass String
    | ContentClass String


{-| Internal. Represents the initial state of the list of customizations for the component.
-}
defaultOptions : Options
defaultOptions =
    { wrapperClasses = []
    , iconClasses = []
    , contentClasses = []
    }


{-| Internal. Applies the customizations made by the end user to the component.
-}
applyOption : AccordionOption -> Options -> Options
applyOption modifier options =
    case modifier of
        WrapperClass class ->
            { options | wrapperClasses = ( class, True ) :: options.wrapperClasses }

        IconClass class ->
            { options | iconClasses = class :: options.iconClasses }

        ContentClass class ->
            { options | contentClasses = class :: options.contentClasses }


{-| Internal. Applies all the customizations and returns the internal `Options` type.
-}
computeOptions : Config msg -> Options
computeOptions (Config config) =
    List.foldl applyOption defaultOptions config.options


{-| Internal. Adds a generic option to the `Accordion`.
-}
addOption : AccordionOption -> Config msg -> Config msg
addOption option (Config accordionConfig) =
    Config { accordionConfig | options = accordionConfig.options ++ [ option ] }


{-| Returns the configuration for a Base accordion skin.

    ...

    type alias Slug =
        String

    type Msg =
        Toggled Slug Bool

    ...

    myAccordionConfig : Accordion.Config
    myAccordionConfig =
    let
        slug =
            "my_accordion_slug"

        tagger =
            Toggled
    in
        Accordion.base slug tagger

    ...

-}
base : String -> (String -> Bool -> msg) -> Config msg
base slug tagger =
    Config <| Configuration Base slug tagger []


{-| The same as base but with a Light skin.
-}
light : String -> (String -> Bool -> msg) -> Config msg
light slug tagger =
    Config <| Configuration Light slug tagger []


{-| The same as base but with a Dark skin.
-}
dark : String -> (String -> Bool -> msg) -> Config msg
dark slug tagger =
    Config <| Configuration Dark slug tagger []


isBase : AccordionType -> Bool
isBase =
    (==) Base


isLight : AccordionType -> Bool
isLight =
    (==) Light


isDark : AccordionType -> Bool
isDark =
    (==) Dark


{-| Returns the basic state of the component.

    ...

    myAccordionState : Accordion.State
    myAccordionState =
        let
            isOpen =
                False

            title =
                "My title"

            content =
                (List.singleton <<  text) "Lorem ipsum dolor sit amet."
        in
        Accordion.state isOpen title content

    ...

-}
state : Bool -> String -> List (Html msg) -> State msg
state isOpen title content =
    State <| InternalState isOpen title content


{-| Opens the Accordion to reveal it's content.

    updatedAccordionState =
        Accordion.open myAccordionState

-}
open : State msg -> State msg
open (State internalState) =
    State { internalState | isOpen = True }


{-| Closes the Accordion to hide it's content.

    updatedAccordionState =
        Accordion.close myAccordionState

-}
close : State msg -> State msg
close (State internalState) =
    State { internalState | isOpen = False }


{-| Adds a class for the wrapper to the `Config`.
-}
withWrapperClass : String -> Config msg -> Config msg
withWrapperClass class_ =
    addOption (WrapperClass class_)


{-| Adds a class for the icon to the `Config`.
-}
withIconClass : String -> Config msg -> Config msg
withIconClass class_ =
    addOption (IconClass class_)


{-| Adds a class for the content to the `Config`.
-}
withContentClass : String -> Config msg -> Config msg
withContentClass class_ =
    addOption (ContentClass class_)


{-| Renders the Accordion component by receiving is State and Config.

    Accordion.render myAccordionState myAccordionConfiguration

-}
render : State msg -> Config msg -> Html msg
render (State { isOpen, title, content }) ((Config { type_, tagger, slug }) as config) =
    div
        [ id slug
        , [ ( "a-accordion", True )
          , ( "a-accordion--base", isBase type_ )
          , ( "a-accordion--light", isLight type_ )
          , ( "a-accordion--dark", isDark type_ )
          , ( "is-open", isOpen )
          ]
            |> buildWrapperClass config
        ]
        [ span
            [ class "a-accordion__toggle fs-xsmall fw-heavy a-link--alt"
            , onClick (tagger slug isOpen)
            ]
            [ text title
            , i
                [ buildIconClass config ]
                []
            ]
        , div
            [ buildContentClass config
            ]
            content
        ]


{-| Renders a group of Accordion(s) inside an AccordionGroup.

    Accordion.renderGroup
        [ ( myAccordionState1, myAccordionConfiguration1 )
        , ( myAccordionState2, myAccordionConfiguration2 )
        , ( myAccordionState3, myAccordionConfiguration3 )
        ]

-}
renderGroup : List ( State msg, Config msg ) -> Html msg
renderGroup dataSet =
    div
        [ class "m-accordion-group" ]
        (List.map (\( accordionState, accordionConfig ) -> render accordionState accordionConfig) dataSet)


{-| Internal. Transforms the customized contentClasses into an Html.Attribute
-}
buildContentClass : Config msg -> Html.Attribute msg
buildContentClass config =
    let
        options =
            computeOptions config
    in
    options.contentClasses
        |> String.join " "
        |> String.append "a-accordion__content fs-small "
        |> class


{-| Internal. Transforms the customized iconClasses into an Html.Attribute
-}
buildIconClass : Config msg -> Html.Attribute msg
buildIconClass config =
    let
        options =
            computeOptions config
    in
    options.iconClasses
        |> String.join " "
        |> String.append "a-icon "
        |> class


{-| Internal. Transforms the customized wrapperClasses into an Html.Attribute
-}
buildWrapperClass : Config msg -> List ( String, Bool ) -> Html.Attribute msg
buildWrapperClass config classes =
    let
        options =
            computeOptions config
    in
    options.wrapperClasses
        |> List.append classes
        |> classList



-- TODO verify implementation of AccordionGroup for exclusive opening
