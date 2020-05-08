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
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    Browser.Document "Message component" (appBody model)


appBody : Model -> List (Html Msg)
appBody _ =
    [ Helpers.pyxisStyle
    , Helpers.pyxisIconSetStyle
    , Container.column
        |> Container.withContent
            ([ [ text "Info: Lorem ipsum dolor sit amet." ]
                |> Message.info
                |> Message.withClass "custom-class"
             , [ text "Success: Lorem ipsum dolor sit amet." ]
                |> Message.success
             , [ text "Warning: Lorem ipsum dolor sit amet." ]
                |> Message.alert
             , [ text "Error: Lorem ipsum dolor sit amet." ]
                |> Message.error
             , [ text "Info: Lorem ipsum dolor sit amet." ]
                |> Message.infoAlt
                |> Message.withClass "custom-class"
             , [ text "Success: Lorem ipsum dolor sit amet." ]
                |> Message.successAlt
             , [ text "Warning: Lorem ipsum dolor sit amet." ]
                |> Message.alertAlt
             , [ text "Error: Lorem ipsum dolor sit amet." ]
                |> Message.errorAlt
             ]
                |> List.map Message.render
                |> List.intersperse Helpers.spacer
            )
        |> Container.render
    ]
