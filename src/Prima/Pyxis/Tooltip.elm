module Prima.Pyxis.Tooltip exposing
    ( Tooltip, upConfig, downConfig, leftConfig, rightConfig
    , withClass, withId
    , render
    )

{-|


## Types and Configuration

@docs Tooltip, upConfig, downConfig, leftConfig, rightConfig


## TooltipOptions

@docs withClass, withId


# Render

@docs render

-}

import Html exposing (Html)
import Html.Attributes as Attrs


{-| Represents the opaque `Tooltip` configuration.
-}
type Tooltip msg
    = Tooltip (TooltipConfig msg)


{-| Internal. Represents the `Tooltip` configuration.
-}
type alias TooltipConfig msg =
    { type_ : TooltipType
    , options : List (TooltipOption msg)
    , children : List (Html msg)
    }


{-| Internal. Represents the `Tooltip` type.
-}
type TooltipType
    = Up
    | Down
    | Left
    | Right


{-| Create a tooltip up.
-}
upConfig : List (Html msg) -> Tooltip msg
upConfig children =
    Tooltip (TooltipConfig Up [] children)


{-| Create a tooltip down.
-}
downConfig : List (Html msg) -> Tooltip msg
downConfig children =
    Tooltip (TooltipConfig Down [] children)


{-| Create a tooltip left.
-}
leftConfig : List (Html msg) -> Tooltip msg
leftConfig children =
    Tooltip (TooltipConfig Left [] children)


{-| Create a tooltip right.
-}
rightConfig : List (Html msg) -> Tooltip msg
rightConfig children =
    Tooltip (TooltipConfig Right [] children)


{-| Internal. Represents the possible modifiers for an `Tooltip`.
-}
type alias TooltipOptions =
    { classes : List String
    , id : Maybe String
    }


{-| Internal. Represents the possible modifiers for an `Tooltip`.
-}
type TooltipOption msg
    = Class String
    | Id String


{-| Adds a `class` to the `Tooltip`.
-}
withClass : String -> Tooltip msg -> Tooltip msg
withClass class_ =
    addOption (Class class_)


{-| Adds an `id` Html.Attribute to the `Tooltip`.
-}
withId : String -> Tooltip msg -> Tooltip msg
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
computeOptions : Tooltip msg -> TooltipOptions
computeOptions (Tooltip config) =
    List.foldl applyOption defaultOptions config.options


{-| Internal. Transforms a list of `class`(es) into a valid Html.Attribute.
-}
classesAttribute : List String -> Html.Attribute msg
classesAttribute =
    Attrs.class << String.join " "


{-| Internal. Transforms all the customizations into a list of valid Html.Attribute(s).
-}
buildAttributes : Tooltip msg -> List (Html.Attribute msg)
buildAttributes tooltip =
    let
        options =
            computeOptions tooltip
    in
    [ Maybe.map Attrs.id options.id ]
        |> List.filterMap identity
        |> (::) (classesAttribute options.classes)


{-| Internal. Represents the initial state of the list of customizations for the `Tooltip` component.
-}
defaultOptions : TooltipOptions
defaultOptions =
    { classes = [ "a-tooltip" ]
    , id = Nothing
    }


{-| Internal. Adds a generic option to the `Tooltip`.
-}
addOption : TooltipOption msg -> Tooltip msg -> Tooltip msg
addOption option (Tooltip inputConfig) =
    Tooltip { inputConfig | options = inputConfig.options ++ [ option ] }


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
render : Tooltip msg -> Html msg
render ((Tooltip { children, type_ }) as tooltipModel) =
    Html.div
        ([ Attrs.classList
            [ ( "a-tooltip", True )
            , ( "a-tooltip--up", isTooltipUp type_ )
            , ( "a-tooltip--down", isTooltipDown type_ )
            , ( "a-tooltip--left", isTooltipLeft type_ )
            , ( "a-tooltip--right", isTooltipRight type_ )
            ]
         ]
            ++ buildAttributes tooltipModel
        )
        children
