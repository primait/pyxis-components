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
import Html exposing (Html)
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
    , clicked : Maybe String
    }


initialModel : Model
initialModel =
    Model
        []
        Nothing


type Msg
    = HandleEvent String
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        HandleEvent label ->
            ( { model | clicked = Just label }, Cmd.none )

        _ ->
            ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    Browser.Document "Download Button component" (appBody model)


appBody : Model -> List (Html Msg)
appBody model =
    [ Helpers.pyxisStyle
    , DownloadButton.render myDownloadBtn
    , DownloadButton.render myDownloadBtnDisabled
    , model.clicked
            |> Maybe.withDefault "No button clicked"
            |> Html.text
    ]

myDownloadBtn : DownloadButton.Config Msg
myDownloadBtn =
    DownloadButton.download "Certificato di polizza" "Scarica .pdf"
        |> DownloadButton.withOnClick (HandleEvent "Clicked")

myDownloadBtnDisabled : DownloadButton.Config Msg
myDownloadBtnDisabled =
    DownloadButton.download "Certificato di polizza" "Scarica .pdf"
        |> DownloadButton.withDisabled True
