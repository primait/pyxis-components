module Prima.PyxisV3.Form.Grid exposing
    ( Grid, Row, Children
    , create, emptyRow, addRow
    , render
    , withOneColumn, withTwoColumns, withThreeColumns, withFourColumns
    )

{-|


## Configuration

@docs Grid, Row, Children


## Configuration Methods

@docs create, emptyRow, addRow


## Rendering

@docs render


## Options

@docs withOneColumn, withTwoColumns, withThreeColumns, withFourColumns

-}

import Html exposing (Html, div)
import Html.Attributes exposing (attribute, class)


{-| Represent the `Grid`.
-}
type Grid msg
    = Grid (List (Row msg))


{-| Creates a `Grid`.
-}
create : Grid msg
create =
    Grid []


{-| Represents a `Row` which is the child of a `Grid`.
-}
type Row msg
    = Row (InternalRow msg)


{-| Creates an empty `Row`.
-}
emptyRow : Row msg
emptyRow =
    Row WithoutColumns


{-| Adds a `Row` to the `Grid`.
-}
addRow : Row msg -> Grid msg -> Grid msg
addRow row_ (Grid rows) =
    Grid (rows ++ [ row_ ])


{-| Represents a `RowStruct`.
-}
type InternalRow msg
    = WithoutColumns
    | OneColumn (Children msg)
    | TwoColumns (InternalTwoColumns msg)
    | ThreeColumns (InternalThreeColumns msg)
    | FourColumns (InternalFourColumns msg)


{-| Convenient alias for a `List (Html msg)`.
-}
type alias Children msg =
    List (Html msg)


{-| Adds one `Column` to a row.
-}
withOneColumn : Children msg -> Row msg
withOneColumn childs =
    Row <| OneColumn childs


{-| Internal. Represents a `Column` of 2 elements.
-}
type alias InternalTwoColumns msg =
    { first : Children msg
    , second : Children msg
    }


{-| Creates a `Row` with 2 `Column`s.
-}
withTwoColumns : Children msg -> Children msg -> Row msg
withTwoColumns first second =
    Row <| TwoColumns <| InternalTwoColumns first second


{-| Creates a `Column` with 2 childrens.
-}
type alias InternalThreeColumns msg =
    { first : Children msg
    , second : Children msg
    , third : Children msg
    }


{-| Creates a `Row` with 3 `Column`s.
-}
withThreeColumns : Children msg -> Children msg -> Children msg -> Row msg
withThreeColumns first second third =
    Row <| ThreeColumns <| InternalThreeColumns first second third


type alias InternalFourColumns msg =
    { first : Children msg
    , second : Children msg
    , third : Children msg
    , fourth : Children msg
    }


{-| Creates a `Row` with 4 `Column`s.
-}
withFourColumns : Children msg -> Children msg -> Children msg -> Children msg -> Row msg
withFourColumns first second third fourth =
    Row <| FourColumns <| InternalFourColumns first second third fourth


{-| Renders the `Grid`.
-}
render : Grid msg -> List (Html msg)
render (Grid grid) =
    List.map renderRow grid


renderRow : Row msg -> Html msg
renderRow (Row rowStruct) =
    div
        [ class "form-row"
        , rowStruct
            |> rowStructToChildCount
            |> String.fromInt
            |> attribute "data-children-count"
        ]
        (rowStruct
            |> toListOfChildren
            |> List.map renderColumn
        )


rowStructToChildCount : InternalRow msg -> Int
rowStructToChildCount rowStruct =
    case rowStruct of
        WithoutColumns ->
            0

        OneColumn _ ->
            1

        TwoColumns _ ->
            2

        ThreeColumns _ ->
            3

        FourColumns _ ->
            4


toListOfChildren : InternalRow msg -> List (Children msg)
toListOfChildren rowStruct =
    case rowStruct of
        WithoutColumns ->
            []

        OneColumn child ->
            [ child ]

        TwoColumns { first, second } ->
            [ first, second ]

        ThreeColumns { first, second, third } ->
            [ first, second, third ]

        FourColumns { first, second, third, fourth } ->
            [ first, second, third, fourth ]


renderColumn : Children msg -> Html msg
renderColumn =
    div
        [ class "form-row__item" ]
