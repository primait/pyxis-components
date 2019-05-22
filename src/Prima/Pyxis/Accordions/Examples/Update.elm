module Prima.Pyxis.Accordions.Examples.Update exposing (update)

import Prima.Pyxis.Accordions.Accordions as Accordions
import Prima.Pyxis.Accordions.Examples.Model
    exposing
        ( Accordion
        , Model
        , Msg(..)
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleAccordion slug isOpen ->
            ( { model | accordionList = List.map (updateAccordion slug isOpen) model.accordionList }, Cmd.none )


updateAccordion : String -> Bool -> Accordion -> Accordion
updateAccordion slug isOpen accordion =
    case ( slug == accordion.slug, isOpen ) of
        ( True, False ) ->
            updateAccordionState Accordions.open accordion

        ( _, _ ) ->
            updateAccordionState Accordions.close accordion


updateAccordionState : (Accordions.State Msg -> Accordions.State Msg) -> Accordion -> Accordion
updateAccordionState mapper accordion =
    { accordion | state = mapper accordion.state }
