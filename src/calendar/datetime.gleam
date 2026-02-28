// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: 2021 The Elixir Team
// SPDX-FileCopyrightText: 2012 Plataformatec

import calendar/date
import calendar/duration
import calendar/iso
import calendar/naive_datetime
import calendar/time
import gleam/int
import gleam/order
import gleam/string

@external(erlang, "os", "system_time")
@external(javascript, "../os_ffi.mjs", "system_time")
fn system_time_native() -> Int

/// A datetime implementation with a time zone.
///
/// This datetime can be seen as a snapshot of a date and time
/// at a given time zone. For such purposes, it also includes both
/// UTC and Standard offsets, as well as the zone abbreviation
/// field used exclusively for formatting purposes.
pub type DateTime {
  DateTime(
    year: Int,
    month: Int,
    day: Int,
    hour: Int,
    minute: Int,
    second: Int,
    time_zone: String,
    zone_abbr: String,
    utc_offset: Int,
    std_offset: Int,
    microsecond: #(Int, Int),
    calendar: String,
  )
}

pub type DateTimeError {
  InvalidDateTime
  InvalidDate
  InvalidTime
  InvalidFormat
  TimeZoneNotFound
  UtcOnlyTimeZoneDatabase
  AmbiguousTime
  GapInTime
}

pub type DateTimeFormat {
  Extended
  Basic
}

pub type TimeUnit {
  Native
  Second
  Millisecond
  Microsecond
  Nanosecond
}

/// Creates a new DateTime struct.
pub fn new(
  year: Int,
  month: Int,
  day: Int,
  hour: Int,
  minute: Int,
  second: Int,
  time_zone: String,
  zone_abbr: String,
  utc_offset: Int,
  std_offset: Int,
  microsecond: #(Int, Int),
  calendar: String,
) -> Result(DateTime, DateTimeError) {
  // Validate date component
  case date.new(year, month, day, calendar) {
    Error(_) -> Error(InvalidDate)
    Ok(_) -> {
      // Validate time component
      case time.new(hour, minute, second, microsecond, calendar) {
        Error(_) -> Error(InvalidTime)
        Ok(_) ->
          Ok(DateTime(
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute,
            second: second,
            time_zone: time_zone,
            zone_abbr: zone_abbr,
            utc_offset: utc_offset,
            std_offset: std_offset,
            microsecond: microsecond,
            calendar: calendar,
          ))
      }
    }
  }
}

/// Creates a UTC DateTime from date and time components.
pub fn new_utc(
  year: Int,
  month: Int,
  day: Int,
  hour: Int,
  minute: Int,
  second: Int,
  microsecond: #(Int, Int),
  calendar: String,
) -> Result(DateTime, DateTimeError) {
  new(
    year,
    month,
    day,
    hour,
    minute,
    second,
    "Etc/UTC",
    "UTC",
    0,
    0,
    microsecond,
    calendar,
  )
}

/// Creates a simple UTC DateTime with default values.
pub fn new_utc_simple(
  year: Int,
  month: Int,
  day: Int,
  hour: Int,
  minute: Int,
  second: Int,
) -> Result(DateTime, DateTimeError) {
  new_utc(year, month, day, hour, minute, second, #(0, 0), "Calendar.ISO")
}

/// Creates a DateTime from a NaiveDateTime and timezone information.
pub fn from_naive_datetime(
  ndt: naive_datetime.NaiveDateTime,
  time_zone: String,
  zone_abbr: String,
  utc_offset: Int,
  std_offset: Int,
) -> DateTime {
  DateTime(
    year: ndt.year,
    month: ndt.month,
    day: ndt.day,
    hour: ndt.hour,
    minute: ndt.minute,
    second: ndt.second,
    time_zone: time_zone,
    zone_abbr: zone_abbr,
    utc_offset: utc_offset,
    std_offset: std_offset,
    microsecond: ndt.microsecond,
    calendar: ndt.calendar,
  )
}

/// Converts a DateTime to a string with timezone information.
pub fn to_string(dt: DateTime) -> String {
  let date_part =
    pad_left(int.to_string(dt.year), 4, "0")
    <> "-"
    <> pad_left(int.to_string(dt.month), 2, "0")
    <> "-"
    <> pad_left(int.to_string(dt.day), 2, "0")

  let time_part =
    pad_left(int.to_string(dt.hour), 2, "0")
    <> ":"
    <> pad_left(int.to_string(dt.minute), 2, "0")
    <> ":"
    <> pad_left(int.to_string(dt.second), 2, "0")

  let #(ms, precision) = dt.microsecond
  let microsecond_part = case ms == 0 || precision == 0 {
    True -> ""
    False -> "." <> pad_microseconds(ms, precision)
  }

  let offset_part = format_offset(dt.utc_offset + dt.std_offset)

  date_part
  <> " "
  <> time_part
  <> microsecond_part
  <> offset_part
  <> " "
  <> dt.zone_abbr
}

/// Converts a DateTime to ISO8601 format with timezone.
pub fn to_iso8601(dt: DateTime) -> String {
  let date_part =
    pad_left(int.to_string(dt.year), 4, "0")
    <> "-"
    <> pad_left(int.to_string(dt.month), 2, "0")
    <> "-"
    <> pad_left(int.to_string(dt.day), 2, "0")

  let time_part =
    pad_left(int.to_string(dt.hour), 2, "0")
    <> ":"
    <> pad_left(int.to_string(dt.minute), 2, "0")
    <> ":"
    <> pad_left(int.to_string(dt.second), 2, "0")

  let #(ms, precision) = dt.microsecond
  let microsecond_part = case ms == 0 || precision == 0 {
    True -> ""
    False -> "." <> pad_microseconds(ms, precision)
  }

  let offset_part = case dt.time_zone == "Etc/UTC" {
    True -> "Z"
    False -> format_offset(dt.utc_offset + dt.std_offset)
  }

  date_part <> "T" <> time_part <> microsecond_part <> offset_part
}

/// Extracts the NaiveDateTime part from a DateTime.
pub fn to_naive_datetime(dt: DateTime) -> naive_datetime.NaiveDateTime {
  case
    naive_datetime.new(
      dt.year,
      dt.month,
      dt.day,
      dt.hour,
      dt.minute,
      dt.second,
      dt.microsecond,
      dt.calendar,
    )
  {
    Ok(ndt) -> ndt
    Error(_) -> panic as "Invalid datetime in valid DateTime struct"
  }
}

/// Extracts the Date part from a DateTime.
pub fn to_date(dt: DateTime) -> date.Date {
  case date.new(dt.year, dt.month, dt.day, dt.calendar) {
    Ok(d) -> d
    Error(_) -> panic as "Invalid date in valid DateTime struct"
  }
}

/// Extracts the Time part from a DateTime.
pub fn to_time(dt: DateTime) -> time.Time {
  case time.new(dt.hour, dt.minute, dt.second, dt.microsecond, dt.calendar) {
    Ok(t) -> t
    Error(_) -> panic as "Invalid time in valid DateTime struct"
  }
}

pub fn compare(dt1: DateTime, dt2: DateTime) -> order.Order {
  let utc1 = to_utc_timestamp(dt1)
  let utc2 = to_utc_timestamp(dt2)
  int.compare(utc1, utc2)
}

/// Convert DateTime to UTC timestamp.
pub fn to_utc_timestamp(dt: DateTime) -> Int {
  let local_timestamp = to_local_timestamp(dt)
  local_timestamp - { dt.utc_offset + dt.std_offset }
}

/// Convert DateTime to local timestamp.
pub fn to_local_timestamp(dt: DateTime) -> Int {
  let date_part = to_date(dt)
  let date_timestamp = date.to_timestamp(date_part)
  let time_seconds = dt.hour * 3600 + dt.minute * 60 + dt.second
  date_timestamp + time_seconds
}

/// Create DateTime from UTC timestamp.
pub fn from_utc_timestamp(
  timestamp: Int,
  time_zone: String,
) -> Result(DateTime, DateTimeError) {
  case time_zone == "Etc/UTC" {
    True -> {
      case naive_datetime.from_timestamp(timestamp) {
        Error(_) -> Error(InvalidDateTime)
        Ok(ndt) -> {
          Ok(from_naive_datetime(ndt, "Etc/UTC", "UTC", 0, 0))
        }
      }
    }
    False -> Error(UtcOnlyTimeZoneDatabase)
  }
}

/// Add seconds to a DateTime (adjusts UTC time).
pub fn add_seconds(
  dt: DateTime,
  seconds: Int,
) -> Result(DateTime, DateTimeError) {
  let utc_timestamp = to_utc_timestamp(dt)
  from_utc_timestamp(utc_timestamp + seconds, dt.time_zone)
}

/// Helper functions
fn pad_left(str: String, width: Int, pad_char: String) -> String {
  let current_length = string.length(str)
  case current_length >= width {
    True -> str
    False -> string.repeat(pad_char, width - current_length) <> str
  }
}

fn pad_microseconds(microseconds: Int, precision: Int) -> String {
  let ms_str = int.to_string(microseconds)
  let padded = case string.length(ms_str) < precision {
    True -> string.repeat("0", precision - string.length(ms_str)) <> ms_str
    False -> ms_str
  }
  string.slice(padded, 0, precision)
}

fn format_offset(total_offset: Int) -> String {
  case total_offset == 0 {
    True -> "+00:00"
    False -> {
      let sign = case total_offset >= 0 {
        True -> "+"
        False -> "-"
      }
      let abs_offset = case total_offset < 0 {
        True -> -total_offset
        False -> total_offset
      }
      let hours = abs_offset / 3600
      let minutes = { abs_offset % 3600 } / 60

      sign
      <> pad_left(int.to_string(hours), 2, "0")
      <> ":"
      <> pad_left(int.to_string(minutes), 2, "0")
    }
  }
}

// Additional DateTime functions to match Elixir implementation

/// Returns the current datetime in UTC.
pub fn utc_now() -> Result(DateTime, DateTimeError) {
  utc_now_with_precision(Native, "Calendar.ISO")
}

/// Returns the current datetime in UTC with specified precision and calendar.
pub fn utc_now_with_precision(
  time_unit: TimeUnit,
  calendar: String,
) -> Result(DateTime, DateTimeError) {
  let timestamp = system_time_native()
  case from_unix(timestamp, time_unit, calendar) {
    Ok(dt) -> Ok(dt)
    Error(_) ->
      new(1970, 1, 1, 0, 0, 0, "Etc/UTC", "UTC", 0, 0, #(0, 0), calendar)
  }
}

/// Creates a DateTime from Date and Time structs with UTC timezone.
pub fn new_from_date_and_time(
  date_val: date.Date,
  time_val: time.Time,
) -> Result(DateTime, DateTimeError) {
  case date_val.calendar == time_val.calendar {
    False -> Error(InvalidDateTime)
    True ->
      new_utc(
        date_val.year,
        date_val.month,
        date_val.day,
        time_val.hour,
        time_val.minute,
        time_val.second,
        time_val.microsecond,
        date_val.calendar,
      )
  }
}

/// Creates a DateTime from Date and Time structs with specified timezone.
pub fn new_from_date_and_time_with_tz(
  date_val: date.Date,
  time_val: time.Time,
  time_zone: String,
  zone_abbr: String,
  utc_offset: Int,
  std_offset: Int,
) -> Result(DateTime, DateTimeError) {
  case date_val.calendar == time_val.calendar {
    False -> Error(InvalidDateTime)
    True ->
      new(
        date_val.year,
        date_val.month,
        date_val.day,
        time_val.hour,
        time_val.minute,
        time_val.second,
        time_zone,
        zone_abbr,
        utc_offset,
        std_offset,
        time_val.microsecond,
        date_val.calendar,
      )
  }
}

/// Converts a Unix timestamp to a DateTime.
pub fn from_unix(
  timestamp: Int,
  unit: TimeUnit,
  _calendar: String,
) -> Result(DateTime, DateTimeError) {
  let seconds = convert_to_seconds(timestamp, unit)
  case naive_datetime.from_timestamp(seconds) {
    Error(_) -> Error(InvalidDateTime)
    Ok(ndt) -> {
      Ok(from_naive_datetime(ndt, "Etc/UTC", "UTC", 0, 0))
    }
  }
}

/// Converts a DateTime to Unix timestamp.
pub fn to_unix(dt: DateTime, unit: TimeUnit) -> Int {
  let utc_seconds = to_utc_timestamp(dt)
  convert_from_seconds(utc_seconds, unit)
}

/// Creates a DateTime from NaiveDateTime with UTC timezone.
pub fn from_naive_utc(ndt: naive_datetime.NaiveDateTime) -> DateTime {
  from_naive_datetime(ndt, "Etc/UTC", "UTC", 0, 0)
}

/// Creates a DateTime from NaiveDateTime with specified timezone.
pub fn from_naive_with_timezone(
  ndt: naive_datetime.NaiveDateTime,
  time_zone: String,
  zone_abbr: String,
  utc_offset: Int,
  std_offset: Int,
) -> Result(DateTime, DateTimeError) {
  Ok(from_naive_datetime(ndt, time_zone, zone_abbr, utc_offset, std_offset))
}

/// Shifts a DateTime to a different timezone.
pub fn shift_zone(
  dt: DateTime,
  time_zone: String,
  zone_abbr: String,
  utc_offset: Int,
  std_offset: Int,
) -> Result(DateTime, DateTimeError) {
  case time_zone == dt.time_zone {
    True -> Ok(dt)
    False -> {
      let utc_timestamp = to_utc_timestamp(dt)
      let adjusted_timestamp = utc_timestamp + utc_offset + std_offset
      case naive_datetime.from_timestamp(adjusted_timestamp) {
        Error(_) -> Error(InvalidDateTime)
        Ok(ndt) ->
          Ok(from_naive_datetime(
            ndt,
            time_zone,
            zone_abbr,
            utc_offset,
            std_offset,
          ))
      }
    }
  }
}

/// Returns the current datetime in a specific timezone.
pub fn now(
  time_zone: String,
  zone_abbr: String,
  utc_offset: Int,
  std_offset: Int,
) -> Result(DateTime, DateTimeError) {
  case utc_now() {
    Ok(utc_dt) ->
      shift_zone(utc_dt, time_zone, zone_abbr, utc_offset, std_offset)
    Error(e) -> Error(e)
  }
}

/// Parses an ISO 8601 datetime string.
pub fn from_iso8601(string: String) -> Result(DateTime, DateTimeError) {
  parse_iso8601_datetime(string, "Calendar.ISO")
}

/// Parses an ISO 8601 datetime string with specified calendar.
pub fn from_iso8601_with_calendar(
  string: String,
  calendar: String,
) -> Result(DateTime, DateTimeError) {
  parse_iso8601_datetime(string, calendar)
}

/// Converts DateTime to ISO 8601 with format option.
pub fn to_iso8601_with_format(dt: DateTime, format: DateTimeFormat) -> String {
  case format {
    Extended -> to_iso8601(dt)
    Basic -> to_iso8601_basic(dt)
  }
}

/// Converts DateTime to basic ISO 8601 format.
pub fn to_iso8601_basic(dt: DateTime) -> String {
  let date_part =
    pad_left(int.to_string(dt.year), 4, "0")
    <> pad_left(int.to_string(dt.month), 2, "0")
    <> pad_left(int.to_string(dt.day), 2, "0")

  let time_part =
    pad_left(int.to_string(dt.hour), 2, "0")
    <> pad_left(int.to_string(dt.minute), 2, "0")
    <> pad_left(int.to_string(dt.second), 2, "0")

  let #(ms, precision) = dt.microsecond
  let microsecond_part = case ms == 0 || precision == 0 {
    True -> ""
    False -> "." <> pad_microseconds(ms, precision)
  }

  let offset_part = case dt.time_zone == "Etc/UTC" {
    True -> "Z"
    False -> format_offset_basic(dt.utc_offset + dt.std_offset)
  }

  date_part <> "T" <> time_part <> microsecond_part <> offset_part
}

/// Converts DateTime to Erlang datetime tuple.
pub fn to_erl(dt: DateTime) -> #(#(Int, Int, Int), #(Int, Int, Int)) {
  #(#(dt.year, dt.month, dt.day), #(dt.hour, dt.minute, dt.second))
}

/// Creates DateTime from Erlang datetime tuple.
pub fn from_erl(
  erl_datetime: #(#(Int, Int, Int), #(Int, Int, Int)),
  time_zone: String,
  zone_abbr: String,
  utc_offset: Int,
  std_offset: Int,
) -> Result(DateTime, DateTimeError) {
  let #(#(year, month, day), #(hour, minute, second)) = erl_datetime
  new(
    year,
    month,
    day,
    hour,
    minute,
    second,
    time_zone,
    zone_abbr,
    utc_offset,
    std_offset,
    #(0, 0),
    "Calendar.ISO",
  )
}

/// Returns `true` if the first datetime is strictly earlier than the second.
pub fn before(dt1: DateTime, dt2: DateTime) -> Bool {
  case compare(dt1, dt2) {
    order.Lt -> True
    _ -> False
  }
}

/// Returns `true` if the first datetime is strictly later than the second.
pub fn after(dt1: DateTime, dt2: DateTime) -> Bool {
  case compare(dt1, dt2) {
    order.Gt -> True
    _ -> False
  }
}

/// Calculates the difference between two datetimes in the specified unit.
pub fn diff(dt1: DateTime, dt2: DateTime, unit: TimeUnit) -> Int {
  let timestamp1 = to_utc_timestamp(dt1)
  let timestamp2 = to_utc_timestamp(dt2)
  let diff_seconds = timestamp1 - timestamp2
  convert_from_seconds(diff_seconds, unit)
}

/// Adds an amount of time to a DateTime in the given unit.
pub fn add(
  dt: DateTime,
  amount: Int,
  unit: TimeUnit,
) -> Result(DateTime, DateTimeError) {
  let seconds = convert_to_seconds(amount, unit)
  add_seconds(dt, seconds)
}

/// Adds time to a DateTime using Duration.
pub fn shift(
  dt: DateTime,
  dur: duration.Duration,
) -> Result(DateTime, DateTimeError) {
  let month_shift = dur.year * 12 + dur.month
  let day_shift = dur.week * 7 + dur.day
  let #(us, _) = dur.microsecond

  let #(y, m, d, h, min, s, microsecond) =
    iso.shift_naive_datetime(
      dt.year,
      dt.month,
      dt.day,
      dt.hour,
      dt.minute,
      dt.second,
      dt.microsecond,
      month_shift,
      day_shift,
      dur.hour * 3600 + dur.minute * 60 + dur.second,
      us,
    )

  new(
    y,
    m,
    d,
    h,
    min,
    s,
    dt.time_zone,
    dt.zone_abbr,
    dt.utc_offset,
    dt.std_offset,
    microsecond,
    dt.calendar,
  )
}

/// Returns the given datetime with the microsecond field truncated to the given precision.
pub fn truncate(dt: DateTime, precision: Int) -> DateTime {
  let #(ms, _) = dt.microsecond
  let truncated_ms = case precision {
    0 -> 0
    1 -> { ms / 100_000 } * 100_000
    2 -> { ms / 10_000 } * 10_000
    3 -> { ms / 1000 } * 1000
    4 -> { ms / 100 } * 100
    5 -> { ms / 10 } * 10
    _ -> ms
  }

  DateTime(
    year: dt.year,
    month: dt.month,
    day: dt.day,
    hour: dt.hour,
    minute: dt.minute,
    second: dt.second,
    time_zone: dt.time_zone,
    zone_abbr: dt.zone_abbr,
    utc_offset: dt.utc_offset,
    std_offset: dt.std_offset,
    microsecond: #(truncated_ms, precision),
    calendar: dt.calendar,
  )
}

/// Converts the given `datetime` from its calendar to the given `calendar`.
pub fn convert(
  dt: DateTime,
  target_calendar: String,
) -> Result(DateTime, DateTimeError) {
  case dt.calendar == target_calendar {
    True -> Ok(dt)
    False -> {
      Ok(DateTime(
        year: dt.year,
        month: dt.month,
        day: dt.day,
        hour: dt.hour,
        minute: dt.minute,
        second: dt.second,
        time_zone: dt.time_zone,
        zone_abbr: dt.zone_abbr,
        utc_offset: dt.utc_offset,
        std_offset: dt.std_offset,
        microsecond: dt.microsecond,
        calendar: target_calendar,
      ))
    }
  }
}

/// Creates a DateTime from Gregorian seconds (seconds since 0000-01-01 00:00:00 UTC).
pub fn from_gregorian_seconds(
  seconds: Int,
  microsecond: #(Int, Int),
  calendar: String,
) -> Result(DateTime, DateTimeError) {
  let #(ms, precision) = microsecond
  let iso_days = iso.gregorian_seconds_to_iso_days(seconds, ms)
  let #(year, month, day, hour, minute, second, #(us, _)) =
    iso.naive_datetime_from_iso_days(iso_days)
  new(
    year,
    month,
    day,
    hour,
    minute,
    second,
    "Etc/UTC",
    "UTC",
    0,
    0,
    #(us, precision),
    calendar,
  )
}

/// Converts a DateTime to Gregorian seconds (seconds since 0000-01-01 00:00:00 UTC).
/// Returns #(gregorian_seconds, microseconds).
pub fn to_gregorian_seconds(dt: DateTime) -> #(Int, Int) {
  let #(ms, _precision) = dt.microsecond
  let iso_days =
    iso.naive_datetime_to_iso_days(
      dt.year,
      dt.month,
      dt.day,
      dt.hour,
      dt.minute,
      dt.second,
      dt.microsecond,
    )
  let #(days, #(day_fraction_us, _ppd)) = iso_days
  // Apply timezone offset
  let total_offset = dt.utc_offset + dt.std_offset
  let seconds_in_day = day_fraction_us / 1_000_000
  let total_seconds = days * 86_400 + seconds_in_day - total_offset
  #(total_seconds, ms)
}

// Additional helper functions

fn convert_to_seconds(value: Int, unit: TimeUnit) -> Int {
  case unit {
    Second -> value
    Millisecond -> value / 1000
    Microsecond -> value / 1_000_000
    Nanosecond -> value / 1_000_000_000
    Native -> value / 1_000_000_000
    // Assume native is nanoseconds
  }
}

fn convert_from_seconds(seconds: Int, unit: TimeUnit) -> Int {
  case unit {
    Second -> seconds
    Millisecond -> seconds * 1000
    Microsecond -> seconds * 1_000_000
    Nanosecond -> seconds * 1_000_000_000
    Native -> seconds * 1_000_000_000
    // Assume native is nanoseconds
  }
}

fn format_offset_basic(total_offset: Int) -> String {
  case total_offset == 0 {
    True -> "+0000"
    False -> {
      let sign = case total_offset >= 0 {
        True -> "+"
        False -> "-"
      }
      let abs_offset = case total_offset < 0 {
        True -> -total_offset
        False -> total_offset
      }
      let hours = abs_offset / 3600
      let minutes = { abs_offset % 3600 } / 60

      sign
      <> pad_left(int.to_string(hours), 2, "0")
      <> pad_left(int.to_string(minutes), 2, "0")
    }
  }
}

fn parse_iso8601_datetime(
  string: String,
  calendar: String,
) -> Result(DateTime, DateTimeError) {
  // Improved parser - handles both T and space separators
  case try_parse_datetime_with_separator(string, "T", calendar) {
    Ok(datetime) -> Ok(datetime)
    Error(_) ->
      case try_parse_datetime_with_separator(string, " ", calendar) {
        Ok(datetime) -> Ok(datetime)
        Error(_) -> Error(InvalidFormat)
      }
  }
}

fn try_parse_datetime_with_separator(
  string: String,
  separator: String,
  calendar: String,
) -> Result(DateTime, DateTimeError) {
  case string.split(string, separator) {
    [date_part, time_part] -> {
      case date.from_iso8601_with_calendar(date_part, calendar) {
        Error(_) -> Error(InvalidFormat)
        Ok(parsed_date) -> {
          case parse_time_with_tz(time_part, calendar) {
            Error(_) -> Error(InvalidFormat)
            Ok(#(parsed_time, tz_info)) -> {
              let #(time_zone, zone_abbr, utc_offset, std_offset) = tz_info
              new(
                parsed_date.year,
                parsed_date.month,
                parsed_date.day,
                parsed_time.hour,
                parsed_time.minute,
                parsed_time.second,
                time_zone,
                zone_abbr,
                utc_offset,
                std_offset,
                parsed_time.microsecond,
                calendar,
              )
            }
          }
        }
      }
    }
    _ -> Error(InvalidFormat)
  }
}

fn parse_time_with_tz(
  time_string: String,
  _calendar: String,
) -> Result(#(time.Time, #(String, String, Int, Int)), DateTimeError) {
  // Check for Z suffix (UTC)
  case string.ends_with(time_string, "Z") {
    True -> {
      let time_part = string.drop_end(time_string, 1)
      case time.from_iso8601(time_part) {
        Error(_) -> Error(InvalidFormat)
        Ok(parsed_time) -> Ok(#(parsed_time, #("Etc/UTC", "UTC", 0, 0)))
      }
    }
    False -> {
      // Try to find + offset
      case split_time_at_offset(time_string, "+") {
        Ok(#(time_part, offset_seconds)) -> {
          case time.from_iso8601(time_part) {
            Error(_) -> Error(InvalidFormat)
            Ok(parsed_time) ->
              Ok(#(parsed_time, #("Etc/UTC", "UTC", offset_seconds, 0)))
          }
        }
        Error(_) -> {
          // Try to find - offset (but not in microsecond part)
          case split_time_at_negative_offset(time_string) {
            Ok(#(time_part, offset_seconds)) -> {
              case time.from_iso8601(time_part) {
                Error(_) -> Error(InvalidFormat)
                Ok(parsed_time) ->
                  Ok(#(parsed_time, #("Etc/UTC", "UTC", offset_seconds, 0)))
              }
            }
            Error(_) -> {
              // No timezone info - treat as UTC
              case time.from_iso8601(time_string) {
                Error(_) -> Error(InvalidFormat)
                Ok(parsed_time) -> Ok(#(parsed_time, #("Etc/UTC", "UTC", 0, 0)))
              }
            }
          }
        }
      }
    }
  }
}

fn split_time_at_offset(s: String, sep: String) -> Result(#(String, Int), Nil) {
  case string.split_once(s, sep) {
    Ok(#(time_part, offset_part)) -> {
      case parse_offset_hhmm(offset_part) {
        Ok(seconds) -> {
          let sign = case sep {
            "+" -> 1
            _ -> -1
          }
          Ok(#(time_part, sign * seconds))
        }
        Error(_) -> Error(Nil)
      }
    }
    Error(_) -> Error(Nil)
  }
}

fn split_time_at_negative_offset(s: String) -> Result(#(String, Int), Nil) {
  // Find the last dash that's part of the offset (not in the time)
  // Time format is HH:MM:SS or HH:MM:SS.fff, so offset dash comes after
  let len = string.length(s)
  case len >= 6 {
    False -> Error(Nil)
    True -> {
      // Try 6-char offset at end (-HH:MM)
      let maybe = string.slice(s, len - 6, 6)
      case string.first(maybe) {
        Ok("-") -> {
          let offset_part = string.drop_start(maybe, 1)
          case parse_offset_hhmm(offset_part) {
            Ok(seconds) -> {
              let time_part = string.slice(s, 0, len - 6)
              Ok(#(time_part, -seconds))
            }
            Error(_) -> {
              // Try 5-char (-HHMM)
              try_5_char_negative_offset(s, len)
            }
          }
        }
        _ -> try_5_char_negative_offset(s, len)
      }
    }
  }
}

fn try_5_char_negative_offset(
  s: String,
  len: Int,
) -> Result(#(String, Int), Nil) {
  case len >= 5 {
    False -> Error(Nil)
    True -> {
      let maybe = string.slice(s, len - 5, 5)
      case string.first(maybe) {
        Ok("-") -> {
          let offset_part = string.drop_start(maybe, 1)
          case parse_offset_hhmm(offset_part) {
            Ok(seconds) -> {
              let time_part = string.slice(s, 0, len - 5)
              Ok(#(time_part, -seconds))
            }
            Error(_) -> Error(Nil)
          }
        }
        _ -> Error(Nil)
      }
    }
  }
}

fn parse_offset_hhmm(s: String) -> Result(Int, Nil) {
  case string.contains(s, ":") {
    True -> {
      case string.split(s, ":") {
        [h_str, m_str] -> {
          case int.parse(h_str), int.parse(m_str) {
            Ok(h), Ok(m) -> Ok(h * 3600 + m * 60)
            _, _ -> Error(Nil)
          }
        }
        _ -> Error(Nil)
      }
    }
    False -> {
      case string.length(s) {
        4 -> {
          case
            int.parse(string.slice(s, 0, 2)),
            int.parse(string.slice(s, 2, 2))
          {
            Ok(h), Ok(m) -> Ok(h * 3600 + m * 60)
            _, _ -> Error(Nil)
          }
        }
        2 -> {
          case int.parse(s) {
            Ok(h) -> Ok(h * 3600)
            Error(_) -> Error(Nil)
          }
        }
        _ -> Error(Nil)
      }
    }
  }
}
