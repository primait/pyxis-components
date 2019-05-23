module Main exposing (Model, Msg(..), initialModel, main, update, view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Prima.Pyxis.Helpers as Helpers
import Prima.Pyxis.Tables.Tables as Tables


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel, Cmd.none )


type alias Model =
    { headers : List String
    , rows : List (List String)
    , tableState : Tables.State
    , sortByColumn : Maybe String
    , sortBy : Maybe Sort
    }


initialModel : Model
initialModel =
    Model
        [ "Nazione", "Capitale" ]
        [ [ "Italia", "Roma" ], [ "Francia", "Parigi" ], [ "UK", "Londra" ], [ "Russia", "Mosca" ], [ "Spagna", "Madrid" ] ]
        Tables.initialState
        Nothing
        Nothing


type Msg
    = Table
    | SortBy String


type Sort
    = Asc
    | Desc


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "Update " msg of
        Table ->
            ( model, Cmd.none )

        SortBy headerSlug ->
            let
                ( sortAlgorithm, sortFn ) =
                    case model.sortBy of
                        Nothing ->
                            ( Just Asc, Tables.sortByAsc )

                        Just Asc ->
                            ( Just Desc, Tables.sortByDesc )

                        Just Desc ->
                            ( Nothing, Tables.sortByNothing )
            in
            ( { model
                | sortBy = sortAlgorithm
                , tableState = sortFn headerSlug model.tableState
              }
            , Cmd.none
            )


view : Model -> Browser.Document Msg
view model =
    { title = "Table"
    , body =
        [ Helpers.pyxisStyle
        , Tables.render model.tableState <| createTableConfiguration model
        ]
    }


createTableConfiguration : Model -> Tables.Config Msg
createTableConfiguration model =
    Tables.config
        (createHeaders model.headers)
        (createRows model.rows)
        True
        False


createHeaders : List String -> List (Tables.Header Msg)
createHeaders headers =
    List.map (\h -> Tables.header (String.toLower h) h SortBy) headers


createRows : List (List String) -> List (Tables.Row Msg)
createRows rows =
    List.map (\r -> Tables.row <| createColumns r) rows


createColumns : List String -> List (Tables.Column Msg)
createColumns columns =
    List.map (\c -> Tables.columnString c) columns
