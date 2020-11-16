module Prima.Pyxis.Form.DatePicker exposing
    ( Model, Msg(..), Date(..)
    , init, update
    , render
    , selectedDate, setDate
    , isParsedDate, isPartialDate, toMaybeDate
    )

{-|


## Configuration

@docs Model, Msg, Date


## Configuration Methods

@docs init, update


## Rendering

@docs render


## Methods

@docs selectedDate, setDate

-}

import Date
import Html exposing (Html)
import Html.Attributes as Attrs
import Prima.Pyxis.Helpers as H
import Time exposing (Month(..), Weekday(..))


{-| Represents the `DatePicker`'s `Model`.
-}
type alias Model =
    { date : Date.Date
    , selectingYear : Bool
    , daysPickerRange : ( Date.Date, Date.Date )
    }


{-| Represents a Date. It can be a valid one (ParsedDate Date.Date) or a partial
-}
type Date
    = ParsedDate Date.Date
    | PartialDate (Maybe String)


{-| Get initial time picker model
-}
init : Date.Date -> ( Date.Date, Date.Date ) -> Model
init date daysRange =
    { date = adjustInitialDate date daysRange
    , selectingYear = False
    , daysPickerRange = daysRange
    }


{-| Returns currently selected date
-}
selectedDate : Model -> Date
selectedDate model =
    ParsedDate model.date


{-| Selects a valid Date into the DatePicker
-}
setDate : Date.Date -> Model -> Model
setDate date model =
    model
        |> updateModelIfValid ValidDay date
        |> updateModelIfValid ValidMonth date


adjustInitialDate : Date.Date -> ( Date.Date, Date.Date ) -> Date.Date
adjustInitialDate day ( low, high ) =
    if Date.isBetween low high day then
        day

    else
        low


formattedDay : Model -> String
formattedDay =
    Date.formatWithLanguage italianLanguage "EEEE, d MMMM" << .date


formattedMonth : Model -> String
formattedMonth =
    Date.formatWithLanguage italianLanguage "MMMM y" << .date


{-| The DatePicker message
-}
type Msg
    = Noop
    | YearSelection
    | DaySelection
    | PrevMonth
    | NextMonth
    | SelectYear Int
    | SelectDay Int
    | SelectDate Date.Date


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
            updateSelectedYear year { model | selectingYear = False }

        SelectDay day ->
            updateSelectedDay day model

        SelectDate date ->
            setDate date model


fromDateRangeToList : List Date.Date -> ( Date.Date, Date.Date ) -> List Date.Date
fromDateRangeToList dates ( low, high ) =
    let
        newDate : Date.Date
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
        newDate : Date.Date
        newDate =
            Date.fromCalendarDate year (Date.month model.date) (Date.day model.date)
    in
    updateModelIfValid ValidMonth newDate model


shiftToPreviousMonth : Model -> Model
shiftToPreviousMonth model =
    let
        ( newMonth, newYear ) =
            prevMonth (Date.month model.date) (Date.year model.date)

        newDate : Date.Date
        newDate =
            Date.fromCalendarDate newYear newMonth (Date.day model.date)
    in
    updateModelIfValid ValidMonth newDate model


shiftToNextMonth : Model -> Model
shiftToNextMonth model =
    let
        ( newMonth, newYear ) =
            nextMonth (Date.month model.date) (Date.year model.date)

        newDate : Date.Date
        newDate =
            Date.fromCalendarDate newYear newMonth (Date.day model.date)
    in
    updateModelIfValid ValidMonth newDate model


updateSelectedDay : Int -> Model -> Model
updateSelectedDay day model =
    let
        newDate : Date.Date
        newDate =
            Date.fromCalendarDate (Date.year model.date) (Date.month model.date) day
    in
    updateModelIfValid ValidDay newDate model


type ValidityCheck
    = ValidDay
    | ValidMonth


updateModelIfValid : ValidityCheck -> Date.Date -> Model -> Model
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
render : Model -> Html Msg
render ({ selectingYear } as model) =
    Html.div
        [ Attrs.class "datepicker" ]
        [ header model
        , if selectingYear then
            yearPicker model

          else
            picker model
        ]


header : Model -> Html Msg
header ({ date, selectingYear } as model) =
    Html.div
        [ Attrs.class "datepicker__header"
        ]
        [ Html.div
            [ Attrs.classList
                [ ( "datepicker__header__year", True )
                , ( "is-selected", selectingYear )
                ]
            , H.stopEvt "click"
                (if selectingYear then
                    DaySelection

                 else
                    YearSelection
                )
            ]
            [ (Html.text << String.fromInt << Date.year) date
            ]
        , Html.div
            [ Attrs.classList
                [ ( "datepicker__header__day", True )
                , ( "is-selected", not selectingYear )
                ]
            , H.stopEvt "click" DaySelection
            ]
            [ (Html.text << formattedDay) model
            ]
        ]


weekDays : Html Msg
weekDays =
    Html.div
        [ Attrs.class "datepicker__picker__days-name" ]
        (List.map
            (\day ->
                Html.span
                    [ Attrs.class "datepicker__picker__days-name__item" ]
                    [ Html.text day ]
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

        firstDayOfMonth : Date.Date
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

        firstOfMonth : Date.Date
        firstOfMonth =
            Date.fromCalendarDate (Date.year model.date) (Date.month model.date) 1

        lastOfMonth : Date.Date
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
    Html.div
        [ Attrs.class "datepicker__picker__month"
        ]
        (List.map (\week -> weekRow week (Date.day date) disabledDaysInMonth) weeks)


weekRow : List Int -> Int -> List Int -> Html Msg
weekRow days currentDay disabledDays =
    Html.div
        [ Attrs.class "datepicker__picker__week" ]
        (List.map (\day -> dayCell day currentDay (List.member day disabledDays)) days)


dayCell : Int -> Int -> Bool -> Html Msg
dayCell dayNumber currentDay disabled =
    if dayNumber > 0 then
        Html.div
            [ Attrs.classList
                [ ( "datepicker__picker__day", True )
                , ( "is-selected", dayNumber == currentDay )
                , ( "is-disabled", disabled )
                ]
            , (H.stopEvt "click" << SelectDay) dayNumber
            ]
            [ (Html.text << String.fromInt) dayNumber
            ]

    else
        Html.div
            [ Attrs.class "datepicker__picker__day is-empty" ]
            []


picker : Model -> Html Msg
picker model =
    Html.div
        [ Attrs.class "datepicker__picker" ]
        [ Html.div
            [ Attrs.class "datepicker__picker__header" ]
            [ Html.span
                [ Attrs.class "datepicker__picker__header__arrow datepicker__picker__header__arrow--prev"
                , H.stopEvt "click" PrevMonth
                ]
                []
            , Html.div
                [ Attrs.class "datepicker__picker__header__current-month" ]
                [ (Html.text << formattedMonth) model
                ]
            , Html.span
                [ Attrs.class "datepicker__picker__header__arrow datepicker__picker__header__arrow--next"
                , H.stopEvt "click" NextMonth
                ]
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
    Html.div
        [ Attrs.class "datepicker__year-picker" ]
        [ Html.div
            [ Attrs.class "datepicker__year-picker__scroller" ]
            [ Html.div
                [ Attrs.class "datepicker__year-picker__scroller__list" ]
                (List.map (H.flip yearButton (Date.year model.date)) <| List.range (Date.year lowerBound) (Date.year upperBound))
            ]
        ]


yearButton : Int -> Int -> Html Msg
yearButton year currentYear =
    Html.span
        [ Attrs.classList
            [ ( "datepicker__year-picker__scroller__item", True )
            , ( "is-selected", year == currentYear )
            ]
        , (H.stopEvt "click" << SelectYear) year
        ]
        [ (Html.text << String.fromInt) year
        ]


chunks : Int -> List a -> List (List a)
chunks k xs =
    if List.length xs > k then
        List.take k xs :: chunks k (List.drop k xs)

    else
        [ xs ]


italianLanguage : Date.Language
italianLanguage =
    { monthName = formatMonth
    , monthNameShort = String.left 3 << formatMonth
    , weekdayName = formatDay
    , weekdayNameShort = String.left 3 << formatDay
    , dayWithSuffix = always ""
    }


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


prevMonth : Month -> Int -> ( Month, Int )
prevMonth month year =
    case month of
        Jan ->
            ( Dec, year - 1 )

        Feb ->
            ( Jan, year )

        Mar ->
            ( Feb, year )

        Apr ->
            ( Mar, year )

        May ->
            ( Apr, year )

        Jun ->
            ( May, year )

        Jul ->
            ( Jun, year )

        Aug ->
            ( Jul, year )

        Sep ->
            ( Aug, year )

        Oct ->
            ( Sep, year )

        Nov ->
            ( Oct, year )

        Dec ->
            ( Nov, year )


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


updateToLastDayOfMonth : Date.Date -> Date.Date
updateToLastDayOfMonth date =
    Date.fromCalendarDate (Date.year date) (Date.month date) (getDaysInMonth (Date.year date) (Date.month date))


isParsedDate : Date -> Bool
isParsedDate date =
    case date of
        ParsedDate _ ->
            True

        PartialDate _ ->
            False


isPartialDate : Date -> Bool
isPartialDate =
    not << isParsedDate


toMaybeDate : Date -> Maybe Date.Date
toMaybeDate date =
    case date of
        ParsedDate parsedDate ->
            Just parsedDate

        PartialDate _ ->
            Nothing
