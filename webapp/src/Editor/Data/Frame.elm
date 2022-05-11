module Editor.Data.Frame exposing
    ( Frame(..)
    , ceiling
    , floor
    , format
    , formatLong
    , hasPrev
    , isWithin
    , isWithinPrev
    , toInterval
    , toMs
    , toString
    , toTimes
    )

import DateFormat as F
import Dict exposing (Dict)
import Editor.Data.Registry.Package as Pkg
import Editor.Data.Time
import Http
import Json.Decode as JD
import Time


type Frame
    = Days14
    | Days7
    | Days2
    | Hours24
    | Hours12



-- TRANSLATIONS


toMs : Frame -> Int
toMs frame =
    case frame of
        Days14 ->
            1000 * 60 * 60 * 24 * 14

        Days7 ->
            1000 * 60 * 60 * 24 * 7

        Days2 ->
            1000 * 60 * 60 * 24 * 2

        Hours24 ->
            1000 * 60 * 60 * 24

        Hours12 ->
            1000 * 60 * 60 * 12


toInterval : Frame -> Int
toInterval frame =
    case frame of
        Days14 ->
            1000 * 60 * 60 * 24

        Days7 ->
            1000 * 60 * 60 * 12

        Days2 ->
            1000 * 60 * 60 * 2

        Hours24 ->
            1000 * 60 * 60

        Hours12 ->
            1000 * 60 * 30


toString : Frame -> String
toString frame =
    case frame of
        Days14 ->
            "14 days"

        Days7 ->
            "7 days"

        Days2 ->
            "2 days"

        Hours24 ->
            "24 hours"

        Hours12 ->
            "12 hours"


toTimes : Time.Zone -> Time.Posix -> Frame -> List Int
toTimes zone now frame =
    let
        interval =
            toInterval frame

        amount =
            toMs frame // interval

        first =
            Time.posixToMillis (floor zone frame now)

        toTime mult =
            first - mult * interval
    in
    List.map toTime (List.range 0 amount)



-- QUESTIONS


hasPrev : Frame -> Bool
hasPrev frame =
    case frame of
        Days14 ->
            False

        Days7 ->
            True

        Days2 ->
            True

        Hours24 ->
            True

        Hours12 ->
            True


isWithin : Time.Posix -> Frame -> Int -> Bool
isWithin now frame timestamp =
    let
        frameMs =
            toMs frame

        nowMs =
            Time.posixToMillis now

        lowerLimit =
            nowMs - frameMs
    in
    timestamp > lowerLimit


isWithinPrev : Time.Posix -> Frame -> Int -> Bool
isWithinPrev now frame timestamp =
    let
        frameMs =
            toMs frame

        nowMs =
            Time.posixToMillis now

        lowerLimit =
            nowMs - frameMs * 2

        upperLimit =
            nowMs - frameMs
    in
    timestamp > lowerLimit && timestamp <= upperLimit



-- MANIPULATION


ceiling : Time.Zone -> Frame -> Time.Posix -> Time.Posix
ceiling zone frame =
    case frame of
        Days14 ->
            Editor.Data.Time.ceilingDay zone 1

        Days7 ->
            Editor.Data.Time.ceilingHour zone 12

        Days2 ->
            Editor.Data.Time.ceilingHour zone 2

        Hours24 ->
            Editor.Data.Time.ceilingHour zone 1

        Hours12 ->
            Editor.Data.Time.ceilingMinute zone 30


floor : Time.Zone -> Frame -> Time.Posix -> Time.Posix
floor zone frame =
    case frame of
        Days14 ->
            Editor.Data.Time.floorDay zone 1

        Days7 ->
            Editor.Data.Time.floorHour zone 12

        Days2 ->
            Editor.Data.Time.floorHour zone 2

        Hours24 ->
            Editor.Data.Time.floorHour zone 1

        Hours12 ->
            Editor.Data.Time.floorMinute zone 30



-- FORMATTING


format : Frame -> Time.Zone -> Time.Posix -> String
format frame =
    F.format <|
        case frame of
            Days14 ->
                [ F.monthNameAbbreviated, F.text " ", F.dayOfMonthSuffix ]

            Days7 ->
                [ F.dayOfMonthNumber, F.text "/", F.monthNumber, F.text " ", F.hourNumber, F.amPmLowercase ]

            Days2 ->
                [ F.hourMilitaryFixed, F.text ":", F.minuteFixed ]

            Hours24 ->
                [ F.hourMilitaryFixed, F.text ":", F.minuteFixed ]

            Hours12 ->
                [ F.hourMilitaryFixed, F.text ":", F.minuteFixed ]


formatLong : Frame -> Time.Zone -> Time.Posix -> String
formatLong frame =
    F.format <|
        case frame of
            Days14 ->
                [ F.monthNameAbbreviated, F.text " ", F.dayOfMonthSuffix ]

            Days7 ->
                [ F.monthNameAbbreviated, F.text " ", F.dayOfMonthSuffix ]

            Days2 ->
                [ F.monthNameAbbreviated, F.text " ", F.dayOfMonthSuffix, F.text " ", F.hourMilitaryFixed, F.text ":", F.minuteFixed ]

            Hours24 ->
                [ F.monthNameAbbreviated, F.text " ", F.dayOfMonthSuffix, F.text " ", F.hourMilitaryFixed, F.text ":", F.minuteFixed ]

            Hours12 ->
                [ F.monthNameAbbreviated, F.text " ", F.dayOfMonthSuffix, F.text " ", F.hourMilitaryFixed, F.text ":", F.minuteFixed ]
