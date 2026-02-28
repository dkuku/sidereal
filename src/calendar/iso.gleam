// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: 2021 The Elixir Team
// SPDX-FileCopyrightText: 2012 Plataformatec

import gleam/int
import gleam/list
import gleam/string

/// The default calendar implementation, a Gregorian calendar following ISO 8601.
///
/// This calendar implements a proleptic Gregorian calendar and
/// is therefore compatible with the calendar used in most countries today.
pub type ParseError {
  InvalidFormat
  InvalidDate
  InvalidTime
  InvalidDuration
}

/// Time unit for precision conversions.
pub type TimeUnit {
  Second
  Millisecond
  Microsecond
  Nanosecond
}

pub type ParseResult(t) {
  ParseOk(t)
  ParseError(ParseError)
}

/// Format type for date and time string representation
pub type Format {
  Basic
  Extended
}

/// Starting day of the week
pub type StartingDay {
  Monday
  Sunday
}

/// Parse an ISO 8601 date string in extended format (YYYY-MM-DD).
pub fn parse_date(date_string: String) -> ParseResult(#(Int, Int, Int)) {
  parse_date_with_format(date_string, Extended)
}

/// Parse an ISO 8601 date string with specified format.
/// Extended: YYYY-MM-DD, Basic: YYYYMMDD
pub fn parse_date_with_format(
  date_string: String,
  format: Format,
) -> ParseResult(#(Int, Int, Int)) {
  case format {
    Extended -> {
      case string.split(date_string, "-") {
        [year_str, month_str, day_str] -> {
          case parse_date_parts(year_str, month_str, day_str) {
            ParseOk(#(year, month, day)) ->
              case is_valid_date_parts(year, month, day) {
                True -> ParseOk(#(year, month, day))
                False -> ParseError(InvalidDate)
              }
            ParseError(err) -> ParseError(err)
          }
        }
        _ -> ParseError(InvalidFormat)
      }
    }
    Basic -> {
      // YYYYMMDD - 8 characters
      let len = string.length(date_string)
      case len >= 8 {
        False -> ParseError(InvalidFormat)
        True -> {
          let year_str = string.slice(date_string, 0, 4)
          let month_str = string.slice(date_string, 4, 2)
          let day_str = string.slice(date_string, 6, 2)
          case parse_date_parts(year_str, month_str, day_str) {
            ParseOk(#(year, month, day)) ->
              case is_valid_date_parts(year, month, day) {
                True -> ParseOk(#(year, month, day))
                False -> ParseError(InvalidDate)
              }
            ParseError(err) -> ParseError(err)
          }
        }
      }
    }
  }
}

/// Parse an ISO 8601 time string in extended format (HH:MM:SS or HH:MM:SS.ffffff).
pub fn parse_time(
  time_string: String,
) -> ParseResult(#(Int, Int, Int, #(Int, Int))) {
  parse_time_with_format(time_string, Extended)
}

/// Parse an ISO 8601 time string with specified format.
/// Extended: HH:MM:SS[.ffffff], Basic: HHMMSS[.ffffff]
/// Also accepts a leading 'T' prefix which is stripped.
pub fn parse_time_with_format(
  time_string: String,
  format: Format,
) -> ParseResult(#(Int, Int, Int, #(Int, Int))) {
  // Strip optional leading T
  let s = case string.first(time_string) {
    Ok("T") -> string.drop_start(time_string, 1)
    _ -> time_string
  }
  case format {
    Extended -> parse_time_extended(s)
    Basic -> parse_time_basic(s)
  }
}

/// Parse an ISO 8601 naive datetime string in extended format (YYYY-MM-DDTHH:MM:SS).
pub fn parse_naive_datetime(
  datetime_string: String,
) -> ParseResult(#(Int, Int, Int, Int, Int, Int, #(Int, Int))) {
  parse_naive_datetime_with_format(datetime_string, Extended)
}

/// Parse an ISO 8601 naive datetime string with specified format.
/// Extended: YYYY-MM-DDTHH:MM:SS, Basic: YYYYMMDDTHHMMSS
/// Also accepts space separator.
pub fn parse_naive_datetime_with_format(
  datetime_string: String,
  format: Format,
) -> ParseResult(#(Int, Int, Int, Int, Int, Int, #(Int, Int))) {
  // Try T separator first, then space
  case try_parse_ndt_with_separator(datetime_string, "T", format) {
    ParseOk(result) -> ParseOk(result)
    ParseError(_) -> {
      case try_parse_ndt_with_separator(datetime_string, " ", format) {
        ParseOk(result) -> ParseOk(result)
        ParseError(err) -> ParseError(err)
      }
    }
  }
}

/// Check if a year is a leap year.
pub fn leap_year(year: Int) -> Bool {
  case year % 4 == 0 {
    True ->
      case year % 100 == 0 {
        True -> year % 400 == 0
        False -> True
      }
    False -> False
  }
}

/// Get the number of days in a month for a given year.
pub fn days_in_month(year: Int, month: Int) -> Int {
  case month {
    1 | 3 | 5 | 7 | 8 | 10 | 12 -> 31
    4 | 6 | 9 | 11 -> 30
    2 ->
      case leap_year(year) {
        True -> 29
        False -> 28
      }
    _ -> 0
  }
}

/// Get the number of months in a year (always 12 for ISO calendar).
pub fn months_in_year(_year: Int) -> Int {
  12
}

/// Convert date to days since the ISO epoch.
pub fn date_to_iso_days(year: Int, month: Int, day: Int) -> Int {
  case year == 0 && month == 1 && day == 1 {
    True -> 0
    False ->
      case year == 1970 && month == 1 && day == 1 {
        True -> 719_528
        False -> {
          days_in_previous_years(year)
          + days_before_month(month)
          + leap_day_offset_for_month(year, month)
          + day
          - 1
        }
      }
  }
}

/// Convert days since ISO epoch back to date.
pub fn date_from_iso_days(iso_days: Int) -> #(Int, Int, Int) {
  let #(year, day_of_year) = days_to_year(iso_days)
  let extra_day = case leap_year(year) {
    True -> 1
    False -> 0
  }
  let #(month, day_in_month) = year_day_to_year_date(extra_day, day_of_year)
  #(year, month, day_in_month + 1)
}

/// Convert naive datetime to ISO days representation.
pub fn naive_datetime_to_iso_days(
  year: Int,
  month: Int,
  day: Int,
  hour: Int,
  minute: Int,
  second: Int,
  microsecond: #(Int, Int),
) -> #(Int, #(Int, Int)) {
  let days = date_to_iso_days(year, month, day)
  let #(ms, precision) = microsecond
  let day_fraction_ms =
    hour * 3600 * 1_000_000 + minute * 60 * 1_000_000 + second * 1_000_000 + ms
  #(days, #(day_fraction_ms, precision))
}

/// Convert ISO days representation back to naive datetime.
pub fn naive_datetime_from_iso_days(
  iso_days: #(Int, #(Int, Int)),
) -> #(Int, Int, Int, Int, Int, Int, #(Int, Int)) {
  let #(days, #(day_fraction_ms, precision)) = iso_days
  let #(year, month, day) = date_from_iso_days(days)

  let total_seconds = day_fraction_ms / 1_000_000
  let microseconds = day_fraction_ms % 1_000_000

  let hours = total_seconds / 3600
  let remaining = total_seconds % 3600
  let minutes = remaining / 60
  let seconds = remaining % 60

  #(year, month, day, hours, minutes, seconds, #(microseconds, precision))
}

/// Helper functions
fn parse_date_parts(
  year_str: String,
  month_str: String,
  day_str: String,
) -> ParseResult(#(Int, Int, Int)) {
  case int.parse(year_str), int.parse(month_str), int.parse(day_str) {
    Ok(year), Ok(month), Ok(day) -> ParseOk(#(year, month, day))
    _, _, _ -> ParseError(InvalidFormat)
  }
}

fn is_valid_date_parts(year: Int, month: Int, day: Int) -> Bool {
  month >= 1 && month <= 12 && day >= 1 && day <= days_in_month(year, month)
}

fn is_valid_time_parts(
  hour: Int,
  minute: Int,
  second: Int,
  microsecond: Int,
  precision: Int,
) -> Bool {
  hour >= 0
  && hour <= 23
  && minute >= 0
  && minute <= 59
  && second >= 0
  && second <= 59
  && microsecond >= 0
  && microsecond < 1_000_000
  && precision >= 0
  && precision <= 6
}

fn pad_microsecond_string(ms_str: String) -> String {
  let len = string.length(ms_str)
  case len {
    n if n >= 6 -> string.slice(ms_str, 0, 6)
    n -> ms_str <> string.repeat("0", 6 - n)
  }
}

fn parse_time_extended(s: String) -> ParseResult(#(Int, Int, Int, #(Int, Int))) {
  case string.split(s, ":") {
    [hour_str, minute_str, second_part] -> {
      case int.parse(hour_str), int.parse(minute_str) {
        Ok(hour), Ok(minute) -> parse_second_part(hour, minute, second_part)
        _, _ -> ParseError(InvalidFormat)
      }
    }
    _ -> ParseError(InvalidFormat)
  }
}

fn parse_time_basic(s: String) -> ParseResult(#(Int, Int, Int, #(Int, Int))) {
  // HHMMSS or HHMMSS.ffffff - at least 6 digits
  let len = string.length(s)
  case len >= 6 {
    False -> ParseError(InvalidFormat)
    True -> {
      let hour_str = string.slice(s, 0, 2)
      let minute_str = string.slice(s, 2, 2)
      let second_part = string.drop_start(s, 4)
      case int.parse(hour_str), int.parse(minute_str) {
        Ok(hour), Ok(minute) -> parse_second_part(hour, minute, second_part)
        _, _ -> ParseError(InvalidFormat)
      }
    }
  }
}

fn parse_second_part(
  hour: Int,
  minute: Int,
  second_part: String,
) -> ParseResult(#(Int, Int, Int, #(Int, Int))) {
  case string.split(second_part, ".") {
    [second_str] -> {
      case int.parse(second_str) {
        Ok(second) ->
          case is_valid_time_parts(hour, minute, second, 0, 0) {
            True -> ParseOk(#(hour, minute, second, #(0, 0)))
            False -> ParseError(InvalidTime)
          }
        Error(_) -> ParseError(InvalidFormat)
      }
    }
    [second_str, microsecond_str] -> {
      case int.parse(second_str) {
        Ok(second) -> {
          let padded_ms = pad_microsecond_string(microsecond_str)
          case int.parse(padded_ms) {
            Ok(microsecond) -> {
              let precision = string.length(microsecond_str)
              case
                is_valid_time_parts(
                  hour,
                  minute,
                  second,
                  microsecond,
                  precision,
                )
              {
                True ->
                  ParseOk(#(hour, minute, second, #(microsecond, precision)))
                False -> ParseError(InvalidTime)
              }
            }
            Error(_) -> ParseError(InvalidFormat)
          }
        }
        Error(_) -> ParseError(InvalidFormat)
      }
    }
    _ -> ParseError(InvalidFormat)
  }
}

fn try_parse_ndt_with_separator(
  datetime_string: String,
  separator: String,
  format: Format,
) -> ParseResult(#(Int, Int, Int, Int, Int, Int, #(Int, Int))) {
  case string.split_once(datetime_string, separator) {
    Ok(#(date_part, time_part)) -> {
      case
        parse_date_with_format(date_part, format),
        parse_time_with_format(time_part, format)
      {
        ParseOk(#(year, month, day)),
          ParseOk(#(hour, minute, second, microsecond))
        -> ParseOk(#(year, month, day, hour, minute, second, microsecond))
        ParseError(err), _ -> ParseError(err)
        _, ParseError(err) -> ParseError(err)
      }
    }
    Error(_) -> ParseError(InvalidFormat)
  }
}

// Constants for date calculations
const days_per_nonleap_year = 365

const days_per_leap_year = 366

// Convert days to year and day of year
fn days_to_year(days: Int) -> #(Int, Int) {
  case days < 0 {
    True -> days_to_year_negative(days)
    False -> days_to_year_positive(days)
  }
}

fn days_to_year_negative(days: Int) -> #(Int, Int) {
  let negative_days = 0 - days
  let year_estimate = 0 - { negative_days / days_per_nonleap_year } - 1
  let #(year, days_before_year) =
    days_to_year_helper(
      year_estimate,
      days,
      days_to_end_of_epoch(year_estimate),
    )
  let leap_year_pad = case leap_year(year) {
    True -> 1
    False -> 0
  }
  #(year, leap_year_pad + days_per_nonleap_year + days - days_before_year)
}

fn days_to_year_positive(days: Int) -> #(Int, Int) {
  let year_estimate = days / days_per_nonleap_year
  let #(year, days_before_year) =
    days_to_year_helper(
      year_estimate,
      days,
      days_in_previous_years(year_estimate),
    )
  #(year, days - days_before_year)
}

fn days_to_year_helper(year: Int, days1: Int, days2: Int) -> #(Int, Int) {
  case year < 0, days1 >= days2 {
    True, True ->
      days_to_year_helper(year + 1, days1, days_to_end_of_epoch(year + 1))
    False, False ->
      case days1 < days2 {
        True ->
          days_to_year_helper(year - 1, days1, days_in_previous_years(year - 1))
        False -> #(year, days2)
      }
    _, _ -> #(year, days2)
  }
}

fn days_to_end_of_epoch(year: Int) -> Int {
  case year < 0 {
    True -> {
      let previous_year = year + 1
      previous_year
      / 4
      - previous_year
      / 100
      + previous_year
      / 400
      + previous_year
      * days_per_nonleap_year
    }
    False -> 0
  }
}

fn days_in_previous_years(year: Int) -> Int {
  case year > 0 {
    True -> {
      let previous_year = year - 1
      previous_year
      / 4
      - previous_year
      / 100
      + previous_year
      / 400
      + previous_year
      * days_per_nonleap_year
      + days_per_leap_year
    }
    False -> {
      let previous_year = year - 1
      year
      / 4
      - year
      / 100
      + year
      / 400
      - 1
      + previous_year
      * days_per_nonleap_year
      + days_per_leap_year
    }
  }
}

// Helper functions for date_to_iso_days
fn days_before_month(month: Int) -> Int {
  case month {
    1 -> 0
    2 -> 31
    3 -> 59
    4 -> 90
    5 -> 120
    6 -> 151
    7 -> 181
    8 -> 212
    9 -> 243
    10 -> 273
    11 -> 304
    12 -> 334
    _ -> 0
  }
}

fn leap_day_offset_for_month(year: Int, month: Int) -> Int {
  case month < 3 {
    True -> 0
    False ->
      case leap_year(year) {
        True -> 1
        False -> 0
      }
  }
}

// Convert day of year to month and day within month
fn year_day_to_year_date(extra_day: Int, day_of_year: Int) -> #(Int, Int) {
  case day_of_year < 31 {
    True -> #(1, day_of_year)
    False ->
      case day_of_year < 59 + extra_day {
        True -> #(2, day_of_year - 31)
        False ->
          case day_of_year < 90 + extra_day {
            True -> #(3, day_of_year - 59 - extra_day)
            False ->
              case day_of_year < 120 + extra_day {
                True -> #(4, day_of_year - 90 - extra_day)
                False ->
                  case day_of_year < 151 + extra_day {
                    True -> #(5, day_of_year - 120 - extra_day)
                    False ->
                      case day_of_year < 181 + extra_day {
                        True -> #(6, day_of_year - 151 - extra_day)
                        False ->
                          case day_of_year < 212 + extra_day {
                            True -> #(7, day_of_year - 181 - extra_day)
                            False ->
                              case day_of_year < 243 + extra_day {
                                True -> #(8, day_of_year - 212 - extra_day)
                                False ->
                                  case day_of_year < 273 + extra_day {
                                    True -> #(9, day_of_year - 243 - extra_day)
                                    False ->
                                      case day_of_year < 304 + extra_day {
                                        True -> #(
                                          10,
                                          day_of_year - 273 - extra_day,
                                        )
                                        False ->
                                          case day_of_year < 334 + extra_day {
                                            True -> #(
                                              11,
                                              day_of_year - 304 - extra_day,
                                            )
                                            False -> #(
                                              12,
                                              day_of_year - 334 - extra_day,
                                            )
                                          }
                                      }
                                  }
                              }
                          }
                      }
                  }
              }
          }
      }
  }
}

// Constants
const iso_epoch = 366

/// Convert date to string representation
pub fn date_to_string(year: Int, month: Int, day: Int, format: Format) -> String {
  case format {
    Extended -> {
      zero_pad(year, 4) <> "-" <> zero_pad(month, 2) <> "-" <> zero_pad(day, 2)
    }
    Basic -> {
      zero_pad(year, 4) <> zero_pad(month, 2) <> zero_pad(day, 2)
    }
  }
}

/// Convert time to string representation
pub fn time_to_string(
  hour: Int,
  minute: Int,
  second: Int,
  microsecond: Int,
  format: Format,
) -> String {
  let time_part = case format {
    Extended ->
      zero_pad(hour, 2)
      <> ":"
      <> zero_pad(minute, 2)
      <> ":"
      <> zero_pad(second, 2)
    Basic -> zero_pad(hour, 2) <> zero_pad(minute, 2) <> zero_pad(second, 2)
  }

  case microsecond {
    0 -> time_part
    _ -> time_part <> "." <> zero_pad(microsecond, 6)
  }
}

/// Calculate day of week (1-7, where 1 is the starting day)
pub fn day_of_week(
  year: Int,
  month: Int,
  day: Int,
  starting_day: StartingDay,
) -> Int {
  let iso_days = date_to_iso_days(year, month, day)
  let offset = case starting_day {
    Monday -> 5
    Sunday -> 6
  }
  { iso_days + offset } % 7 + 1
}

/// Calculate day of year (1-366)
pub fn day_of_year(year: Int, month: Int, day: Int) -> Int {
  days_before_month(month) + leap_day_offset_for_month(year, month) + day
}

/// Calculate day of era
pub fn day_of_era(year: Int, month: Int, day: Int) -> #(Int, Int) {
  let days = date_to_iso_days(year, month, day)
  case year >= 1 {
    True -> #(days - iso_epoch + 1, 1)
    False -> #(int.absolute_value(days - iso_epoch), 0)
  }
}

/// Check if a date is valid
pub fn valid_date(year: Int, month: Int, day: Int) -> Bool {
  month >= 1 && month <= 12 && day >= 1 && day <= days_in_month(year, month)
}

/// Check if a time is valid
pub fn valid_time(hour: Int, minute: Int, second: Int, microsecond: Int) -> Bool {
  hour >= 0
  && hour <= 23
  && minute >= 0
  && minute <= 59
  && second >= 0
  && second <= 59
  && microsecond >= 0
  && microsecond < 1_000_000
}

/// Convert time to microseconds since midnight
pub fn time_to_microseconds(
  hour: Int,
  minute: Int,
  second: Int,
  microsecond: Int,
) -> Int {
  hour
  * 3600
  * 1_000_000
  + minute
  * 60
  * 1_000_000
  + second
  * 1_000_000
  + microsecond
}

/// Convert microseconds since midnight to time components
pub fn microseconds_to_time(total_microseconds: Int) -> #(Int, Int, Int, Int) {
  let total_seconds = total_microseconds / 1_000_000
  let microseconds = total_microseconds % 1_000_000

  let hours = total_seconds / 3600
  let remaining = total_seconds % 3600
  let minutes = remaining / 60
  let seconds = remaining % 60

  #(hours, minutes, seconds, microseconds)
}

/// Parse an ISO 8601 UTC datetime string with offset.
/// Returns the datetime components and the UTC offset in seconds.
pub fn parse_utc_datetime(
  datetime_string: String,
) -> ParseResult(#(#(Int, Int, Int, Int, Int, Int, #(Int, Int)), Int)) {
  parse_utc_datetime_with_format(datetime_string, Extended)
}

/// Parse an ISO 8601 UTC datetime string with specified format.
pub fn parse_utc_datetime_with_format(
  datetime_string: String,
  format: Format,
) -> ParseResult(#(#(Int, Int, Int, Int, Int, Int, #(Int, Int)), Int)) {
  // Check for Z suffix (UTC)
  case string.ends_with(datetime_string, "Z") {
    True -> {
      let without_z = string.drop_end(datetime_string, 1)
      case parse_naive_datetime_with_format(without_z, format) {
        ParseOk(#(year, month, day, hour, minute, second, microsecond)) ->
          ParseOk(#(#(year, month, day, hour, minute, second, microsecond), 0))
        ParseError(err) -> ParseError(err)
      }
    }
    False -> {
      // Try to find + or - offset
      case split_at_offset(datetime_string) {
        Ok(#(dt_part, offset_seconds)) -> {
          case parse_naive_datetime_with_format(dt_part, format) {
            ParseOk(#(year, month, day, hour, minute, second, microsecond)) ->
              ParseOk(#(
                #(year, month, day, hour, minute, second, microsecond),
                offset_seconds,
              ))
            ParseError(err) -> ParseError(err)
          }
        }
        Error(_) -> ParseError(InvalidFormat)
      }
    }
  }
}

/// Convert time to day fraction representation.
/// Day fraction is {microseconds_in_day, parts_per_day}.
pub fn time_to_day_fraction(
  hour: Int,
  minute: Int,
  second: Int,
  microsecond: #(Int, Int),
) -> #(Int, Int) {
  let #(ms, _precision) = microsecond
  case hour == 0 && minute == 0 && second == 0 && ms == 0 {
    True -> #(0, parts_per_day)
    False -> {
      let combined =
        { hour * seconds_per_hour + minute * seconds_per_minute + second }
        * microseconds_per_second
        + ms
      #(combined, parts_per_day)
    }
  }
}

/// Convert day fraction back to time components.
pub fn time_from_day_fraction(
  day_fraction: #(Int, Int),
) -> #(Int, Int, Int, #(Int, Int)) {
  let #(parts_in_day, ppd) = day_fraction
  case parts_in_day == 0 {
    True -> #(0, 0, 0, #(0, 6))
    False -> {
      let total_microseconds = divide_by_parts_per_day(parts_in_day, ppd)
      let #(hours, rest1) =
        div_rem(total_microseconds, seconds_per_hour * microseconds_per_second)
      let #(minutes, rest2) =
        div_rem(rest1, seconds_per_minute * microseconds_per_second)
      let #(seconds, microseconds) = div_rem(rest2, microseconds_per_second)
      #(hours, minutes, seconds, #(microseconds, 6))
    }
  }
}

/// Get ISO days for the beginning of a day.
pub fn iso_days_to_beginning_of_day(
  iso_days: #(Int, #(Int, Int)),
) -> #(Int, #(Int, Int)) {
  let #(days, _day_fraction) = iso_days
  #(days, #(0, parts_per_day))
}

/// Get ISO days for the end of a day.
pub fn iso_days_to_end_of_day(
  iso_days: #(Int, #(Int, Int)),
) -> #(Int, #(Int, Int)) {
  let #(days, _day_fraction) = iso_days
  #(days, #(parts_per_day - 1, parts_per_day))
}

/// Calculate quarter of year (1-4).
pub fn quarter_of_year(_year: Int, month: Int, _day: Int) -> Int {
  { month - 1 } / 3 + 1
}

/// Calculate year of era from a year.
pub fn year_of_era(year: Int) -> #(Int, Int) {
  case year >= 1 {
    True -> #(year, 1)
    False -> #(int.absolute_value(year) + 1, 0)
  }
}

/// Calculate year of era from a date.
pub fn year_of_era_from_date(year: Int, _month: Int, _day: Int) -> #(Int, Int) {
  year_of_era(year)
}

/// Shift a date by a duration.
/// Duration is given as #(months, days) where months includes year*12.
pub fn shift_date(
  year: Int,
  month: Int,
  day: Int,
  month_shift: Int,
  day_shift: Int,
) -> #(Int, Int, Int) {
  // Apply month shift first
  let #(new_year, new_month, new_day) = case month_shift {
    0 -> #(year, month, day)
    _ -> shift_months(#(year, month, day), month_shift)
  }
  // Then apply day shift
  case day_shift {
    0 -> #(new_year, new_month, new_day)
    _ -> shift_days(#(new_year, new_month, new_day), day_shift)
  }
}

/// Shift a naive datetime by duration components.
pub fn shift_naive_datetime(
  year: Int,
  month: Int,
  day: Int,
  hour: Int,
  minute: Int,
  second: Int,
  microsecond: #(Int, Int),
  month_shift: Int,
  day_shift: Int,
  second_shift: Int,
  microsecond_shift: Int,
) -> #(Int, Int, Int, Int, Int, Int, #(Int, Int)) {
  // Apply month shift to date first
  let #(y, m, d) = case month_shift {
    0 -> #(year, month, day)
    _ -> shift_months(#(year, month, day), month_shift)
  }

  // Then apply day shift
  let #(y2, m2, d2) = case day_shift {
    0 -> #(y, m, d)
    _ -> shift_days(#(y, m, d), day_shift)
  }

  // Apply time shift (seconds + microseconds)
  let total_time_shift =
    second_shift * microseconds_per_second + microsecond_shift
  case total_time_shift {
    0 -> #(y2, m2, d2, hour, minute, second, microsecond)
    _ -> {
      let #(ms, precision) = microsecond
      let current_us =
        { hour * seconds_per_hour + minute * seconds_per_minute + second }
        * microseconds_per_second
        + ms
      let new_us = current_us + total_time_shift
      // Handle day overflow/underflow
      let #(day_overflow, day_us) = div_rem(new_us, parts_per_day)
      let #(y3, m3, d3) = case day_overflow {
        0 -> #(y2, m2, d2)
        _ -> shift_days(#(y2, m2, d2), day_overflow)
      }
      let #(h, min, sec, us) = microseconds_to_time(day_us)
      #(y3, m3, d3, h, min, sec, #(us, precision))
    }
  }
}

/// Shift time by duration components.
pub fn shift_time(
  hour: Int,
  minute: Int,
  second: Int,
  microsecond: #(Int, Int),
  second_shift: Int,
  microsecond_shift: Int,
) -> #(Int, Int, Int, #(Int, Int)) {
  let #(ms, precision) = microsecond
  let total_shift = second_shift * microseconds_per_second + microsecond_shift
  case total_shift {
    0 -> #(hour, minute, second, microsecond)
    _ -> {
      let current_us =
        { hour * seconds_per_hour + minute * seconds_per_minute + second }
        * microseconds_per_second
        + ms
      let new_us = current_us + total_shift
      // Wrap within a single day
      let wrapped = modulo(new_us, parts_per_day)
      let #(h, min, sec, us) = microseconds_to_time(wrapped)
      #(h, min, sec, #(us, precision))
    }
  }
}

/// Get the precision for a time unit.
pub fn time_unit_to_precision(unit: TimeUnit) -> Int {
  case unit {
    Nanosecond -> 6
    Microsecond -> 6
    Millisecond -> 3
    Second -> 0
  }
}

/// Convert ISO days to a time unit value.
pub fn iso_days_to_unit(iso_days: #(Int, #(Int, Int)), unit: TimeUnit) -> Int {
  let #(days, #(parts, ppd)) = iso_days
  let day_microseconds = days * parts_per_day
  let microseconds = divide_by_parts_per_day(parts, ppd)
  let total_us = day_microseconds + microseconds
  case unit {
    Second -> total_us / microseconds_per_second
    Millisecond -> total_us / 1000
    Microsecond -> total_us
    Nanosecond -> total_us * 1000
  }
}

/// Add a day fraction value to ISO days.
pub fn add_day_fraction_to_iso_days(
  iso_days: #(Int, #(Int, Int)),
  add: Int,
  add_ppd: Int,
) -> #(Int, #(Int, Int)) {
  let #(days, #(parts, ppd)) = iso_days
  case ppd == add_ppd {
    True -> normalize_iso_days(days, parts + add, ppd)
    False -> {
      let new_parts = parts * add_ppd + add * ppd
      let gcd_val = gcd(ppd, add_ppd)
      let result_parts = new_parts / gcd_val
      let result_ppd = ppd * add_ppd / gcd_val
      normalize_iso_days(days, result_parts, result_ppd)
    }
  }
}

/// Convert naive datetime to string representation.
pub fn naive_datetime_to_string(
  year: Int,
  month: Int,
  day: Int,
  hour: Int,
  minute: Int,
  second: Int,
  microsecond: #(Int, Int),
  format: Format,
) -> String {
  let #(ms, precision) = microsecond
  let ms_part = case ms == 0 || precision == 0 {
    True -> ""
    False -> "." <> pad_microsecond_value(ms, precision)
  }
  case format {
    Extended ->
      date_to_string(year, month, day, Extended)
      <> " "
      <> time_to_string(hour, minute, second, 0, Extended)
      <> ms_part
    Basic ->
      date_to_string(year, month, day, Basic)
      <> " "
      <> time_to_string(hour, minute, second, 0, Basic)
      <> ms_part
  }
}

/// Convert datetime to string representation with timezone.
pub fn datetime_to_string(
  year: Int,
  month: Int,
  day: Int,
  hour: Int,
  minute: Int,
  second: Int,
  microsecond: #(Int, Int),
  time_zone: String,
  zone_abbr: String,
  utc_offset: Int,
  std_offset: Int,
  format: Format,
) -> String {
  let #(ms, precision) = microsecond
  let ms_part = case ms == 0 || precision == 0 {
    True -> ""
    False -> "." <> pad_microsecond_value(ms, precision)
  }
  let offset_part = offset_to_string(utc_offset, std_offset, time_zone, format)
  let zone_part = zone_to_string(utc_offset, std_offset, zone_abbr, time_zone)
  case format {
    Extended ->
      date_to_string(year, month, day, Extended)
      <> " "
      <> time_to_string(hour, minute, second, 0, Extended)
      <> ms_part
      <> offset_part
      <> zone_part
    Basic ->
      date_to_string(year, month, day, Basic)
      <> " "
      <> time_to_string(hour, minute, second, 0, Basic)
      <> ms_part
      <> offset_part
      <> zone_part
  }
}

/// Parse an ISO 8601 duration string.
pub fn parse_duration(
  duration_string: String,
) -> ParseResult(List(#(String, Int))) {
  case string.first(duration_string) {
    Ok("P") -> {
      let content = string.drop_start(duration_string, 1)
      case string.split_once(content, "T") {
        Ok(#(date_part, time_part)) -> {
          case
            do_parse_duration_date(date_part, []),
            do_parse_duration_time(time_part, [])
          {
            ParseOk(date_pairs), ParseOk(time_pairs) -> {
              let pairs =
                list.append(list.reverse(date_pairs), list.reverse(time_pairs))
              ParseOk(pairs)
            }
            ParseError(err), _ -> ParseError(err)
            _, ParseError(err) -> ParseError(err)
          }
        }
        Error(_) -> {
          // Only date part (or just weeks)
          case do_parse_duration_date(content, []) {
            ParseOk(pairs) -> ParseOk(list.reverse(pairs))
            ParseError(err) -> ParseError(err)
          }
        }
      }
    }
    Ok("+") -> {
      case string.drop_start(duration_string, 1) {
        "P" <> rest -> parse_duration("P" <> rest)
        _ -> ParseError(InvalidDuration)
      }
    }
    Ok("-") -> {
      case string.drop_start(duration_string, 1) {
        "P" <> rest -> {
          case parse_duration("P" <> rest) {
            ParseOk(pairs) ->
              ParseOk(list.map(pairs, fn(pair) { #(pair.0, -pair.1) }))
            ParseError(err) -> ParseError(err)
          }
        }
        _ -> ParseError(InvalidDuration)
      }
    }
    _ -> ParseError(InvalidDuration)
  }
}

/// Convert a gregorian seconds value to ISO days representation.
pub fn gregorian_seconds_to_iso_days(
  seconds: Int,
  microsecond: Int,
) -> #(Int, #(Int, Int)) {
  let #(days, rest_seconds) = div_rem(seconds, seconds_per_day)
  let microseconds_in_day = rest_seconds * microseconds_per_second + microsecond
  #(days, #(microseconds_in_day, parts_per_day))
}

// Constants
const seconds_per_hour = 3600

const seconds_per_minute = 60

const seconds_per_day = 86_400

const microseconds_per_second = 1_000_000

const parts_per_day = 86_400_000_000

// Helper functions

fn divide_by_parts_per_day(parts: Int, ppd: Int) -> Int {
  case ppd == parts_per_day {
    True -> parts
    False -> parts * parts_per_day / ppd
  }
}

fn div_rem(a: Int, b: Int) -> #(Int, Int) {
  let d = a / b
  let r = a - d * b
  case r >= 0 {
    True -> #(d, r)
    False -> #(d - 1, r + b)
  }
}

fn normalize_iso_days(days: Int, parts: Int, ppd: Int) -> #(Int, #(Int, Int)) {
  case parts < 0 {
    True -> {
      let new_days = days - 1 + parts / ppd
      let new_parts = modulo(parts, ppd)
      #(new_days, #(new_parts, ppd))
    }
    False ->
      case parts >= ppd {
        True -> {
          let new_days = days + parts / ppd
          let new_parts = parts % ppd
          #(new_days, #(new_parts, ppd))
        }
        False -> #(days, #(parts, ppd))
      }
  }
}

fn modulo(a: Int, b: Int) -> Int {
  let r = a % b
  case r < 0 {
    True -> r + b
    False -> r
  }
}

fn gcd(a: Int, b: Int) -> Int {
  let abs_a = int.absolute_value(a)
  let abs_b = int.absolute_value(b)
  gcd_helper(abs_a, abs_b)
}

fn gcd_helper(a: Int, b: Int) -> Int {
  case b {
    0 -> a
    _ -> gcd_helper(b, a % b)
  }
}

fn shift_months(date: #(Int, Int, Int), months: Int) -> #(Int, Int, Int) {
  let #(year, month, day) = date
  let total_months = year * 12 + month - 1 + months
  let #(new_year, new_month_zero) = div_rem(total_months, 12)
  let new_month = new_month_zero + 1
  let max_day = days_in_month(new_year, new_month)
  let new_day = case day > max_day {
    True -> max_day
    False -> day
  }
  #(new_year, new_month, new_day)
}

fn shift_days(date: #(Int, Int, Int), days: Int) -> #(Int, Int, Int) {
  let #(year, month, day) = date
  let iso_days = date_to_iso_days(year, month, day) + days
  date_from_iso_days(iso_days)
}

fn split_at_offset(s: String) -> Result(#(String, Int), Nil) {
  // Try to find the last + or - for timezone offset
  // The offset is at the end, after the time portion
  case string.last(s) {
    Error(_) -> Error(Nil)
    Ok(_) -> {
      // Look for +HH:MM or -HH:MM at end
      let len = string.length(s)
      case len >= 6 {
        False -> Error(Nil)
        True -> {
          let maybe_offset = string.slice(s, len - 6, 6)
          case string.first(maybe_offset) {
            Ok("+") | Ok("-") -> {
              let dt_part = string.slice(s, 0, len - 6)
              case parse_offset_string(maybe_offset) {
                Ok(offset) -> Ok(#(dt_part, offset))
                Error(_) -> {
                  // Try +HHMM format (5 chars)
                  let maybe_offset5 = string.slice(s, len - 5, 5)
                  let dt_part5 = string.slice(s, 0, len - 5)
                  case parse_offset_string(maybe_offset5) {
                    Ok(offset) -> Ok(#(dt_part5, offset))
                    Error(_) -> Error(Nil)
                  }
                }
              }
            }
            _ -> {
              // Try 5-char offset
              let maybe_offset5 = string.slice(s, len - 5, 5)
              case string.first(maybe_offset5) {
                Ok("+") | Ok("-") -> {
                  let dt_part5 = string.slice(s, 0, len - 5)
                  case parse_offset_string(maybe_offset5) {
                    Ok(offset) -> Ok(#(dt_part5, offset))
                    Error(_) -> Error(Nil)
                  }
                }
                _ -> Error(Nil)
              }
            }
          }
        }
      }
    }
  }
}

fn parse_offset_string(offset: String) -> Result(Int, Nil) {
  case string.first(offset) {
    Ok("+") -> parse_offset_value(string.drop_start(offset, 1), 1)
    Ok("-") -> parse_offset_value(string.drop_start(offset, 1), -1)
    _ -> Error(Nil)
  }
}

fn parse_offset_value(value: String, sign: Int) -> Result(Int, Nil) {
  // Handle HH:MM or HHMM
  case string.contains(value, ":") {
    True -> {
      case string.split(value, ":") {
        [h_str, m_str] -> {
          case int.parse(h_str), int.parse(m_str) {
            Ok(h), Ok(m) -> Ok(sign * { h * 3600 + m * 60 })
            _, _ -> Error(Nil)
          }
        }
        _ -> Error(Nil)
      }
    }
    False -> {
      case string.length(value) {
        4 -> {
          let h_str = string.slice(value, 0, 2)
          let m_str = string.slice(value, 2, 2)
          case int.parse(h_str), int.parse(m_str) {
            Ok(h), Ok(m) -> Ok(sign * { h * 3600 + m * 60 })
            _, _ -> Error(Nil)
          }
        }
        2 -> {
          case int.parse(value) {
            Ok(h) -> Ok(sign * h * 3600)
            Error(_) -> Error(Nil)
          }
        }
        _ -> Error(Nil)
      }
    }
  }
}

fn offset_to_string(
  utc_offset: Int,
  std_offset: Int,
  time_zone: String,
  format: Format,
) -> String {
  case time_zone == "Etc/UTC" && utc_offset == 0 && std_offset == 0 {
    True -> "Z"
    False -> {
      let total = utc_offset + std_offset
      let sign = case total >= 0 {
        True -> "+"
        False -> "-"
      }
      let abs_total = int.absolute_value(total)
      let hours = abs_total / 3600
      let minutes = { abs_total % 3600 } / 60
      case format {
        Extended -> sign <> zero_pad(hours, 2) <> ":" <> zero_pad(minutes, 2)
        Basic -> sign <> zero_pad(hours, 2) <> zero_pad(minutes, 2)
      }
    }
  }
}

fn zone_to_string(
  utc_offset: Int,
  std_offset: Int,
  zone_abbr: String,
  time_zone: String,
) -> String {
  case time_zone == "Etc/UTC" && utc_offset == 0 && std_offset == 0 {
    True -> ""
    False -> " " <> zone_abbr
  }
}

fn pad_microsecond_value(ms: Int, precision: Int) -> String {
  let ms_str = int.to_string(ms)
  let padded = case string.length(ms_str) < 6 {
    True -> string.repeat("0", 6 - string.length(ms_str)) <> ms_str
    False -> ms_str
  }
  string.slice(padded, 0, precision)
}

fn do_parse_duration_date(
  s: String,
  acc: List(#(String, Int)),
) -> ParseResult(List(#(String, Int))) {
  case s {
    "" -> ParseOk(acc)
    _ -> {
      case extract_number_and_unit(s) {
        Ok(#(value, unit, rest)) -> {
          let pair = case unit {
            "Y" -> Ok(#("year", value))
            "M" -> Ok(#("month", value))
            "W" -> Ok(#("week", value))
            "D" -> Ok(#("day", value))
            _ -> Error(Nil)
          }
          case pair {
            Ok(p) -> do_parse_duration_date(rest, [p, ..acc])
            Error(_) -> ParseError(InvalidDuration)
          }
        }
        Error(_) -> ParseError(InvalidDuration)
      }
    }
  }
}

fn do_parse_duration_time(
  s: String,
  acc: List(#(String, Int)),
) -> ParseResult(List(#(String, Int))) {
  case s {
    "" -> ParseOk(acc)
    _ -> {
      case extract_number_and_unit(s) {
        Ok(#(value, unit, rest)) -> {
          let pair = case unit {
            "H" -> Ok(#("hour", value))
            "M" -> Ok(#("minute", value))
            "S" -> Ok(#("second", value))
            _ -> Error(Nil)
          }
          case pair {
            Ok(p) -> do_parse_duration_time(rest, [p, ..acc])
            Error(_) -> ParseError(InvalidDuration)
          }
        }
        Error(_) -> ParseError(InvalidDuration)
      }
    }
  }
}

fn extract_number_and_unit(s: String) -> Result(#(Int, String, String), Nil) {
  let chars = string.to_graphemes(s)
  extract_digits(chars, "")
}

fn extract_digits(
  chars: List(String),
  acc: String,
) -> Result(#(Int, String, String), Nil) {
  case chars {
    [] -> Error(Nil)
    [c, ..rest] -> {
      case is_digit(c) {
        True -> extract_digits(rest, acc <> c)
        False -> {
          case acc {
            "" -> Error(Nil)
            _ -> {
              case int.parse(acc) {
                Ok(num) -> Ok(#(num, c, string.join(rest, "")))
                Error(_) -> Error(Nil)
              }
            }
          }
        }
      }
    }
  }
}

fn is_digit(c: String) -> Bool {
  case c {
    "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" -> True
    _ -> False
  }
}

// Helper function for zero padding
fn zero_pad(value: Int, width: Int) -> String {
  case value >= 0 {
    True -> {
      let s = int.to_string(value)
      let len = string.length(s)
      case width - len {
        n if n <= 0 -> s
        1 -> "0" <> s
        2 -> "00" <> s
        3 -> "000" <> s
        4 -> "0000" <> s
        5 -> "00000" <> s
        6 -> "000000" <> s
        _ -> s
      }
    }
    False -> "-" <> zero_pad(-value, width)
  }
}
