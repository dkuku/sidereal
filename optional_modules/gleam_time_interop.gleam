// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: 2024 glcalendar contributors

/// Conversion functions between our calendar types and gleam_time types.
/// This module is only available when gleam_time is installed as a dependency.
import calendar/date
import calendar/datetime
import calendar/duration
import calendar/naive_datetime
import calendar/time
import gleam/float
import gleam/result
import gleam/time/calendar as gleam_calendar
import gleam/time/duration as gleam_duration
import gleam/time/timestamp

pub type ConversionError {
  InvalidDate
  InvalidTime
  InvalidDateTime
  InvalidMonth
}

// Date conversions

/// Convert our Date to gleam_time Date
pub fn date_to_gleam(
  our_date: date.Date,
) -> Result(gleam_calendar.Date, ConversionError) {
  case gleam_calendar.month_from_int(our_date.month) {
    Error(_) -> Error(InvalidMonth)
    Ok(month) -> {
      let gleam_date = gleam_calendar.Date(our_date.year, month, our_date.day)
      case gleam_calendar.is_valid_date(gleam_date) {
        True -> Ok(gleam_date)
        False -> Error(InvalidDate)
      }
    }
  }
}

/// Convert gleam_time Date to our Date
pub fn date_from_gleam(
  gleam_date: gleam_calendar.Date,
) -> Result(date.Date, ConversionError) {
  let month_int = gleam_calendar.month_to_int(gleam_date.month)
  date.new(gleam_date.year, month_int, gleam_date.day, "Calendar.ISO")
  |> result.map_error(fn(_) { InvalidDate })
}

// Time conversions

/// Convert our Time to gleam_time TimeOfDay
pub fn time_to_gleam(
  our_time: time.Time,
) -> Result(gleam_calendar.TimeOfDay, ConversionError) {
  let #(microseconds, _precision) = our_time.microsecond
  let nanoseconds = microseconds * 1000
  let gleam_time =
    gleam_calendar.TimeOfDay(
      our_time.hour,
      our_time.minute,
      our_time.second,
      nanoseconds,
    )
  case gleam_calendar.is_valid_time_of_day(gleam_time) {
    True -> Ok(gleam_time)
    False -> Error(InvalidTime)
  }
}

/// Convert gleam_time TimeOfDay to our Time
pub fn time_from_gleam(
  gleam_time: gleam_calendar.TimeOfDay,
) -> Result(time.Time, ConversionError) {
  let microseconds = gleam_time.nanoseconds / 1000
  let precision = case microseconds {
    0 -> 0
    n if n < 10 -> 1
    n if n < 100 -> 2
    n if n < 1000 -> 3
    n if n < 10_000 -> 4
    n if n < 100_000 -> 5
    _ -> 6
  }

  time.new(
    gleam_time.hours,
    gleam_time.minutes,
    gleam_time.seconds,
    #(microseconds, precision),
    "Calendar.ISO",
  )
  |> result.map_error(fn(_) { InvalidTime })
}

// DateTime conversions

/// Convert our DateTime to gleam_time Timestamp
pub fn datetime_to_timestamp(
  our_datetime: datetime.DateTime,
) -> timestamp.Timestamp {
  let unix_seconds = datetime.to_unix(our_datetime, datetime.Second)
  timestamp.from_unix_seconds(unix_seconds)
}

/// Convert gleam_time Timestamp to our DateTime (UTC)
pub fn datetime_from_timestamp(ts: timestamp.Timestamp) -> datetime.DateTime {
  let unix_seconds = timestamp.to_unix_seconds(ts) |> float.truncate
  case datetime.from_unix(unix_seconds, datetime.Second, "Calendar.ISO") {
    Ok(dt) -> dt
    Error(_) ->
      datetime.new_unchecked(
        1970,
        1,
        1,
        0,
        0,
        0,
        "Etc/UTC",
        "UTC",
        0,
        0,
        #(0, 0),
        "Calendar.ISO",
      )
  }
}

/// Convert our NaiveDateTime to gleam_time calendar types
pub fn naive_datetime_to_gleam(
  our_ndt: naive_datetime.NaiveDateTime,
) -> Result(#(gleam_calendar.Date, gleam_calendar.TimeOfDay), ConversionError) {
  let our_date =
    date.new_unchecked(
      our_ndt.year,
      our_ndt.month,
      our_ndt.day,
      our_ndt.calendar,
    )
  let our_time =
    time.new_unchecked(
      our_ndt.hour,
      our_ndt.minute,
      our_ndt.second,
      our_ndt.microsecond,
      our_ndt.calendar,
    )

  case date_to_gleam(our_date), time_to_gleam(our_time) {
    Ok(gleam_date), Ok(gleam_time) -> Ok(#(gleam_date, gleam_time))
    Error(e), _ -> Error(e)
    _, Error(e) -> Error(e)
  }
}

/// Convert gleam_time calendar types to our NaiveDateTime
pub fn naive_datetime_from_gleam(
  gleam_date: gleam_calendar.Date,
  gleam_time: gleam_calendar.TimeOfDay,
) -> Result(naive_datetime.NaiveDateTime, ConversionError) {
  case date_from_gleam(gleam_date), time_from_gleam(gleam_time) {
    Ok(our_date), Ok(our_time) -> {
      naive_datetime.new(
        our_date.year,
        our_date.month,
        our_date.day,
        our_time.hour,
        our_time.minute,
        our_time.second,
        our_time.microsecond,
        "Calendar.ISO",
      )
      |> result.map_error(fn(_) { InvalidDateTime })
    }
    Error(e), _ -> Error(e)
    _, Error(e) -> Error(e)
  }
}

// Duration conversions

/// Convert our Duration to gleam_time Duration (approximation)
pub fn duration_to_gleam(
  our_duration: duration.Duration,
) -> gleam_duration.Duration {
  let #(microseconds, _precision) = our_duration.microsecond
  let total_seconds =
    our_duration.year
    * 31_536_000
    + our_duration.month
    * 2_629_746
    + our_duration.week
    * 604_800
    + our_duration.day
    * 86_400
    + our_duration.hour
    * 3600
    + our_duration.minute
    * 60
    + our_duration.second

  let total_nanoseconds = microseconds * 1000

  gleam_duration.seconds(total_seconds)
  |> gleam_duration.add(gleam_duration.nanoseconds(total_nanoseconds))
}

/// Convert gleam_time Duration to our Duration (seconds only)
pub fn duration_from_gleam(
  gleam_dur: gleam_duration.Duration,
) -> duration.Duration {
  // gleam_time Duration is opaque, we can only get total seconds/nanoseconds
  let #(total_seconds, nanoseconds) =
    gleam_duration.to_seconds_and_nanoseconds(gleam_dur)
  let microseconds = nanoseconds / 1000
  let precision = case microseconds {
    0 -> 0
    n if n < 10 -> 1
    n if n < 100 -> 2
    n if n < 1000 -> 3
    n if n < 10_000 -> 4
    n if n < 100_000 -> 5
    _ -> 6
  }

  // Convert back to years, months, etc. (approximation)
  let years = total_seconds / 31_536_000
  let remaining = total_seconds % 31_536_000
  let months = remaining / 2_629_746
  let remaining = remaining % 2_629_746
  let days = remaining / 86_400
  let remaining = remaining % 86_400
  let hours = remaining / 3600
  let remaining = remaining % 3600
  let minutes = remaining / 60
  let seconds = remaining % 60

  duration.Duration(
    year: years,
    month: months,
    week: 0,
    day: days,
    hour: hours,
    minute: minutes,
    second: seconds,
    microsecond: #(microseconds, precision),
  )
}

// Utility functions

/// Convert our DateTime to RFC3339 string using gleam_time
pub fn datetime_to_rfc3339(our_datetime: datetime.DateTime) -> String {
  let ts = datetime_to_timestamp(our_datetime)
  let offset_seconds = our_datetime.utc_offset + our_datetime.std_offset
  let offset_duration = gleam_duration.seconds(offset_seconds)
  timestamp.to_rfc3339(ts, offset_duration)
}

/// Parse RFC3339 string to our DateTime using gleam_time
pub fn datetime_from_rfc3339(
  rfc3339_string: String,
) -> Result(datetime.DateTime, ConversionError) {
  case timestamp.parse_rfc3339(rfc3339_string) {
    Ok(ts) -> Ok(datetime_from_timestamp(ts))
    Error(_) -> Error(InvalidDateTime)
  }
}
