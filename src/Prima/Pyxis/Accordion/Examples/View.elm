module Prima.Pyxis.Accordion.Examples.View exposing
    ( accordionConfig
    , accordionRender
    , appBody
    , view
    )

import Browser
import Html exposing (Html)
import Prima.Pyxis.Accordion as Accordion
import Prima.Pyxis.Accordion.Examples.Model
    exposing
        ( Accordion
        , AccordionType(..)
        , Msg(..)
        , accordionContent
        , accordionTypeToTitle
        )
import Prima.Pyxis.Container as Container
import Prima.Pyxis.Helpers as Helpers


view : List Accordion -> Browser.Document Msg
view accordionList =
    Browser.Document "Accordion component" (appBody accordionList)


appBody : List Accordion -> List (Html Msg)
appBody accordionList =
    [ Helpers.pyxisStyle
    , Container.default
        ((List.intersperse Helpers.spacer << List.map accordionRender) accordionList)
    ]


accordionRender : Accordion -> Html Msg
accordionRender accordion =
    Accordion.render accordion.state (accordionConfig accordion)


accordionConfig : Accordion -> Accordion.Config Msg
accordionConfig accordion =
    (case accordion.accordionType of
        Light ->
            Accordion.light

        Dark ->
            Accordion.dark

        Base ->
            Accordion.base
    )
        accordion.slug
        ToggleAccordion
        |> Accordion.withSimpleTitle (accordionTypeToTitle accordion.accordionType)
        |> Accordion.withContent accordionContent
