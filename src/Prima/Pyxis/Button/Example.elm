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
import Prima.Pyxis.Button as Button
import Prima.Pyxis.Helpers as Helpers


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
    { buttons : List (Button.Config Msg)
    }


initialModel : Model
initialModel =
    Model
        [ Button.primary "Primary" NoOp False
        , Button.primarySmall "Primary small" NoOp False
        , Button.secondary "Secondary" NoOp False
        , Button.secondarySmall "Secondary small" NoOp False
        , Button.tertiarySmall "Tertiary" NoOp False
        , Button.tertiarySmall "Tertiary small" NoOp False
        ]


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    Browser.Document "Button component" (appBody model)


appBody : Model -> List (Html Msg)
appBody model =
    [ Helpers.pyxisStyle
    , div
        [ class "a-container a-container--small directionColumn"
        ]
        ((List.intersperse Helpers.spacer << List.map Button.render) model.buttons)
    ]
