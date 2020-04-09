module Prima.Pyxis.Accordion exposing
    ( Config, State, base, light, dark, state
    , withAttribute, withWrapperClass, withContentClass, withSimpleTitle, withHtmlTitle, withContent
    , open, close
    , render, renderGroup
    )

{-| Creates an Accordion component by using predefined Html syntax.


## Types and Configuration

@docs Config, State, base, light, dark, state


## Options

@docs withAttribute, withWrapperClass, withContentClass, withSimpleTitle, withHtmlTitle, withContent


## Helpers

@docs open, close


## Render

@docs render, renderGroup

-}

import Html exposing (Html, div, i, text)
import Html.Attributes exposing (class, classList, id)
import Html.Events exposing (onClick)


{-| Represents the static configuration of the component. Values
passed in are no more modified by the setter.
-}
type Config msg
    = Config (AccordionConfig msg)


type alias AccordionConfig msg =
    { type_ : AccordionType
    , slug : String
    , tagger : String -> Bool -> msg
    , title : Maybe (Html msg)
    , content : List (Html msg)
    , options : List (AccordionOption msg)
    }


{-| Internal. Represents the type of accordion to be created
-}
type AccordionType
    = Base
    | Dark
    | Light


{-| Internal. Represents the state of the component. Values passed in are
susceptible to change.
-}
type State
    = State Bool


{-| Internal. Represents the list of available customizations.
-}
type alias Options msg =
    { attributes : List (Html.Attribute msg)
    , wrapperClasses : List ( String, Bool )
    , contentClasses : List String
    }


{-| Internal. Represents the initial state of the list of customizations for the component.
-}
defaultOptions : Options msg
defaultOptions =
    { attributes = []
    , wrapperClasses = []
    , contentClasses = []
    }


{-| Internal. Represents the possible modifiers.
-}
type AccordionOption msg
    = Attribute (Html.Attribute msg)
    | WrapperClass String
    | ContentClass String


{-| Internal. Applies the customizations made by the end user to the component.
-}
applyOption : AccordionOption msg -> Options msg -> Options msg
applyOption modifier options =
    case modifier of
        Attribute attribute ->
            { options | attributes = attribute :: options.attributes }

        WrapperClass class ->
            { options | wrapperClasses = ( class, True ) :: options.wrapperClasses }

        ContentClass class ->
            { options | contentClasses = class :: options.contentClasses }


{-| Internal. Applies all the customizations and returns the internal `Options` type.
-}
computeOptions : Config msg -> Options msg
computeOptions (Config config) =
    List.foldl applyOption defaultOptions config.options


{-| Internal. Adds a generic option to the `Accordion`.
-}
addOption : AccordionOption msg -> Config msg -> Config msg
addOption option (Config accordionConfig) =
    Config { accordionConfig | options = accordionConfig.options ++ [ option ] }


{-| Returns the configuration for a Base accordion skin.

    ...

    type alias Slug =
        String

    type Msg =
        Toggled Slug Bool

    ...

    myAccordionConfig : Accordion.Config
    myAccordionConfig =
    let
        slug =
            "my_accordion_slug"

        tagger =
            Toggled
    in
        Accordion.base slug tagger

    ...

-}
base : String -> (String -> Bool -> msg) -> Config msg
base slug tagger =
    Config <| AccordionConfig Base slug tagger Nothing [] []


{-| The same as base but with a Light skin.
-}
light : String -> (String -> Bool -> msg) -> Config msg
light slug tagger =
    Config <| AccordionConfig Light slug tagger Nothing [] []


{-| The same as base but with a Dark skin.
-}
dark : String -> (String -> Bool -> msg) -> Config msg
dark slug tagger =
    Config <| AccordionConfig Dark slug tagger Nothing [] []


isBase : AccordionType -> Bool
isBase =
    (==) Base


isLight : AccordionType -> Bool
isLight =
    (==) Light


isDark : AccordionType -> Bool
isDark =
    (==) Dark


{-| Returns the basic state of the component.

    ...

    myAccordionState : Accordion.State
    myAccordionState =
        let
            isOpen =
                False

            title =
                "My title"

            content =
                (List.singleton <<  text) "Lorem ipsum dolor sit amet."
        in
        Accordion.state isOpen title content

    ...

-}
state : Bool -> State
state isOpen =
    State isOpen


{-| Opens the Accordion to reveal it's content.

    updatedAccordionState =
        Accordion.open myAccordionState

-}
open : State
open =
    State True


{-| Closes the Accordion to hide it's content.

    updatedAccordionState =
        Accordion.close myAccordionState

-}
close : State
close =
    State False


{-| Adds a generic Html.Attribute to the `Config`.
-}
withAttribute : Html.Attribute msg -> Config msg -> Config msg
withAttribute attribute =
    addOption (Attribute attribute)


{-| Adds a class for the wrapper to the `Config`.
-}
withWrapperClass : String -> Config msg -> Config msg
withWrapperClass class_ =
    addOption (WrapperClass class_)


{-| Adds a class for the content to the `Config`.
-}
withContentClass : String -> Config msg -> Config msg
withContentClass class_ =
    addOption (ContentClass class_)


{-| Adds a string title to the Accordion
-}
withSimpleTitle : String -> Config msg -> Config msg
withSimpleTitle title (Config accordionConfig) =
    Config { accordionConfig | title = Just (text title) }


{-| Adds an Html title to the Accordion
-}
withHtmlTitle : Html msg -> Config msg -> Config msg
withHtmlTitle title (Config accordionConfig) =
    Config { accordionConfig | title = Just title }


{-| Adds content to the Accordion
-}
withContent : List (Html msg) -> Config msg -> Config msg
withContent content (Config accordionConfig) =
    Config { accordionConfig | content = content }


{-| Renders the Accordion component by receiving is State and Config.

    Accordion.render myAccordionState myAccordionConfiguration

-}
render : State -> Config msg -> Html msg
render (State isOpen) ((Config { type_, tagger, slug, title, content }) as config) =
    let
        options =
            computeOptions config
    in
    div
        ([ id slug
         , [ ( "m-accordion", True )
           , ( "m-accordion--base", isBase type_ )
           , ( "m-accordion--light", isLight type_ )
           , ( "m-accordion--dark", isDark type_ )
           , ( "is-open", isOpen )
           ]
            |> buildWrapperClass config
         ]
            |> (++) options.attributes
        )
        [ div
            [ class "m-accordion__toggle fs-xsmall fw-heavy a-link--alt"
            , onClick (tagger slug isOpen)
            ]
            [ title
                |> Maybe.withDefault (text "")
            , div
                [ class "m-accordion__icon" ]
                []
            ]
        , div
            [ buildContentClass config
            ]
            content
        ]


{-| Renders a group of Accordion(s) inside an AccordionGroup.

    Accordion.renderGroup
        [ ( myAccordionState1, myAccordionConfiguration1 )
        , ( myAccordionState2, myAccordionConfiguration2 )
        , ( myAccordionState3, myAccordionConfiguration3 )
        ]

-}
renderGroup : List ( State, Config msg ) -> Html msg
renderGroup dataSet =
    div
        [ class "m-accordion-group" ]
        (List.map (\( accordionState, accordionConfig ) -> render accordionState accordionConfig) dataSet)


{-| Internal. Transforms the customized contentClasses into an Html.Attribute
-}
buildContentClass : Config msg -> Html.Attribute msg
buildContentClass config =
    let
        options =
            computeOptions config
    in
    options.contentClasses
        |> String.join " "
        |> String.append "m-accordion__content fs-small "
        |> class


{-| Internal. Transforms the customized wrapperClasses into an Html.Attribute
-}
buildWrapperClass : Config msg -> List ( String, Bool ) -> Html.Attribute msg
buildWrapperClass config classes =
    let
        options =
            computeOptions config
    in
    options.wrapperClasses
        |> List.append classes
        |> classList
