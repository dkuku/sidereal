import calendar/date
import gleeunit
import gleeunit/should
import test_helpers

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn basic_date_creation_test() {
  // Test successful date creation
  let result = date.new(2023, 12, 25, "Calendar.ISO")
  case result {
    Ok(d) -> {
      d.year |> should.equal(2023)
      d.month |> should.equal(12)
      d.day |> should.equal(25)
    }
    Error(_) -> panic as "Expected valid date"
  }
}

pub fn date_with_simple_wrapper_test() {
  // Test using new_simple wrapper
  let result = date.new_simple(2023, 1, 15)
  case result {
    Ok(d) -> {
      d.calendar |> should.equal("Calendar.ISO")
    }
    Error(_) -> panic as "Expected valid date with simple wrapper"
  }
}

pub fn invalid_date_test() {
  // Test invalid date creation
  let result = date.new(2023, 13, 25, "Calendar.ISO")
  case result {
    Ok(_) -> panic as "Expected invalid date error"
    Error(date.InvalidDate) -> Nil
    Error(_) -> panic as "Expected InvalidDate error"
  }
}

pub fn date_operations_test() {
  // Test that we can perform operations on dates
  let d = test_helpers.unwrap_date(date.new(2023, 6, 15, "Calendar.ISO"))

  // Test string conversion
  let date_str = date.to_string(d)
  date_str |> should.equal("2023-06-15")

  // Test ISO8601 conversion
  let iso_str = date.to_iso8601(d)
  iso_str |> should.equal("2023-06-15")
}
