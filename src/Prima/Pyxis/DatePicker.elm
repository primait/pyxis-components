module Prima.Pyxis.DatePicker exposing (init, Model, Msg(..), update, view, selectedDate)

{-|

@docs init, Model, Msg, update, view, selectedDate

-}

import Date exposing (Date)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Time exposing (Month(..), Weekday(..))


{-| -}
type alias Model =
    { date : Date
    , selectingYear : Bool
    , daysPickerRange : ( Date, Date )
    }


{-| Get initial time picker model
-}
init : Date -> ( Date, Date ) -> Model
init date daysRange =
    { date = adjustInitialDate date daysRange
    , selectingYear = False
    , daysPickerRange = daysRange
    }


{-| Returns currently selected date
-}
selectedDate : Model -> Date
selectedDate model =
    model.date


adjustInitialDate : Date -> ( Date, Date ) -> Date
adjustInitialDate day ( low, high ) =
    if Date.isBetween low high day then
        day

    else
        low


formattedDay : Model -> String
formattedDay =
    Date.format "EEEE, d MMMM" << .date


formattedMonth : Model -> String
formattedMonth =
    Date.format "MMMM y" << .date


{-| -}
type Msg
    = Noop
    | YearSelection
    | DaySelection
    | PrevMonth
    | NextMonth
    | SelectYear Int
    | SelectDay Int


{-| -}
update : Msg -> Model -> Model
update msg model =
    case msg of
        Noop ->
            model

        YearSelection ->
            { model | selectingYear = True }

        DaySelection ->
            { model | selectingYear = False }

        PrevMonth ->
            shiftToPreviousMonth model

        NextMonth ->
            shiftToNextMonth model

        SelectYear year ->
            updateSelectedYear year model

        SelectDay day ->
            updateSelectedDay day model


fromDateRangeToList : List Date -> ( Date, Date ) -> List Date
fromDateRangeToList dates ( low, high ) =
    let
        newDate : Date
        newDate =
            Date.fromCalendarDate (Date.year low) (Date.month low) (Date.day low + 1)
    in
    if Date.compare low high == EQ then
        low :: dates

    else
        fromDateRangeToList (low :: dates) ( newDate, high )


updateSelectedYear : Int -> Model -> Model
updateSelectedYear year model =
    let
        newDate : Date
        newDate =
            Date.fromCalendarDate year (Date.month model.date) (Date.day model.date)
    in
    updateModelIfValid ValidMonth newDate model


shiftToPreviousMonth : Model -> Model
shiftToPreviousMonth model =
    let
        newDate : Date
        newDate =
            Date.fromCalendarDate (Date.year model.date) (prevMonth <| Date.month model.date) (Date.day model.date)
    in
    updateModelIfValid ValidMonth newDate model


shiftToNextMonth : Model -> Model
shiftToNextMonth model =
    let
        ( newMonth, newYear ) =
            nextMonth (Date.month model.date) (Date.year model.date)

        newDate : Date
        newDate =
            Date.fromCalendarDate newYear newMonth (Date.day model.date)
    in
    updateModelIfValid ValidMonth newDate model


updateSelectedDay : Int -> Model -> Model
updateSelectedDay day model =
    let
        newDate : Date
        newDate =
            Date.fromCalendarDate (Date.year model.date) (Date.month model.date) day
    in
    updateModelIfValid ValidDay newDate model


type ValidityCheck
    = ValidDay
    | ValidMonth


updateModelIfValid : ValidityCheck -> Date -> Model -> Model
updateModelIfValid validityCheck newDate model =
    let
        ( low_, high_ ) =
            model.daysPickerRange

        ( low, high ) =
            case validityCheck of
                ValidDay ->
                    ( low_, high_ )

                ValidMonth ->
                    ( Date.fromCalendarDate (Date.year low_) (Date.month low_) 1, updateToLastDayOfMonth high_ )
    in
    if Date.isBetween low high newDate then
        { model | date = newDate }

    else
        model


{-| -}
view : Model -> Html Msg
view ({ selectingYear } as model) =
    div
        [ class "a-datepicker" ]
        [ header model
        , if selectingYear then
            yearPicker model

          else
            picker model
        ]


header : Model -> Html Msg
header ({ date, selectingYear } as model) =
    div
        [ class "a-datepicker__header"
        ]
        [ div
            [ classList
                [ ( "a-datepicker__header__year", True )
                , ( "is-selected", selectingYear )
                ]
            , onClick
                (if selectingYear then
                    DaySelection

                 else
                    YearSelection
                )
            ]
            [ (text << String.fromInt << Date.year) date
            ]
        , div
            [ classList
                [ ( "a-datepicker__header__day", True )
                , ( "is-selected", not selectingYear )
                ]
            , onClick DaySelection
            ]
            [ (text << formattedDay) model
            ]
        ]


weekDays : Html Msg
weekDays =
    div
        [ class "a-datepicker__picker__weekDays" ]
        (List.map
            (\day ->
                span [] [ text day ]
            )
            [ "Lun", "Mar", "Mer", "Gio", "Ven", "Sab", "Dom" ]
        )


monthDays : Model -> Html Msg
monthDays ({ date, daysPickerRange } as model) =
    let
        currentYear : Int
        currentYear =
            Date.year date

        currentMonth : Month
        currentMonth =
            Date.month date

        ( lowDate, highDate ) =
            daysPickerRange

        daysCount : Int
        daysCount =
            getDaysInMonth currentYear currentMonth

        firstDayOfMonth : Date
        firstDayOfMonth =
            Date.fromCalendarDate (Date.year model.date) (Date.month model.date) 1

        weekDay : Int
        weekDay =
            firstDayOfMonth
                |> Date.weekday
                |> Date.weekdayToNumber

        leftPadding =
            weekDay - 1

        rightPadding =
            35 - daysCount - leftPadding

        weeks =
            chunks 7 (List.repeat leftPadding 0 ++ List.range 1 daysCount ++ List.repeat rightPadding 0)

        firstOfMonth : Date
        firstOfMonth =
            Date.fromCalendarDate (Date.year model.date) (Date.month model.date) 1

        lastOfMonth : Date
        lastOfMonth =
            Date.fromCalendarDate (Date.year model.date) (Date.month model.date) 31

        lowDayInMonth =
            if Date.compare firstOfMonth lowDate == LT then
                lowDate

            else
                firstOfMonth

        highDayInMonth =
            if Date.compare highDate lastOfMonth == LT then
                highDate

            else
                lastOfMonth

        availableDays =
            (List.map Date.day << List.reverse << fromDateRangeToList []) ( lowDayInMonth, highDayInMonth )

        disabledDaysInMonth =
            (List.filter (not << (\a -> List.member a availableDays)) << List.range 1) daysCount
    in
    div
        [ class "a-datepicker__picker__monthDays"
        ]
        (List.map (\week -> weekRow week (Date.day date) disabledDaysInMonth) weeks)


weekRow : List Int -> Int -> List Int -> Html Msg
weekRow days currentDay disabledDays =
    div
        [ class "a-datepicker__picker__days" ]
        (List.map (\day -> dayCell day currentDay (List.member day disabledDays)) days)


dayCell : Int -> Int -> Bool -> Html Msg
dayCell dayNumber currentDay disabled =
    if dayNumber > 0 then
        div
            [ classList
                [ ( "a-datepicker__picker__days__item", True )
                , ( "is-selected", dayNumber == currentDay )
                , ( "is-disabled", disabled )
                ]
            , (onClick << SelectDay) dayNumber
            ]
            [ (text << String.fromInt) dayNumber
            ]

    else
        div
            [ class "a-datepicker__picker__days__item is-empty" ]
            []


picker : Model -> Html Msg
picker model =
    div
        [ class "a-datepicker__picker" ]
        [ div
            [ class "a-datepicker__picker__header" ]
            [ span
                [ class "a-datepicker__picker__header__prevMonth", onClick PrevMonth ]
                []
            , div
                [ class "a-datepicker__picker__header__currentMonth" ]
                [ (text << formattedMonth) model
                ]
            , span
                [ class "a-datepicker__picker__header__nextMonth", onClick NextMonth ]
                []
            ]
        , weekDays
        , monthDays model
        ]


yearPicker : Model -> Html Msg
yearPicker ({ daysPickerRange } as model) =
    let
        ( lowerBound, upperBound ) =
            daysPickerRange
    in
    div
        [ class "a-datepicker__yearPicker" ]
        [ div
            [ class "a-datepicker__yearPicker__scroller" ]
            [ div
                [ class "a-datepicker__yearPicker__scroller__list" ]
                (List.map (\y -> yearButton y (Date.year model.date)) <| List.range (Date.year lowerBound) (Date.year upperBound))
            ]
        ]


yearButton : Int -> Int -> Html Msg
yearButton year currentYear =
    span
        [ classList
            [ ( "a-datepicker__yearPicker__scroller__list__item", True )
            , ( "is-selected", year == currentYear )
            ]
        , (onClick << SelectYear) year
        ]
        [ (text << String.fromInt) year
        ]


chunks : Int -> List a -> List (List a)
chunks k xs =
    if List.length xs > k then
        List.take k xs :: chunks k (List.drop k xs)

    else
        [ xs ]


formatDay : Weekday -> String
formatDay day =
    case day of
        Mon ->
            "Lunedì"

        Tue ->
            "Martedì"

        Wed ->
            "Mercoledì"

        Thu ->
            "Giovedì"

        Fri ->
            "Venerdì"

        Sat ->
            "Sabato"

        Sun ->
            "Domenica"


formatMonth : Month -> String
formatMonth month =
    case month of
        Jan ->
            "Gennaio"

        Feb ->
            "Febbraio"

        Mar ->
            "Marzo"

        Apr ->
            "Aprile"

        May ->
            "Maggio"

        Jun ->
            "Giugno"

        Jul ->
            "Luglio"

        Aug ->
            "Agosto"

        Sep ->
            "Settembre"

        Oct ->
            "Ottobre"

        Nov ->
            "Novembre"

        Dec ->
            "Dicembre"


nextMonth : Month -> Int -> ( Month, Int )
nextMonth month year =
    case month of
        Jan ->
            ( Feb, year )

        Feb ->
            ( Mar, year )

        Mar ->
            ( Apr, year )

        Apr ->
            ( May, year )

        May ->
            ( Jun, year )

        Jun ->
            ( Jul, year )

        Jul ->
            ( Aug, year )

        Aug ->
            ( Sep, year )

        Sep ->
            ( Oct, year )

        Oct ->
            ( Nov, year )

        Nov ->
            ( Dec, year )

        Dec ->
            ( Jan, year + 1 )


prevMonth : Month -> Month
prevMonth month =
    case month of
        Jan ->
            Dec

        Feb ->
            Jan

        Mar ->
            Feb

        Apr ->
            Mar

        May ->
            Apr

        Jun ->
            May

        Jul ->
            Jun

        Aug ->
            Jul

        Sep ->
            Aug

        Oct ->
            Sep

        Nov ->
            Oct

        Dec ->
            Nov


getDaysInMonth : Int -> Month -> Int
getDaysInMonth year month =
    case month of
        Jan ->
            31

        Feb ->
            if isLeapYear year then
                28

            else
                29

        Mar ->
            31

        Apr ->
            30

        May ->
            31

        Jun ->
            30

        Jul ->
            31

        Aug ->
            31

        Sep ->
            30

        Oct ->
            31

        Nov ->
            30

        Dec ->
            31


isLeapYear : Int -> Bool
isLeapYear year =
    remainderBy year 4 == 0 && (remainderBy year 100 /= 0 || remainderBy year 400 == 0)


updateToLastDayOfMonth : Date -> Date
updateToLastDayOfMonth date =
    Date.fromCalendarDate (Date.year date) (Date.month date) (getDaysInMonth (Date.year date) (Date.month date))
