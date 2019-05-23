module Prima.Pyxis.Accordion.Examples.Model exposing
    ( Accordion
    , AccordionType(..)
    , Model
    , Msg(..)
    , initialModel
    )

import Html exposing (..)
import Prima.Pyxis.Accordion.Accordion as Accordion
import Prima.Pyxis.Helpers as Helpers


type Msg
    = ToggleAccordion String Bool


type alias Model =
    { accordionList : List Accordion
    }


initialModel : Model
initialModel =
    Model (List.map accordionBuilder [ Base, Light, Dark ])


type alias Accordion =
    { accordionType : AccordionType
    , slug : String
    , state : Accordion.State Msg
    }


type AccordionType
    = Base
    | Dark
    | Light


accordionBuilder : AccordionType -> Accordion
accordionBuilder type_ =
    Accordion type_ (accordionTypeToSlug type_) (Accordion.state False (accordionTypeToTitle type_) accordionContent)


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
