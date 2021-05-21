module Prima.Pyxis.Tooltip exposing
    ( Config
    , top, bottom, left, right, brand, error, warning
    , render
    , withClass, withId, withPositionBottom, withPositionLeft, withPositionRight, withPositionTop
    )

{-|


## Configuration

@docs Config


## Configuration Methods

@docs top, bottom, left, right, brand, error, warning


## Rendering

@docs render


## Options

@docs withClass, withId, withPositionBottom, withPositionLeft, withPositionRight, withPositionTop

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
    , kind : TooltipKind
    , options : List (TooltipOption msg)
    , children : List (Html msg)
    }


{-| Internal. Represent the `Tooltip` type.
-}
type TooltipType
    = Undefined
    | Top
    | Bottom
    | Left
    | Right


type TooltipKind
    = Default
    | Brand
    | Warning
    | Error


{-| Create a tooltip top.
-}
top : List (Html msg) -> Config msg
top children =
    Config (TooltipConfig Top Default [] children)


{-| Create a tooltip bottom.
-}
bottom : List (Html msg) -> Config msg
bottom children =
    Config (TooltipConfig Bottom Default [] children)


{-| Create a tooltip left.
-}
left : List (Html msg) -> Config msg
left children =
    Config (TooltipConfig Left Default [] children)


{-| Create a tooltip right.
-}
right : List (Html msg) -> Config msg
right children =
    Config (TooltipConfig Right Default [] children)


{-| Create a tooltip brand.
-}
brand : List (Html msg) -> Config msg
brand children =
    Config (TooltipConfig Undefined Brand [] children)


{-| Create a tooltip warning.
-}
warning : List (Html msg) -> Config msg
warning children =
    Config (TooltipConfig Undefined Warning [] children)


{-| Create a tooltip error.
-}
error : List (Html msg) -> Config msg
error children =
    Config (TooltipConfig Undefined Error [] children)


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


{-| Sets a type position `Top` to the `Tooltip`.
-}
withPositionTop : Config msg -> Config msg
withPositionTop (Config inputConfig) =
    Config { inputConfig | type_ = Top }


{-| Sets a type position `Left` to the `Tooltip`.
-}
withPositionLeft : Config msg -> Config msg
withPositionLeft (Config inputConfig) =
    Config { inputConfig | type_ = Left }


{-| Sets a type position `Right` to the `Tooltip`.
-}
withPositionRight : Config msg -> Config msg
withPositionRight (Config inputConfig) =
    Config { inputConfig | type_ = Right }


{-| Sets a type position `Bottom` to the `Tooltip`.
-}
withPositionBottom : Config msg -> Config msg
withPositionBottom (Config inputConfig) =
    Config { inputConfig | type_ = Bottom }


{-| Internal. Check is tooltip type top.
-}
isTooltipTop : TooltipType -> Bool
isTooltipTop =
    (==) Top


{-| Internal. Check is tooltip type bottom.
-}
isTooltipBottom : TooltipType -> Bool
isTooltipBottom =
    (==) Bottom


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


{-| Internal. Check is tooltip kind brand.
-}
isBrand : TooltipKind -> Bool
isBrand =
    (==) Brand


{-| Internal. Check is tooltip type warning.
-}
isWarning : TooltipKind -> Bool
isWarning =
    (==) Warning


{-| Internal. Check is tooltip type error.
-}
isError : TooltipKind -> Bool
isError =
    (==) Error


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
    { classes = []
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
            Tooltip.brand [ text "Lorem ipsum dolor sit amet" ]
              |> Tooltip.render

-}
render : Config msg -> Html msg
render ((Config { children, type_, kind }) as tooltipModel) =
    Html.div
        (List.append
            (buildAttributes tooltipModel)
            [ Attrs.classList
                [ ( "tooltip", True )
                , ( "tooltip--top", isTooltipTop type_ )
                , ( "tooltip--bottom", isTooltipBottom type_ )
                , ( "tooltip--left", isTooltipLeft type_ )
                , ( "tooltip--right", isTooltipRight type_ )
                , ( "tooltip--brand", isBrand kind )
                , ( "tooltip--warning", isWarning kind )
                , ( "tooltip--error", isError kind )
                ]
            ]
        )
        children
