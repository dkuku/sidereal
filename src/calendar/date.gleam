// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: 2021 The Elixir Team
// SPDX-FileCopyrightText: 2012 Plataformatec

import calendar/duration as calendar_duration
import calendar/iso
import gleam/int
import gleam/list
import gleam/order
import gleam/string

@external(erlang, "os", "system_time")
@external(javascript, "../os_ffi.mjs", "system_time")
fn system_time_seconds() -> Int

/// A Date struct and functions.
///
/// The Date struct contains the fields year, month, day and calendar.
/// New dates can be built with the `new` function.
pub type Date {
  Date(year: Int, month: Int, day: Int, calendar: String)
}

pub type DateError {
  InvalidDate
  InvalidYear
  InvalidMonth
  InvalidDay
  InvalidFormat
  InvalidCalendar
  IncompatibleCalendars
}

pub type DateFormat {
  Extended
  Basic
}

/// Creates a new Date struct.
pub fn new(
  year: Int,
  month: Int,
  day: Int,
  calendar: String,
) -> Result(Date, DateError) {
  case is_valid_date(year, month, day) {
    True -> Ok(Date(year: year, month: month, day: day, calendar: calendar))
    False -> Error(InvalidDate)
  }
}

/// Creates a new Date struct with ISO calendar as default.
pub fn new_simple(year: Int, month: Int, day: Int) -> Result(Date, DateError) {
  new(year, month, day, "Calendar.ISO")
}

/// Creates a new Date struct with ISO calendar as default.
pub fn new_iso(year: Int, month: Int, day: Int) -> Result(Date, DateError) {
  new(year, month, day, "Calendar.ISO")
}

/// Checks if a year is a leap year.
pub fn is_leap_year(year: Int) -> Bool {
  case year % 4 == 0 {
    True ->
      case year % 100 == 0 {
        True -> year % 400 == 0
        False -> True
      }
    False -> False
  }
}

/// Returns the number of days in a given month and year.
pub fn days_in_month(year: Int, month: Int) -> Int {
  case month {
    1 | 3 | 5 | 7 | 8 | 10 | 12 -> 31
    4 | 6 | 9 | 11 -> 30
    2 ->
      case is_leap_year(year) {
        True -> 29
        False -> 28
      }
    _ -> 0
  }
}

/// Validates if the given date components form a valid date.
fn is_valid_date(year: Int, month: Int, day: Int) -> Bool {
  month >= 1 && month <= 12 && day >= 1 && day <= days_in_month(year, month)
}

/// Converts a Date to a string in ISO8601 format (YYYY-MM-DD).
pub fn to_string(date: Date) -> String {
  let year_str = case date.year >= 0 && date.year <= 9999 {
    True -> pad_left(int.to_string(date.year), 4, "0")
    False -> int.to_string(date.year)
  }
  let month_str = pad_left(int.to_string(date.month), 2, "0")
  let day_str = pad_left(int.to_string(date.day), 2, "0")

  year_str <> "-" <> month_str <> "-" <> day_str
}

/// Helper function to pad string with leading characters.
fn pad_left(str: String, width: Int, pad_char: String) -> String {
  let current_length = string.length(str)
  case current_length >= width {
    True -> str
    False -> string.repeat(pad_char, width - current_length) <> str
  }
}

/// Converts a Date to ISO8601 format.
pub fn to_iso8601(date: Date) -> String {
  to_string(date)
}

/// Add days to a date.
pub fn add_days(date: Date, days: Int) -> Result(Date, DateError) {
  let total_days = to_days_since_epoch(date) + days
  from_days_since_epoch(total_days, date.calendar)
}

/// Subtract days from a date.
pub fn subtract_days(date: Date, days: Int) -> Result(Date, DateError) {
  add_days(date, -days)
}

/// Compare two dates. Returns order.Lt, order.Eq, or order.Gt.
pub fn compare(date1: Date, date2: Date) -> order.Order {
  let days1 = to_days_since_epoch(date1)
  let days2 = to_days_since_epoch(date2)

  int.compare(days1, days2)
}

/// Convert date to days since Unix epoch (1970-01-01).
fn to_days_since_epoch(date: Date) -> Int {
  iso.date_to_iso_days(date.year, date.month, date.day) - 719_528
}

/// Convert days since epoch back to a date.
fn from_days_since_epoch(days: Int, calendar: String) -> Result(Date, DateError) {
  // Use the proper ISO calendar implementation
  // Convert from Unix epoch (1970-01-01) to ISO epoch (0000-01-01)
  let iso_days = days + 719_528
  // 719_528 is the offset from ISO epoch to Unix epoch
  let #(year, month, day) = iso.date_from_iso_days(iso_days)

  // Validate the result
  case is_valid_date(year, month, day) {
    True -> Ok(Date(year: year, month: month, day: day, calendar: calendar))
    False -> Error(InvalidDate)
  }
}

/// Convert month to approximate day of year.
fn month_to_day_of_year(year: Int, month: Int) -> Int {
  case month {
    1 -> 0
    2 -> 31
    3 -> 59 + leap_day_offset(year)
    4 -> 90 + leap_day_offset(year)
    5 -> 120 + leap_day_offset(year)
    6 -> 151 + leap_day_offset(year)
    7 -> 181 + leap_day_offset(year)
    8 -> 212 + leap_day_offset(year)
    9 -> 243 + leap_day_offset(year)
    10 -> 273 + leap_day_offset(year)
    11 -> 304 + leap_day_offset(year)
    12 -> 334 + leap_day_offset(year)
    _ -> 0
  }
}

fn leap_day_offset(year: Int) -> Int {
  case is_leap_year(year) {
    True -> 1
    False -> 0
  }
}

/// Create a date from Unix timestamp (seconds since epoch).
pub fn from_timestamp(timestamp: Int) -> Result(Date, DateError) {
  from_days_since_epoch(timestamp / 86_400, "Calendar.ISO")
}

/// Create a date from days since Unix epoch (1970-01-01).
pub fn from_days_since_unix_epoch(
  days: Int,
  calendar: String,
) -> Result(Date, DateError) {
  from_days_since_epoch(days, calendar)
}

/// Convert date to Unix timestamp (approximation).
pub fn to_timestamp(date: Date) -> Int {
  to_days_since_epoch(date) * 86_400
}

/// Returns the current date in UTC.
pub fn utc_today() -> Date {
  utc_today_with_calendar("Calendar.ISO")
}

/// Returns the current date in UTC with specified calendar.
pub fn utc_today_with_calendar(calendar: String) -> Date {
  let timestamp = system_time_seconds()
  let days = timestamp / 86_400
  case from_days_since_epoch(days, calendar) {
    Ok(date) -> date
    Error(_) -> Date(year: 1970, month: 1, day: 1, calendar: calendar)
  }
}

/// Returns `true` if the year in the given `date` is a leap year.
pub fn leap_year(date: Date) -> Bool {
  is_leap_year(date.year)
}

/// Returns the number of days in the given `date` month.
pub fn days_in_month_for_date(date: Date) -> Int {
  days_in_month(date.year, date.month)
}

/// Returns the number of months in the given `date` year.
pub fn months_in_year(_date: Date) -> Int {
  12
  // Always 12 for ISO calendar
}

/// Parses an ISO 8601 date string.
pub fn from_iso8601(string: String) -> Result(Date, DateError) {
  from_iso8601_with_calendar(string, "Calendar.ISO")
}

/// Parses an ISO 8601 date string with specified calendar.
pub fn from_iso8601_with_calendar(
  string: String,
  calendar: String,
) -> Result(Date, DateError) {
  parse_iso8601_date(string, calendar)
}

/// Converts the given `date` to ISO 8601 with format option.
pub fn to_iso8601_with_format(date: Date, format: DateFormat) -> String {
  case format {
    Extended -> to_string(date)
    Basic -> {
      let year_str = case date.year >= 0 && date.year <= 9999 {
        True -> pad_left(int.to_string(date.year), 4, "0")
        False -> int.to_string(date.year)
      }
      let month_str = pad_left(int.to_string(date.month), 2, "0")
      let day_str = pad_left(int.to_string(date.day), 2, "0")
      year_str <> month_str <> day_str
    }
  }
}

/// Converts the given `date` to an Erlang date tuple.
pub fn to_erl(date: Date) -> #(Int, Int, Int) {
  #(date.year, date.month, date.day)
}

/// Converts an Erlang date tuple to a `Date` struct.
pub fn from_erl(tuple: #(Int, Int, Int)) -> Result(Date, DateError) {
  from_erl_with_calendar(tuple, "Calendar.ISO")
}

/// Converts an Erlang date tuple to a `Date` struct with specified calendar.
pub fn from_erl_with_calendar(
  tuple: #(Int, Int, Int),
  calendar: String,
) -> Result(Date, DateError) {
  let #(year, month, day) = tuple
  new(year, month, day, calendar)
}

/// Converts a number of gregorian days to a `Date` struct.
pub fn from_gregorian_days(days: Int) -> Date {
  from_gregorian_days_with_calendar(days, "Calendar.ISO")
}

/// Converts a number of gregorian days to a `Date` struct with specified calendar.
pub fn from_gregorian_days_with_calendar(days: Int, calendar: String) -> Date {
  case from_days_since_epoch(days - 719_163, calendar) {
    // 719163 is gregorian epoch offset
    Ok(date) -> date
    Error(_) -> Date(year: 0, month: 1, day: 1, calendar: calendar)
  }
}

/// Converts a `date` struct to a number of gregorian days.
pub fn to_gregorian_days(date: Date) -> Int {
  to_days_since_epoch(date) + 719_163
  // Add gregorian epoch offset
}

/// Returns `true` if the first date is strictly earlier than the second.
pub fn before(date1: Date, date2: Date) -> Bool {
  case compare(date1, date2) {
    order.Lt -> True
    _ -> False
  }
}

/// Returns `true` if the first date is strictly later than the second.
pub fn after(date1: Date, date2: Date) -> Bool {
  case compare(date1, date2) {
    order.Gt -> True
    _ -> False
  }
}

/// Converts the given `date` from its calendar to the given `calendar`.
pub fn convert(date: Date, target_calendar: String) -> Result(Date, DateError) {
  case date.calendar == target_calendar {
    True -> Ok(date)
    False -> {
      // Simple conversion - in a full implementation, this would check calendar compatibility
      Ok(Date(
        year: date.year,
        month: date.month,
        day: date.day,
        calendar: target_calendar,
      ))
    }
  }
}

/// Adds the number of days to the given `date`.
pub fn add(date: Date, days: Int) -> Date {
  case add_days(date, days) {
    Ok(new_date) -> new_date
    Error(_) -> date
    // Fallback to original date
  }
}

/// Calculates the difference between two dates, in a full number of days.
pub fn diff(date1: Date, date2: Date) -> Int {
  to_days_since_epoch(date1) - to_days_since_epoch(date2)
}

/// Shifts given `date` by `duration` according to its calendar.
pub fn shift(
  date: Date,
  duration: calendar_duration.Duration,
) -> Result(Date, DateError) {
  // Extract duration components
  let years = duration.year
  let months = duration.month
  let weeks = duration.week
  let days = duration.day

  // Apply year and month shifts first
  let new_year = date.year + years
  let new_month = date.month + months

  // Normalize month overflow
  let normalized_year = new_year + { new_month - 1 } / 12
  let normalized_month = { { new_month - 1 } % 12 } + 1

  // Handle day overflow
  let max_days = days_in_month(normalized_year, normalized_month)
  let normalized_day = case date.day > max_days {
    True -> max_days
    False -> date.day
  }

  // Create intermediate date
  case new(normalized_year, normalized_month, normalized_day, date.calendar) {
    Ok(intermediate_date) -> {
      // Add weeks and days
      let total_days = weeks * 7 + days
      add_days(intermediate_date, total_days)
    }
    Error(e) -> Error(e)
  }
}

/// Calculates the ordinal day of the week of a given `date`.
pub fn day_of_week(date: Date) -> Int {
  day_of_week_starting_on(date, 1)
  // Monday = 1
}

/// Calculates the ordinal day of the week with custom starting day.
pub fn day_of_week_starting_on(date: Date, starting_on: Int) -> Int {
  // Zeller's congruence for day of week calculation
  let year = case date.month < 3 {
    True -> date.year - 1
    False -> date.year
  }
  let month = case date.month < 3 {
    True -> date.month + 12
    False -> date.month
  }

  let day_of_week =
    {
      date.day
      + { 13 * { month + 1 } }
      / 5
      + year
      + year
      / 4
      - year
      / 100
      + year
      / 400
    }
    % 7

  // Adjust for starting day (convert from 0=Saturday to 1=Monday standard)
  let adjusted = case day_of_week {
    0 -> 7
    // Saturday -> 7
    n -> n
  }

  // Rotate based on starting_on
  case adjusted - starting_on + 1 {
    n if n <= 0 -> n + 7
    n if n > 7 -> n - 7
    n -> n
  }
}

/// Calculates a date that is the first day of the week for the given `date`.
pub fn beginning_of_week(date: Date) -> Date {
  beginning_of_week_starting_on(date, 1)
  // Monday
}

/// Calculates beginning of week with custom starting day.
pub fn beginning_of_week_starting_on(date: Date, starting_on: Int) -> Date {
  let current_day_of_week = day_of_week_starting_on(date, starting_on)
  let days_to_subtract = current_day_of_week - 1
  add(date, -days_to_subtract)
}

/// Calculates a date that is the last day of the week for the given `date`.
pub fn end_of_week(date: Date) -> Date {
  end_of_week_starting_on(date, 1)
  // Monday
}

/// Calculates end of week with custom starting day.
pub fn end_of_week_starting_on(date: Date, starting_on: Int) -> Date {
  let current_day_of_week = day_of_week_starting_on(date, starting_on)
  let days_to_add = 7 - current_day_of_week
  add(date, days_to_add)
}

/// Calculates the day of the year of a given `date`.
pub fn day_of_year(date: Date) -> Int {
  month_to_day_of_year(date.year, date.month) + date.day
}

/// Calculates the quarter of the year of a given `date`.
pub fn quarter_of_year(date: Date) -> Int {
  case date.month {
    1 | 2 | 3 -> 1
    4 | 5 | 6 -> 2
    7 | 8 | 9 -> 3
    10 | 11 | 12 -> 4
    _ -> 1
  }
}

/// Calculates the year-of-era and era for a given calendar year.
pub fn year_of_era(date: Date) -> #(Int, Int) {
  case date.year >= 1 {
    True -> #(date.year, 1)
    // CE era
    False -> #(-date.year + 1, 0)
    // BCE era
  }
}

/// Calculates the day-of-era and era for a given calendar `date`.
pub fn day_of_era(date: Date) -> #(Int, Int) {
  let #(_, era) = year_of_era(date)
  let days = to_gregorian_days(date)
  case era {
    1 -> #(days, 1)
    // CE era
    0 -> #(-days + 1, 0)
    // BCE era
    _ -> #(days, era)
  }
}

/// Calculates a date that is the first day of the month for the given `date`.
pub fn beginning_of_month(date: Date) -> Date {
  Date(year: date.year, month: date.month, day: 1, calendar: date.calendar)
}

/// Calculates a date that is the last day of the month for the given `date`.
pub fn end_of_month(date: Date) -> Date {
  let last_day = days_in_month(date.year, date.month)
  Date(
    year: date.year,
    month: date.month,
    day: last_day,
    calendar: date.calendar,
  )
}

/// Creates a date range between two dates.
pub fn range(first: Date, last: Date) -> Result(List(Date), DateError) {
  range_with_step(first, last, 1)
}

/// Creates a date range with a step.
pub fn range_with_step(
  first: Date,
  last: Date,
  step: Int,
) -> Result(List(Date), DateError) {
  case step == 0 {
    True -> Error(InvalidDate)
    False -> {
      case first.calendar == last.calendar {
        False -> Error(IncompatibleCalendars)
        True -> {
          let first_days = to_days_since_epoch(first)
          let last_days = to_days_since_epoch(last)
          generate_date_range(first, first_days, last_days, step, [])
        }
      }
    }
  }
}

// Helper functions

fn parse_iso8601_date(
  string: String,
  calendar: String,
) -> Result(Date, DateError) {
  // Simple ISO8601 parser - expects YYYY-MM-DD format
  case string.split(string, "-") {
    [year_str, month_str, day_str] -> {
      case int.parse(year_str), int.parse(month_str), int.parse(day_str) {
        Ok(year), Ok(month), Ok(day) -> new(year, month, day, calendar)
        _, _, _ -> Error(InvalidFormat)
      }
    }
    _ -> Error(InvalidFormat)
  }
}

fn generate_date_range(
  current: Date,
  current_days: Int,
  target_days: Int,
  step: Int,
  acc: List(Date),
) -> Result(List(Date), DateError) {
  case
    step > 0
    && current_days > target_days
    || step < 0
    && current_days < target_days
  {
    True -> Ok(list.reverse(acc))
    False -> {
      let new_acc = [current, ..acc]
      case from_days_since_epoch(current_days + step, current.calendar) {
        Ok(next_date) ->
          generate_date_range(
            next_date,
            current_days + step,
            target_days,
            step,
            new_acc,
          )
        Error(e) -> Error(e)
      }
    }
  }
}
