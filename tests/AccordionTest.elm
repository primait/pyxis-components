module AccordionTest exposing (baseAccordion, darkAccordion, lightAccordion)

import Html exposing (Html)
import Prima.PyxisV3.Accordion as Accordion
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector exposing (class, classes, tag)


type Msg
    = Toggle String Bool


accordionState : Accordion.State
accordionState =
    Accordion.state False


accordionBaseConfig : Accordion.Config Msg
accordionBaseConfig =
    Accordion.base "accordion_base" Toggle
        |> Accordion.withContent accordionContent


accordionContent : List (Html Msg)
accordionContent =
    [ Html.p [] [ Html.text "Lorem ipsum dolor sit amet." ] ]


accordionDarkConfig : Accordion.Config Msg
accordionDarkConfig =
    Accordion.dark "accordion_dark" Toggle


accordionLightConfig : Accordion.Config Msg
accordionLightConfig =
    Accordion.light "accordion_light" Toggle


baseAccordion : Test
baseAccordion =
    let
        html =
            Accordion.render accordionState accordionBaseConfig
    in
    describe "Basic accordion"
        [ test "expect classes " <|
            \() ->
                html
                    |> Query.fromHtml
                    |> Query.has [ classes [ "accordion", "accordion--base" ] ]
        , test "expect toggle classes " <|
            \() ->
                html
                    |> Query.fromHtml
                    |> Query.find [ tag "div", class "accordion__toggle" ]
                    |> Query.has [ class "accordion__toggle" ]
        , test "expect toggle icon classes " <|
            \() ->
                html
                    |> Query.fromHtml
                    |> Query.find [ tag "i", class "accordion__toggle__icon" ]
                    |> Query.has [ class "accordion__toggle__icon" ]
        , test "expect content " <|
            \() ->
                html
                    |> Query.fromHtml
                    |> Query.find [ tag "div", class "accordion__content" ]
                    |> Query.has [ class "accordion__content" ]
        , test "expect content to match configuration" <|
            \() ->
                html
                    |> Query.fromHtml
                    |> Query.find [ tag "div", class "accordion__content" ]
                    |> Query.contains accordionContent
        ]


darkAccordion : Test
darkAccordion =
    let
        html =
            Accordion.render accordionState accordionDarkConfig
    in
    describe "Dark accordion"
        [ test "expect classes " <|
            \() ->
                html
                    |> Query.fromHtml
                    |> Query.has [ classes [ "accordion", "accordion--dark" ] ]
        ]


lightAccordion : Test
lightAccordion =
    let
        html =
            Accordion.render accordionState accordionLightConfig
    in
    describe "Light accordion"
        [ test "expect classes " <|
            \() ->
                html
                    |> Query.fromHtml
                    |> Query.has [ classes [ "accordion", "accordion--light" ] ]
        ]
