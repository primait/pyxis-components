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
import Html exposing (Html, div)
import Html.Attributes exposing (class)
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
    case msg of
        LinkClicked ->
            ( model, Cmd.none )


view : Model -> Browser.Document Msg
view _ =
    Browser.Document "Link component" appBody


appBody : List (Html Msg)
appBody =
    [ Helpers.pyxisStyle
    , Helpers.pyxisIconSetStyle
    , [ Link.simple "Visit Google"
            |> Link.withHref "https://www.google.it"
            |> Link.withId "my-link"
      , Link.simple "Visit Google"
            |> Link.withHref "https://www.google.it"
            |> Link.withIcon "phone"
      , Link.standalone "Visit Google in another tab"
            |> Link.withHref "https://www.google.it"
            |> Link.withTargetBlank
      , Link.simple "Visit Google with click prevented"
            |> Link.withOnClick LinkClicked
            |> Link.withClassList [ ( "fsSmall", True ) ]
      ]
        |> List.map Link.render
        |> List.intersperse Helpers.spacer
        |> wrapper
    ]


wrapper : List (Html Msg) -> Html Msg
wrapper content =
    div
        [ class "container direction-column"
        ]
        content
