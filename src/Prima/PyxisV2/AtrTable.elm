module Prima.PyxisV2.AtrTable exposing
    ( Config, AtrDetail, Msg
    , init, atr, update
    , paritaria, paritariaMista, paritariaCose, paritariaPersone, principale, principaleMista, principaleCose, principalePersone
    , render
    )

{-| Creates a specific kind of table, the ATR table component.
Uses Prima.PyxisV2.Table.Table under the hood.

Warning. This documentation requires knownledge of Insurance domain.


# Configuration

@docs Config, AtrDetail, Msg


# Configuration Helpers

@docs init, atr, update


# Helpers

@docs paritaria, paritariaMista, paritariaCose, paritariaPersone, principale, principaleMista, principaleCose, principalePersone


# Render

@docs render

-}

import Html exposing (Html, option, select, text)
import Html.Attributes exposing (class, classList, selected, value)
import Html.Events exposing (onInput)
import Prima.PyxisV2.Table as Table


{-| Defines the configuration of an Atr table
-}
type Config
    = Config Configuration


type alias Configuration =
    { atrDetails : List AtrDetail
    , alternateRows : Bool
    , isEditable : Bool
    , tableClassList : List ( String, Bool )
    }


{-| Returns a Tuple containing the Config and a possible batch of side effects to
be managed by parent application. Requires a list of AtrDetail.
-}
init : Bool -> List ( String, Bool ) -> List AtrDetail -> ( Config, Cmd Msg )
init isEditable tableClassList atrDetails =
    ( Config (Configuration atrDetails True isEditable tableClassList), Cmd.none )


{-| Represents a changing AtrDetail action
-}
type Msg
    = AtrDetailChanged AtrDetailType Year String


{-| Updates the configuration of the Atr table.
Returns a tuple containing the new Config.
-}
update : Msg -> Config -> ( Config, Cmd Msg, List AtrDetail )
update msg (Config configuration) =
    case msg of
        AtrDetailChanged atrType year value ->
            let
                updatedConf =
                    updateConfiguration atrType year value configuration
            in
            ( Config updatedConf
            , Cmd.none
            , updatedConf.atrDetails
            )


updateConfiguration : AtrDetailType -> Year -> String -> Configuration -> Configuration
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


updateAtrDetail : AtrDetailType -> Year -> String -> AtrDetail -> AtrDetail
updateAtrDetail atrType year value theAtrDetail =
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


{-| Represents a detail for an ATR which contains information about
the number of accidents in a specific year.
-}
type AtrDetail
    = AtrDetail AtrDetailConfiguration


type alias AtrDetailConfiguration =
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


{-| Creates an empty AtrDetail. Each detail is identified by an year and representation of accidents occurred
during it. All setters methods are pipeable.
-}
atr : Int -> AtrDetail
atr year =
    AtrDetail (AtrDetailConfiguration year Nothing Nothing Nothing Nothing Nothing Nothing Nothing Nothing)


{-| Sets the Responsabilità Principale value for a specific AtrDetail.
-}
principale : Maybe String -> AtrDetail -> AtrDetail
principale maybeValue (AtrDetail atrConfig) =
    AtrDetail { atrConfig | principale = maybeValue }


{-| Sets the Responsabilità Principale Persone value for a specific AtrDetail.
-}
principalePersone : Maybe String -> AtrDetail -> AtrDetail
principalePersone maybeValue (AtrDetail atrConfig) =
    AtrDetail { atrConfig | principalePersone = maybeValue }


{-| Sets the Responsabilità Principale Cose value for a specific AtrDetail.
-}
principaleCose : Maybe String -> AtrDetail -> AtrDetail
principaleCose maybeValue (AtrDetail atrConfig) =
    AtrDetail { atrConfig | principaleCose = maybeValue }


{-| Sets the Responsabilità Principale Mista value for a specific AtrDetail.
-}
principaleMista : Maybe String -> AtrDetail -> AtrDetail
principaleMista maybeValue (AtrDetail atrConfig) =
    AtrDetail { atrConfig | principaleMista = maybeValue }


{-| Sets the Responsabilità Paritaria value for a specific AtrDetail.
-}
paritaria : Maybe String -> AtrDetail -> AtrDetail
paritaria maybeValue (AtrDetail atrConfig) =
    AtrDetail { atrConfig | paritaria = maybeValue }


{-| Sets the Responsabilità Paritaria Persone value for a specific AtrDetail.
-}
paritariaPersone : Maybe String -> AtrDetail -> AtrDetail
paritariaPersone maybeValue (AtrDetail atrConfig) =
    AtrDetail { atrConfig | paritariaPersone = maybeValue }


{-| Sets the Responsabilità Paritaria Cose value for a specific AtrDetail.
-}
paritariaCose : Maybe String -> AtrDetail -> AtrDetail
paritariaCose maybeValue (AtrDetail atrConfig) =
    AtrDetail { atrConfig | paritariaCose = maybeValue }


{-| Sets the Responsabilità Paritaria Mista value for a specific AtrDetail.
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


atrTypeExtractor : AtrDetailType -> (AtrDetailConfiguration -> Maybe String)
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
render : Config -> Html Msg
render (Config ({ atrDetails, alternateRows, isEditable, tableClassList } as config)) =
    let
        destructureAtrDetail (AtrDetail atrConfiguration) =
            atrConfiguration

        headers =
            (buildHeaders << List.map (String.fromInt << .year << destructureAtrDetail)) atrDetails

        rows =
            buildRows isEditable atrDetails
    in
    Table.render (Table.initialState Nothing Nothing) <| Table.config Table.defaultType True headers rows alternateRows [] tableClassList


buildHeaders : List String -> List (Table.Header Msg)
buildHeaders yearsOfAtrDetail =
    Table.header "" "" Nothing :: List.map (\year -> Table.header year year Nothing) yearsOfAtrDetail


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


buildSelect : AtrDetailType -> AtrDetailConfiguration -> Html Msg
buildSelect atrType ({ year } as atrConfig) =
    select
        [ (onInput << AtrDetailChanged atrType) year ]
        (List.map (buildSelectOption atrType atrConfig) atrSelectableOptions)


buildSelectOption : AtrDetailType -> AtrDetailConfiguration -> String -> Html Msg
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


calculateTotalAccidents : AtrDetailConfiguration -> List AtrDetailType -> Int
calculateTotalAccidents atrConfig atrTypes =
    atrTypes
        |> List.filterMap
            (\atrType ->
                atrConfig
                    |> atrTypeExtractor atrType
                    |> Maybe.andThen String.toInt
            )
        |> List.sum
