module Prima.Pyxis.Accordion.Examples.View exposing
    ( accordionConfig
    , accordionRender
    , appBody
    , view
    )

import Browser
import Html exposing (..)
import Html.Attributes exposing (class)
import Prima.Pyxis.Accordion as Accordion
import Prima.Pyxis.Accordion.Examples.Model
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
