module Prima.PyxisV2.Accordion.Examples.View exposing
    ( accordionConfig
    , accordionRender
    , appBody
    , view
    )

import Browser
import Html exposing (..)
import Html.Attributes exposing (class)
import Prima.PyxisV2.Accordion as Accordion
import Prima.PyxisV2.Accordion.Examples.Model
    exposing
        ( Accordion
        , AccordionType(..)
        , Model
        , Msg(..)
        )
import Prima.PyxisV2.Container as Container
import Prima.PyxisV2.Helpers as Helpers


view : Model -> Browser.Document Msg
view model =
    Browser.Document "Accordion component" (appBody model)


appBody : Model -> List (Html Msg)
appBody model =
    [ Helpers.pyxisStyle
    , Container.default
        ((List.intersperse Helpers.spacer << List.map accordionRender) model.accordionList)
    ]


accordionRender : Accordion -> Html Msg
accordionRender accordion =
    Accordion.render accordion.state (accordionConfig accordion)


accordionConfig : Accordion -> Accordion.Config Msg
accordionConfig accordion =
    (case accordion.accordionType of
        Light ->
            Accordion.lightConfig

        Dark ->
            Accordion.darkConfig

        Base ->
            Accordion.baseConfig
    )
        accordion.slug
        ToggleAccordion
