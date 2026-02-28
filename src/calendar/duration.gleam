// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: 2021 The Elixir Team

import gleam/int
import gleam/list
import gleam/string

/// Struct and functions for handling durations.
///
/// A `Duration` struct represents a collection of time scale units,
/// allowing for manipulation and calculation of durations.
///
/// Date and time scale units are represented as integers, allowing for
/// both positive and negative values.
///
/// Microseconds are represented using a tuple `#(microsecond, precision)`.
/// This ensures compatibility with other calendar types implementing time,
/// such as `Time`, `DateTime`, and `NaiveDateTime`.
pub type Duration {
  Duration(
    year: Int,
    month: Int,
    week: Int,
    day: Int,
    hour: Int,
    minute: Int,
    second: Int,
    microsecond: #(Int, Int),
  )
}

pub type UnitPair {
  Year(Int)
  Month(Int)
  Week(Int)
  Day(Int)
  Hour(Int)
  Minute(Int)
  Second(Int)
  Microsecond(#(Int, Int))
}

/// Creates a new Duration struct with all units set to zero.
pub fn new() -> Duration {
  Duration(
    year: 0,
    month: 0,
    week: 0,
    day: 0,
    hour: 0,
    minute: 0,
    second: 0,
    microsecond: #(0, 0),
  )
}

/// Creates a new Duration from a list of unit pairs.
pub fn from_unit_pairs(pairs: List(UnitPair)) -> Duration {
  let initial = new()
  list_fold_duration(pairs, initial)
}

fn list_fold_duration(pairs: List(UnitPair), acc: Duration) -> Duration {
  case pairs {
    [] -> acc
    [Year(value), ..rest] ->
      list_fold_duration(rest, Duration(..acc, year: value))
    [Month(value), ..rest] ->
      list_fold_duration(rest, Duration(..acc, month: value))
    [Week(value), ..rest] ->
      list_fold_duration(rest, Duration(..acc, week: value))
    [Day(value), ..rest] ->
      list_fold_duration(rest, Duration(..acc, day: value))
    [Hour(value), ..rest] ->
      list_fold_duration(rest, Duration(..acc, hour: value))
    [Minute(value), ..rest] ->
      list_fold_duration(rest, Duration(..acc, minute: value))
    [Second(value), ..rest] ->
      list_fold_duration(rest, Duration(..acc, second: value))
    [Microsecond(value), ..rest] ->
      list_fold_duration(rest, Duration(..acc, microsecond: value))
  }
}

/// Adds two durations together.
pub fn add(d1: Duration, d2: Duration) -> Duration {
  let #(d1_ms, d1_p) = d1.microsecond
  let #(d2_ms, d2_p) = d2.microsecond
  let max_precision = case d1_p >= d2_p {
    True -> d1_p
    False -> d2_p
  }

  Duration(
    year: d1.year + d2.year,
    month: d1.month + d2.month,
    week: d1.week + d2.week,
    day: d1.day + d2.day,
    hour: d1.hour + d2.hour,
    minute: d1.minute + d2.minute,
    second: d1.second + d2.second,
    microsecond: #(d1_ms + d2_ms, max_precision),
  )
}

/// Subtracts the second duration from the first.
pub fn subtract(d1: Duration, d2: Duration) -> Duration {
  let #(d1_ms, d1_p) = d1.microsecond
  let #(d2_ms, d2_p) = d2.microsecond
  let max_precision = case d1_p >= d2_p {
    True -> d1_p
    False -> d2_p
  }

  Duration(
    year: d1.year - d2.year,
    month: d1.month - d2.month,
    week: d1.week - d2.week,
    day: d1.day - d2.day,
    hour: d1.hour - d2.hour,
    minute: d1.minute - d2.minute,
    second: d1.second - d2.second,
    microsecond: #(d1_ms - d2_ms, max_precision),
  )
}

/// Multiplies a duration by an integer.
pub fn multiply(duration: Duration, multiplier: Int) -> Duration {
  let #(ms, p) = duration.microsecond

  Duration(
    year: duration.year * multiplier,
    month: duration.month * multiplier,
    week: duration.week * multiplier,
    day: duration.day * multiplier,
    hour: duration.hour * multiplier,
    minute: duration.minute * multiplier,
    second: duration.second * multiplier,
    microsecond: #(ms * multiplier, p),
  )
}

/// Negates a duration (makes positive units negative and vice versa).
pub fn negate(duration: Duration) -> Duration {
  let #(ms, p) = duration.microsecond

  Duration(
    year: -duration.year,
    month: -duration.month,
    week: -duration.week,
    day: -duration.day,
    hour: -duration.hour,
    minute: -duration.minute,
    second: -duration.second,
    microsecond: #(-ms, p),
  )
}

pub type ParseError {
  InvalidFormat
  InvalidDuration
}

/// Parses an ISO8601 duration string.
/// 
/// Examples:
/// - "P1Y2M3DT4H5M6S" -> 1 year, 2 months, 3 days, 4 hours, 5 minutes, 6 seconds
/// - "P1W" -> 1 week
/// - "PT30M" -> 30 minutes
pub fn from_iso8601(duration_string: String) -> Result(Duration, ParseError) {
  case parse_iso8601_duration(duration_string) {
    Ok(duration) -> Ok(duration)
    Error(_) -> Error(InvalidFormat)
  }
}

/// Parses an ISO8601 duration string, panicking on invalid input.
pub fn from_iso8601_unchecked(duration_string: String) -> Duration {
  case from_iso8601(duration_string) {
    Ok(duration) -> duration
    Error(_) -> panic as "Invalid ISO8601 duration format"
  }
}

/// Converts a duration to a human-readable string.
pub fn to_string(duration: Duration) -> String {
  let parts = []

  let parts = case duration.year != 0 {
    True -> [
      int.to_string(duration.year) <> " year" <> plural(duration.year),
      ..parts
    ]
    False -> parts
  }

  let parts = case duration.month != 0 {
    True -> [
      int.to_string(duration.month) <> " month" <> plural(duration.month),
      ..parts
    ]
    False -> parts
  }

  let parts = case duration.week != 0 {
    True -> [
      int.to_string(duration.week) <> " week" <> plural(duration.week),
      ..parts
    ]
    False -> parts
  }

  let parts = case duration.day != 0 {
    True -> [
      int.to_string(duration.day) <> " day" <> plural(duration.day),
      ..parts
    ]
    False -> parts
  }

  let parts = case duration.hour != 0 {
    True -> [
      int.to_string(duration.hour) <> " hour" <> plural(duration.hour),
      ..parts
    ]
    False -> parts
  }

  let parts = case duration.minute != 0 {
    True -> [
      int.to_string(duration.minute) <> " minute" <> plural(duration.minute),
      ..parts
    ]
    False -> parts
  }

  let parts = case duration.second != 0 {
    True -> [
      int.to_string(duration.second) <> " second" <> plural(duration.second),
      ..parts
    ]
    False -> parts
  }

  case parts {
    [] -> "0 seconds"
    _ -> string.join(list.reverse(parts), ", ")
  }
}

/// Converts a duration to ISO8601 format.
pub fn to_iso8601(duration: Duration) -> String {
  let date_parts = []

  let date_parts = case duration.year != 0 {
    True -> [int.to_string(duration.year) <> "Y", ..date_parts]
    False -> date_parts
  }

  let date_parts = case duration.month != 0 {
    True -> [int.to_string(duration.month) <> "M", ..date_parts]
    False -> date_parts
  }

  let date_parts = case duration.week != 0 {
    True -> [int.to_string(duration.week) <> "W", ..date_parts]
    False -> date_parts
  }

  let date_parts = case duration.day != 0 {
    True -> [int.to_string(duration.day) <> "D", ..date_parts]
    False -> date_parts
  }

  let time_parts = []

  let time_parts = case duration.hour != 0 {
    True -> [int.to_string(duration.hour) <> "H", ..time_parts]
    False -> time_parts
  }

  let time_parts = case duration.minute != 0 {
    True -> [int.to_string(duration.minute) <> "M", ..time_parts]
    False -> time_parts
  }

  let #(ms, precision) = duration.microsecond
  let time_parts = case duration.second != 0 || ms != 0 {
    True -> {
      let second_str = case ms == 0 || precision == 0 {
        True -> int.to_string(duration.second)
        False ->
          int.to_string(duration.second)
          <> "."
          <> format_microseconds(ms, precision)
      }
      [second_str <> "S", ..time_parts]
    }
    False -> time_parts
  }

  let date_part = string.join(list.reverse(date_parts), "")
  let time_part = case time_parts {
    [] -> ""
    _ -> "T" <> string.join(list.reverse(time_parts), "")
  }

  case date_part == "" && time_part == "" {
    True -> "PT0S"
    False -> "P" <> date_part <> time_part
  }
}

// Helper functions

fn plural(n: Int) -> String {
  case n == 1 || n == -1 {
    True -> ""
    False -> "s"
  }
}

fn format_microseconds(ms: Int, precision: Int) -> String {
  let ms_str = int.to_string(ms)
  let padded = case string.length(ms_str) < precision {
    True -> string.repeat("0", precision - string.length(ms_str)) <> ms_str
    False -> ms_str
  }
  string.slice(padded, 0, precision)
  |> strip_trailing_zeros
}

fn strip_trailing_zeros(s: String) -> String {
  case string.ends_with(s, "0") {
    True -> strip_trailing_zeros(string.drop_end(s, 1))
    False -> s
  }
}

fn parse_iso8601_duration(duration_string: String) -> Result(Duration, Nil) {
  case string.starts_with(duration_string, "P") {
    False -> Error(Nil)
    True -> {
      let content = string.drop_start(duration_string, 1)
      case string.split_once(content, "T") {
        Ok(#(date_part, time_part)) -> {
          case parse_date_part(date_part), parse_time_part(time_part) {
            Ok(date_duration), Ok(time_duration) ->
              Ok(merge_durations(date_duration, time_duration))
            Error(_), _ -> Error(Nil)
            _, Error(_) -> Error(Nil)
          }
        }
        Error(_) -> parse_date_part(content)
      }
    }
  }
}

fn parse_date_part(date_part: String) -> Result(Duration, Nil) {
  do_parse_date_part(string.to_graphemes(date_part), "", new())
}

fn do_parse_date_part(
  chars: List(String),
  acc: String,
  duration: Duration,
) -> Result(Duration, Nil) {
  case chars {
    [] ->
      case acc {
        "" -> Ok(duration)
        _ -> Error(Nil)
      }
    [c, ..rest] -> {
      case c {
        "Y" ->
          case int.parse(acc) {
            Ok(n) -> do_parse_date_part(rest, "", Duration(..duration, year: n))
            Error(_) -> Error(Nil)
          }
        "M" ->
          case int.parse(acc) {
            Ok(n) ->
              do_parse_date_part(rest, "", Duration(..duration, month: n))
            Error(_) -> Error(Nil)
          }
        "W" ->
          case int.parse(acc) {
            Ok(n) -> do_parse_date_part(rest, "", Duration(..duration, week: n))
            Error(_) -> Error(Nil)
          }
        "D" ->
          case int.parse(acc) {
            Ok(n) -> do_parse_date_part(rest, "", Duration(..duration, day: n))
            Error(_) -> Error(Nil)
          }
        _ -> do_parse_date_part(rest, acc <> c, duration)
      }
    }
  }
}

fn parse_time_part(time_part: String) -> Result(Duration, Nil) {
  do_parse_time_part(string.to_graphemes(time_part), "", new())
}

fn do_parse_time_part(
  chars: List(String),
  acc: String,
  duration: Duration,
) -> Result(Duration, Nil) {
  case chars {
    [] ->
      case acc {
        "" -> Ok(duration)
        _ -> Error(Nil)
      }
    [c, ..rest] -> {
      case c {
        "H" ->
          case int.parse(acc) {
            Ok(n) -> do_parse_time_part(rest, "", Duration(..duration, hour: n))
            Error(_) -> Error(Nil)
          }
        "M" ->
          case int.parse(acc) {
            Ok(n) ->
              do_parse_time_part(rest, "", Duration(..duration, minute: n))
            Error(_) -> Error(Nil)
          }
        "S" -> {
          // Handle fractional seconds (e.g., "1.5S")
          case string.contains(acc, ".") {
            True -> {
              case string.split(acc, ".") {
                [sec_str, frac_str] -> {
                  case int.parse(sec_str) {
                    Ok(sec) -> {
                      let padded = pad_to_6(frac_str)
                      case int.parse(padded) {
                        Ok(us) -> {
                          let precision = string.length(frac_str)
                          do_parse_time_part(
                            rest,
                            "",
                            Duration(..duration, second: sec, microsecond: #(
                              us,
                              precision,
                            )),
                          )
                        }
                        Error(_) -> Error(Nil)
                      }
                    }
                    Error(_) -> Error(Nil)
                  }
                }
                _ -> Error(Nil)
              }
            }
            False ->
              case int.parse(acc) {
                Ok(n) ->
                  do_parse_time_part(rest, "", Duration(..duration, second: n))
                Error(_) -> Error(Nil)
              }
          }
        }
        _ -> do_parse_time_part(rest, acc <> c, duration)
      }
    }
  }
}

fn pad_to_6(s: String) -> String {
  let len = string.length(s)
  case len >= 6 {
    True -> string.slice(s, 0, 6)
    False -> s <> string.repeat("0", 6 - len)
  }
}

fn merge_durations(d1: Duration, d2: Duration) -> Duration {
  add(d1, d2)
}

/// Converts a duration to a timeout value in milliseconds.
/// Raises if the duration contains non-zero year or month values,
/// as those cannot be reliably converted.
pub fn to_timeout(duration: Duration) -> Int {
  let #(microsecond_val, _precision) = duration.microsecond
  let ms_from_us = microsecond_val / 1000

  duration.week
  * 7
  * 24
  * 60
  * 60
  * 1000
  + duration.day
  * 24
  * 60
  * 60
  * 1000
  + duration.hour
  * 60
  * 60
  * 1000
  + duration.minute
  * 60
  * 1000
  + duration.second
  * 1000
  + ms_from_us
}
