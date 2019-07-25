module Prima.Pyxis.Container exposing
    ( fluid, default
    , Modifier(..), defaultWithModifiers, fluidWithModifiers, custom
    )

{-| Creates a Container component by using predefined Html syntax.


# Ready to use

@docs fluid, default


# Custom

@docs Modifier, defaultWithModifiers, fluidWithModifiers, custom

-}

import Html exposing (..)
import Html.Attributes exposing (class, classList)


{-| Represents a list of modifiers which can be applied to the container itself.

Use `RowDirection | ColumnDirection` to manage `flex-direction`.

Use `OnBPXsmall | OnBPSmall | OnBPMedium | OnBPLarge | OnBPXlarge` to transform a `fluid` Container in a `default` one in a specific Breakpoint (BP).

Use `FluidOnBPXsmall | FluidOnBPSmall | FluidOnBPMedium | FluidOnBPLarge | FluidOnBPXlarge` to transform a `default` Container in a `fluid` one in a specific Breakpoint (BP).

-}
type Modifier
    = RowDirection
    | ColumnDirection
      ----------
    | OnBPXsmall
    | OnBPSmall
    | OnBPMedium
    | OnBPLarge
    | OnBPXlarge
      ----------
    | FluidOnBPXsmall
    | FluidOnBPSmall
    | FluidOnBPMedium
    | FluidOnBPLarge
    | FluidOnBPXlarge


modifierToString : Modifier -> String
modifierToString modifier =
    case modifier of
        RowDirection ->
            "directionRow"

        ColumnDirection ->
            "directionColumn"

        OnBPXsmall ->
            "a-containerOnBPXsmall"

        OnBPSmall ->
            "a-containerOnBPSmall"

        OnBPMedium ->
            "a-containerOnBPMedium"

        OnBPLarge ->
            "a-containerOnBPLarge"

        OnBPXlarge ->
            "a-containerOnBPXlarge"

        FluidOnBPXsmall ->
            "a-containerFluidOnBPXsmall"

        FluidOnBPSmall ->
            "a-containerFluidOnBPSmall"

        FluidOnBPMedium ->
            "a-containerFluidOnBPMedium"

        FluidOnBPLarge ->
            "a-containerFluidOnBPLarge"

        FluidOnBPXlarge ->
            "a-containerFluidOnBPXlarge"


{-| Renders a `default` Container
-}
default : List (Html msg) -> Html msg
default =
    div
        [ class "a-container directionColumn" ]


{-| Renders a `default` Container but with some `Modifier`(s) to manage it's appearance in specific Breakpoints (BP)
-}
defaultWithModifiers : List Modifier -> List (Html msg) -> Html msg
defaultWithModifiers modifiers =
    div
        [ class <| String.join " " <| "a-container" :: List.map modifierToString modifiers
        ]


{-| Renders a `fluid` Container
-}
fluid : List (Html msg) -> Html msg
fluid =
    div
        [ class "a-containerFluid directionColumn" ]


{-| Renders a `fluid` Container but with some `Modifier`(s) to manage it's appearance in specific Breakpoints (BP)
-}
fluidWithModifiers : List Modifier -> List (Html msg) -> Html msg
fluidWithModifiers modifiers =
    div
        [ class <| String.join " " <| "a-containerFluid" :: List.map modifierToString modifiers
        ]


{-| Renders a completely customizable container.

    Container.custom [ "my-custom-class", "a-container" ] [ ColumnDirection, FluidOnBpXSmall ] [ text "Lorem ipsum dolor sit amet." ]

-}
custom : List String -> List Modifier -> List (Html msg) -> Html msg
custom classes modifiers =
    div
        [ class <| String.join " " <| classes ++ List.map modifierToString modifiers
        ]
