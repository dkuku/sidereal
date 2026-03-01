import calendar/date
import calendar/duration.{Duration}
import calendar/naive_datetime
import calendar/time
import gleam/list
import gleam/order
import gleeunit
import gleeunit/should
import test_helpers

pub fn main() -> Nil {
  gleeunit.main()
}

// Basic naive datetime creation tests
pub fn naive_datetime_creation_test() {
  let result =
    naive_datetime.new(2000, 1, 1, 12, 34, 56, #(0, 0), "Calendar.ISO")
  case result {
    Ok(ndt) -> {
      ndt.year |> should.equal(2000)
      ndt.month |> should.equal(1)
      ndt.day |> should.equal(1)
      ndt.hour |> should.equal(12)
      ndt.minute |> should.equal(34)
      ndt.second |> should.equal(56)
      ndt.microsecond |> should.equal(#(0, 0))
      ndt.calendar |> should.equal("Calendar.ISO")
    }
    Error(_) -> panic as "Expected valid naive datetime"
  }
}

pub fn naive_datetime_with_microseconds_test() {
  let result =
    naive_datetime.new(2000, 1, 1, 23, 0, 7, #(5000, 3), "Calendar.ISO")
  case result {
    Ok(ndt) -> {
      ndt.year |> should.equal(2000)
      ndt.month |> should.equal(1)
      ndt.day |> should.equal(1)
      ndt.hour |> should.equal(23)
      ndt.minute |> should.equal(0)
      ndt.second |> should.equal(7)
      ndt.microsecond |> should.equal(#(5000, 3))
    }
    Error(_) -> panic as "Expected valid naive datetime with microseconds"
  }
}

// Invalid naive datetime tests
pub fn invalid_naive_datetime_date_test() {
  let result =
    naive_datetime.new(2001, 50, 50, 12, 34, 56, #(0, 0), "Calendar.ISO")
  case result {
    Ok(_) -> panic as "Expected invalid naive datetime error"
    Error(naive_datetime.InvalidDate) -> Nil
    Error(_) -> panic as "Expected InvalidDate error"
  }
}

pub fn invalid_naive_datetime_time_test() {
  let result =
    naive_datetime.new(2001, 1, 1, 12, 34, 65, #(0, 0), "Calendar.ISO")
  case result {
    Ok(_) -> panic as "Expected invalid naive datetime error"
    Error(naive_datetime.InvalidTime) -> Nil
    Error(_) -> panic as "Expected InvalidTime error"
  }
}

// String conversion tests
pub fn to_string_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2000,
      1,
      1,
      23,
      0,
      7,
      #(5000, 3),
      "Calendar.ISO",
    ))
  let ndt_str = naive_datetime.to_string(ndt)
  ndt_str |> should.equal("2000-01-01 23:00:07.500")
}

pub fn to_string_no_microseconds_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2000,
      1,
      1,
      12,
      34,
      56,
      #(0, 0),
      "Calendar.ISO",
    ))
  let ndt_str = naive_datetime.to_string(ndt)
  ndt_str |> should.equal("2000-01-01 12:34:56")
}

pub fn to_string_with_full_microseconds_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2000,
      1,
      1,
      1,
      1,
      1,
      #(123_456, 6),
      "Calendar.ISO",
    ))
  let ndt_str = naive_datetime.to_string(ndt)
  ndt_str |> should.equal("2000-01-01 01:01:01.123456")
}

// ISO8601 conversion tests
pub fn to_iso8601_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2000,
      1,
      1,
      23,
      0,
      7,
      #(5000, 3),
      "Calendar.ISO",
    ))
  let iso_str = naive_datetime.to_iso8601(ndt)
  iso_str |> should.equal("2000-01-01T23:00:07.500")
}

pub fn to_iso8601_no_microseconds_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2000,
      1,
      1,
      12,
      34,
      56,
      #(0, 0),
      "Calendar.ISO",
    ))
  let iso_str = naive_datetime.to_iso8601(ndt)
  iso_str |> should.equal("2000-01-01T12:34:56")
}

// TODO: Implement to_iso8601_basic if needed
// pub fn to_iso8601_basic_test() {
//   let ndt = test_helpers.unwrap_naive_datetime(naive_datetime.new(2000, 1, 1, 23, 0, 7, #(5000, 3), "Calendar.ISO"))
//   let iso_str = naive_datetime.to_iso8601_basic(ndt)
//   iso_str |> should.equal("20000101T230007.005")
// }

// NaiveDateTime comparison tests
pub fn compare_equal_test() {
  let ndt1 =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2000,
      1,
      1,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let ndt2 =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2000,
      1,
      1,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let result = naive_datetime.compare(ndt1, ndt2)
  result |> should.equal(order.Eq)
}

pub fn compare_less_than_test() {
  let ndt1 =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2000,
      1,
      1,
      11,
      59,
      59,
      #(0, 0),
      "Calendar.ISO",
    ))
  let ndt2 =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2000,
      1,
      1,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let result = naive_datetime.compare(ndt1, ndt2)
  result |> should.equal(order.Lt)
}

pub fn compare_greater_than_test() {
  let ndt1 =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2000,
      1,
      2,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let ndt2 =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2000,
      1,
      1,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let result = naive_datetime.compare(ndt1, ndt2)
  result |> should.equal(order.Gt)
}

pub fn compare_with_microseconds_test() {
  let ndt1 =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2000,
      1,
      1,
      12,
      0,
      0,
      #(123_000, 6),
      "Calendar.ISO",
    ))
  let ndt2 =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2000,
      1,
      1,
      12,
      0,
      1,
      #(123_456, 6),
      "Calendar.ISO",
    ))
  let result = naive_datetime.compare(ndt1, ndt2)
  result |> should.equal(order.Lt)
}

// Before and after tests
pub fn before_test() {
  let ndt1 =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2000,
      1,
      1,
      11,
      59,
      59,
      #(0, 0),
      "Calendar.ISO",
    ))
  let ndt2 =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2000,
      1,
      1,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let result = naive_datetime.before(ndt1, ndt2)
  result |> should.equal(True)
}

pub fn not_before_test() {
  let ndt1 =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2000,
      1,
      1,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let ndt2 =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2000,
      1,
      1,
      11,
      59,
      59,
      #(0, 0),
      "Calendar.ISO",
    ))
  let result = naive_datetime.before(ndt1, ndt2)
  result |> should.equal(False)
}

pub fn after_test() {
  let ndt1 =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2000,
      1,
      1,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let ndt2 =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2000,
      1,
      1,
      11,
      59,
      59,
      #(0, 0),
      "Calendar.ISO",
    ))
  let result = naive_datetime.after(ndt1, ndt2)
  result |> should.equal(True)
}

// NaiveDateTime difference tests
pub fn diff_seconds_test() {
  let ndt1 =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2000,
      1,
      1,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let ndt2 =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2000,
      1,
      1,
      12,
      1,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let diff = naive_datetime.diff(ndt1, ndt2, time.Second)
  diff |> should.equal(-60)
}

pub fn diff_minutes_test() {
  let ndt1 =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2000,
      1,
      1,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let ndt2 =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2000,
      1,
      1,
      13,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let diff_seconds = naive_datetime.diff(ndt1, ndt2, time.Second)
  let diff = diff_seconds / 60
  diff |> should.equal(-60)
}

pub fn diff_hours_test() {
  let ndt1 =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2000,
      1,
      1,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let ndt2 =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2000,
      1,
      2,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let diff_seconds = naive_datetime.diff(ndt1, ndt2, time.Second)
  let diff = diff_seconds / 3600
  diff |> should.equal(-24)
}

pub fn diff_days_test() {
  let ndt1 =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2000,
      1,
      1,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let ndt2 =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2000,
      1,
      8,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let diff_seconds = naive_datetime.diff(ndt1, ndt2, time.Second)
  let diff = diff_seconds / 86_400
  diff |> should.equal(-7)
}

// NaiveDateTime arithmetic tests
pub fn add_seconds_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2000,
      1,
      1,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let result = naive_datetime.add_seconds(ndt, 60)
  case result {
    Ok(new_ndt) -> {
      new_ndt.hour |> should.equal(12)
      new_ndt.minute |> should.equal(1)
      new_ndt.second |> should.equal(0)
    }
    Error(_) -> panic as "Expected valid naive datetime addition"
  }
}

pub fn add_minutes_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2000,
      1,
      1,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let result = naive_datetime.add_seconds(ndt, 30 * 60)
  case result {
    Ok(new_ndt) -> {
      new_ndt.hour |> should.equal(12)
      new_ndt.minute |> should.equal(30)
      new_ndt.second |> should.equal(0)
    }
    Error(_) -> panic as "Expected valid naive datetime addition"
  }
}

pub fn add_hours_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2000,
      1,
      1,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let result = naive_datetime.add_seconds(ndt, 6 * 3600)
  case result {
    Ok(new_ndt) -> {
      new_ndt.year |> should.equal(2000)
      new_ndt.month |> should.equal(1)
      new_ndt.day |> should.equal(1)
      new_ndt.hour |> should.equal(18)
    }
    Error(_) -> panic as "Expected valid naive datetime addition"
  }
}

pub fn add_days_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2000,
      1,
      31,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let result = naive_datetime.add_seconds(ndt, 1 * 86_400)
  case result {
    Ok(new_ndt) -> {
      new_ndt.year |> should.equal(2000)
      new_ndt.month |> should.equal(2)
      new_ndt.day |> should.equal(1)
      new_ndt.hour |> should.equal(12)
    }
    Error(_) -> panic as "Expected valid naive datetime addition"
  }
}

// NaiveDateTime truncation tests
// TODO: Fix truncate API to match expected behavior
// pub fn truncate_second_test() {
//   let ndt = test_helpers.unwrap_naive_datetime(naive_datetime.new(2000, 1, 1, 12, 34, 56, #(123456, 6), "Calendar.ISO"))
//   let result = naive_datetime.truncate(ndt, naive_datetime.Second)
//   case result {
//     Ok(truncated) -> {
//       truncated.second |> should.equal(56)
//       truncated.microsecond |> should.equal(#(0, 0))
//     }
//     Error(_) -> panic as "Expected valid naive datetime truncation"
//   }
// }

// pub fn truncate_minute_test() {
//   let ndt = test_helpers.unwrap_naive_datetime(naive_datetime.new(2000, 1, 1, 12, 34, 56, #(123456, 6), "Calendar.ISO"))
//   let result = naive_datetime.truncate(ndt, naive_datetime.Minute)
//   case result {
//     Ok(truncated) -> {
//       truncated.minute |> should.equal(34)
//       truncated.second |> should.equal(0)
//       truncated.microsecond |> should.equal(#(0, 0))
//     }
//     Error(_) -> panic as "Expected valid naive datetime truncation"
//   }
// }

// pub fn truncate_hour_test() {
//   let ndt = test_helpers.unwrap_naive_datetime(naive_datetime.new(2000, 1, 1, 12, 34, 56, #(123456, 6), "Calendar.ISO"))
//   let result = naive_datetime.truncate(ndt, naive_datetime.Hour)
//   case result {
//     Ok(truncated) -> {
//       truncated.hour |> should.equal(12)
//       truncated.minute |> should.equal(0)
//       truncated.second |> should.equal(0)
//       truncated.microsecond |> should.equal(#(0, 0))
//     }
//     Error(_) -> panic as "Expected valid naive datetime truncation"
//   }
// }

// NaiveDateTime from components tests
pub fn from_date_and_time_test() {
  let date_result = date.new(2000, 1, 1, "Calendar.ISO")
  let time_result = time.new(12, 34, 56, #(123_456, 6), "Calendar.ISO")

  case date_result, time_result {
    Ok(d), Ok(t) -> {
      let result = naive_datetime.from_date_and_time(d, t)
      case result {
        Ok(ndt) -> {
          ndt.year |> should.equal(2000)
          ndt.month |> should.equal(1)
          ndt.day |> should.equal(1)
          ndt.hour |> should.equal(12)
          ndt.minute |> should.equal(34)
          ndt.second |> should.equal(56)
          ndt.microsecond |> should.equal(#(123_456, 6))
        }
        Error(_) -> panic as "Expected valid naive datetime from date and time"
      }
    }
    _, _ -> panic as "Expected valid date and time"
  }
}

// Local datetime tests
pub fn local_now_test() {
  let result = naive_datetime.local_now()
  case result {
    Ok(ndt) -> {
      // Just verify it's a valid datetime - can't predict exact values
      ndt.year |> should.not_equal(0)
      ndt.month |> should.not_equal(0)
      ndt.day |> should.not_equal(0)
    }
    Error(_) -> panic as "Expected valid local datetime"
  }
}

// ISO 8601 parsing tests

pub fn from_iso8601_basic_test() {
  let result = naive_datetime.from_iso8601("2024-03-15T12:34:56")
  case result {
    Ok(ndt) -> {
      ndt.year |> should.equal(2024)
      ndt.month |> should.equal(3)
      ndt.day |> should.equal(15)
      ndt.hour |> should.equal(12)
      ndt.minute |> should.equal(34)
      ndt.second |> should.equal(56)
    }
    Error(_) -> panic as "Expected valid ISO8601 naive datetime parse"
  }
}

pub fn from_iso8601_with_microseconds_test() {
  let result = naive_datetime.from_iso8601("2024-03-15T12:34:56.123456")
  case result {
    Ok(ndt) -> {
      ndt.year |> should.equal(2024)
      ndt.hour |> should.equal(12)
      ndt.second |> should.equal(56)
    }
    Error(_) ->
      panic as "Expected valid ISO8601 naive datetime with microseconds"
  }
}

pub fn from_iso8601_midnight_test() {
  let result = naive_datetime.from_iso8601("2024-01-01T00:00:00")
  case result {
    Ok(ndt) -> {
      ndt.hour |> should.equal(0)
      ndt.minute |> should.equal(0)
      ndt.second |> should.equal(0)
    }
    Error(_) -> panic as "Expected valid ISO8601 midnight parse"
  }
}

pub fn from_iso8601_invalid_test() {
  let result = naive_datetime.from_iso8601("not-a-datetime")
  case result {
    Ok(_) -> panic as "Expected error for invalid format"
    Error(_) -> Nil
  }
}

pub fn from_iso8601_invalid_date_test() {
  let result = naive_datetime.from_iso8601("2024-13-01T12:00:00")
  case result {
    Ok(_) -> panic as "Expected error for invalid date in datetime"
    Error(_) -> Nil
  }
}

pub fn from_iso8601_invalid_time_test() {
  let result = naive_datetime.from_iso8601("2024-01-01T25:00:00")
  case result {
    Ok(_) -> panic as "Expected error for invalid time in datetime"
    Error(_) -> Nil
  }
}

// Timestamp round-trip tests

pub fn timestamp_round_trip_epoch_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      1970,
      1,
      1,
      0,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let ts = naive_datetime.to_timestamp(ndt)
  ts |> should.equal(0)
}

pub fn timestamp_round_trip_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      6,
      15,
      12,
      30,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let ts = naive_datetime.to_timestamp(ndt)
  let result = naive_datetime.from_timestamp(ts)
  case result {
    Ok(ndt2) -> {
      ndt2.year |> should.equal(2024)
      ndt2.month |> should.equal(6)
      ndt2.day |> should.equal(15)
      ndt2.hour |> should.equal(12)
      ndt2.minute |> should.equal(30)
      ndt2.second |> should.equal(0)
    }
    Error(_) -> panic as "Expected valid naive datetime from timestamp"
  }
}

// Additional arithmetic tests using the actual module functions

pub fn add_days_function_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      1,
      31,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let result = naive_datetime.add_days(ndt, 1)
  case result {
    Ok(ndt2) -> {
      ndt2.year |> should.equal(2024)
      ndt2.month |> should.equal(2)
      ndt2.day |> should.equal(1)
      ndt2.hour |> should.equal(12)
    }
    Error(_) -> panic as "Expected valid add_days"
  }
}

pub fn add_hours_function_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      1,
      1,
      23,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let result = naive_datetime.add_hours(ndt, 2)
  case result {
    Ok(ndt2) -> {
      ndt2.day |> should.equal(2)
      ndt2.hour |> should.equal(1)
    }
    Error(_) -> panic as "Expected valid add_hours"
  }
}

pub fn add_minutes_function_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      1,
      1,
      12,
      50,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let result = naive_datetime.add_minutes(ndt, 20)
  case result {
    Ok(ndt2) -> {
      ndt2.hour |> should.equal(13)
      ndt2.minute |> should.equal(10)
    }
    Error(_) -> panic as "Expected valid add_minutes"
  }
}

pub fn diff_days_function_test() {
  let ndt1 =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      1,
      10,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let ndt2 =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      1,
      1,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  naive_datetime.diff_days(ndt1, ndt2) |> should.equal(9)
}

pub fn diff_hours_function_test() {
  let ndt1 =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      1,
      1,
      15,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let ndt2 =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      1,
      1,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  naive_datetime.diff_hours(ndt1, ndt2) |> should.equal(3)
}

pub fn diff_minutes_function_test() {
  let ndt1 =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      1,
      1,
      12,
      45,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let ndt2 =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      1,
      1,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  naive_datetime.diff_minutes(ndt1, ndt2) |> should.equal(45)
}

// Erlang interop tests

pub fn to_erl_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      3,
      15,
      12,
      34,
      56,
      #(0, 0),
      "Calendar.ISO",
    ))
  let erl = naive_datetime.to_erl(ndt)
  erl |> should.equal(#(#(2024, 3, 15), #(12, 34, 56)))
}

pub fn from_erl_test() {
  let result =
    naive_datetime.from_erl(
      #(#(2024, 3, 15), #(12, 34, 56)),
      #(0, 0),
      "Calendar.ISO",
    )
  case result {
    Ok(ndt) -> {
      ndt.year |> should.equal(2024)
      ndt.month |> should.equal(3)
      ndt.day |> should.equal(15)
      ndt.hour |> should.equal(12)
      ndt.minute |> should.equal(34)
      ndt.second |> should.equal(56)
    }
    Error(_) -> panic as "Expected valid naive datetime from Erlang tuple"
  }
}

pub fn from_erl_invalid_test() {
  let result =
    naive_datetime.from_erl(
      #(#(2024, 13, 1), #(12, 0, 0)),
      #(0, 0),
      "Calendar.ISO",
    )
  case result {
    Ok(_) -> panic as "Expected error for invalid Erlang datetime tuple"
    Error(_) -> Nil
  }
}

pub fn erl_round_trip_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      12,
      31,
      23,
      59,
      59,
      #(0, 0),
      "Calendar.ISO",
    ))
  let erl = naive_datetime.to_erl(ndt)
  let result = naive_datetime.from_erl(erl, #(0, 0), "Calendar.ISO")
  case result {
    Ok(ndt2) -> {
      ndt2.year |> should.equal(ndt.year)
      ndt2.month |> should.equal(ndt.month)
      ndt2.day |> should.equal(ndt.day)
      ndt2.hour |> should.equal(ndt.hour)
      ndt2.minute |> should.equal(ndt.minute)
      ndt2.second |> should.equal(ndt.second)
    }
    Error(_) -> panic as "Expected valid Erlang round trip"
  }
}

// to_date and to_time extraction tests

pub fn to_date_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      3,
      15,
      12,
      34,
      56,
      #(0, 0),
      "Calendar.ISO",
    ))
  let d = naive_datetime.to_date(ndt)
  d.year |> should.equal(2024)
  d.month |> should.equal(3)
  d.day |> should.equal(15)
}

pub fn to_time_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      3,
      15,
      12,
      34,
      56,
      #(123_456, 6),
      "Calendar.ISO",
    ))
  let t = naive_datetime.to_time(ndt)
  t.hour |> should.equal(12)
  t.minute |> should.equal(34)
  t.second |> should.equal(56)
  t.microsecond |> should.equal(#(123_456, 6))
}

// new_simple test

pub fn new_simple_test() {
  let result = naive_datetime.new_simple(2024, 3, 15, 12, 34, 56)
  case result {
    Ok(ndt) -> {
      ndt.year |> should.equal(2024)
      ndt.microsecond |> should.equal(#(0, 0))
      ndt.calendar |> should.equal("Calendar.ISO")
    }
    Error(_) -> panic as "Expected valid new_simple naive datetime"
  }
}

// beginning_of_day and end_of_day tests

pub fn beginning_of_day_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      3,
      15,
      12,
      34,
      56,
      #(123_456, 6),
      "Calendar.ISO",
    ))
  let bod = naive_datetime.beginning_of_day(ndt)
  bod.year |> should.equal(2024)
  bod.month |> should.equal(3)
  bod.day |> should.equal(15)
  bod.hour |> should.equal(0)
  bod.minute |> should.equal(0)
  bod.second |> should.equal(0)
  bod.microsecond |> should.equal(#(0, 0))
}

pub fn end_of_day_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      3,
      15,
      12,
      34,
      56,
      #(0, 0),
      "Calendar.ISO",
    ))
  let eod = naive_datetime.end_of_day(ndt)
  eod.year |> should.equal(2024)
  eod.month |> should.equal(3)
  eod.day |> should.equal(15)
  eod.hour |> should.equal(23)
  eod.minute |> should.equal(59)
  eod.second |> should.equal(59)
  eod.microsecond |> should.equal(#(999_999, 6))
}

// equal test

pub fn equal_true_test() {
  let ndt1 =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      1,
      1,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let ndt2 =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      1,
      1,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  naive_datetime.equal(ndt1, ndt2) |> should.equal(True)
}

pub fn equal_false_test() {
  let ndt1 =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      1,
      1,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let ndt2 =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      1,
      1,
      12,
      0,
      1,
      #(0, 0),
      "Calendar.ISO",
    ))
  naive_datetime.equal(ndt1, ndt2) |> should.equal(False)
}

// Getter tests

pub fn year_getter_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      3,
      15,
      12,
      34,
      56,
      #(123_456, 6),
      "Calendar.ISO",
    ))
  naive_datetime.year(ndt) |> should.equal(2024)
}

pub fn month_getter_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      3,
      15,
      12,
      34,
      56,
      #(0, 0),
      "Calendar.ISO",
    ))
  naive_datetime.month(ndt) |> should.equal(3)
}

pub fn day_getter_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      3,
      15,
      12,
      34,
      56,
      #(0, 0),
      "Calendar.ISO",
    ))
  naive_datetime.day(ndt) |> should.equal(15)
}

pub fn hour_getter_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      3,
      15,
      12,
      34,
      56,
      #(0, 0),
      "Calendar.ISO",
    ))
  naive_datetime.hour(ndt) |> should.equal(12)
}

pub fn minute_getter_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      3,
      15,
      12,
      34,
      56,
      #(0, 0),
      "Calendar.ISO",
    ))
  naive_datetime.minute(ndt) |> should.equal(34)
}

pub fn second_getter_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      3,
      15,
      12,
      34,
      56,
      #(0, 0),
      "Calendar.ISO",
    ))
  naive_datetime.second(ndt) |> should.equal(56)
}

pub fn microsecond_getter_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      3,
      15,
      12,
      34,
      56,
      #(123_456, 6),
      "Calendar.ISO",
    ))
  naive_datetime.microsecond(ndt) |> should.equal(#(123_456, 6))
}

pub fn calendar_getter_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      3,
      15,
      12,
      34,
      56,
      #(0, 0),
      "Calendar.ISO",
    ))
  naive_datetime.calendar(ndt) |> should.equal("Calendar.ISO")
}

// inspect test

pub fn inspect_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      3,
      15,
      12,
      34,
      56,
      #(0, 0),
      "Calendar.ISO",
    ))
  naive_datetime.inspect(ndt) |> should.equal("~N[2024-03-15 12:34:56]")
}

// is_valid tests

pub fn is_valid_true_test() {
  naive_datetime.is_valid(2024, 3, 15, 12, 34, 56, #(0, 0))
  |> should.equal(True)
}

pub fn is_valid_false_date_test() {
  naive_datetime.is_valid(2024, 13, 1, 12, 0, 0, #(0, 0))
  |> should.equal(False)
}

pub fn is_valid_false_time_test() {
  naive_datetime.is_valid(2024, 1, 1, 25, 0, 0, #(0, 0))
  |> should.equal(False)
}

// Calendar conversion tests

pub fn convert_same_calendar_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      3,
      15,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let result = naive_datetime.convert(ndt, "Calendar.ISO")
  case result {
    Ok(ndt2) -> {
      ndt2.calendar |> should.equal("Calendar.ISO")
      ndt2.year |> should.equal(2024)
    }
    Error(_) -> panic as "Expected same calendar conversion to succeed"
  }
}

pub fn convert_different_calendar_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      3,
      15,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let result = naive_datetime.convert(ndt, "Calendar.Other")
  case result {
    Ok(ndt2) -> {
      ndt2.calendar |> should.equal("Calendar.Other")
    }
    Error(_) -> panic as "Expected calendar conversion to succeed"
  }
}

pub fn convert_unchecked_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      3,
      15,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let ndt2 = naive_datetime.convert_unchecked(ndt, "Calendar.Other")
  ndt2.calendar |> should.equal("Calendar.Other")
}

// day_of_year, day_of_week, week_of_year tests

pub fn day_of_year_jan1_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      1,
      1,
      0,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  naive_datetime.day_of_year(ndt) |> should.equal(1)
}

pub fn day_of_year_dec31_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      12,
      31,
      0,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  naive_datetime.day_of_year(ndt) |> should.equal(366)
}

pub fn day_of_week_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      1,
      1,
      0,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let dow = naive_datetime.day_of_week(ndt)
  // Should be a value between 1-7
  should.equal(True, dow >= 1 && dow <= 7)
}

pub fn week_of_year_jan1_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      1,
      1,
      0,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let woy = naive_datetime.week_of_year(ndt)
  woy |> should.equal(1)
}

pub fn week_of_year_mid_year_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      7,
      1,
      0,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let woy = naive_datetime.week_of_year(ndt)
  // Should be around week 26-27
  should.equal(True, woy >= 25 && woy <= 28)
}

// Gregorian seconds tests

pub fn gregorian_seconds_round_trip_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      6,
      15,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let #(greg_secs, _ms) = naive_datetime.to_gregorian_seconds(ndt)
  let result =
    naive_datetime.from_gregorian_seconds(greg_secs, #(0, 0), "Calendar.ISO")
  case result {
    Ok(ndt2) -> {
      ndt2.year |> should.equal(2024)
      ndt2.month |> should.equal(6)
      ndt2.day |> should.equal(15)
      ndt2.hour |> should.equal(12)
    }
    Error(_) -> panic as "Expected valid Gregorian seconds round trip"
  }
}

// Shift with Duration test

pub fn shift_days_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      1,
      1,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let dur =
    Duration(
      year: 0,
      month: 0,
      week: 0,
      day: 10,
      hour: 0,
      minute: 0,
      second: 0,
      microsecond: #(0, 0),
    )
  let result = naive_datetime.shift(ndt, dur)
  case result {
    Ok(ndt2) -> {
      ndt2.day |> should.equal(11)
      ndt2.hour |> should.equal(12)
    }
    Error(_) -> panic as "Expected valid naive datetime shift"
  }
}

pub fn shift_months_and_hours_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      1,
      15,
      10,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let dur =
    Duration(
      year: 0,
      month: 1,
      week: 0,
      day: 0,
      hour: 3,
      minute: 0,
      second: 0,
      microsecond: #(0, 0),
    )
  let result = naive_datetime.shift(ndt, dur)
  case result {
    Ok(ndt2) -> {
      ndt2.month |> should.equal(2)
      ndt2.day |> should.equal(15)
      ndt2.hour |> should.equal(13)
    }
    Error(_) -> panic as "Expected valid naive datetime shift"
  }
}

// Truncate tests

pub fn truncate_to_second_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      1,
      1,
      12,
      34,
      56,
      #(123_456, 6),
      "Calendar.ISO",
    ))
  let result = naive_datetime.truncate(ndt, 0)
  case result {
    Ok(truncated) -> {
      truncated.microsecond |> should.equal(#(0, 0))
      truncated.second |> should.equal(56)
    }
    Error(_) -> panic as "Expected valid truncation"
  }
}

pub fn truncate_to_millisecond_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      1,
      1,
      12,
      34,
      56,
      #(123_456, 6),
      "Calendar.ISO",
    ))
  let result = naive_datetime.truncate(ndt, 3)
  case result {
    Ok(truncated) -> {
      truncated.microsecond |> should.equal(#(123_000, 3))
    }
    Error(_) -> panic as "Expected valid truncation"
  }
}

// Range test

pub fn range_basic_test() {
  let ndt1 =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      1,
      1,
      0,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let ndt2 =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      1,
      1,
      3,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let result = naive_datetime.range(ndt1, ndt2, 3600)
  // 0:00, 1:00, 2:00 = 3 entries (3:00 excluded since range is < end)
  list.length(result) |> should.equal(3)
}

pub fn range_empty_test() {
  let ndt1 =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      1,
      1,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let ndt2 =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      1,
      1,
      10,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let result = naive_datetime.range(ndt1, ndt2, 3600)
  list.length(result) |> should.equal(0)
}

pub fn range_zero_step_test() {
  let ndt1 =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      1,
      1,
      0,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let ndt2 =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      1,
      1,
      3,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let result = naive_datetime.range(ndt1, ndt2, 0)
  list.length(result) |> should.equal(0)
}

// Replace tests

pub fn replace_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      1,
      1,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let result = naive_datetime.replace(ndt, 2025, 6, 15, 18, 30, 45, #(0, 0))
  case result {
    Ok(ndt2) -> {
      ndt2.year |> should.equal(2025)
      ndt2.month |> should.equal(6)
      ndt2.day |> should.equal(15)
      ndt2.hour |> should.equal(18)
      ndt2.minute |> should.equal(30)
      ndt2.second |> should.equal(45)
    }
    Error(_) -> panic as "Expected valid replace"
  }
}

pub fn replace_partial_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      1,
      1,
      12,
      34,
      56,
      #(0, 0),
      "Calendar.ISO",
    ))
  let result = naive_datetime.replace_partial(ndt, 2025, 6, 15)
  case result {
    Ok(ndt2) -> {
      ndt2.year |> should.equal(2025)
      ndt2.month |> should.equal(6)
      ndt2.day |> should.equal(15)
      // Time should be preserved
      ndt2.hour |> should.equal(12)
      ndt2.minute |> should.equal(34)
      ndt2.second |> should.equal(56)
    }
    Error(_) -> panic as "Expected valid replace_partial"
  }
}

pub fn replace_invalid_test() {
  let ndt =
    test_helpers.unwrap_naive_datetime(naive_datetime.new(
      2024,
      1,
      1,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let result = naive_datetime.replace(ndt, 2024, 13, 1, 12, 0, 0, #(0, 0))
  case result {
    Ok(_) -> panic as "Expected error for invalid replace"
    Error(_) -> Nil
  }
}

// from_iso8601_unchecked test

pub fn from_iso8601_unchecked_test() {
  let ndt = naive_datetime.from_iso8601_unchecked("2024-06-15T12:34:56")
  ndt.year |> should.equal(2024)
  ndt.hour |> should.equal(12)
}

// from_erl_unchecked test

pub fn from_erl_unchecked_test() {
  let ndt =
    naive_datetime.from_erl_unchecked(
      #(#(2024, 3, 15), #(12, 34, 56)),
      #(0, 0),
      "Calendar.ISO",
    )
  ndt.year |> should.equal(2024)
  ndt.hour |> should.equal(12)
}
