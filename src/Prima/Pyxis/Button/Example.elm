module Prima.Pyxis.Button.Example exposing
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
    , darkButtons : List (Button.Config Msg)
    }


initialModel : Model
initialModel =
    Model
        [ Button.callOut Button.Brand "CallOut" NoOp
        , Button.primary Button.Brand "Primary" NoOp
        , Button.secondary Button.Brand "Secondary" NoOp
        , Button.tertiary Button.Brand "Tertiary" NoOp
        ]
        [ Button.callOut Button.BrandDark "CallOut dark" NoOp
        , Button.primary Button.BrandDark "Primary dark" NoOp
        , Button.secondary Button.BrandDark "Secondary dark" NoOp
        , Button.tertiary Button.BrandDark "Tertiary dark" NoOp
        ]


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update _ model =
    ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    Browser.Document "Button component" (appBody model)


appBody : Model -> List (Html Msg)
appBody model =
    [ Helpers.pyxisStyle
    , model.buttons
        |> List.map (\btn -> ( True, btn ))
        |> Button.group
        |> List.singleton
        |> wrapper False
    , model.darkButtons
        |> List.map (\btn -> ( True, btn ))
        |> Button.group
        |> List.singleton
        |> wrapper True
    ]


wrapper : Bool -> List (Html Msg) -> Html Msg
wrapper isDark content =
    div
        [ classList
            [ ( "a-container", True )
            , ( "directionColumn", True )
            , ( "bgBackgroundAltLight", isDark )
            ]
        ]
        content
