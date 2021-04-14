module Prima.PyxisV2.Link.Example exposing
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
import Html.Attributes exposing (class, classList, style)
import Prima.PyxisV2.Helpers as Helpers
import Prima.PyxisV2.Link as Link


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
    Browser.Document "Link component" (appBody model)


appBody : Model -> List (Html Msg)
appBody model =
    [ Helpers.pyxisStyle
    , [ Link.simple "Visit Google" "https://www.google.it"
      , Link.withIcon "Call us" "https://www.google.it" Link.iconPhone
      , Link.standalone "Visit Google" "https://www.google.it"
      ]
        |> List.map Link.render
        |> List.intersperse Helpers.spacer
        |> wrapper
    ]


wrapper : List (Html Msg) -> Html Msg
wrapper content =
    div
        [ class "a-container directionColumn"
        ]
        content
