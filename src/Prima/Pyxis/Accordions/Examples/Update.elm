module Prima.Pyxis.Accordions.Examples.Update exposing (update)

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
            let
                updateAccordion : Accordion -> Accordion
                updateAccordion accordion =
                    if slug == accordion.slug then
                        { accordion | isAccordionOpen = not isOpen }

                    else
                        { accordion | isAccordionOpen = False }
            in
            ( { model | accordionList = List.map updateAccordion model.accordionList }, Cmd.none )
