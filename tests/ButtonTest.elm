module ButtonTest exposing
    ( genericButton
    , primaryButton
    , secondaryButton
    , tertiaryButton
    )

import Prima.Pyxis.Button as Button
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector exposing (class, classes, disabled, id, text)


genericButton : Test
genericButton =
    let
        config =
            Button.primary "Press me"
    in
    describe "Generic button"
        [ test "expect text" <|
            \() ->
                config
                    |> Button.render
                    |> Query.fromHtml
                    |> Query.find [ class "btn__text" ]
                    |> Query.has [ text "Press me" ]
        , test "expect id" <|
            \() ->
                config
                    |> Button.withId "my_id"
                    |> Button.render
                    |> Query.fromHtml
                    |> Query.has [ id "my_id" ]
        , test "expect disabled" <|
            \() ->
                config
                    |> Button.withDisabled True
                    |> Button.render
                    |> Query.fromHtml
                    |> Query.has [ disabled True ]
        , test "expect classes" <|
            \() ->
                config
                    |> Button.withClass "my-custom-class"
                    |> Button.render
                    |> Query.fromHtml
                    |> Query.has [ class "my-custom-class" ]
        , test "expect tiny size" <|
            \() ->
                config
                    |> Button.withTinySize
                    |> Button.render
                    |> Query.fromHtml
                    |> Query.has [ class "btn--tiny" ]
        , test "expect small size" <|
            \() ->
                config
                    |> Button.withSmallSize
                    |> Button.render
                    |> Query.fromHtml
                    |> Query.has [ class "btn--small" ]
        , test "expect medium size" <|
            \() ->
                config
                    |> Button.withMediumSize
                    |> Button.render
                    |> Query.fromHtml
                    |> Query.has [ class "btn--medium" ]
        ]


primaryButton : Test
primaryButton =
    let
        html =
            Button.render <| Button.primary "Press me"
    in
    describe "Primary button"
        [ test "expect classes" <|
            \() ->
                html
                    |> Query.fromHtml
                    |> Query.has [ classes [ "btn", "btn--primary" ] ]
        ]


secondaryButton : Test
secondaryButton =
    let
        html =
            Button.render <| Button.secondary "Press me"
    in
    describe "Secondary button"
        [ test "expect classes" <|
            \() ->
                html
                    |> Query.fromHtml
                    |> Query.has [ classes [ "btn", "btn--secondary" ] ]
        ]


tertiaryButton : Test
tertiaryButton =
    let
        html =
            Button.render <| Button.tertiary "Press me"
    in
    describe "Tertiary button"
        [ test "expect classes" <|
            \() ->
                html
                    |> Query.fromHtml
                    |> Query.has [ classes [ "btn", "btn--tertiary" ] ]
        ]
