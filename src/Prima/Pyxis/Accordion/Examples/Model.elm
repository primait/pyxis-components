module Prima.Pyxis.Accordion.Examples.Model exposing
    ( Accordion
    , AccordionType(..)
    , Msg(..)
    , accordionContent
    , accordionTypeToTitle
    , initialModel
    )

import Html exposing (Html, text)
import Prima.Pyxis.Accordion as Accordion
import Prima.Pyxis.Helpers as Helpers


type Msg
    = ToggleAccordion String Bool


initialModel : List Accordion
initialModel =
    List.map accordionBuilder [ Base, Light, Dark ]


type alias Accordion =
    { accordionType : AccordionType
    , slug : String
    , state : Accordion.State
    }


type AccordionType
    = Base
    | Dark
    | Light


accordionBuilder : AccordionType -> Accordion
accordionBuilder type_ =
    Accordion type_ (accordionTypeToSlug type_) (Accordion.state False)


accordionTypeToSlug : AccordionType -> String
accordionTypeToSlug type_ =
    case type_ of
        Base ->
            "slug-accordion-base"

        Light ->
            "slug-accordion-light"

        Dark ->
            "slug-accordion-dark"


accordionTypeToTitle : AccordionType -> String
accordionTypeToTitle type_ =
    case type_ of
        Base ->
            "I am a base accordion"

        Light ->
            "I am a light accordion"

        Dark ->
            "I am a dark accordion"


accordionContent : List (Html Msg)
accordionContent =
    [ text Helpers.loremIpsum ]
