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
        [ Button.callOut "CallOut"
            |> Button.withOnClick (HandleEvent "Click 1")
            |> Button.withClass "test"
            |> Button.withTabIndex 1
        , Button.primaryAlt "Primary alt"
            |> Button.withIcon "editing"
            |> Button.withOnClick (HandleEvent "Click 2")
            |> Button.withTabIndex 0
        , Button.secondaryAlt "Secondary alt"
            |> Button.withOnMouseEnter (HandleEvent "Hover 3")
            |> Button.withOnClick (HandleEvent "Click 3")
            |> Button.withTabIndex 2
        , Button.tertiaryAlt "Tertiary alt"
            |> Button.withTypeSubmit
            |> Button.withTabIndex 3
        ]
        Nothing


type Msg
    = HandleEvent String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        HandleEvent label ->
            ( { model | clicked = Just label }, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    Browser.Document "Button component" (appBody model)


appBody : Model -> List (Html Msg)
appBody model =
    [ Helpers.pyxisStyle
    , Helpers.pyxisIconSetStyle
    , model.buttons
        |> ButtonGroup.create
        |> ButtonGroup.render
        |> List.singleton
        |> wrapper False
    , model.darkButtons
        |> ButtonGroup.create
        |> ButtonGroup.withAlignmentCoverFluid
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
            [ ( "container", True )
            , ( "direction-column", True )
            , ( "bg-background-alt-light", isDark )
            ]
        ]
        content
