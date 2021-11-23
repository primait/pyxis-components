module Prima.PyxisV3.Accordion.Examples.View exposing
    ( accordionConfig
    , accordionRender
    , appBody
    , view
    )

import Browser
import Html exposing (Html)
import Prima.PyxisV3.Accordion as Accordion
import Prima.PyxisV3.Accordion.Examples.Model
    exposing
        ( Accordion
        , AccordionType(..)
        , Msg(..)
        , accordionContent
        , accordionTypeToHtmlTitle
        , accordionTypeToSimpleTitle
        )
import Prima.PyxisV3.Container as Container
import Prima.PyxisV3.Helpers as Helpers


view : List Accordion -> Browser.Document Msg
view accordionList =
    Browser.Document "Accordion component" (appBody accordionList)


appBody : List Accordion -> List (Html Msg)
appBody accordionList =
    [ Helpers.pyxisStyle
    , Container.column
        |> Container.withContent
            ((List.intersperse Helpers.spacer << List.map accordionRender) accordionList)
        |> Container.render
    ]


accordionRender : Accordion -> Html Msg
accordionRender accordion =
    Accordion.render accordion.state (accordionConfig accordion)


accordionConfig : Accordion -> Accordion.Config Msg
accordionConfig accordion =
    case accordion.accordionType of
        Light ->
            Accordion.light accordion.slug ToggleAccordion
                |> Accordion.withSimpleTitle (accordionTypeToSimpleTitle accordion.accordionType)
                |> Accordion.withContent accordionContent

        Dark ->
            Accordion.dark accordion.slug ToggleAccordion
                |> Accordion.withHtmlTitle (accordionTypeToHtmlTitle accordion.accordionType)
                |> Accordion.withContent accordionContent

        Base ->
            Accordion.base accordion.slug ToggleAccordion
                |> Accordion.withSimpleTitle (accordionTypeToSimpleTitle accordion.accordionType)
                |> Accordion.withContent accordionContent
