module Prima.Pyxis.AtrTable exposing
    ( State, AtrDetail, Msg
    , state, update, atr, paritaria, paritariaMista, paritariaCose, paritariaPersone, principale, principaleMista, principaleCose, principalePersone
    , render
    , withClass
    )

{-|


## Configuration

@docs State, AtrDetail, Msg


## Configuration Methods

@docs state, update, atr, paritaria, paritariaMista, paritariaCose, paritariaPersone, principale, principaleMista, principaleCose, principalePersone


## Rendering

@docs render


## Options

@docs withClass

-}

import Html exposing (Html, option, select, text)
import Html.Attributes exposing (selected, value)
import Html.Events exposing (onInput)
import Prima.Pyxis.Helpers as H
import Prima.Pyxis.Table as Table


{-| Defines the configuration of an Atr table
-}
type State
    = State StateConfig


type alias StateConfig =
    { atrDetails : List AtrDetail
    , alternateRows : Bool
    , isEditable : Bool
    , tableState : Table.State
    , classes : List String
    }


{-| Returns a Tuple containing the Config and a possible batch of side effects to
be managed by parent application. Requires a list of `AtrDetail`.
-}
state : Bool -> List AtrDetail -> ( State, Cmd Msg )
state isEditable atrDetails =
    ( State (StateConfig atrDetails True isEditable createTableState []), Cmd.none )


{-| Internal. Creates an initial Table.State to be saved in the configuration.
-}
createTableState : Table.State
createTableState =
    Table.init Nothing Nothing


{-| Adds a class to the `AtrTable`.
-}
withClass : String -> State -> State
withClass klass (State conf) =
    State { conf | classes = klass :: conf.classes }


{-| Represents the `AtrTable`'s `Msg`.
-}
type Msg
    = AtrDetailChanged AtrDetailType Year String
    | SortBy Table.State


{-| Updates the configuration of the Atr table.
Returns a tuple containing the new Config.
-}
update : Msg -> State -> ( State, Cmd Msg, List AtrDetail )
update msg (State stateConfig) =
    case msg of
        AtrDetailChanged atrType year value ->
            let
                updatedConf =
                    updateConfiguration atrType year value stateConfig
            in
            ( State updatedConf
            , Cmd.none
            , updatedConf.atrDetails
            )

        SortBy tableState ->
            let
                updatedConf =
                    updateTableState tableState stateConfig
            in
            ( State updatedConf
            , Cmd.none
            , updatedConf.atrDetails
            )


updateConfiguration : AtrDetailType -> Year -> String -> StateConfig -> StateConfig
updateConfiguration atrType year value configuration =
    { configuration
        | atrDetails =
            List.map
                (\(AtrDetail atrConfig) ->
                    if atrConfig.year == year then
                        updateAtrDetail atrType year value (AtrDetail atrConfig)

                    else
                        AtrDetail atrConfig
                )
                configuration.atrDetails
    }


updateTableState : Table.State -> StateConfig -> StateConfig
updateTableState tableState configuration =
    { configuration | tableState = tableState }


updateAtrDetail : AtrDetailType -> Year -> String -> AtrDetail -> AtrDetail
updateAtrDetail atrType _ value theAtrDetail =
    case atrType of
        Principale ->
            principale (Just value) theAtrDetail

        PrincipalePersone ->
            principalePersone (Just value) theAtrDetail

        PrincipaleCose ->
            principaleCose (Just value) theAtrDetail

        PrincipaleMista ->
            principaleMista (Just value) theAtrDetail

        Paritaria ->
            paritaria (Just value) theAtrDetail

        ParitariaPersone ->
            paritariaPersone (Just value) theAtrDetail

        ParitariaCose ->
            paritariaCose (Just value) theAtrDetail

        ParitariaMista ->
            paritariaMista (Just value) theAtrDetail


{-| Represents a detail for an `ATR` which contains information about
the number of accidents in a specific year.
-}
type AtrDetail
    = AtrDetail AtrDetailConfig


{-| Internal.
-}
type alias AtrDetailConfig =
    { year : Year
    , principale : Maybe String
    , principalePersone : Maybe String
    , principaleCose : Maybe String
    , principaleMista : Maybe String
    , paritaria : Maybe String
    , paritariaPersone : Maybe String
    , paritariaCose : Maybe String
    , paritariaMista : Maybe String
    }


{-| Creates an empty `AtrDetail`.
Each detail is identified by an year and representation of accidents occurred
during it. All setters methods are pipeable.
-}
atr : Int -> AtrDetail
atr year =
    AtrDetail (AtrDetailConfig year Nothing Nothing Nothing Nothing Nothing Nothing Nothing Nothing)


{-| Sets the `Responsabilità Principale` value for a specific `AtrDetail`.
-}
principale : Maybe String -> AtrDetail -> AtrDetail
principale maybeValue (AtrDetail atrConfig) =
    AtrDetail { atrConfig | principale = maybeValue }


{-| Sets the Responsabilità Principale Persone value for a specific `AtrDetail`.
-}
principalePersone : Maybe String -> AtrDetail -> AtrDetail
principalePersone maybeValue (AtrDetail atrConfig) =
    AtrDetail { atrConfig | principalePersone = maybeValue }


{-| Sets the Responsabilità Principale Cose value for a specific `AtrDetail`.
-}
principaleCose : Maybe String -> AtrDetail -> AtrDetail
principaleCose maybeValue (AtrDetail atrConfig) =
    AtrDetail { atrConfig | principaleCose = maybeValue }


{-| Sets the Responsabilità Principale Mista value for a specific `AtrDetail`.
-}
principaleMista : Maybe String -> AtrDetail -> AtrDetail
principaleMista maybeValue (AtrDetail atrConfig) =
    AtrDetail { atrConfig | principaleMista = maybeValue }


{-| Sets the Responsabilità Paritaria value for a specific `AtrDetail`.
-}
paritaria : Maybe String -> AtrDetail -> AtrDetail
paritaria maybeValue (AtrDetail atrConfig) =
    AtrDetail { atrConfig | paritaria = maybeValue }


{-| Sets the Responsabilità Paritaria Persone value for a specific `AtrDetail`.
-}
paritariaPersone : Maybe String -> AtrDetail -> AtrDetail
paritariaPersone maybeValue (AtrDetail atrConfig) =
    AtrDetail { atrConfig | paritariaPersone = maybeValue }


{-| Sets the Responsabilità Paritaria Cose value for a specific `AtrDetail`.
-}
paritariaCose : Maybe String -> AtrDetail -> AtrDetail
paritariaCose maybeValue (AtrDetail atrConfig) =
    AtrDetail { atrConfig | paritariaCose = maybeValue }


{-| Sets the Responsabilità Paritaria Mista value for a specific `AtrDetail`.
-}
paritariaMista : Maybe String -> AtrDetail -> AtrDetail
paritariaMista maybeValue (AtrDetail atrConfig) =
    AtrDetail { atrConfig | paritariaMista = maybeValue }


isLegacy : Year -> Bool
isLegacy year =
    year < 2015


type AtrDetailType
    = Principale
    | PrincipalePersone
    | PrincipaleCose
    | PrincipaleMista
    | Paritaria
    | ParitariaPersone
    | ParitariaCose
    | ParitariaMista


atrTypeToString : AtrDetailType -> String
atrTypeToString type_ =
    case type_ of
        Principale ->
            "Principale"

        PrincipalePersone ->
            "Persone"

        PrincipaleCose ->
            "Cose"

        PrincipaleMista ->
            "Mista"

        Paritaria ->
            "Paritaria"

        ParitariaPersone ->
            "Persone"

        ParitariaCose ->
            "Cose"

        ParitariaMista ->
            "Mista"


atrTypeExtractor : AtrDetailType -> (AtrDetailConfig -> Maybe String)
atrTypeExtractor type_ =
    case type_ of
        Principale ->
            .principale

        PrincipalePersone ->
            .principalePersone

        PrincipaleCose ->
            .principaleCose

        PrincipaleMista ->
            .principaleMista

        Paritaria ->
            .paritaria

        ParitariaPersone ->
            .paritariaPersone

        ParitariaCose ->
            .paritariaCose

        ParitariaMista ->
            .paritariaMista


atrSelectableOptions : List String
atrSelectableOptions =
    (List.map String.fromInt << List.range 0) 5 ++ [ "NA", "ND" ]


type alias Year =
    Int


{-| Renders the table by receiving a Configuration. The columns of this table are expressed by the length of the AtrDetail list.
-}
render : State -> Html Msg
render (State { atrDetails, alternateRows, isEditable, tableState, classes }) =
    let
        destructureAtrDetail (AtrDetail atrConfiguration) =
            atrConfiguration

        headers =
            (buildHeaders << List.map (String.fromInt << .year << destructureAtrDetail)) atrDetails

        tableConfig =
            Table.base False SortBy
                |> Table.withAlternateRows alternateRows
                |> H.flip (List.foldr Table.withClass) classes
                |> Table.addHeaders headers
                |> Table.addRows (buildRows isEditable atrDetails)
    in
    Table.render tableState tableConfig


buildHeaders : List String -> List (Table.Header Msg)
buildHeaders yearsOfAtrDetail =
    Table.header "" [ text "" ] :: List.map (\year -> Table.header year [ text year ]) yearsOfAtrDetail


buildRows : Bool -> List AtrDetail -> List (Table.Row Msg)
buildRows isEditable atrDetails =
    List.map
        (\atrType -> Table.row <| Table.columnString 1 (atrTypeToString atrType) :: List.map (buildColumn isEditable atrType) atrDetails)
        [ Principale
        , PrincipaleCose
        , PrincipalePersone
        , PrincipaleMista
        , Paritaria
        , ParitariaCose
        , ParitariaPersone
        , ParitariaMista
        ]


buildColumn : Bool -> AtrDetailType -> AtrDetail -> Table.Column Msg
buildColumn isEditable atrType atrDetail =
    (Table.columnHtml 1 << buildColumnContent isEditable atrType) atrDetail


buildColumnContent : Bool -> AtrDetailType -> AtrDetail -> List (Html Msg)
buildColumnContent isEditable atrType (AtrDetail atrConfig) =
    let
        atrDetailsAccidents =
            (Maybe.withDefault "" << atrTypeExtractor atrType) atrConfig
    in
    case ( atrType, isEditable, isLegacy atrConfig.year ) of
        ( Principale, True, True ) ->
            [ buildSelect atrType atrConfig ]

        ( Principale, False, True ) ->
            [ text atrDetailsAccidents ]

        ( Paritaria, True, True ) ->
            [ buildSelect atrType atrConfig ]

        ( Paritaria, False, True ) ->
            [ text atrDetailsAccidents ]

        ( Principale, _, False ) ->
            [ (text << String.fromInt << calculateTotalAccidents atrConfig) [ PrincipalePersone, PrincipaleCose, PrincipaleMista ] ]

        ( Paritaria, _, False ) ->
            [ (text << String.fromInt << calculateTotalAccidents atrConfig) [ ParitariaPersone, ParitariaCose, ParitariaMista ] ]

        ( _, _, True ) ->
            [ text "--" ]

        ( _, True, _ ) ->
            [ buildSelect atrType atrConfig ]

        ( _, False, _ ) ->
            [ text atrDetailsAccidents ]


buildSelect : AtrDetailType -> AtrDetailConfig -> Html Msg
buildSelect atrType ({ year } as atrConfig) =
    select
        [ (onInput << AtrDetailChanged atrType) year ]
        (List.map (buildSelectOption atrType atrConfig) atrSelectableOptions)


buildSelectOption : AtrDetailType -> AtrDetailConfig -> String -> Html Msg
buildSelectOption atrType atrConfig optionValue =
    let
        atrDetailsAccidents =
            atrTypeExtractor atrType atrConfig
    in
    option
        [ value optionValue
        , (selected << Maybe.withDefault False << Maybe.map ((==) optionValue)) atrDetailsAccidents
        ]
        [ text optionValue
        ]


calculateTotalAccidents : AtrDetailConfig -> List AtrDetailType -> Int
calculateTotalAccidents atrConfig atrTypes =
    atrTypes
        |> List.filterMap
            (\atrType ->
                atrConfig
                    |> atrTypeExtractor atrType
                    |> Maybe.andThen String.toInt
            )
        |> List.sum
