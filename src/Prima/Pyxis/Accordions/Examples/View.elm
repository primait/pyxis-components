module Prima.Pyxis.Accordions.Examples.View exposing
    ( accordionConfig
    , accordionHandler
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
    Accordions.render (accordionHandler accordion) (accordionConfig accordion)


accordionHandler : Accordion -> Accordions.Accordion Msg
accordionHandler accordion =
    Accordions.accordionHandler accordion.isAccordionOpen accordion.title accordion.content


accordionConfig : Accordion -> Accordions.Config Msg
accordionConfig accordion =
    (case accordion.accordionType of
        Light ->
            Accordions.accordionLightConfig

        Dark ->
            Accordions.accordionDarkConfig

        Base ->
            Accordions.accordionBaseConfig
    )
        accordion.slug
        ToggleAccordion
