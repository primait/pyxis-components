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
import Prima.Pyxis.ButtonGroup as ButtonGroup
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
    , clicked : Maybe String
    }


initialModel : Model
initialModel =
    Model
        [ Button.callOut "CallOut"
        , Button.primary "Primary"
        , Button.secondary "Secondary"
        , Button.tertiary "Tertiary"
        ]
        [ Button.callOut "CallOut dark"
            |> Button.withColorScheme Button.BrandDark
            |> Button.withOnClick (HandleEvent "Click 1")
            |> Button.withClassList [ ( "test", True ), ( "never-applied", False ) ]
            |> Button.withTabIndex 1
        , Button.primary "Primary dark"
            |> Button.withIcon "editing"
            |> Button.withColorScheme Button.BrandDark
            |> Button.withOnClick (HandleEvent "Click 2")
            |> Button.withTabIndex 0
        , Button.secondary "Secondary dark"
            |> Button.withColorScheme Button.BrandDark
            |> Button.withOnMouseEnter (HandleEvent "Hover 3")
            |> Button.withOnClick (HandleEvent "Click 3")
            |> Button.withTabIndex 2
        , Button.tertiary "Tertiary dark"
            |> Button.withColorScheme Button.BrandDark
            |> Button.withTabIndex 3
        ]
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
    Browser.Document "Button component" (appBody model)


appBody : Model -> List (Html Msg)
appBody model =
    [ Helpers.pyxisStyle
    , model.buttons
        |> ButtonGroup.centered
        |> ButtonGroup.render
        |> List.singleton
        |> wrapper False
    , model.darkButtons
        |> ButtonGroup.coverFluid
        |> ButtonGroup.render
        |> List.singleton
        |> wrapper True
    , model.clicked
        |> Maybe.withDefault "No button clicked"
        |> Html.text
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
