module Prima.Pyxis.Container.Example.View exposing (view)

import Browser
import Html exposing (Html, div, h3, hr, p, text)
import Html.Attributes exposing (class, style)
import Prima.Pyxis.Container as Container
import Prima.Pyxis.Container.Example.Model as Model exposing (Model, Msg(..))
import Prima.Pyxis.Helpers as Helpers


view : Model -> Browser.Document Msg
view model =
    { title = "Container component"
    , body = appBody model
    }


block : String -> Html Msg
block string =
    div
        [ style "padding" "5px"
        , style "min-height" "100px"
        , style "min-width" "100px"
        ]
        [ div
            [ style "border" "1px solid purple"
            , style "border-radius" "5px"
            , class "bgBrandLight cTextLight"
            , style "text-align" "center"
            , style "height" "100%"
            , style "width" "100%"
            , style "padding" "5px"
            , style "line-height" "85px"
            ]
            [ p [] [ text string ] ]
        ]


dummyBlocks : List (Html Msg)
dummyBlocks =
    [ block "some"
    , block "blocks"
    , block "in"
    , block "a"
    , block "container"
    ]


eventBlocks : String -> List (Html Msg)
eventBlocks =
    List.map block << String.words


sectionTitle : String -> Html Msg
sectionTitle title =
    h3 [ style "text-align" "center" ] [ text title ]


appBody : Model -> List (Html Msg)
appBody model =
    [ Helpers.pyxisStyle
    , sectionTitle "Row Container"
    , Container.row
        |> Container.withClass "bgAlertBase"
        |> Container.withContent dummyBlocks
        |> Container.render
    , hr [] []
    , sectionTitle "Column Container"
    , Container.column
        |> Container.withClass "bgAlertBase"
        |> Container.withContent dummyBlocks
        |> Container.render
    , hr [] []
    , sectionTitle "Row Container Fluid"
    , Container.rowFluid
        |> Container.withClass "bgAlertBase"
        |> Container.withContent dummyBlocks
        |> Container.render
    , hr [] []
    , hr [] []
    , sectionTitle "Column Container Fluid"
    , Container.columnFluid
        |> Container.withClass "bgAlertBase"
        |> Container.withContent dummyBlocks
        |> Container.render
    , hr [] []
    , sectionTitle "Row Container Fluid, regular on Medium"
    , Container.rowFluid
        |> Container.changeSizeOnMedium
        |> Container.withClass "bgAlertBase"
        |> Container.withContent dummyBlocks
        |> Container.render
    , hr [] []
    , sectionTitle "Row Container, fluid on Medium"
    , Container.row
        |> Container.changeSizeOnMedium
        |> Container.withClass "bgAlertBase"
        |> Container.withContent dummyBlocks
        |> Container.render
    , hr [] []
    , sectionTitle "Row Container, with content editable"
    , Container.row
        |> Container.withClass "bgAlertBase"
        |> Container.withContentEditable True
        |> Container.withContent
            [ block "You can edit this text writing something"
            ]
        |> Container.render
    , hr [] []
    , sectionTitle "Row Container with ID, Title, and events"
    , Container.row
        |> veryLongComposedAttributes
        |> Container.withContent
            (eventBlocks model.eventMessage)
        |> Container.render
    , hr [] []
    ]


veryLongComposedAttributes : Container.Config Msg -> Container.Config Msg
veryLongComposedAttributes =
    Container.withClass "bgAlertBase"
        << Container.withId "container-with-id"
        << Container.withTitle "container with title"
        << Container.withAccessKey 'c'
        << Container.withTabIndex 1
        << Container.onBlur Model.OnBlur
        << Container.onClick Model.OnClick
        << Container.onDoubleClick Model.OnDoubleClick
        << Container.onMouseEnter Model.OnMouseEnter
        << Container.onMouseLeave Model.OnMouseLeave
        << Container.onMouseOut Model.OnMouseOut
        << Container.onMouseOver Model.OnMouseOver
        << Container.onFocus Model.OnFocus
