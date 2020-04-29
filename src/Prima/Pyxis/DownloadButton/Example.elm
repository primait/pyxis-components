module Prima.Pyxis.DownloadButton.Example exposing
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
import Html.Attributes exposing (classList)
import Prima.Pyxis.DownloadButton as DownloadButton
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
    { downloadButtons : List (DownloadButton.Config Msg)
    }


initialModel : Model
initialModel =
    Model
        []


type Msg = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        _ ->
            ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    Browser.Document "Download Button component" (appBody)


appBody : List (Html Msg)
appBody =
    [ Helpers.pyxisStyle
    , DownloadButton.render myDownloadBtn
    , DownloadButton.render myDownloadBtnDisabled
    ]

myDownloadBtn : DownloadButton.Config Msg
myDownloadBtn =
    DownloadButton.download "Certificato di polizza" "Scarica .pdf"

myDownloadBtnDisabled : DownloadButton.Config Msg
myDownloadBtnDisabled =
    DownloadButton.download "Certificato di polizza" "Scarica .pdf"
        |> DownloadButton.withDisabled True
