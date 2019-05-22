module Prima.Pyxis.Accordions.Examples.Model exposing
    ( Model
    , Msg(..)
    , initialModel
    )

import Html exposing (..)
import Prima.Pyxis.Accordions.Accordions as Accordions
import Prima.Pyxis.Helpers as Helpers


type Msg
    = ToggleAccordion String Bool


type alias Model =
    { accordionList : List Accordion
    }


initialModel : Model
initialModel =
    Model (List.map accordionBuilder [ Base, Light, Dark ])

