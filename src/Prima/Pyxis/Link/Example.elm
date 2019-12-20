module Prima.Pyxis.Link.Example exposing
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
import Prima.Pyxis.Helpers as Helpers
import Prima.Pyxis.Link as Link


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
    = LinkClicked


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "handle onClick" msg of
        LinkClicked ->
            ( model, Cmd.none )


view : Model -> Browser.Document Msg
view _ =
    Browser.Document "Link component" appBody


appBody : List (Html Msg)
appBody =
    [ Helpers.pyxisStyle
    , [ Link.simpleWithOnClick "Visit Google" LinkClicked |> Link.withTargetSelf
      , Link.standalone "Visit Google standalone" "https://www.google.it"
      , Link.standaloneWithOnClick "Visit Google standalone" LinkClicked
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
