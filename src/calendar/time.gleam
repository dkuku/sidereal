// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: 2021 The Elixir Team
// SPDX-FileCopyrightText: 2012 Plataformatec

import calendar/duration as calendar_duration
import gleam/int
import gleam/string

@external(erlang, "gleam_time_ffi", "system_time")
@external(javascript, "../gleam_time_ffi.mjs", "system_time")
fn system_time() -> #(Int, Int)

/// A Time struct and functions.
///
/// The Time struct contains the fields hour, minute, second and microseconds.
/// New times can be built with the `new` function.
///
/// The functions on this module work with the `Time` struct as well
/// as any struct that contains the same fields as the `Time` struct,
/// such as `NaiveDateTime` and `DateTime`.
pub type Time {
  Time(
    hour: Int,
    minute: Int,
    second: Int,
    microsecond: #(Int, Int),
    calendar: String,
  )
}

pub type TimeError {
  InvalidTime
  InvalidHour
  InvalidMinute
  InvalidSecond
  InvalidMicrosecond
}

const seconds_per_day = 86_400

/// Creates a new Time struct.
///
/// Returns an error if the time is invalid.
pub fn new(
  hour: Int,
  minute: Int,
  second: Int,
  microsecond: #(Int, Int),
  calendar: String,
) -> Result(Time, TimeError) {
  case is_valid_time(hour, minute, second, microsecond) {
    True ->
      Ok(Time(
        hour: hour,
        minute: minute,
        second: second,
        microsecond: microsecond,
        calendar: calendar,
      ))
    False -> Error(InvalidTime)
  }
}

/// Creates a new Time struct with default values.
/// Uses microsecond #(0, 0) and Calendar.ISO as defaults.
pub fn new_simple(
  hour: Int,
  minute: Int,
  second: Int,
) -> Result(Time, TimeError) {
  new(hour, minute, second, #(0, 0), "Calendar.ISO")
}

/// Validates if the given time components are valid.
fn is_valid_time(
  hour: Int,
  minute: Int,
  second: Int,
  microsecond: #(Int, Int),
) -> Bool {
  let #(ms, precision) = microsecond

  hour >= 0
  && hour <= 23
  && minute >= 0
  && minute <= 59
  && second >= 0
  && second <= 59
  && ms >= 0
  && ms < 1_000_000
  && precision >= 0
  && precision <= 6
}

/// Converts a Time to a string in ISO8601 format.
pub fn to_string(time: Time) -> String {
  let hour_str = pad_zero(time.hour)
  let minute_str = pad_zero(time.minute)
  let second_str = pad_zero(time.second)

  let #(ms, precision) = time.microsecond
  case ms == 0 || precision == 0 {
    True -> hour_str <> ":" <> minute_str <> ":" <> second_str
    False -> {
      let ms_str = pad_microseconds(ms, precision)
      hour_str <> ":" <> minute_str <> ":" <> second_str <> "." <> ms_str
    }
  }
}

/// Converts a Time to ISO8601 format.
pub fn to_iso8601(time: Time) -> String {
  to_iso8601_with_format(time, Extended)
}

pub type TimeFormat {
  Extended
  Basic
}

/// Converts a Time to ISO8601 format with specified format.
pub fn to_iso8601_with_format(time: Time, format: TimeFormat) -> String {
  case format {
    Extended -> to_string(time)
    Basic -> {
      let hour_str = pad_zero(time.hour)
      let minute_str = pad_zero(time.minute)
      let second_str = pad_zero(time.second)

      let #(ms, precision) = time.microsecond
      case ms == 0 || precision == 0 {
        True -> hour_str <> minute_str <> second_str
        False -> {
          let ms_str = pad_microseconds(ms, precision)
          hour_str <> minute_str <> second_str <> "." <> ms_str
        }
      }
    }
  }
}

/// Converts time to total seconds since midnight.
pub fn to_seconds_after_midnight(time: Time) -> Int {
  time.hour * 3600 + time.minute * 60 + time.second
}

/// Converts time to total seconds since midnight as a tuple with microseconds.
pub fn to_seconds_after_midnight_tuple(time: Time) -> #(Int, Int) {
  let #(ms, _precision) = time.microsecond
  let total_seconds = time.hour * 3600 + time.minute * 60 + time.second
  #(total_seconds, ms)
}

/// Converts time to total microseconds since midnight.
pub fn to_microseconds_after_midnight(time: Time) -> Int {
  let #(ms, _precision) = time.microsecond
  let total_seconds = time.hour * 3600 + time.minute * 60 + time.second
  total_seconds * 1_000_000 + ms
}

/// Creates a Time from seconds since midnight.
pub fn from_seconds_after_midnight(seconds: Int) -> Result(Time, TimeError) {
  from_seconds_after_midnight_with_microsecond(seconds, #(0, 0), "Calendar.ISO")
}

/// Creates a Time from seconds since midnight with microsecond precision.
pub fn from_seconds_after_midnight_with_microsecond(
  seconds: Int,
  microsecond: #(Int, Int),
  calendar: String,
) -> Result(Time, TimeError) {
  case seconds >= 0 && seconds < seconds_per_day {
    True -> {
      let hours = seconds / 3600
      let remaining_seconds = seconds % 3600
      let minutes = remaining_seconds / 60
      let secs = remaining_seconds % 60
      new(hours, minutes, secs, microsecond, calendar)
    }
    False -> Error(InvalidTime)
  }
}

/// Converts a Time to a Unix timestamp (seconds since epoch).
/// Note: This requires a date to be meaningful. This function assumes 
/// the Unix epoch date (1970-01-01) for demonstration purposes.
pub fn to_timestamp(time: Time) -> Int {
  to_seconds_after_midnight(time)
}

/// Creates a Time from a Unix timestamp.
/// Note: This extracts only the time portion, ignoring the date.
pub fn from_timestamp(timestamp: Int) -> Result(Time, TimeError) {
  let seconds_in_day = timestamp % seconds_per_day
  from_seconds_after_midnight(seconds_in_day)
}

/// Returns the current time in UTC.
pub fn utc_now() -> Result(Time, TimeError) {
  utc_now_with_precision(Microsecond, "Calendar.ISO")
}

/// Returns the current time in UTC with specified precision and calendar.
pub fn utc_now_with_precision(
  precision: TimeUnit,
  calendar: String,
) -> Result(Time, TimeError) {
  let #(_seconds, nanoseconds) = system_time()
  let total_seconds = nanoseconds / 1_000_000_000
  let remaining_nanos = nanoseconds % 1_000_000_000
  let microseconds = remaining_nanos / 1000

  let hours = { total_seconds / 3600 } % 24
  let remaining = total_seconds % 3600
  let minutes = remaining / 60
  let seconds = remaining % 60

  let adjusted_precision = case precision {
    Second -> #(0, 0)
    Millisecond -> #(microseconds / 1000 * 1000, 3)
    Microsecond | Native -> #(microseconds, 6)
  }

  new(hours, minutes, seconds, adjusted_precision, calendar)
}

pub type TimeUnit {
  Second
  Millisecond
  Microsecond
  Native
}

/// Creates a new Time, panicking if invalid.
pub fn new_unchecked_bang(
  hour: Int,
  minute: Int,
  second: Int,
  microsecond: #(Int, Int),
  calendar: String,
) -> Time {
  case new(hour, minute, second, microsecond, calendar) {
    Ok(time) -> time
    Error(_) -> panic as "Invalid time"
  }
}

/// Parses an ISO8601 time string.
pub fn from_iso8601(time_string: String) -> Result(Time, TimeError) {
  case parse_iso8601_time(time_string) {
    Ok(#(hour, minute, second, microsecond)) ->
      new(hour, minute, second, microsecond, "Calendar.ISO")
    Error(_) -> Error(InvalidTime)
  }
}

/// Parses an ISO8601 time string, panicking on error.
pub fn from_iso8601_unchecked(time_string: String) -> Time {
  case from_iso8601(time_string) {
    Ok(time) -> time
    Error(_) -> panic as "Invalid ISO8601 time format"
  }
}

/// Converts time to Erlang time tuple.
pub fn to_erl(time: Time) -> #(Int, Int, Int) {
  #(time.hour, time.minute, time.second)
}

/// Creates time from Erlang time tuple.
pub fn from_erl(
  erl_time: #(Int, Int, Int),
  microsecond: #(Int, Int),
  calendar: String,
) -> Result(Time, TimeError) {
  let #(hour, minute, second) = erl_time
  new(hour, minute, second, microsecond, calendar)
}

/// Creates time from Erlang time tuple, panicking on error.
pub fn from_erl_unchecked(
  erl_time: #(Int, Int, Int),
  microsecond: #(Int, Int),
  calendar: String,
) -> Time {
  case from_erl(erl_time, microsecond, calendar) {
    Ok(time) -> time
    Error(_) -> panic as "Invalid Erlang time tuple"
  }
}

/// Adds a duration to a time.
pub fn add(time: Time, amount: Int, unit: TimeUnit) -> Result(Time, TimeError) {
  let total_microseconds = to_microseconds_after_midnight(time)

  let microseconds_to_add = case unit {
    Second -> amount * 1_000_000
    Millisecond -> amount * 1000
    Microsecond -> amount
    Native -> amount
    // Assume microseconds for native
  }

  let new_total = total_microseconds + microseconds_to_add
  let new_seconds = new_total / 1_000_000
  let new_microseconds = new_total % 1_000_000

  case from_seconds_after_midnight(new_seconds % seconds_per_day) {
    Ok(base_time) -> {
      let #(_, precision) = time.microsecond
      case
        new(
          base_time.hour,
          base_time.minute,
          base_time.second,
          #(new_microseconds, precision),
          time.calendar,
        )
      {
        Ok(t) -> Ok(t)
        Error(e) -> Error(e)
      }
    }
    Error(err) -> Error(err)
  }
}

/// Compare two times.
pub type TimeComparison {
  Lt
  Eq
  Gt
}

pub fn compare(time1: Time, time2: Time) -> TimeComparison {
  let ms1 = to_microseconds_after_midnight(time1)
  let ms2 = to_microseconds_after_midnight(time2)

  case ms1 < ms2 {
    True -> Lt
    False ->
      case ms1 > ms2 {
        True -> Gt
        False -> Eq
      }
  }
}

/// Check if first time is before second time.
pub fn before(time1: Time, time2: Time) -> Bool {
  case compare(time1, time2) {
    Lt -> True
    _ -> False
  }
}

/// Check if first time is after second time.
pub fn after(time1: Time, time2: Time) -> Bool {
  case compare(time1, time2) {
    Gt -> True
    _ -> False
  }
}

/// Convert time between calendars.
pub fn convert(time: Time, target_calendar: String) -> Result(Time, TimeError) {
  case time.calendar == target_calendar {
    True -> Ok(time)
    False -> {
      // Simplified conversion - would need proper calendar implementation
      case
        new(
          time.hour,
          time.minute,
          time.second,
          time.microsecond,
          target_calendar,
        )
      {
        Ok(t) -> Ok(t)
        Error(e) -> Error(e)
      }
    }
  }
}

/// Convert time between calendars, panicking on error.
pub fn convert_unchecked(time: Time, target_calendar: String) -> Time {
  case convert(time, target_calendar) {
    Ok(converted) -> converted
    Error(_) -> panic as "Calendar conversion failed"
  }
}

/// Calculate difference between two times.
pub fn diff(time1: Time, time2: Time, unit: TimeUnit) -> Int {
  let ms1 = to_microseconds_after_midnight(time1)
  let ms2 = to_microseconds_after_midnight(time2)
  let diff_microseconds = ms1 - ms2

  case unit {
    Microsecond | Native -> diff_microseconds
    Millisecond -> diff_microseconds / 1000
    Second -> diff_microseconds / 1_000_000
  }
}

/// Shift time by a duration.
pub fn shift(
  time: Time,
  duration: calendar_duration.Duration,
) -> Result(Time, TimeError) {
  let total_seconds =
    duration.hour * 3600 + duration.minute * 60 + duration.second

  let #(duration_ms, _) = duration.microsecond
  let total_microseconds = total_seconds * 1_000_000 + duration_ms

  add(time, total_microseconds, Microsecond)
}

/// Truncate time precision.
pub fn truncate(time: Time, precision: Int) -> Time {
  let #(ms, _) = time.microsecond
  let truncated_ms = case precision {
    0 -> #(0, 0)
    p if p >= 6 -> #(ms, 6)
    p -> {
      let divisor = case p {
        1 -> 100_000
        2 -> 10_000
        3 -> 1000
        4 -> 100
        5 -> 10
        _ -> 1
      }
      #(ms / divisor * divisor, p)
    }
  }

  case new(time.hour, time.minute, time.second, truncated_ms, time.calendar) {
    Ok(t) -> t
    Error(_) -> time
    // Return original time if truncation fails
  }
}

/// Get string representation for inspection.
pub fn inspect(time: Time) -> String {
  "~T[" <> to_string(time) <> "]"
}

/// Check if a time is valid.
pub fn is_valid(
  hour: Int,
  minute: Int,
  second: Int,
  microsecond: #(Int, Int),
) -> Bool {
  is_valid_time(hour, minute, second, microsecond)
}

/// Get the maximum precision for a time unit.
pub fn max_precision(unit: TimeUnit) -> Int {
  case unit {
    Second -> 0
    Millisecond -> 3
    Microsecond | Native -> 6
  }
}

/// Normalize microseconds to a specific precision.
pub fn normalize_precision(
  microsecond: #(Int, Int),
  target_precision: Int,
) -> #(Int, Int) {
  let #(ms, current_precision) = microsecond
  case target_precision >= current_precision {
    True -> #(
      ms * int_pow(10, target_precision - current_precision),
      target_precision,
    )
    False -> #(
      ms / int_pow(10, current_precision - target_precision),
      target_precision,
    )
  }
}

/// Convert between time units.
pub fn convert_unit(amount: Int, from_unit: TimeUnit, to_unit: TimeUnit) -> Int {
  let microseconds = case from_unit {
    Second -> amount * 1_000_000
    Millisecond -> amount * 1000
    Microsecond | Native -> amount
  }

  case to_unit {
    Second -> microseconds / 1_000_000
    Millisecond -> microseconds / 1000
    Microsecond | Native -> microseconds
  }
}

/// Get the time at midnight (00:00:00).
pub fn midnight() -> Result(Time, TimeError) {
  new(0, 0, 0, #(0, 0), "Calendar.ISO")
}

/// Get the time at noon (12:00:00).
pub fn noon() -> Result(Time, TimeError) {
  new(12, 0, 0, #(0, 0), "Calendar.ISO")
}

/// Check if a time is at midnight.
pub fn is_midnight(time: Time) -> Bool {
  time.hour == 0
  && time.minute == 0
  && time.second == 0
  && time.microsecond == #(0, 0)
}

/// Get the second of the day (0-86399).
pub fn second_of_day(time: Time) -> Int {
  time.hour * 3600 + time.minute * 60 + time.second
}

// Helper functions

fn parse_iso8601_time(
  time_string: String,
) -> Result(#(Int, Int, Int, #(Int, Int)), Nil) {
  // Simplified parsing - would need full ISO8601 implementation
  case string.split(time_string, ":") {
    [hour_str, minute_str, second_part] -> {
      case int.parse(hour_str), int.parse(minute_str) {
        Ok(hour), Ok(minute) -> {
          case string.split(second_part, ".") {
            [second_str] -> {
              case int.parse(second_str) {
                Ok(second) -> Ok(#(hour, minute, second, #(0, 0)))
                Error(_) -> Error(Nil)
              }
            }
            [second_str, ms_str] -> {
              case int.parse(second_str), int.parse(ms_str) {
                Ok(second), Ok(ms) -> {
                  let precision = string.length(ms_str)
                  let normalized_ms = normalize_microseconds(ms, precision)
                  Ok(#(hour, minute, second, #(normalized_ms, precision)))
                }
                _, _ -> Error(Nil)
              }
            }
            _ -> Error(Nil)
          }
        }
        _, _ -> Error(Nil)
      }
    }
    _ -> Error(Nil)
  }
}

fn normalize_microseconds(ms: Int, precision: Int) -> Int {
  case precision {
    p if p >= 6 -> ms
    p -> ms * int_pow(10, 6 - p)
  }
}

fn int_pow(base: Int, exp: Int) -> Int {
  case exp {
    0 -> 1
    n if n > 0 -> base * int_pow(base, n - 1)
    _ -> 1
  }
}

/// Helper function to pad single digits with leading zero.
fn pad_zero(n: Int) -> String {
  case n < 10 {
    True -> "0" <> int.to_string(n)
    False -> int.to_string(n)
  }
}

/// Helper function to format microseconds with proper padding.
fn pad_microseconds(microseconds: Int, precision: Int) -> String {
  let ms_str = int.to_string(microseconds)
  // Pad with leading zeros to ensure we have at least precision digits
  let padded = case string.length(ms_str) < precision {
    True -> string.repeat("0", precision - string.length(ms_str)) <> ms_str
    False -> ms_str
  }
  // Take only the first precision digits
  string.slice(padded, 0, precision)
}
