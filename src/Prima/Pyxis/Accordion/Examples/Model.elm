module Prima.Pyxis.Accordion.Examples.Model exposing
    ( Accordion
    , AccordionType(..)
    , Msg(..)
    , accordionContent
    , accordionTypeToHtmlTitle
    , accordionTypeToSimpleTitle
    , initialModel
    )

import Html exposing (Html, text)
import Html.Attributes as Attrs
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


accordionTypeToSimpleTitle : AccordionType -> String
accordionTypeToSimpleTitle type_ =
    case type_ of
        Base ->
            "I am a base accordion"

        Light ->
            "I am a light accordion"

        Dark ->
            "I am a dark accordion"


accordionTypeToHtmlTitle : AccordionType -> Html msg
accordionTypeToHtmlTitle type_ =
    case type_ of
        Base ->
            Html.span []
                [ text "I am a "
                , Html.strong [ Attrs.class "cBrandBase" ] [ text "base accordion" ]
                ]

        Light ->
            Html.span []
                [ text "I am a "
                , Html.strong [ Attrs.class "cBrandBase" ] [ text "light accordion" ]
                ]

        Dark ->
            Html.span []
                [ text "I am a "
                , Html.strong [ Attrs.class "cBrandBase" ] [ text "dark accordion" ]
                ]


accordionContent : List (Html Msg)
accordionContent =
    [ text Helpers.loremIpsum ]
