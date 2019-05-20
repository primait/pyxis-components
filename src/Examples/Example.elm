module Examples.Example exposing (Model, Msg(..), initialModel, update)

import Browser
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


update : Msg -> Model -> Model
update msg model =
    case Debug.log "update" msg of
        ToggleAccordion isOpen ->
            { model | isAccordionOpen = not isOpen }

        OpenAccordion ->
            { model | isAccordionOpen = True }

        CloseAccordion ->
            { model | isAccordionOpen = False }


view : Model -> Html Msg
view model =
    let
        accordionConfig =
            Accordions.accordionBaseConfig
                "Sono un accordion"
                [ text "Lorem ipsum dolor sit amet..." ]
                ToggleAccordion
    in
    div
        []
        [ btn OpenAccordion "Apri"
        , btn CloseAccordion "Chiudi"
        , Accordions.render model.isAccordionOpen accordionConfig
        ]


btn : Msg -> String -> Html Msg
btn tagger label =
    button
        [ onClick tagger ]
        [ text label ]


main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }
