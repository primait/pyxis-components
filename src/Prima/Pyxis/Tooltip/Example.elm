module Prima.Pyxis.Tooltip.Example exposing
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
import Prima.Pyxis.Helpers as Helpers
import Prima.Pyxis.Tooltip as Tooltip


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
    ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    Browser.Document "Tooltip component" (appBody model)


appBody : Model -> List (Html Msg)
appBody _ =
    [ Helpers.pyxisStyle
    , div
        [ class "a-container a-container--small directionColumn"
        , style "position" "relative"
        , style "top" "100px"
        ]
        ([ Tooltip.upConfig
         , Tooltip.downConfig
         , Tooltip.leftConfig
         , Tooltip.rightConfig
         ]
            |> List.map tooltipBuilder
            |> List.intersperse Helpers.spacer
        )
    ]


tooltipBuilder : (List (Html Msg) -> Tooltip.Config msg) -> Html msg
tooltipBuilder mapper =
    (Tooltip.render << mapper) contentTooltip


contentTooltip : List (Html Msg)
contentTooltip =
    [ div [ class "cose" ] [ text "Lorem ipsum dolor sit amet" ]
    ]
