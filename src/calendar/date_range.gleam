// Date range utilities for calendar operations
import calendar/date.{type Date}
import gleam/list

pub type DateRange {
  DateRange(first: Date, last: Date, step: Int)
}

pub type DateRangeError {
  InvalidRange
}

/// Creates a date range with step 1.
pub fn new(first: Date, last: Date) -> Result(DateRange, DateRangeError) {
  new_with_step(first, last, 1)
}

/// Creates a date range with a custom step.
pub fn new_with_step(
  first: Date,
  last: Date,
  step: Int,
) -> Result(DateRange, DateRangeError) {
  case step == 0 {
    True -> Error(InvalidRange)
    False -> {
      case first.calendar == last.calendar {
        False -> Error(InvalidRange)
        True -> Ok(DateRange(first: first, last: last, step: step))
      }
    }
  }
}

/// Converts a date range to a list of dates.
pub fn to_list(range: DateRange) -> List(Date) {
  let first_days = date.to_gregorian_days(range.first)
  let last_days = date.to_gregorian_days(range.last)
  date_range_to_list(range.first, first_days, last_days, range.step, [])
  |> list.reverse
}

/// Returns the number of dates in the range.
pub fn size(range: DateRange) -> Int {
  let first_days = date.to_gregorian_days(range.first)
  let last_days = date.to_gregorian_days(range.last)
  let diff = last_days - first_days
  case range.step > 0 && diff >= 0 {
    True -> diff / range.step + 1
    False ->
      case range.step < 0 && diff <= 0 {
        True -> { -diff } / { -range.step } + 1
        False -> 0
      }
  }
}

/// Checks if a date is in the range.
pub fn member(range: DateRange, d: Date) -> Bool {
  let d_days = date.to_gregorian_days(d)
  let first_days = date.to_gregorian_days(range.first)
  let last_days = date.to_gregorian_days(range.last)
  let diff = d_days - first_days
  case range.step > 0 {
    True ->
      d_days >= first_days && d_days <= last_days && diff % range.step == 0
    False ->
      d_days <= first_days && d_days >= last_days && diff % range.step == 0
  }
}

fn date_range_to_list(
  current: Date,
  current_days: Int,
  target_days: Int,
  step: Int,
  acc: List(Date),
) -> List(Date) {
  case
    step > 0
    && current_days > target_days
    || step < 0
    && current_days < target_days
  {
    True -> acc
    False -> {
      let next = date.add(current, step)
      date_range_to_list(next, current_days + step, target_days, step, [
        current,
        ..acc
      ])
    }
  }
}
