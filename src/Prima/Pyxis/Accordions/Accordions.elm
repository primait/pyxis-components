module Prima.Pyxis.Accordions.Accordions exposing
    ( Config
    , State
    , baseConfig
    , close
    , darkConfig
    , lightConfig
    , open
    , render
    , state
    )

import Html exposing (..)
import Html.Attributes exposing (class, classList, id)
import Html.Events exposing (onClick)


type Config msg
    = Config (Configuration msg)


type alias Configuration msg =
    { type_ : AccordionType
    , slug : String
    , tagger : String -> Bool -> msg
    }


type State msg
    = State (InternalState msg)


type alias InternalState msg =
    { isOpen : Bool
    , title : String
    , content : List (Html msg)
    }


state : Bool -> String -> List (Html msg) -> State msg
state isOpen title content =
    State <| InternalState isOpen title content


open : State msg -> State msg
open (State internalState) =
    State { internalState | isOpen = True }


close : State msg -> State msg
close (State internalState) =
    State { internalState | isOpen = False }


baseConfig : String -> (String -> Bool -> msg) -> Config msg
baseConfig slug tagger =
    Config <| Configuration Base slug tagger


lightConfig : String -> (String -> Bool -> msg) -> Config msg
lightConfig slug tagger =
    Config <| Configuration Light slug tagger


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
