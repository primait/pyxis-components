module Prima.Pyxis.AtrTable.AtrTable exposing
    ( AtrDetail
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
    { atrDetails : List AtrDetail
    , alternateRows : Bool
    , isSortable : Bool
    }


init : List AtrDetail -> ( Config, Cmd Msg )
init atrDetails =
    ( Config (Configuration atrDetails False False), Cmd.none )


type Msg
    = AtrDetailChanged AtrDetailType Year String
    | NoOpSort String


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

        NoOpSort _ ->
            ( Config configuration, Cmd.none, configuration.atrDetails )


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
        Main ->
            setMain (Just value) theAtrDetail

        MainPeople ->
            setMainPeople (Just value) theAtrDetail

        MainObjects ->
            setMainObjects (Just value) theAtrDetail

        MainMixed ->
            setMainMixed (Just value) theAtrDetail

        Equal ->
            setEqual (Just value) theAtrDetail

        EqualPeople ->
            setEqualPeople (Just value) theAtrDetail

        EqualObjects ->
            setEqualObjects (Just value) theAtrDetail

        EqualMixed ->
            setEqualMixed (Just value) theAtrDetail


type AtrDetail
    = AtrDetail AtrDetailConfiguration


type alias AtrDetailConfiguration =
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


atr : Int -> AtrDetail
atr year =
    AtrDetail (AtrDetailConfiguration year Nothing Nothing Nothing Nothing Nothing Nothing Nothing Nothing)


isLegacy : Year -> Bool
isLegacy year =
    year < 2015


setMain : Maybe String -> AtrDetail -> AtrDetail
setMain maybeValue (AtrDetail atrConfig) =
    AtrDetail { atrConfig | main = maybeValue }


setMainPeople : Maybe String -> AtrDetail -> AtrDetail
setMainPeople maybeValue (AtrDetail atrConfig) =
    AtrDetail { atrConfig | mainPeople = maybeValue }


setMainObjects : Maybe String -> AtrDetail -> AtrDetail
setMainObjects maybeValue (AtrDetail atrConfig) =
    AtrDetail { atrConfig | mainObjects = maybeValue }


setMainMixed : Maybe String -> AtrDetail -> AtrDetail
setMainMixed maybeValue (AtrDetail atrConfig) =
    AtrDetail { atrConfig | mainMixed = maybeValue }


setEqual : Maybe String -> AtrDetail -> AtrDetail
setEqual maybeValue (AtrDetail atrConfig) =
    AtrDetail { atrConfig | equal = maybeValue }


setEqualPeople : Maybe String -> AtrDetail -> AtrDetail
setEqualPeople maybeValue (AtrDetail atrConfig) =
    AtrDetail { atrConfig | equalPeople = maybeValue }


setEqualObjects : Maybe String -> AtrDetail -> AtrDetail
setEqualObjects maybeValue (AtrDetail atrConfig) =
    AtrDetail { atrConfig | equalObjects = maybeValue }


setEqualMixed : Maybe String -> AtrDetail -> AtrDetail
setEqualMixed maybeValue (AtrDetail atrConfig) =
    AtrDetail { atrConfig | equalMixed = maybeValue }


type AtrDetailType
    = Main
    | MainPeople
    | MainObjects
    | MainMixed
    | Equal
    | EqualPeople
    | EqualObjects
    | EqualMixed


atrTypeToString : AtrDetailType -> String
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


atrTypeExtractor : AtrDetailType -> (AtrDetailConfiguration -> Maybe String)
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
        destructureAtrDetail (AtrDetail atrConfiguration) =
            atrConfiguration

        headers =
            (buildHeaders << List.map (String.fromInt << .year << destructureAtrDetail)) atrDetails

        rows =
            buildRows atrDetails
    in
    Table.render Table.initialState <| Table.config headers rows alternateRows isSortable


buildHeaders : List String -> List (Table.Header Msg)
buildHeaders yearsOfAtrDetail =
    Table.header "" "" NoOpSort :: List.map (\year -> Table.header year year NoOpSort) yearsOfAtrDetail


buildRows : List AtrDetail -> List (Table.Row Msg)
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


buildColumn : AtrDetailType -> AtrDetail -> Table.Column Msg
buildColumn atrType atrDetail =
    (Table.columnHtml << buildColumnContent atrType) atrDetail


buildColumnContent : AtrDetailType -> AtrDetail -> List (Html Msg)
buildColumnContent atrType (AtrDetail atrConfig) =
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
