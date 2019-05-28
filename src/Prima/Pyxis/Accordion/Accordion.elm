module Prima.Pyxis.Accordion.Accordion exposing
    ( Config, State
    , baseConfig, lightConfig, darkConfig, state
    , open, close
    , render
    )

{-| Creates an `Accordion` component by using predefined `Html` syntax.

#Configuration

@docs Config, State

#Configuration Helpers

@docs baseConfig, lightConfig, darkConfig, state

#Helpers

@docs open, close

#Render

@docs render

-}

import Html exposing (..)
import Html.Attributes exposing (class, classList, id)
import Html.Events exposing (onClick)


{-| Represent the static configuration of the component. Values
passed in are no more modified by the setter.
-}
type Config msg
    = Config (Configuration msg)


type alias Configuration msg =
    { type_ : AccordionType
    , slug : String
    , tagger : String -> Bool -> msg
    }


{-| Represent the state of the component. Values passed in are
susceptible to change.
-}
type State msg
    = State (InternalState msg)


type alias InternalState msg =
    { isOpen : Bool
    , title : String
    , content : List (Html msg)
    }


{-| Returns the basic state of the component.

    -- Create a new `Accordion.State`
    ...
    myAccordionState : Accordion.State
    myAccordionState =
    let
        isOpen = True
        title = "My title"
        content = [ text "Lorem ipsum dolor sit amet." ]
    in
    myAccordionState = Accordion.state
    ...

-}
state : Bool -> String -> List (Html msg) -> State msg
state isOpen title content =
    State <| InternalState isOpen title content


{-| Opens the Accordion to reveal it's content.

    --
    ...
    updatedAccordionState = Accordion.open myAccordionState
    ...

-}
open : State msg -> State msg
open (State internalState) =
    State { internalState | isOpen = True }


{-| Closes the Accordion to hide it's content.

    --
    ...
    updatedAccordionState = Accordion.close myAccordionState
    ...

-}
close : State msg -> State msg
close (State internalState) =
    State { internalState | isOpen = False }


{-| Returns the configuration for a Base accordion skin.

    --
    ...
    type alias Slug =
        String

    type Msg =
        Toggled Slug Bool

    myAccordionConfig : `Accordion.Config`
    myAccordionConfig =
    let
        slug =
            "my_accordion_slug"

        tagger =
            Toggled
    in
        Accordion.baseConfig slug tagger
    ...

-}
baseConfig : String -> (String -> Bool -> msg) -> Config msg
baseConfig slug tagger =
    Config <| Configuration Base slug tagger


{-| The same as `baseConfig` but with a Light skin.
-}
lightConfig : String -> (String -> Bool -> msg) -> Config msg
lightConfig slug tagger =
    Config <| Configuration Light slug tagger


{-| The same as `baseConfig` but with a Dark skin.
-}
darkConfig : String -> (String -> Bool -> msg) -> Config msg
darkConfig slug tagger =
    Config <| Configuration Dark slug tagger


type AccordionType
    = Base
    | Dark
    | Light


isBaseAccordion : AccordionType -> Bool
isBaseAccordion =
    (==) Base


isLightAccordion : AccordionType -> Bool
isLightAccordion =
    (==) Light


isDarkAccordion : AccordionType -> Bool
isDarkAccordion =
    (==) Dark


{-| Renders the `Accordion` component by receiving is `State` and `Config`.
--
...
Accordion.render myAccordionState myAccordionConfiguration
...
-}
render : State msg -> Config msg -> Html msg
render ((State { isOpen, title, content }) as accordion) (Config { type_, tagger, slug }) =
    div
        [ id slug
        , classList
            [ ( "a-accordion", True )
            , ( "is-open", isOpen )
            , ( "a-accordion--base", isBaseAccordion type_ )
            , ( "a-accordion--light", isLightAccordion type_ )
            , ( "a-accordion--dark", isDarkAccordion type_ )
            ]
        ]
        [ span
            [ class "a-accordion__toggle fs-xsmall fw-heavy a-link--alt"
            , onClick (tagger slug isOpen)
            ]
            [ text title
            , i
                [ classList
                    [ ( "a-icon", True )
                    , ( "a-icon-info", True )
                    ]
                ]
                []
            ]
        , div
            [ class "a-accordion__content fs-small"
            ]
            content
        ]
