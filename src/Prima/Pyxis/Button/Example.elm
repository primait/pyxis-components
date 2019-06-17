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
        [ Button.primary Button.brand "Primary" NoOp False
        , Button.primarySmall Button.brand "Primary small" NoOp False
        , Button.primary Button.dark "Primary dark" NoOp False
        , Button.primarySmall Button.dark "Primary dark small" NoOp False
        , Button.secondary Button.brand "Secondary" NoOp False
        , Button.secondarySmall Button.brand "Secondary small" NoOp False
        , Button.secondary Button.dark "Secondary dark" NoOp False
        , Button.secondarySmall Button.dark "Secondary dark small" NoOp False
        , Button.tertiarySmall Button.brand "Tertiary" NoOp False
        , Button.tertiarySmall Button.brand "Tertiary small" NoOp False
        , Button.tertiarySmall Button.dark "Tertiary dark" NoOp False
        , Button.tertiarySmall Button.dark "Tertiary dark small" NoOp False
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
