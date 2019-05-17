module Prima.Pyxis.Accordions exposing (Msg, State, baseAccordion, darkAccordion, defaultAccordion, init, lightAccordion, render, updateAccordionContent, updateState)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)


type alias Opened =
    Bool


type alias State parentMsg =
    { accordionType : AccordionType
    , accordionId : String
    , title : String
    , content : Html parentMsg
    , isOpen : Opened
    , tagger : Msg -> parentMsg
    }


type AccordionType
    = Default
    | Light
    | Dark
    | Base


type Msg
    = Toggle


init : (Msg -> parentMsg) -> AccordionType -> String -> String -> Opened -> Html parentMsg -> State parentMsg
init tagger accordionType id title isOpen content =
    State accordionType id title content isOpen tagger


isDefaultAccordion : AccordionType -> Bool
isDefaultAccordion =
    (==) Default


isBaseAccordion : AccordionType -> Bool
isBaseAccordion =
    (==) Base


isLightAccordion : AccordionType -> Bool
isLightAccordion =
    (==) Light


isDarkAccordion : AccordionType -> Bool
isDarkAccordion =
    (==) Dark


defaultAccordion : AccordionType
defaultAccordion =
    Default


lightAccordion : AccordionType
lightAccordion =
    Light


darkAccordion : AccordionType
darkAccordion =
    Dark


baseAccordion : AccordionType
baseAccordion =
    Base


toggleAccordion : Opened -> String
toggleAccordion isOpen =
    if isOpen then
        "block"

    else
        "none"


updateAccordionContent : Html parentMsg -> State parentMsg -> State parentMsg
updateAccordionContent newContent state =
    { state | content = newContent }


updateState : Msg -> State parentMsg -> State parentMsg
updateState parentMsg state =
    case parentMsg of
        Toggle ->
            { state | isOpen = not state.isOpen }


render : State parentMsg -> Html parentMsg
render { accordionId, content, isOpen, title, tagger, accordionType } =
    div
        [ id accordionId
        , classList
            [ ( "accordion", isDefaultAccordion accordionType )
            , ( "accordion--base", isBaseAccordion accordionType )
            , ( "accordion--light", isLightAccordion accordionType )
            , ( "accordion--dark", isDarkAccordion accordionType )
            ]
        ]
        [ a
            [ class "accordion__toggle"
            , onClick <| tagger Toggle
            ]
            [ text title
            , i
                [ classList
                    [ ( "accordion__icon", True )
                    , ( "accordion__icon--open", isOpen )
                    , ( "accordion__icon--collapse", not isOpen )
                    ]
                ]
                [ text "+" ]
            ]
        , div
            [ classList
                [ ( "accordion__content--open", isOpen )
                , ( "accordion__content--collapse", not isOpen )
                ]
            ]
            [ content ]
        ]
