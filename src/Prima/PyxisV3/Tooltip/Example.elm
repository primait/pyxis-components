module Prima.PyxisV3.Tooltip.Example exposing
    ( Model
    , Msg(..)
    , appBody
    , init
    , initialModel
    , main
    , update
    , view
    )

import Browser
import Html exposing (Html, div, text)
import Html.Attributes exposing (class, style)
import Prima.PyxisV3.Helpers as Helpers
import Prima.PyxisV3.Tooltip as Tooltip


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel, Cmd.none )


type alias Model =
    {}


initialModel : Model
initialModel =
    Model


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    Browser.Document "Tooltip component" (appBody model)


appBody : Model -> List (Html Msg)
appBody _ =
    [ Helpers.pyxisStyle
    , div
        [ class "container container--small direction-column position-relative"
        , style "margin-top" "100px"
        , style "height" "60px"
        ]
        ([ Tooltip.top
         , Tooltip.bottom
         , Tooltip.left
         , Tooltip.right
         ]
            |> List.map tooltipBuilder
            |> List.intersperse Helpers.spacer
        )
    , Helpers.spacer
    , div
        [ class "container container--small direction-column position-relative"
        , style "margin-top" "120px"
        , style "height" "60px"
        ]
        [ Tooltip.brand contentTooltip |> Tooltip.withPositionTop |> Tooltip.render
        , Tooltip.brand contentTooltip |> Tooltip.withPositionBottom |> Tooltip.render
        , Tooltip.brand contentTooltip |> Tooltip.withPositionLeft |> Tooltip.render
        , Tooltip.brand contentTooltip |> Tooltip.withPositionRight |> Tooltip.render
        ]
    , Helpers.spacer
    , div
        [ class "container container--small direction-column position-relative"
        , style "margin-top" "120px"
        , style "height" "60px"
        ]
        [ Tooltip.warning contentTooltip |> Tooltip.withPositionTop |> Tooltip.render
        , Tooltip.warning contentTooltip |> Tooltip.withPositionBottom |> Tooltip.render
        , Tooltip.warning contentTooltip |> Tooltip.withPositionLeft |> Tooltip.render
        , Tooltip.warning contentTooltip |> Tooltip.withPositionRight |> Tooltip.render
        ]
    , Helpers.spacer
    , div
        [ class "container container--small direction-column position-relative"
        , style "margin-top" "120px"
        , style "height" "60px"
        ]
        [ Tooltip.error contentTooltip |> Tooltip.withPositionTop |> Tooltip.render
        , Tooltip.error contentTooltip |> Tooltip.withPositionBottom |> Tooltip.render
        , Tooltip.error contentTooltip |> Tooltip.withPositionLeft |> Tooltip.render
        , Tooltip.error contentTooltip |> Tooltip.withPositionRight |> Tooltip.render
        ]
    ]


tooltipBuilder : (List (Html Msg) -> Tooltip.Config Msg) -> Html Msg
tooltipBuilder mapper =
    (Tooltip.render << Tooltip.withClass "tooltip-my-class" << mapper) contentTooltip


contentTooltip : List (Html Msg)
contentTooltip =
    [ text "Lorem ipsum dolor sit amet" ]
