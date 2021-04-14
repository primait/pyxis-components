module Prima.PyxisV2.Accordion.Examples.Update exposing (update)

import Prima.PyxisV2.Accordion as Accordion
import Prima.PyxisV2.Accordion.Examples.Model
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
            updateAccordionState Accordion.open accordion

        ( _, _ ) ->
            updateAccordionState Accordion.close accordion


updateAccordionState : (Accordion.State Msg -> Accordion.State Msg) -> Accordion -> Accordion
updateAccordionState mapper accordion =
    { accordion | state = mapper accordion.state }
