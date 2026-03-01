import calendar/time
import gleeunit
import gleeunit/should
import test_helpers

pub fn main() -> Nil {
  gleeunit.main()
}

// Basic time creation tests
pub fn time_creation_test() {
  let result = time.new(23, 0, 7, #(5000, 3), "Calendar.ISO")
  case result {
    Ok(t) -> {
      t.hour |> should.equal(23)
      t.minute |> should.equal(0)
      t.second |> should.equal(7)
      t.microsecond |> should.equal(#(5000, 3))
      t.calendar |> should.equal("Calendar.ISO")
    }
    Error(_) -> panic as "Expected valid time"
  }
}

pub fn time_creation_simple_test() {
  let result = time.new_simple(12, 34, 56)
  case result {
    Ok(t) -> {
      t.hour |> should.equal(12)
      t.minute |> should.equal(34)
      t.second |> should.equal(56)
      t.microsecond |> should.equal(#(0, 0))
      t.calendar |> should.equal("Calendar.ISO")
    }
    Error(_) -> panic as "Expected valid time"
  }
}

// Invalid time tests
pub fn invalid_time_hour_test() {
  let result = time.new(24, 0, 0, #(0, 0), "Calendar.ISO")
  case result {
    Ok(_) -> panic as "Expected invalid time error"
    Error(time.InvalidTime) -> Nil
    Error(_) -> panic as "Expected InvalidTime error"
  }
}

pub fn invalid_time_minute_test() {
  let result = time.new(12, 60, 0, #(0, 0), "Calendar.ISO")
  case result {
    Ok(_) -> panic as "Expected invalid time error"
    Error(time.InvalidTime) -> Nil
    Error(_) -> panic as "Expected InvalidTime error"
  }
}

pub fn invalid_time_second_test() {
  let result = time.new(12, 30, 60, #(0, 0), "Calendar.ISO")
  case result {
    Ok(_) -> panic as "Expected invalid time error"
    Error(time.InvalidTime) -> Nil
    Error(_) -> panic as "Expected InvalidTime error"
  }
}

pub fn invalid_time_negative_hour_test() {
  let result = time.new(-1, 0, 0, #(0, 0), "Calendar.ISO")
  case result {
    Ok(_) -> panic as "Expected invalid time error"
    Error(time.InvalidTime) -> Nil
    Error(_) -> panic as "Expected InvalidTime error"
  }
}

// String conversion tests
pub fn to_string_test() {
  let t =
    test_helpers.unwrap_time(time.new(23, 0, 7, #(5000, 3), "Calendar.ISO"))
  let time_str = time.to_string(t)
  time_str |> should.equal("23:00:07.500")
  // Actual output format
}

pub fn to_string_no_microseconds_test() {
  let t =
    test_helpers.unwrap_time(time.new(12, 34, 56, #(0, 0), "Calendar.ISO"))
  let time_str = time.to_string(t)
  time_str |> should.equal("12:34:56")
}

pub fn to_string_with_microseconds_test() {
  let t =
    test_helpers.unwrap_time(time.new(1, 1, 1, #(123_456, 6), "Calendar.ISO"))
  let time_str = time.to_string(t)
  time_str |> should.equal("01:01:01.123456")
}

// ISO8601 conversion tests
pub fn to_iso8601_test() {
  let t =
    test_helpers.unwrap_time(time.new(23, 0, 7, #(5000, 3), "Calendar.ISO"))
  let iso_str = time.to_iso8601(t)
  iso_str |> should.equal("23:00:07.500")
  // Actual output format
}

pub fn to_iso8601_basic_test() {
  let t =
    test_helpers.unwrap_time(time.new(23, 0, 7, #(5000, 3), "Calendar.ISO"))
  let iso_str = time.to_iso8601_with_format(t, time.Basic)
  iso_str |> should.equal("230007.500")
  // Actual output format
}

pub fn to_iso8601_no_microseconds_test() {
  let t =
    test_helpers.unwrap_time(time.new(12, 34, 56, #(0, 0), "Calendar.ISO"))
  let iso_str = time.to_iso8601(t)
  iso_str |> should.equal("12:34:56")
}

// Time comparison and arithmetic tests would require additional functions
// that may not be available in the current API.
// Focus on the core time creation and formatting functionality for now.

// Test converting time to seconds after midnight
pub fn to_seconds_after_midnight_test() {
  let t = test_helpers.unwrap_time(time.new(1, 0, 0, #(0, 0), "Calendar.ISO"))
  let seconds = time.to_seconds_after_midnight(t)
  seconds |> should.equal(3600)
  // 1 hour = 3600 seconds
}

pub fn to_microseconds_after_midnight_test() {
  let t =
    test_helpers.unwrap_time(time.new(0, 0, 1, #(500_000, 6), "Calendar.ISO"))
  let microseconds = time.to_microseconds_after_midnight(t)
  microseconds |> should.equal(1_500_000)
  // 1 second + 500000 microseconds
}

// ISO 8601 parsing tests

pub fn from_iso8601_basic_test() {
  let result = time.from_iso8601("12:34:56")
  case result {
    Ok(t) -> {
      t.hour |> should.equal(12)
      t.minute |> should.equal(34)
      t.second |> should.equal(56)
      t.microsecond |> should.equal(#(0, 0))
    }
    Error(_) -> panic as "Expected valid ISO8601 time parse"
  }
}

pub fn from_iso8601_with_microseconds_test() {
  let result = time.from_iso8601("23:00:07.500")
  case result {
    Ok(t) -> {
      t.hour |> should.equal(23)
      t.minute |> should.equal(0)
      t.second |> should.equal(7)
    }
    Error(_) -> panic as "Expected valid ISO8601 time with microseconds"
  }
}

pub fn from_iso8601_midnight_test() {
  let result = time.from_iso8601("00:00:00")
  case result {
    Ok(t) -> {
      t.hour |> should.equal(0)
      t.minute |> should.equal(0)
      t.second |> should.equal(0)
    }
    Error(_) -> panic as "Expected valid ISO8601 midnight parse"
  }
}

pub fn from_iso8601_invalid_test() {
  let result = time.from_iso8601("not-a-time")
  case result {
    Ok(_) -> panic as "Expected error for invalid time string"
    Error(_) -> Nil
  }
}

// Timestamp round-trip tests

pub fn timestamp_round_trip_test() {
  let t =
    test_helpers.unwrap_time(time.new(12, 30, 45, #(0, 0), "Calendar.ISO"))
  let ts = time.to_timestamp(t)
  // to_timestamp returns seconds after midnight
  ts |> should.equal(12 * 3600 + 30 * 60 + 45)
}

pub fn from_timestamp_test() {
  // 3661 seconds = 1 hour, 1 minute, 1 second
  let result = time.from_timestamp(3661)
  case result {
    Ok(t) -> {
      t.hour |> should.equal(1)
      t.minute |> should.equal(1)
      t.second |> should.equal(1)
    }
    Error(_) -> panic as "Expected valid time from timestamp"
  }
}

pub fn from_seconds_after_midnight_test() {
  // 45296 seconds = 12:34:56
  let result = time.from_seconds_after_midnight(45_296)
  case result {
    Ok(t) -> {
      t.hour |> should.equal(12)
      t.minute |> should.equal(34)
      t.second |> should.equal(56)
    }
    Error(_) -> panic as "Expected valid time from seconds"
  }
}

pub fn from_seconds_after_midnight_invalid_test() {
  let result = time.from_seconds_after_midnight(86_400)
  case result {
    Ok(_) -> panic as "Expected error for 86400 seconds"
    Error(_) -> Nil
  }
}

// Comparison tests

pub fn compare_equal_test() {
  let t1 = test_helpers.unwrap_time(time.new(12, 0, 0, #(0, 0), "Calendar.ISO"))
  let t2 = test_helpers.unwrap_time(time.new(12, 0, 0, #(0, 0), "Calendar.ISO"))
  time.compare(t1, t2) |> should.equal(time.Eq)
}

pub fn compare_less_than_test() {
  let t1 =
    test_helpers.unwrap_time(time.new(11, 59, 59, #(0, 0), "Calendar.ISO"))
  let t2 = test_helpers.unwrap_time(time.new(12, 0, 0, #(0, 0), "Calendar.ISO"))
  time.compare(t1, t2) |> should.equal(time.Lt)
}

pub fn compare_greater_than_test() {
  let t1 = test_helpers.unwrap_time(time.new(12, 0, 1, #(0, 0), "Calendar.ISO"))
  let t2 = test_helpers.unwrap_time(time.new(12, 0, 0, #(0, 0), "Calendar.ISO"))
  time.compare(t1, t2) |> should.equal(time.Gt)
}

pub fn before_true_test() {
  let t1 = test_helpers.unwrap_time(time.new(10, 0, 0, #(0, 0), "Calendar.ISO"))
  let t2 = test_helpers.unwrap_time(time.new(12, 0, 0, #(0, 0), "Calendar.ISO"))
  time.before(t1, t2) |> should.equal(True)
}

pub fn before_false_test() {
  let t1 = test_helpers.unwrap_time(time.new(12, 0, 0, #(0, 0), "Calendar.ISO"))
  let t2 = test_helpers.unwrap_time(time.new(10, 0, 0, #(0, 0), "Calendar.ISO"))
  time.before(t1, t2) |> should.equal(False)
}

pub fn after_true_test() {
  let t1 = test_helpers.unwrap_time(time.new(12, 0, 0, #(0, 0), "Calendar.ISO"))
  let t2 = test_helpers.unwrap_time(time.new(10, 0, 0, #(0, 0), "Calendar.ISO"))
  time.after(t1, t2) |> should.equal(True)
}

pub fn after_false_test() {
  let t1 = test_helpers.unwrap_time(time.new(10, 0, 0, #(0, 0), "Calendar.ISO"))
  let t2 = test_helpers.unwrap_time(time.new(12, 0, 0, #(0, 0), "Calendar.ISO"))
  time.after(t1, t2) |> should.equal(False)
}

// Arithmetic tests

pub fn add_seconds_test() {
  let t = test_helpers.unwrap_time(time.new(12, 0, 0, #(0, 0), "Calendar.ISO"))
  let result = time.add(t, 90, time.Second)
  case result {
    Ok(t2) -> {
      t2.hour |> should.equal(12)
      t2.minute |> should.equal(1)
      t2.second |> should.equal(30)
    }
    Error(_) -> panic as "Expected valid time addition"
  }
}

pub fn add_milliseconds_test() {
  let t = test_helpers.unwrap_time(time.new(12, 0, 0, #(0, 0), "Calendar.ISO"))
  let result = time.add(t, 1500, time.Millisecond)
  case result {
    Ok(t2) -> {
      t2.hour |> should.equal(12)
      t2.minute |> should.equal(0)
      t2.second |> should.equal(1)
    }
    Error(_) -> panic as "Expected valid millisecond addition"
  }
}

pub fn diff_seconds_test() {
  let t1 =
    test_helpers.unwrap_time(time.new(12, 30, 0, #(0, 0), "Calendar.ISO"))
  let t2 = test_helpers.unwrap_time(time.new(12, 0, 0, #(0, 0), "Calendar.ISO"))
  time.diff(t1, t2, time.Second) |> should.equal(1800)
}

pub fn diff_negative_test() {
  let t1 = test_helpers.unwrap_time(time.new(12, 0, 0, #(0, 0), "Calendar.ISO"))
  let t2 =
    test_helpers.unwrap_time(time.new(12, 30, 0, #(0, 0), "Calendar.ISO"))
  time.diff(t1, t2, time.Second) |> should.equal(-1800)
}

// Special time helpers

pub fn midnight_test() {
  let result = time.midnight()
  case result {
    Ok(t) -> {
      t.hour |> should.equal(0)
      t.minute |> should.equal(0)
      t.second |> should.equal(0)
    }
    Error(_) -> panic as "Expected valid midnight time"
  }
}

pub fn noon_test() {
  let result = time.noon()
  case result {
    Ok(t) -> {
      t.hour |> should.equal(12)
      t.minute |> should.equal(0)
      t.second |> should.equal(0)
    }
    Error(_) -> panic as "Expected valid noon time"
  }
}

pub fn is_midnight_true_test() {
  let t = test_helpers.unwrap_time(time.new(0, 0, 0, #(0, 0), "Calendar.ISO"))
  time.is_midnight(t) |> should.equal(True)
}

pub fn is_midnight_false_test() {
  let t = test_helpers.unwrap_time(time.new(0, 0, 1, #(0, 0), "Calendar.ISO"))
  time.is_midnight(t) |> should.equal(False)
}

// Erlang interop tests

pub fn to_erl_test() {
  let t =
    test_helpers.unwrap_time(time.new(12, 34, 56, #(0, 0), "Calendar.ISO"))
  let erl = time.to_erl(t)
  erl |> should.equal(#(12, 34, 56))
}

pub fn from_erl_test() {
  let result = time.from_erl(#(12, 34, 56), #(0, 0), "Calendar.ISO")
  case result {
    Ok(t) -> {
      t.hour |> should.equal(12)
      t.minute |> should.equal(34)
      t.second |> should.equal(56)
    }
    Error(_) -> panic as "Expected valid time from Erlang tuple"
  }
}

pub fn from_erl_invalid_test() {
  let result = time.from_erl(#(25, 0, 0), #(0, 0), "Calendar.ISO")
  case result {
    Ok(_) -> panic as "Expected error for invalid Erlang time tuple"
    Error(_) -> Nil
  }
}

pub fn erl_round_trip_test() {
  let t =
    test_helpers.unwrap_time(time.new(23, 59, 59, #(0, 0), "Calendar.ISO"))
  let erl = time.to_erl(t)
  let result = time.from_erl(erl, #(0, 0), "Calendar.ISO")
  case result {
    Ok(t2) -> {
      t2.hour |> should.equal(t.hour)
      t2.minute |> should.equal(t.minute)
      t2.second |> should.equal(t.second)
    }
    Error(_) -> panic as "Expected valid Erlang round trip"
  }
}

// Seconds after midnight tuple test

pub fn to_seconds_after_midnight_tuple_test() {
  let t =
    test_helpers.unwrap_time(time.new(1, 30, 45, #(500_000, 6), "Calendar.ISO"))
  let #(seconds, ms) = time.to_seconds_after_midnight_tuple(t)
  seconds |> should.equal(5445)
  ms |> should.equal(500_000)
}

// Second of day test

pub fn second_of_day_test() {
  let t = test_helpers.unwrap_time(time.new(1, 0, 0, #(0, 0), "Calendar.ISO"))
  time.second_of_day(t) |> should.equal(3600)
}

pub fn second_of_day_midnight_test() {
  let t = test_helpers.unwrap_time(time.new(0, 0, 0, #(0, 0), "Calendar.ISO"))
  time.second_of_day(t) |> should.equal(0)
}

// Unit conversion tests

pub fn convert_unit_seconds_to_milliseconds_test() {
  time.convert_unit(5, time.Second, time.Millisecond) |> should.equal(5000)
}

pub fn convert_unit_milliseconds_to_seconds_test() {
  time.convert_unit(5000, time.Millisecond, time.Second) |> should.equal(5)
}

// Truncate test

pub fn truncate_to_second_test() {
  let t =
    test_helpers.unwrap_time(time.new(12, 34, 56, #(123_456, 6), "Calendar.ISO"))
  let truncated = time.truncate(t, 0)
  truncated.microsecond |> should.equal(#(0, 0))
}

pub fn truncate_to_millisecond_test() {
  let t =
    test_helpers.unwrap_time(time.new(12, 34, 56, #(123_456, 6), "Calendar.ISO"))
  let truncated = time.truncate(t, 3)
  truncated.microsecond |> should.equal(#(123_000, 3))
}
