import calendar/date
import calendar/date_range
import gleam/list
import gleeunit
import gleeunit/should
import test_helpers

pub fn main() -> Nil {
  gleeunit.main()
}

// Creation tests

pub fn new_range_test() {
  let d1 = test_helpers.unwrap_date(date.new_simple(2024, 1, 1))
  let d2 = test_helpers.unwrap_date(date.new_simple(2024, 1, 5))
  let result = date_range.new(d1, d2)
  case result {
    Ok(range) -> {
      range.first |> should.equal(d1)
      range.last |> should.equal(d2)
      range.step |> should.equal(1)
    }
    Error(_) -> panic as "Expected valid date range"
  }
}

pub fn new_with_step_test() {
  let d1 = test_helpers.unwrap_date(date.new_simple(2024, 1, 1))
  let d2 = test_helpers.unwrap_date(date.new_simple(2024, 1, 10))
  let result = date_range.new_with_step(d1, d2, 2)
  case result {
    Ok(range) -> {
      range.step |> should.equal(2)
    }
    Error(_) -> panic as "Expected valid date range with step"
  }
}

pub fn new_with_step_zero_test() {
  let d1 = test_helpers.unwrap_date(date.new_simple(2024, 1, 1))
  let d2 = test_helpers.unwrap_date(date.new_simple(2024, 1, 5))
  let result = date_range.new_with_step(d1, d2, 0)
  case result {
    Ok(_) -> panic as "Expected InvalidRange error for step 0"
    Error(date_range.InvalidRange) -> Nil
  }
}

pub fn new_incompatible_calendars_test() {
  let d1 = test_helpers.unwrap_date(date.new(2024, 1, 1, "Calendar.ISO"))
  let d2 = test_helpers.unwrap_date(date.new(2024, 1, 5, "Calendar.Other"))
  let result = date_range.new(d1, d2)
  case result {
    Ok(_) -> panic as "Expected InvalidRange for incompatible calendars"
    Error(date_range.InvalidRange) -> Nil
  }
}

// to_list tests

pub fn to_list_basic_test() {
  let d1 = test_helpers.unwrap_date(date.new_simple(2024, 1, 1))
  let d2 = test_helpers.unwrap_date(date.new_simple(2024, 1, 3))
  let assert Ok(range) = date_range.new(d1, d2)
  let dates = date_range.to_list(range)
  list.length(dates) |> should.equal(3)
}

pub fn to_list_single_day_test() {
  let d1 = test_helpers.unwrap_date(date.new_simple(2024, 1, 1))
  let assert Ok(range) = date_range.new(d1, d1)
  let dates = date_range.to_list(range)
  list.length(dates) |> should.equal(1)
}

pub fn to_list_with_step_test() {
  let d1 = test_helpers.unwrap_date(date.new_simple(2024, 1, 1))
  let d2 = test_helpers.unwrap_date(date.new_simple(2024, 1, 10))
  let assert Ok(range) = date_range.new_with_step(d1, d2, 3)
  let dates = date_range.to_list(range)
  // 1, 4, 7, 10 = 4 dates
  list.length(dates) |> should.equal(4)
}

pub fn to_list_negative_step_test() {
  let d1 = test_helpers.unwrap_date(date.new_simple(2024, 1, 5))
  let d2 = test_helpers.unwrap_date(date.new_simple(2024, 1, 1))
  let assert Ok(range) = date_range.new_with_step(d1, d2, -1)
  let dates = date_range.to_list(range)
  list.length(dates) |> should.equal(5)
}

pub fn to_list_month_boundary_test() {
  let d1 = test_helpers.unwrap_date(date.new_simple(2024, 1, 30))
  let d2 = test_helpers.unwrap_date(date.new_simple(2024, 2, 2))
  let assert Ok(range) = date_range.new(d1, d2)
  let dates = date_range.to_list(range)
  // Jan 30, 31, Feb 1, 2 = 4 dates
  list.length(dates) |> should.equal(4)
}

// size tests

pub fn size_basic_test() {
  let d1 = test_helpers.unwrap_date(date.new_simple(2024, 1, 1))
  let d2 = test_helpers.unwrap_date(date.new_simple(2024, 1, 5))
  let assert Ok(range) = date_range.new(d1, d2)
  date_range.size(range) |> should.equal(5)
}

pub fn size_single_day_test() {
  let d1 = test_helpers.unwrap_date(date.new_simple(2024, 1, 1))
  let assert Ok(range) = date_range.new(d1, d1)
  date_range.size(range) |> should.equal(1)
}

pub fn size_with_step_test() {
  let d1 = test_helpers.unwrap_date(date.new_simple(2024, 1, 1))
  let d2 = test_helpers.unwrap_date(date.new_simple(2024, 1, 10))
  let assert Ok(range) = date_range.new_with_step(d1, d2, 3)
  date_range.size(range) |> should.equal(4)
}

pub fn size_wrong_direction_test() {
  let d1 = test_helpers.unwrap_date(date.new_simple(2024, 1, 5))
  let d2 = test_helpers.unwrap_date(date.new_simple(2024, 1, 1))
  let assert Ok(range) = date_range.new_with_step(d1, d2, 1)
  date_range.size(range) |> should.equal(0)
}

// member tests

pub fn member_in_range_test() {
  let d1 = test_helpers.unwrap_date(date.new_simple(2024, 1, 1))
  let d2 = test_helpers.unwrap_date(date.new_simple(2024, 1, 10))
  let assert Ok(range) = date_range.new(d1, d2)
  let d_check = test_helpers.unwrap_date(date.new_simple(2024, 1, 5))
  date_range.member(range, d_check) |> should.equal(True)
}

pub fn member_not_in_range_test() {
  let d1 = test_helpers.unwrap_date(date.new_simple(2024, 1, 1))
  let d2 = test_helpers.unwrap_date(date.new_simple(2024, 1, 10))
  let assert Ok(range) = date_range.new(d1, d2)
  let d_check = test_helpers.unwrap_date(date.new_simple(2024, 1, 15))
  date_range.member(range, d_check) |> should.equal(False)
}

pub fn member_with_step_hit_test() {
  let d1 = test_helpers.unwrap_date(date.new_simple(2024, 1, 1))
  let d2 = test_helpers.unwrap_date(date.new_simple(2024, 1, 10))
  let assert Ok(range) = date_range.new_with_step(d1, d2, 3)
  // Dates in range with step 3: Jan 1, 4, 7, 10
  let d_check = test_helpers.unwrap_date(date.new_simple(2024, 1, 7))
  date_range.member(range, d_check) |> should.equal(True)
}

pub fn member_with_step_miss_test() {
  let d1 = test_helpers.unwrap_date(date.new_simple(2024, 1, 1))
  let d2 = test_helpers.unwrap_date(date.new_simple(2024, 1, 10))
  let assert Ok(range) = date_range.new_with_step(d1, d2, 3)
  // Jan 2 is in the date span but not on a step boundary
  let d_check = test_helpers.unwrap_date(date.new_simple(2024, 1, 2))
  date_range.member(range, d_check) |> should.equal(False)
}

pub fn member_first_date_test() {
  let d1 = test_helpers.unwrap_date(date.new_simple(2024, 1, 1))
  let d2 = test_helpers.unwrap_date(date.new_simple(2024, 1, 10))
  let assert Ok(range) = date_range.new(d1, d2)
  date_range.member(range, d1) |> should.equal(True)
}

pub fn member_last_date_test() {
  let d1 = test_helpers.unwrap_date(date.new_simple(2024, 1, 1))
  let d2 = test_helpers.unwrap_date(date.new_simple(2024, 1, 10))
  let assert Ok(range) = date_range.new(d1, d2)
  date_range.member(range, d2) |> should.equal(True)
}
