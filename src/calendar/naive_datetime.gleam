// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: 2021 The Elixir Team
// SPDX-FileCopyrightText: 2012 Plataformatec

import calendar/date
import calendar/duration as calendar_duration
import calendar/iso
import calendar/time
import gleam/int
import gleam/list
import gleam/order
import gleam/string

/// A NaiveDateTime struct (without a time zone) and functions.
///
/// The NaiveDateTime struct contains the fields year, month, day, hour,
/// minute, second, microsecond and calendar. New naive datetimes can be
/// built with the `new` functions.
///
/// We call them "naive" because this datetime representation does not
/// have a time zone. This means the datetime may not actually exist in
/// certain areas in the world even though it is valid.
pub type NaiveDateTime {
  NaiveDateTime(
    year: Int,
    month: Int,
    day: Int,
    hour: Int,
    minute: Int,
    second: Int,
    microsecond: #(Int, Int),
    calendar: String,
  )
}

pub type NaiveDateTimeError {
  InvalidNaiveDateTime
  InvalidDate
  InvalidTime
}

const seconds_per_day = 86_400

/// Creates a new NaiveDateTime struct.
pub fn new(
  year: Int,
  month: Int,
  day: Int,
  hour: Int,
  minute: Int,
  second: Int,
  microsecond: #(Int, Int),
  calendar: String,
) -> Result(NaiveDateTime, NaiveDateTimeError) {
  // Validate date component
  case date.new(year, month, day, calendar) {
    Error(_) -> Error(InvalidDate)
    Ok(_) -> {
      // Validate time component
      case time.new(hour, minute, second, microsecond, calendar) {
        Error(_) -> Error(InvalidTime)
        Ok(_) ->
          Ok(NaiveDateTime(
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute,
            second: second,
            microsecond: microsecond,
            calendar: calendar,
          ))
      }
    }
  }
}

/// Creates a new NaiveDateTime with simple parameters.
pub fn new_simple(
  year: Int,
  month: Int,
  day: Int,
  hour: Int,
  minute: Int,
  second: Int,
) -> Result(NaiveDateTime, NaiveDateTimeError) {
  new(year, month, day, hour, minute, second, #(0, 0), "Calendar.ISO")
}

/// Creates a NaiveDateTime from separate Date and Time structs.
pub fn from_date_and_time(
  date_val: date.Date,
  time_val: time.Time,
) -> Result(NaiveDateTime, NaiveDateTimeError) {
  case date_val.calendar == time_val.calendar {
    True ->
      Ok(NaiveDateTime(
        year: date_val.year,
        month: date_val.month,
        day: date_val.day,
        hour: time_val.hour,
        minute: time_val.minute,
        second: time_val.second,
        microsecond: time_val.microsecond,
        calendar: date_val.calendar,
      ))
    False -> Error(InvalidNaiveDateTime)
  }
}

/// Converts a NaiveDateTime to a string in ISO8601 format.
pub fn to_string(ndt: NaiveDateTime) -> String {
  let date_part =
    pad_left(int.to_string(ndt.year), 4, "0")
    <> "-"
    <> pad_left(int.to_string(ndt.month), 2, "0")
    <> "-"
    <> pad_left(int.to_string(ndt.day), 2, "0")

  let time_part =
    pad_left(int.to_string(ndt.hour), 2, "0")
    <> ":"
    <> pad_left(int.to_string(ndt.minute), 2, "0")
    <> ":"
    <> pad_left(int.to_string(ndt.second), 2, "0")

  let #(ms, precision) = ndt.microsecond
  let microsecond_part = case ms == 0 || precision == 0 {
    True -> ""
    False -> "." <> pad_microseconds(ms, precision)
  }

  date_part <> " " <> time_part <> microsecond_part
}

/// Converts a NaiveDateTime to ISO8601 extended format.
pub fn to_iso8601(ndt: NaiveDateTime) -> String {
  to_iso8601_with_format(ndt, iso.Extended)
}

/// Converts a NaiveDateTime to ISO8601 with format option.
pub fn to_iso8601_with_format(ndt: NaiveDateTime, format: iso.Format) -> String {
  let #(ms, precision) = ndt.microsecond
  let microsecond_part = case ms == 0 || precision == 0 {
    True -> ""
    False -> "." <> pad_microseconds(ms, precision)
  }

  case format {
    iso.Extended -> {
      let date_part =
        pad_left(int.to_string(ndt.year), 4, "0")
        <> "-"
        <> pad_left(int.to_string(ndt.month), 2, "0")
        <> "-"
        <> pad_left(int.to_string(ndt.day), 2, "0")
      let time_part =
        pad_left(int.to_string(ndt.hour), 2, "0")
        <> ":"
        <> pad_left(int.to_string(ndt.minute), 2, "0")
        <> ":"
        <> pad_left(int.to_string(ndt.second), 2, "0")
      date_part <> "T" <> time_part <> microsecond_part
    }
    iso.Basic -> {
      let date_part =
        pad_left(int.to_string(ndt.year), 4, "0")
        <> pad_left(int.to_string(ndt.month), 2, "0")
        <> pad_left(int.to_string(ndt.day), 2, "0")
      let time_part =
        pad_left(int.to_string(ndt.hour), 2, "0")
        <> pad_left(int.to_string(ndt.minute), 2, "0")
        <> pad_left(int.to_string(ndt.second), 2, "0")
      date_part <> "T" <> time_part <> microsecond_part
    }
  }
}

/// Extracts the Date part from a NaiveDateTime.
pub fn to_date(ndt: NaiveDateTime) -> date.Date {
  case date.new(ndt.year, ndt.month, ndt.day, ndt.calendar) {
    Ok(d) -> d
    Error(_) -> panic as "Invalid date in valid NaiveDateTime struct"
  }
}

/// Extracts the Time part from a NaiveDateTime.
pub fn to_time(ndt: NaiveDateTime) -> time.Time {
  case
    time.new(ndt.hour, ndt.minute, ndt.second, ndt.microsecond, ndt.calendar)
  {
    Ok(t) -> t
    Error(_) -> panic as "Invalid time in valid NaiveDateTime struct"
  }
}

/// Compare two NaiveDateTime structs.
pub fn compare(ndt1: NaiveDateTime, ndt2: NaiveDateTime) -> order.Order {
  let ts1 = to_timestamp(ndt1)
  let ts2 = to_timestamp(ndt2)
  int.compare(ts1, ts2)
}

/// Add seconds to a NaiveDateTime.
pub fn add_seconds(
  ndt: NaiveDateTime,
  seconds: Int,
) -> Result(NaiveDateTime, NaiveDateTimeError) {
  let current_timestamp = to_timestamp(ndt)
  from_timestamp(current_timestamp + seconds)
}

/// Convert NaiveDateTime to Unix timestamp (seconds since epoch).
pub fn to_timestamp(ndt: NaiveDateTime) -> Int {
  let date_part = to_date(ndt)
  let date_timestamp = date.to_timestamp(date_part)
  let time_seconds = ndt.hour * 3600 + ndt.minute * 60 + ndt.second
  date_timestamp + time_seconds
}

/// Create NaiveDateTime from Unix timestamp.
pub fn from_timestamp(
  timestamp: Int,
) -> Result(NaiveDateTime, NaiveDateTimeError) {
  let days_since_epoch = timestamp / seconds_per_day
  let seconds_in_day = timestamp % seconds_per_day

  case date.from_timestamp(days_since_epoch * seconds_per_day) {
    Error(_) -> Error(InvalidDate)
    Ok(date_val) -> {
      case time.from_seconds_after_midnight(seconds_in_day) {
        Error(_) -> Error(InvalidTime)
        Ok(time_val) -> from_date_and_time(date_val, time_val)
      }
    }
  }
}

/// Helper function to pad string with leading characters.
fn pad_left(str: String, width: Int, pad_char: String) -> String {
  let current_length = string.length(str)
  case current_length >= width {
    True -> str
    False -> string.repeat(pad_char, width - current_length) <> str
  }
}

/// Returns the current naive datetime in UTC.
pub fn utc_now() -> Result(NaiveDateTime, NaiveDateTimeError) {
  utc_now_with_precision(time.Microsecond, "Calendar.ISO")
}

/// Returns the current naive datetime in UTC with precision.
pub fn utc_now_with_precision(
  precision: time.TimeUnit,
  calendar: String,
) -> Result(NaiveDateTime, NaiveDateTimeError) {
  let current_date = date.utc_today_with_calendar(calendar)
  case time.utc_now_with_precision(precision, calendar) {
    Ok(current_time) -> {
      new(
        current_date.year,
        current_date.month,
        current_date.day,
        current_time.hour,
        current_time.minute,
        current_time.second,
        current_time.microsecond,
        calendar,
      )
    }
    Error(_) -> Error(InvalidTime)
  }
}

/// Returns the current local naive datetime.
pub fn local_now() -> Result(NaiveDateTime, NaiveDateTimeError) {
  local_now_with_calendar("Calendar.ISO")
}

/// Returns the current local naive datetime with calendar.
pub fn local_now_with_calendar(
  calendar: String,
) -> Result(NaiveDateTime, NaiveDateTimeError) {
  // For simplicity, returns UTC time - real implementation would use local timezone
  utc_now_with_precision(time.Microsecond, calendar)
}

/// Add days to a naive datetime.
pub fn add_days(
  ndt: NaiveDateTime,
  days: Int,
) -> Result(NaiveDateTime, NaiveDateTimeError) {
  let current_timestamp = to_timestamp(ndt)
  from_timestamp(current_timestamp + days * 86_400)
}

/// Add hours to a naive datetime.
pub fn add_hours(
  ndt: NaiveDateTime,
  hours: Int,
) -> Result(NaiveDateTime, NaiveDateTimeError) {
  let current_timestamp = to_timestamp(ndt)
  from_timestamp(current_timestamp + hours * 3600)
}

/// Add minutes to a naive datetime.
pub fn add_minutes(
  ndt: NaiveDateTime,
  minutes: Int,
) -> Result(NaiveDateTime, NaiveDateTimeError) {
  let current_timestamp = to_timestamp(ndt)
  from_timestamp(current_timestamp + minutes * 60)
}

/// Calculate difference in days between two naive datetimes.
pub fn diff_days(ndt1: NaiveDateTime, ndt2: NaiveDateTime) -> Int {
  diff(ndt1, ndt2, time.Second) / 86_400
}

/// Calculate difference in hours between two naive datetimes.
pub fn diff_hours(ndt1: NaiveDateTime, ndt2: NaiveDateTime) -> Int {
  diff(ndt1, ndt2, time.Second) / 3600
}

/// Calculate difference in minutes between two naive datetimes.
pub fn diff_minutes(ndt1: NaiveDateTime, ndt2: NaiveDateTime) -> Int {
  diff(ndt1, ndt2, time.Second) / 60
}

/// Add amount to a naive datetime with specified unit.
pub fn add(
  ndt: NaiveDateTime,
  amount: Int,
  unit: time.TimeUnit,
) -> NaiveDateTime {
  case add_with_validation(ndt, amount, unit) {
    Ok(new_ndt) -> new_ndt
    Error(_) -> ndt
    // Return original if invalid
  }
}

/// Add amount to naive datetime with validation.
pub fn add_with_validation(
  ndt: NaiveDateTime,
  amount: Int,
  unit: time.TimeUnit,
) -> Result(NaiveDateTime, NaiveDateTimeError) {
  let microseconds_to_add = case unit {
    time.Second -> amount * 1_000_000
    time.Millisecond -> amount * 1000
    time.Microsecond -> amount
    time.Native -> amount
  }
  let current_timestamp = to_timestamp(ndt) * 1_000_000
  let #(ms, _precision) = ndt.microsecond
  let total_us = current_timestamp + ms + microseconds_to_add

  let total_seconds = total_us / 1_000_000
  let remaining_us = total_us % 1_000_000

  let precision = case unit {
    time.Second -> 0
    time.Millisecond -> 3
    time.Microsecond | time.Native -> 6
  }
  let #(_, old_precision) = ndt.microsecond
  let final_precision = case precision > old_precision {
    True -> precision
    False -> old_precision
  }

  let days_since_epoch = total_seconds / seconds_per_day
  let seconds_in_day = total_seconds % seconds_per_day

  case date.from_days_since_unix_epoch(days_since_epoch, ndt.calendar) {
    Error(_) -> Error(InvalidDate)
    Ok(date_val) -> {
      case
        time.from_seconds_after_midnight_with_microsecond(
          seconds_in_day,
          #(remaining_us, final_precision),
          ndt.calendar,
        )
      {
        Error(_) -> Error(InvalidTime)
        Ok(time_val) -> from_date_and_time(date_val, time_val)
      }
    }
  }
}

/// Calculate difference between two naive datetimes.
pub fn diff(
  ndt1: NaiveDateTime,
  ndt2: NaiveDateTime,
  unit: time.TimeUnit,
) -> Int {
  let ts1 = to_timestamp(ndt1)
  let ts2 = to_timestamp(ndt2)
  let diff_seconds = ts1 - ts2

  case unit {
    time.Second -> diff_seconds
    time.Microsecond -> diff_seconds * 1_000_000
    time.Millisecond -> diff_seconds * 1000
    _ -> diff_seconds
  }
}

/// Shift naive datetime by duration.
pub fn shift(
  ndt: NaiveDateTime,
  duration: calendar_duration.Duration,
) -> Result(NaiveDateTime, NaiveDateTimeError) {
  let month_shift = duration.year * 12 + duration.month
  let day_shift = duration.week * 7 + duration.day
  let #(us, _) = duration.microsecond

  let #(y, m, d, h, min, s, microsecond) =
    iso.shift_naive_datetime(
      ndt.year,
      ndt.month,
      ndt.day,
      ndt.hour,
      ndt.minute,
      ndt.second,
      ndt.microsecond,
      month_shift,
      day_shift,
      duration.hour * 3600 + duration.minute * 60 + duration.second,
      us,
    )

  new(y, m, d, h, min, s, microsecond, ndt.calendar)
}

/// Truncate naive datetime to specified precision.
pub fn truncate(
  ndt: NaiveDateTime,
  precision: Int,
) -> Result(NaiveDateTime, NaiveDateTimeError) {
  let current_time = to_time(ndt)
  let truncated_time = time.truncate(current_time, precision)
  new(
    ndt.year,
    ndt.month,
    ndt.day,
    truncated_time.hour,
    truncated_time.minute,
    truncated_time.second,
    truncated_time.microsecond,
    ndt.calendar,
  )
}

/// Check if first datetime is before second.
pub fn before(ndt1: NaiveDateTime, ndt2: NaiveDateTime) -> Bool {
  case compare(ndt1, ndt2) {
    order.Lt -> True
    _ -> False
  }
}

/// Check if first datetime is after second.
pub fn after(ndt1: NaiveDateTime, ndt2: NaiveDateTime) -> Bool {
  case compare(ndt1, ndt2) {
    order.Gt -> True
    _ -> False
  }
}

/// Parse ISO8601 string to NaiveDateTime.
pub fn from_iso8601(
  iso_string: String,
) -> Result(NaiveDateTime, NaiveDateTimeError) {
  case parse_iso8601_naive_datetime(iso_string) {
    Ok(#(year, month, day, hour, minute, second, microsecond)) ->
      new(year, month, day, hour, minute, second, microsecond, "Calendar.ISO")
    Error(_) -> Error(InvalidNaiveDateTime)
  }
}

/// Parse ISO8601 string to NaiveDateTime, panicking on error.
pub fn from_iso8601_unchecked(iso_string: String) -> NaiveDateTime {
  case from_iso8601(iso_string) {
    Ok(ndt) -> ndt
    Error(_) -> panic as "Invalid ISO8601 naive datetime format"
  }
}

/// Convert NaiveDateTime to Erlang datetime tuple.
pub fn to_erl(ndt: NaiveDateTime) -> #(#(Int, Int, Int), #(Int, Int, Int)) {
  #(#(ndt.year, ndt.month, ndt.day), #(ndt.hour, ndt.minute, ndt.second))
}

/// Create NaiveDateTime from Erlang datetime tuple.
pub fn from_erl(
  erl_datetime: #(#(Int, Int, Int), #(Int, Int, Int)),
  microsecond: #(Int, Int),
  calendar: String,
) -> Result(NaiveDateTime, NaiveDateTimeError) {
  let #(#(year, month, day), #(hour, minute, second)) = erl_datetime
  new(year, month, day, hour, minute, second, microsecond, calendar)
}

/// Create NaiveDateTime from Erlang tuple, panicking on error.
pub fn from_erl_unchecked(
  erl_datetime: #(#(Int, Int, Int), #(Int, Int, Int)),
  microsecond: #(Int, Int),
  calendar: String,
) -> NaiveDateTime {
  case from_erl(erl_datetime, microsecond, calendar) {
    Ok(ndt) -> ndt
    Error(_) -> panic as "Invalid Erlang datetime tuple"
  }
}

/// Convert between calendars.
pub fn convert(
  ndt: NaiveDateTime,
  target_calendar: String,
) -> Result(NaiveDateTime, NaiveDateTimeError) {
  case ndt.calendar == target_calendar {
    True -> Ok(ndt)
    False -> {
      // Simplified conversion - would need proper calendar implementation
      case
        new(
          ndt.year,
          ndt.month,
          ndt.day,
          ndt.hour,
          ndt.minute,
          ndt.second,
          ndt.microsecond,
          target_calendar,
        )
      {
        Ok(result) -> Ok(result)
        Error(e) -> Error(e)
      }
    }
  }
}

/// Convert between calendars, panicking on error.
pub fn convert_unchecked(
  ndt: NaiveDateTime,
  target_calendar: String,
) -> NaiveDateTime {
  case convert(ndt, target_calendar) {
    Ok(converted) -> converted
    Error(_) -> panic as "Calendar conversion failed"
  }
}

/// Get beginning of day (00:00:00).
pub fn beginning_of_day(ndt: NaiveDateTime) -> NaiveDateTime {
  case new(ndt.year, ndt.month, ndt.day, 0, 0, 0, #(0, 0), ndt.calendar) {
    Ok(result) -> result
    Error(_) -> panic as "Invalid beginning of day"
  }
}

/// Get end of day (23:59:59.999999).
pub fn end_of_day(ndt: NaiveDateTime) -> NaiveDateTime {
  case
    new(ndt.year, ndt.month, ndt.day, 23, 59, 59, #(999_999, 6), ndt.calendar)
  {
    Ok(result) -> result
    Error(_) -> panic as "Invalid end of day"
  }
}

/// Get string representation for inspection.
pub fn inspect(ndt: NaiveDateTime) -> String {
  "~N[" <> to_string(ndt) <> "]"
}

/// Create from Gregorian seconds since epoch 0000-01-01 00:00:00.
pub fn from_gregorian_seconds(
  seconds: Int,
  _microsecond: #(Int, Int),
  _calendar: String,
) -> Result(NaiveDateTime, NaiveDateTimeError) {
  // Simplified - would need proper Gregorian calendar implementation
  from_timestamp(seconds - 62_167_219_200)
  // Approximate offset to Unix epoch
}

/// Convert to Gregorian seconds since epoch 0000-01-01 00:00:00.
pub fn to_gregorian_seconds(ndt: NaiveDateTime) -> #(Int, Int) {
  let timestamp = to_timestamp(ndt)
  let gregorian_seconds = timestamp + 62_167_219_200
  // Approximate offset from Unix epoch
  let #(ms, _) = ndt.microsecond
  #(gregorian_seconds, ms)
}

/// Create NaiveDateTime with current date and specified time.
pub fn today_with_time(
  hour: Int,
  minute: Int,
  second: Int,
) -> Result(NaiveDateTime, NaiveDateTimeError) {
  today_with_time_and_calendar(hour, minute, second, #(0, 0), "Calendar.ISO")
}

/// Create NaiveDateTime with current date and specified time and calendar.
pub fn today_with_time_and_calendar(
  hour: Int,
  minute: Int,
  second: Int,
  microsecond: #(Int, Int),
  calendar: String,
) -> Result(NaiveDateTime, NaiveDateTimeError) {
  let today = date.utc_today_with_calendar(calendar)
  new(
    today.year,
    today.month,
    today.day,
    hour,
    minute,
    second,
    microsecond,
    calendar,
  )
}

/// Check if two naive datetimes are equal.
pub fn equal(ndt1: NaiveDateTime, ndt2: NaiveDateTime) -> Bool {
  case compare(ndt1, ndt2) {
    order.Eq -> True
    _ -> False
  }
}

/// Get the day of year (1-366).
pub fn day_of_year(ndt: NaiveDateTime) -> Int {
  iso.day_of_year(ndt.year, ndt.month, ndt.day)
}

/// Get the day of week (1=Monday, 7=Sunday).
pub fn day_of_week(ndt: NaiveDateTime) -> Int {
  iso.day_of_week(ndt.year, ndt.month, ndt.day, iso.Monday)
}

/// Get the week of year (1-53).
pub fn week_of_year(ndt: NaiveDateTime) -> Int {
  day_of_year(ndt) / 7 + 1
}

/// Get year from naive datetime.
pub fn year(ndt: NaiveDateTime) -> Int {
  ndt.year
}

/// Get month from naive datetime.
pub fn month(ndt: NaiveDateTime) -> Int {
  ndt.month
}

/// Get day from naive datetime.
pub fn day(ndt: NaiveDateTime) -> Int {
  ndt.day
}

/// Get hour from naive datetime.
pub fn hour(ndt: NaiveDateTime) -> Int {
  ndt.hour
}

/// Get minute from naive datetime.
pub fn minute(ndt: NaiveDateTime) -> Int {
  ndt.minute
}

/// Get second from naive datetime.
pub fn second(ndt: NaiveDateTime) -> Int {
  ndt.second
}

/// Get microsecond from naive datetime.
pub fn microsecond(ndt: NaiveDateTime) -> #(Int, Int) {
  ndt.microsecond
}

/// Get calendar from naive datetime.
pub fn calendar(ndt: NaiveDateTime) -> String {
  ndt.calendar
}

/// Validate if components make a valid naive datetime.
pub fn is_valid(
  year: Int,
  month: Int,
  day: Int,
  hour: Int,
  minute: Int,
  second: Int,
  microsecond: #(Int, Int),
) -> Bool {
  case
    new(year, month, day, hour, minute, second, microsecond, "Calendar.ISO")
  {
    Ok(_) -> True
    Error(_) -> False
  }
}

/// Create naive datetime range.
pub fn range(
  start: NaiveDateTime,
  end: NaiveDateTime,
  step_seconds: Int,
) -> List(NaiveDateTime) {
  case step_seconds <= 0 {
    True -> []
    False -> {
      let start_ts = to_timestamp(start)
      let end_ts = to_timestamp(end)
      case start_ts >= end_ts {
        True -> []
        False -> range_helper(start_ts, end_ts, step_seconds, [])
      }
    }
  }
}

/// Create a new naive datetime with specified components replaced.
pub fn replace(
  ndt: NaiveDateTime,
  year: Int,
  month: Int,
  day: Int,
  hour: Int,
  minute: Int,
  second: Int,
  microsecond: #(Int, Int),
) -> Result(NaiveDateTime, NaiveDateTimeError) {
  new(year, month, day, hour, minute, second, microsecond, ndt.calendar)
}

/// Create a new naive datetime with only some components replaced.
pub fn replace_partial(
  ndt: NaiveDateTime,
  year: Int,
  month: Int,
  day: Int,
) -> Result(NaiveDateTime, NaiveDateTimeError) {
  new(
    year,
    month,
    day,
    ndt.hour,
    ndt.minute,
    ndt.second,
    ndt.microsecond,
    ndt.calendar,
  )
}

// Helper functions

fn range_helper(
  current_ts: Int,
  end_ts: Int,
  step: Int,
  acc: List(NaiveDateTime),
) -> List(NaiveDateTime) {
  case current_ts >= end_ts {
    True -> acc |> list.reverse
    False -> {
      case from_timestamp(current_ts) {
        Ok(ndt) -> range_helper(current_ts + step, end_ts, step, [ndt, ..acc])
        Error(_) -> acc |> list.reverse
      }
    }
  }
}

// Helper functions

/// Parse ISO8601 naive datetime string.
fn parse_iso8601_naive_datetime(
  iso_string: String,
) -> Result(#(Int, Int, Int, Int, Int, Int, #(Int, Int)), Nil) {
  // Simplified parsing - would need full ISO8601 implementation
  case string.split(iso_string, "T") {
    [date_part, time_part] -> {
      case string.split(date_part, "-"), string.split(time_part, ":") {
        [year_str, month_str, day_str], [hour_str, minute_str, second_part] -> {
          case
            int.parse(year_str),
            int.parse(month_str),
            int.parse(day_str),
            int.parse(hour_str),
            int.parse(minute_str)
          {
            Ok(year), Ok(month), Ok(day), Ok(hour), Ok(minute) -> {
              case string.split(second_part, ".") {
                [second_str] -> {
                  case int.parse(second_str) {
                    Ok(second) ->
                      Ok(#(year, month, day, hour, minute, second, #(0, 0)))
                    Error(_) -> Error(Nil)
                  }
                }
                [second_str, ms_str] -> {
                  case int.parse(second_str), int.parse(ms_str) {
                    Ok(second), Ok(ms) -> {
                      let precision = string.length(ms_str)
                      Ok(
                        #(year, month, day, hour, minute, second, #(
                          ms,
                          precision,
                        )),
                      )
                    }
                    _, _ -> Error(Nil)
                  }
                }
                _ -> Error(Nil)
              }
            }
            _, _, _, _, _ -> Error(Nil)
          }
        }
        _, _ -> Error(Nil)
      }
    }
    _ -> Error(Nil)
  }
}

/// Helper function to format microseconds with proper padding.
fn pad_microseconds(microseconds: Int, precision: Int) -> String {
  let ms_str = int.to_string(microseconds)
  let padded = case string.length(ms_str) < precision {
    True -> string.repeat("0", precision - string.length(ms_str)) <> ms_str
    False -> ms_str
  }
  string.slice(padded, 0, precision)
}
