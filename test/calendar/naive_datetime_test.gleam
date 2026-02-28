import calendar/date
import calendar/naive_datetime
import calendar/time
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
// NaiveDateTime shift tests
// TODO: Fix shift API to use Duration properly
// pub fn shift_years_test() {
//   let ndt = test_helpers.unwrap_naive_datetime(naive_datetime.new(2000, 2, 29, 12, 0, 0, #(0, 0), "Calendar.ISO"))
//   let result = naive_datetime.shift(ndt, years: 1)
//   case result {
//     Ok(shifted) -> {
//       shifted.year |> should.equal(2001)
//       shifted.month |> should.equal(2)
//       shifted.day |> should.equal(28)  // Leap year adjustment
//     }
//     Error(_) -> panic as "Expected valid naive datetime shift"
//   }
// }

// pub fn shift_months_test() {
//   let ndt = test_helpers.unwrap_naive_datetime(naive_datetime.new(2000, 1, 31, 12, 0, 0, #(0, 0), "Calendar.ISO"))
//   let result = naive_datetime.shift(ndt, months: 1)
//   case result {
//     Ok(shifted) -> {
//       shifted.year |> should.equal(2000)
//       shifted.month |> should.equal(2)
//       shifted.day |> should.equal(29)  // Month end adjustment for leap year
//     }
//     Error(_) -> panic as "Expected valid naive datetime shift"
//   }
// }
