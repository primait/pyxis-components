module Prima.Pyxis.Accordions.Accordions exposing
    ( Config
    , accordionBaseConfig
    , accordionDarkConfig
    , accordionLightConfig
    , render
    )

import Html exposing (..)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)


type Config msg
    = Config (Configuration msg)


type alias Configuration msg =
    { type_ : AccordionType
    , title : String
    , content : List (Html msg)
    , tagger : Bool -> msg
    }


accordionBaseConfig : String -> List (Html msg) -> (Bool -> msg) -> Config msg
accordionBaseConfig title content tagger =
    Config <| Configuration Base title content tagger


accordionLightConfig : String -> List (Html msg) -> (Bool -> msg) -> Config msg
accordionLightConfig title content tagger =
    Config <| Configuration Light title content tagger


accordionDarkConfig : String -> List (Html msg) -> (Bool -> msg) -> Config msg
accordionDarkConfig title content tagger =
    Config <| Configuration Dark title content tagger


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


render : Bool -> Config msg -> Html msg
render isOpen (Config ({ content, title, type_, tagger } as config)) =
    div
        [ {--id accordionId
        , --}
          classList
            [ ( "a-accordion", True )
            , ( "is-open", isOpen )
            , ( "a-accordion--base", isBaseAccordion type_ )
            , ( "a-accordion--light", isLightAccordion type_ )
            , ( "a-accordion--dark", isDarkAccordion type_ )
            ]
        ]
        [ span
            [ class "a-accordion__toggle fs-xsmall fw-heavy a-link--alt"
            , (onClick << tagger) isOpen
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
