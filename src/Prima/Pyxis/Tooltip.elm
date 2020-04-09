module Prima.Pyxis.Tooltip exposing
    ( Config
    , up, down, left, right
    , render
    , withClass, withId
    )

{-|


## Configuration

@docs Config


## Configuration Methods

@docs up, down, left, right


## Rendering

@docs render


## Options

@docs withClass, withId

-}

import Html exposing (Html)
import Html.Attributes as Attrs
import Prima.Pyxis.Helpers as H


{-| Represent the opaque `Tooltip` configuration.
-}
type Config msg
    = Config (TooltipConfig msg)


{-| Internal. Represent the `Tooltip` configuration.
-}
type alias TooltipConfig msg =
    { type_ : TooltipType
    , options : List (TooltipOption msg)
    , children : List (Html msg)
    }


{-| Internal. Represent the `Tooltip` type.
-}
type TooltipType
    = Up
    | Down
    | Left
    | Right


{-| Create a tooltip up.
-}
up : List (Html msg) -> Config msg
up children =
    Config (TooltipConfig Up [] children)


{-| Create a tooltip down.
-}
down : List (Html msg) -> Config msg
down children =
    Config (TooltipConfig Down [] children)


{-| Create a tooltip left.
-}
left : List (Html msg) -> Config msg
left children =
    Config (TooltipConfig Left [] children)


{-| Create a tooltip right.
-}
right : List (Html msg) -> Config msg
right children =
    Config (TooltipConfig Right [] children)


{-| Internal. Represent the possible modifiers for an `Tooltip`.
-}
type alias TooltipOptions =
    { classes : List String
    , id : Maybe String
    }


{-| Internal. Represent the possible modifiers for an `Tooltip`.
-}
type TooltipOption msg
    = Class String
    | Id String


{-| Adds a `class` to the `Tooltip`.
-}
withClass : String -> Config msg -> Config msg
withClass class_ =
    addOption (Class class_)


{-| Adds an `id` Html.Attribute to the `Tooltip`.
-}
withId : String -> Config msg -> Config msg
withId id =
    addOption (Id id)


{-| Internal. Check is tooltip type up.
-}
isTooltipUp : TooltipType -> Bool
isTooltipUp =
    (==) Up


{-| Internal. Check is tooltip type down.
-}
isTooltipDown : TooltipType -> Bool
isTooltipDown =
    (==) Down


{-| Internal. Check is tooltip type left.
-}
isTooltipLeft : TooltipType -> Bool
isTooltipLeft =
    (==) Left


{-| Internal. Check is tooltip type right.
-}
isTooltipRight : TooltipType -> Bool
isTooltipRight =
    (==) Right


{-| Internal. Applies the customizations made by end user to the `Tooltip` component.
-}
applyOption : TooltipOption msg -> TooltipOptions -> TooltipOptions
applyOption modifier options =
    case modifier of
        Class class ->
            { options | classes = class :: options.classes }

        Id id ->
            { options | id = Just id }


{-| Internal. Applies all the customizations and returns the internal `TooltipOptions` type.
-}
computeOptions : Config msg -> TooltipOptions
computeOptions (Config { options }) =
    List.foldl applyOption defaultOptions options


{-| Internal. Transforms all the customizations into a list of valid Html.Attribute(s).
-}
buildAttributes : Config msg -> List (Html.Attribute msg)
buildAttributes tooltip =
    let
        { id, classes } =
            computeOptions tooltip
    in
    [ Maybe.map Attrs.id id ]
        |> List.filterMap identity
        |> (::) (H.classesAttribute classes)


{-| Internal. Represent the initial state of the list of customizations for the `Tooltip` component.
-}
defaultOptions : TooltipOptions
defaultOptions =
    { classes = [ "a-tooltip" ]
    , id = Nothing
    }


{-| Internal. Adds a generic option to the `Tooltip`.
-}
addOption : TooltipOption msg -> Config msg -> Config msg
addOption option (Config inputConfig) =
    Config { inputConfig | options = inputConfig.options ++ [ option ] }


{-|


## Renders the `Tooltip`.

    import Html
    import Prima.Pyxis.Tooltip as Tooltip

    ...

    type Msg =
        NoOp

    type alias Model =
        {}

    ...

    view : Html Msg
    view =
        Html.div
            []
            (Tooltip.upConfig []
            |> Tooltip.withClass ""
            )

    validate : String -> Validation.Type
    validate str =
        if String.isEmpty str then
            Just <| Validation.ErrorWithMessage "Username is empty".
        else
            Nothing

-}
render : Config msg -> Html msg
render ((Config { children, type_ }) as tooltipModel) =
    Html.div
        (List.append
            (buildAttributes tooltipModel)
            [ Attrs.classList
                [ ( "a-tooltip", True )
                , ( "a-tooltip--up", isTooltipUp type_ )
                , ( "a-tooltip--down", isTooltipDown type_ )
                , ( "a-tooltip--left", isTooltipLeft type_ )
                , ( "a-tooltip--right", isTooltipRight type_ )
                ]
            ]
        )
        children
