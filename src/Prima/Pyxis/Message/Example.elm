module Prima.Pyxis.Message.Example exposing
    ( Model
    , Msg(..)
    , init
    , main
    , update
    , view
    )

import Browser
import Html exposing (Html, text)
import Prima.Pyxis.Container as Container
import Prima.Pyxis.Helpers as Helpers
import Prima.Pyxis.Message as Message


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
update _ model =
    ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    Browser.Document "Message component" (appBody model)


appBody : Model -> List (Html Msg)
appBody _ =
    [ Helpers.pyxisStyle
    , Container.default
        ([ Message.messageInfoConfig
         , Message.messageSuccessConfig
         , Message.messageErrorConfig
         ]
            |> List.map messageBuilder
            |> List.intersperse Helpers.spacer
        )
    ]


messageBuilder : (List (Html msg) -> Message.Config msg) -> Html msg
messageBuilder mapper =
    (Message.render << mapper << List.singleton << text) "Lorem ipsum dolor sit amet."
