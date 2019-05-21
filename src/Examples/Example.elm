module Examples.Example exposing (Model, Msg(..), initialModel, update)

import Browser
import Examples.Helpers as Helpers
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Prima.Pyxis.Accordions.Accordions as Accordions


type alias Model =
    { isAccordionOpen : Bool
    }


initialModel : Model
initialModel =
    Model False


type Msg
    = OpenAccordion
    | CloseAccordion
    | ToggleAccordion Bool


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "update" msg of
        ToggleAccordion isOpen ->
            ( { model | isAccordionOpen = not isOpen }, Cmd.none )

        OpenAccordion ->
            ( { model | isAccordionOpen = True }, Cmd.none )

        CloseAccordion ->
            ( { model | isAccordionOpen = False }, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    Browser.Document "Accordion component" (appBody model)


appBody : Model -> List (Html Msg)
appBody model =
    let
        accordionConfig =
            Accordions.accordionBaseConfig
                "Sono un accordion"
                [ text "Lorem ipsum dolor sit amet..." ]
                ToggleAccordion
    in
    [ Helpers.pyxisStyle
    , btn OpenAccordion "Apri"
    , btn CloseAccordion "Chiudi"
    , Accordions.render model.isAccordionOpen accordionConfig
    ]


btn : Msg -> String -> Html Msg
btn tagger label =
    button
        [ onClick tagger ]
        [ text label ]


init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel, Cmd.none )


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
