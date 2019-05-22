module Prima.Pyxis.Accordions.Accordions exposing
    ( Config
    , State
    , accordionBaseConfig
    , accordionDarkConfig
    , accordionHandler
    , accordionLightConfig
    , render
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


type alias State msg =
    { isOpen : Bool
    , title : String
    , content : List (Html msg)
    }


accordionHandler : Bool -> String -> List (Html msg) -> State msg
accordionHandler isOpen title content =
    State isOpen title content


accordionBaseConfig : String -> (String -> Bool -> msg) -> Config msg
accordionBaseConfig slug tagger =
    Config <| Configuration Base slug tagger


accordionLightConfig : String -> (String -> Bool -> msg) -> Config msg
accordionLightConfig slug tagger =
    Config <| Configuration Light slug tagger


accordionDarkConfig : String -> (String -> Bool -> msg) -> Config msg
accordionDarkConfig slug tagger =
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
render ({ isOpen, title, content } as accordion) (Config { type_, tagger, slug }) =
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
