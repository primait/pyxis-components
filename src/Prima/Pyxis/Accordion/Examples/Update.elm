module Prima.Pyxis.Accordion.Examples.Update exposing (update)

import Prima.Pyxis.Accordion as Accordion
import Prima.Pyxis.Accordion.Examples.Model
    exposing
        ( Accordion
        , Msg(..)
        )


update : Msg -> List Accordion -> ( List Accordion, Cmd Msg )
update msg accordionList =
    case msg of
        ToggleAccordion slug isOpen ->
            ( List.map (updateAccordion slug isOpen) accordionList, Cmd.none )


updateAccordion : String -> Bool -> Accordion -> Accordion
updateAccordion slug isOpen accordion =
    case ( slug == accordion.slug, isOpen ) of
        ( True, False ) ->
            updateAccordionState Accordion.open accordion

        ( _, _ ) ->
            updateAccordionState Accordion.close accordion


updateAccordionState : Accordion.State -> Accordion -> Accordion
updateAccordionState mapper accordion =
    { accordion | state = mapper }
