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

import Html exposing (Html, text)
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
    = AtrChanged AtrType Year
    | NoOpSort String


update : Msg -> Config -> ( Config, Cmd Msg )
update msg config =
    case msg of
        AtrChanged atrType year ->
            ( config, Cmd.none )

        NoOpSort _ ->
            ( config, Cmd.none )


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
buildColumn atrType (Atr atrConfig) =
    let
        extractor =
            atrTypeExtractor atrType
    in
    (Table.columnHtml << List.singleton << text << Maybe.withDefault "-" << extractor) atrConfig
