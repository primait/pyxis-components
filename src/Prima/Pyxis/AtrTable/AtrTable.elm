module Prima.Pyxis.AtrTable.AtrTable exposing
    ( Atr
    , Config
    , Msg
    , atr
    , init
    , render
    , setEqual
    , setEqualMixed
    , setEqualObjects
    , setEqualPeople
    , setMain
    , setMainMixed
    , setMainObjects
    , setMainPeople
    , update
    )

import Html exposing (Html, option, select, text)
import Html.Attributes exposing (class, classList, selected, value)
import Html.Events exposing (onInput)
import Prima.Pyxis.Table.Table as Table


type Config
    = Config Configuration


type alias Configuration =
    { atrDetails : List Atr
    , alternateRows : Bool
    , isSortable : Bool
    }


init : List Atr -> ( Config, Cmd Msg )
init atrDetails =
    ( Config (Configuration atrDetails False False), Cmd.none )


type Msg
    = AtrChanged AtrType Year String
    | NoOpSort String


update : Msg -> Config -> ( Config, Cmd Msg, List Atr )
update msg (Config configuration) =
    case msg of
        AtrChanged atrType year value ->
            let  
                updatedConf = 
                    updateConfiguration atrType year value configuration
            in 
            ( Config updatedConf 
            , Cmd.none
            , updatedConf.atrDetails
            )

        NoOpSort _ ->
            ( Config configuration, Cmd.none, configuration.atrDetails )


updateConfiguration : AtrType -> Year -> String -> Configuration -> Configuration
updateConfiguration atrType year value configuration =
    { configuration
        | atrDetails =
            List.map
                (\(Atr atrConfig) ->
                    if atrConfig.year == year then
                        updateAtr atrType year value (Atr atrConfig)

                    else
                        Atr atrConfig
                )
                configuration.atrDetails
    }


updateAtr : AtrType -> Year -> String -> Atr -> Atr
updateAtr atrType year value theAtr =
    case atrType of
        Main ->
            setMain (Just value) theAtr

        MainPeople ->
            setMainPeople (Just value) theAtr

        MainObjects ->
            setMainObjects (Just value) theAtr

        MainMixed ->
            setMainMixed (Just value) theAtr

        Equal ->
            setEqual (Just value) theAtr

        EqualPeople ->
            setEqualPeople (Just value) theAtr

        EqualObjects ->
            setEqualObjects (Just value) theAtr

        EqualMixed ->
            setEqualMixed (Just value) theAtr


type Atr
    = Atr AtrConfiguration


type alias AtrConfiguration =
    { year : Year
    , main : Maybe String
    , mainPeople : Maybe String
    , mainObjects : Maybe String
    , mainMixed : Maybe String
    , equal : Maybe String
    , equalPeople : Maybe String
    , equalObjects : Maybe String
    , equalMixed : Maybe String
    }


atr : Int -> Atr
atr year =
    Atr (AtrConfiguration year Nothing Nothing Nothing Nothing Nothing Nothing Nothing Nothing)


isLegacy : Year -> Bool
isLegacy year =
    year < 2015


setMain : Maybe String -> Atr -> Atr
setMain maybeValue (Atr atrConfig) =
    Atr { atrConfig | main = maybeValue }


setMainPeople : Maybe String -> Atr -> Atr
setMainPeople maybeValue (Atr atrConfig) =
    Atr { atrConfig | mainPeople = maybeValue }


setMainObjects : Maybe String -> Atr -> Atr
setMainObjects maybeValue (Atr atrConfig) =
    Atr { atrConfig | mainObjects = maybeValue }


setMainMixed : Maybe String -> Atr -> Atr
setMainMixed maybeValue (Atr atrConfig) =
    Atr { atrConfig | mainMixed = maybeValue }


setEqual : Maybe String -> Atr -> Atr
setEqual maybeValue (Atr atrConfig) =
    Atr { atrConfig | equal = maybeValue }


setEqualPeople : Maybe String -> Atr -> Atr
setEqualPeople maybeValue (Atr atrConfig) =
    Atr { atrConfig | equalPeople = maybeValue }


setEqualObjects : Maybe String -> Atr -> Atr
setEqualObjects maybeValue (Atr atrConfig) =
    Atr { atrConfig | equalObjects = maybeValue }


setEqualMixed : Maybe String -> Atr -> Atr
setEqualMixed maybeValue (Atr atrConfig) =
    Atr { atrConfig | equalMixed = maybeValue }


type AtrType
    = Main
    | MainPeople
    | MainObjects
    | MainMixed
    | Equal
    | EqualPeople
    | EqualObjects
    | EqualMixed


atrTypeToString : AtrType -> String
atrTypeToString type_ =
    case type_ of
        Main ->
            "Principale"

        MainPeople ->
            "Persone"

        MainObjects ->
            "Cose"

        MainMixed ->
            "Misto"

        Equal ->
            "Paritaria"

        EqualPeople ->
            "Persone"

        EqualObjects ->
            "Cose"

        EqualMixed ->
            "Misto"


atrTypeExtractor : AtrType -> (AtrConfiguration -> Maybe String)
atrTypeExtractor type_ =
    case type_ of
        Main ->
            .main

        MainPeople ->
            .mainPeople

        MainObjects ->
            .mainObjects

        MainMixed ->
            .mainMixed

        Equal ->
            .equal

        EqualPeople ->
            .equalPeople

        EqualObjects ->
            .equalObjects

        EqualMixed ->
            .equalMixed


atrSelectableOptions : List String
atrSelectableOptions =
    (List.map String.fromInt << List.range 0) 5 ++ [ "NA", "ND" ]


type alias Year =
    Int


render : Config -> Html Msg
render (Config ({ atrDetails, alternateRows, isSortable } as config)) =
    let
        destructureAtr (Atr atrConfiguration) =
            atrConfiguration

        headers =
            (buildHeaders << List.map (String.fromInt << .year << destructureAtr)) atrDetails

        rows =
            buildRows atrDetails
    in
    Table.render Table.initialState <| Table.config headers rows alternateRows isSortable


buildHeaders : List String -> List (Table.Header Msg)
buildHeaders yearsOfAtr =
    Table.header "" "" NoOpSort :: List.map (\year -> Table.header year year NoOpSort) yearsOfAtr


buildRows : List Atr -> List (Table.Row Msg)
buildRows atrDetails =
    List.map
        (\atrType -> Table.row <| Table.columnString (atrTypeToString atrType) :: List.map (buildColumn atrType) atrDetails)
        [ Main
        , MainObjects
        , MainPeople
        , MainMixed
        , Equal
        , EqualObjects
        , EqualPeople
        , EqualMixed
        ]


buildColumn : AtrType -> Atr -> Table.Column Msg
buildColumn atrType atrDetail =
    (Table.columnHtml << buildColumnContent atrType) atrDetail


buildColumnContent : AtrType -> Atr -> List (Html Msg)
buildColumnContent atrType (Atr atrConfig) =
    case ( atrType, isLegacy atrConfig.year ) of
        ( Main, True ) ->
            [ buildSelect atrType atrConfig ]

        ( Equal, True ) ->
            [ buildSelect atrType atrConfig ]

        ( Main, False ) ->
            [ (text << String.fromInt << calculateTotalAccidents atrConfig) [ MainPeople, MainObjects, MainMixed ] ]

        ( Equal, False ) ->
            [ (text << String.fromInt << calculateTotalAccidents atrConfig) [ EqualPeople, EqualObjects, EqualMixed ] ]

        ( _, True ) ->
            [ text "--" ]

        ( _, _ ) ->
            [ buildSelect atrType atrConfig ]


buildSelect : AtrType -> AtrConfiguration -> Html Msg
buildSelect atrType ({ year } as atrConfig) =
    select
        [ (onInput << AtrChanged atrType) year ]
        (List.map (buildSelectOption atrType atrConfig) atrSelectableOptions)


buildSelectOption : AtrType -> AtrConfiguration -> String -> Html Msg
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


calculateTotalAccidents : AtrConfiguration -> List AtrType -> Int
calculateTotalAccidents atrConfig atrTypes =
    atrTypes
        |> List.filterMap
            (\atrType ->
                atrConfig
                    |> atrTypeExtractor atrType
                    |> Maybe.andThen String.toInt
            )
        |> List.sum
