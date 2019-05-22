module Prima.Pyxis.Accordions.Examples.View exposing
    ( accordionConfig
    , accordionRender
    , appBody
    , view
    )

import Browser
import Html exposing (..)
import Html.Attributes exposing (class)
import Prima.Pyxis.Accordions.Accordions as Accordions
import Prima.Pyxis.Accordions.Examples.Model
    exposing
        ( Accordion
        , AccordionType(..)
        , Model
        , Msg(..)
        )
import Prima.Pyxis.Helpers as Helpers


view : Model -> Browser.Document Msg
view model =
    Browser.Document "Accordion component" (appBody model)


appBody : Model -> List (Html Msg)
appBody model =
    [ Helpers.pyxisStyle
    , div
        [ class "a-container a-container--medium directionColumn" ]
        ((List.intersperse Helpers.spacer << List.map accordionRender) model.accordionList)
    ]


accordionRender : Accordion -> Html Msg
accordionRender accordion =
    Accordions.render accordion.state (accordionConfig accordion)


accordionConfig : Accordion -> Accordions.Config Msg
accordionConfig accordion =
    (case accordion.accordionType of
        Light ->
            Accordions.lightConfig

        Dark ->
            Accordions.darkConfig

        Base ->
            Accordions.baseConfig
    )
        accordion.slug
        ToggleAccordion
