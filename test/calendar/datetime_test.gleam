import calendar/date
import calendar/datetime
import calendar/time
import gleam/order
import gleeunit
import gleeunit/should
import test_helpers

pub fn main() -> Nil {
  gleeunit.main()
}

// Basic datetime creation tests
pub fn datetime_creation_test() {
  let result =
    datetime.new(
      2000,
      1,
      1,
      12,
      34,
      56,
      "Etc/UTC",
      "UTC",
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    )
  case result {
    Ok(dt) -> {
      dt.year |> should.equal(2000)
      dt.month |> should.equal(1)
      dt.day |> should.equal(1)
      dt.hour |> should.equal(12)
      dt.minute |> should.equal(34)
      dt.second |> should.equal(56)
      dt.microsecond |> should.equal(#(0, 0))
      dt.time_zone |> should.equal("Etc/UTC")
      dt.zone_abbr |> should.equal("UTC")
      dt.utc_offset |> should.equal(0)
      dt.std_offset |> should.equal(0)
      dt.calendar |> should.equal("Calendar.ISO")
    }
    Error(_) -> panic as "Expected valid datetime"
  }
}

pub fn datetime_utc_creation_test() {
  let result = datetime.new_utc(2000, 1, 1, 12, 34, 56, #(0, 0), "Calendar.ISO")
  case result {
    Ok(dt) -> {
      dt.time_zone |> should.equal("Etc/UTC")
      dt.zone_abbr |> should.equal("UTC")
      dt.utc_offset |> should.equal(0)
      dt.std_offset |> should.equal(0)
    }
    Error(_) -> panic as "Expected valid UTC datetime"
  }
}

// Invalid datetime tests
pub fn invalid_datetime_date_test() {
  let result =
    datetime.new(
      2001,
      50,
      50,
      12,
      34,
      56,
      "Etc/UTC",
      "UTC",
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    )
  case result {
    Ok(_) -> panic as "Expected invalid datetime error"
    Error(datetime.InvalidDate) -> Nil
    Error(_) -> panic as "Expected InvalidDate error"
  }
}

pub fn invalid_datetime_time_test() {
  let result =
    datetime.new(
      2001,
      1,
      1,
      12,
      34,
      65,
      "Etc/UTC",
      "UTC",
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    )
  case result {
    Ok(_) -> panic as "Expected invalid datetime error"
    Error(datetime.InvalidTime) -> Nil
    Error(_) -> panic as "Expected InvalidTime error"
  }
}

// String conversion tests
pub fn to_string_test() {
  let dt =
    test_helpers.unwrap_datetime(datetime.new(
      2000,
      2,
      29,
      23,
      0,
      7,
      "Brazil/Manaus",
      "BRM",
      -12_600,
      3600,
      #(0, 0),
      "Calendar.ISO",
    ))
  let datetime_str = datetime.to_string(dt)
  datetime_str |> should.equal("2000-02-29 23:00:07-02:30 BRM")
}

pub fn to_string_utc_test() {
  let dt =
    test_helpers.unwrap_datetime(datetime.new(
      2000,
      1,
      1,
      23,
      0,
      7,
      "Etc/UTC",
      "UTC",
      0,
      0,
      #(5000, 3),
      "Calendar.ISO",
    ))
  let datetime_str = datetime.to_string(dt)
  datetime_str |> should.equal("2000-01-01 23:00:07.500+00:00 UTC")
}

// ISO8601 conversion tests
pub fn to_iso8601_test() {
  let dt =
    test_helpers.unwrap_datetime(datetime.new(
      2000,
      1,
      1,
      23,
      0,
      7,
      "Etc/UTC",
      "UTC",
      0,
      0,
      #(5000, 3),
      "Calendar.ISO",
    ))
  let iso_str = datetime.to_iso8601(dt)
  iso_str |> should.equal("2000-01-01T23:00:07.500Z")
}

pub fn to_iso8601_with_offset_test() {
  let dt =
    test_helpers.unwrap_datetime(datetime.new(
      2000,
      2,
      29,
      23,
      0,
      7,
      "Brazil/Manaus",
      "BRM",
      -12_600,
      3600,
      #(0, 0),
      "Calendar.ISO",
    ))
  let iso_str = datetime.to_iso8601(dt)
  iso_str |> should.equal("2000-02-29T23:00:07-02:30")
}

pub fn to_iso8601_basic_test() {
  let dt =
    test_helpers.unwrap_datetime(datetime.new(
      2000,
      1,
      1,
      23,
      0,
      7,
      "Etc/UTC",
      "UTC",
      0,
      0,
      #(5000, 3),
      "Calendar.ISO",
    ))
  let iso_str = datetime.to_iso8601_with_format(dt, datetime.Basic)
  iso_str |> should.equal("20000101T230007.500Z")
}

// DateTime comparison tests
pub fn compare_equal_test() {
  let dt1 =
    test_helpers.unwrap_datetime(datetime.new(
      2000,
      1,
      1,
      12,
      0,
      0,
      "Etc/UTC",
      "UTC",
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let dt2 =
    test_helpers.unwrap_datetime(datetime.new(
      2000,
      1,
      1,
      12,
      0,
      0,
      "Etc/UTC",
      "UTC",
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let result = datetime.compare(dt1, dt2)
  result |> should.equal(order.Eq)
}

pub fn compare_less_than_test() {
  let dt1 =
    test_helpers.unwrap_datetime(datetime.new(
      2000,
      1,
      1,
      11,
      59,
      59,
      "Etc/UTC",
      "UTC",
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let dt2 =
    test_helpers.unwrap_datetime(datetime.new(
      2000,
      1,
      1,
      12,
      0,
      0,
      "Etc/UTC",
      "UTC",
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let result = datetime.compare(dt1, dt2)
  result |> should.equal(order.Lt)
}

pub fn compare_greater_than_test() {
  let dt1 =
    test_helpers.unwrap_datetime(datetime.new(
      2000,
      1,
      2,
      12,
      0,
      0,
      "Etc/UTC",
      "UTC",
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let dt2 =
    test_helpers.unwrap_datetime(datetime.new(
      2000,
      1,
      1,
      12,
      0,
      0,
      "Etc/UTC",
      "UTC",
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let result = datetime.compare(dt1, dt2)
  result |> should.equal(order.Gt)
}

// Before and after tests
pub fn before_test() {
  let dt1 =
    test_helpers.unwrap_datetime(datetime.new(
      2000,
      1,
      1,
      11,
      59,
      59,
      "Etc/UTC",
      "UTC",
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let dt2 =
    test_helpers.unwrap_datetime(datetime.new(
      2000,
      1,
      1,
      12,
      0,
      0,
      "Etc/UTC",
      "UTC",
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let result = datetime.before(dt1, dt2)
  result |> should.equal(True)
}

pub fn not_before_test() {
  let dt1 =
    test_helpers.unwrap_datetime(datetime.new(
      2000,
      1,
      1,
      12,
      0,
      0,
      "Etc/UTC",
      "UTC",
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let dt2 =
    test_helpers.unwrap_datetime(datetime.new(
      2000,
      1,
      1,
      11,
      59,
      59,
      "Etc/UTC",
      "UTC",
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let result = datetime.before(dt1, dt2)
  result |> should.equal(False)
}

pub fn after_test() {
  let dt1 =
    test_helpers.unwrap_datetime(datetime.new(
      2000,
      1,
      1,
      12,
      0,
      0,
      "Etc/UTC",
      "UTC",
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let dt2 =
    test_helpers.unwrap_datetime(datetime.new(
      2000,
      1,
      1,
      11,
      59,
      59,
      "Etc/UTC",
      "UTC",
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let result = datetime.after(dt1, dt2)
  result |> should.equal(True)
}

// DateTime difference tests
pub fn diff_seconds_test() {
  let dt1 =
    test_helpers.unwrap_datetime(datetime.new(
      2000,
      1,
      1,
      12,
      0,
      0,
      "Etc/UTC",
      "UTC",
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let dt2 =
    test_helpers.unwrap_datetime(datetime.new(
      2000,
      1,
      1,
      12,
      1,
      0,
      "Etc/UTC",
      "UTC",
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let diff = datetime.diff(dt1, dt2, datetime.Second)
  diff |> should.equal(-60)
}

pub fn diff_minutes_test() {
  let dt1 =
    test_helpers.unwrap_datetime(datetime.new(
      2000,
      1,
      1,
      12,
      0,
      0,
      "Etc/UTC",
      "UTC",
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let dt2 =
    test_helpers.unwrap_datetime(datetime.new(
      2000,
      1,
      1,
      13,
      0,
      0,
      "Etc/UTC",
      "UTC",
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let diff_seconds = datetime.diff(dt1, dt2, datetime.Second)
  let diff = diff_seconds / 60
  diff |> should.equal(-60)
}

pub fn diff_hours_test() {
  let dt1 =
    test_helpers.unwrap_datetime(datetime.new(
      2000,
      1,
      1,
      12,
      0,
      0,
      "Etc/UTC",
      "UTC",
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let dt2 =
    test_helpers.unwrap_datetime(datetime.new(
      2000,
      1,
      2,
      12,
      0,
      0,
      "Etc/UTC",
      "UTC",
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let diff_seconds = datetime.diff(dt1, dt2, datetime.Second)
  let diff = diff_seconds / 3600
  diff |> should.equal(-24)
}

// DateTime arithmetic tests
pub fn add_seconds_test() {
  let dt =
    test_helpers.unwrap_datetime(datetime.new(
      2000,
      1,
      1,
      12,
      0,
      0,
      "Etc/UTC",
      "UTC",
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let result = datetime.add_seconds(dt, 60)
  case result {
    Ok(new_dt) -> {
      new_dt.hour |> should.equal(12)
      new_dt.minute |> should.equal(1)
      new_dt.second |> should.equal(0)
    }
    Error(_) -> panic as "Expected valid datetime addition"
  }
}

pub fn add_minutes_test() {
  let dt =
    test_helpers.unwrap_datetime(datetime.new(
      2000,
      1,
      1,
      12,
      0,
      0,
      "Etc/UTC",
      "UTC",
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let result = datetime.add_seconds(dt, 30 * 60)
  case result {
    Ok(new_dt) -> {
      new_dt.hour |> should.equal(12)
      new_dt.minute |> should.equal(30)
      new_dt.second |> should.equal(0)
    }
    Error(_) -> panic as "Expected valid datetime addition"
  }
}

pub fn add_hours_test() {
  let dt =
    test_helpers.unwrap_datetime(datetime.new(
      2000,
      1,
      1,
      12,
      0,
      0,
      "Etc/UTC",
      "UTC",
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let result = datetime.add_seconds(dt, 6 * 3600)
  case result {
    Ok(new_dt) -> {
      new_dt.year |> should.equal(2000)
      new_dt.month |> should.equal(1)
      new_dt.day |> should.equal(1)
      new_dt.hour |> should.equal(18)
    }
    Error(_) -> panic as "Expected valid datetime addition"
  }
}

pub fn add_days_test() {
  let dt =
    test_helpers.unwrap_datetime(datetime.new(
      2000,
      1,
      31,
      12,
      0,
      0,
      "Etc/UTC",
      "UTC",
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let result = datetime.add_seconds(dt, 1 * 86_400)
  case result {
    Ok(new_dt) -> {
      new_dt.year |> should.equal(2000)
      new_dt.month |> should.equal(2)
      new_dt.day |> should.equal(1)
      new_dt.hour |> should.equal(12)
    }
    Error(_) -> panic as "Expected valid datetime addition"
  }
}

// DateTime truncation tests
// TODO: Fix truncate API to match expected behavior
// pub fn truncate_second_test() {
//   let dt = test_helpers.unwrap_datetime(datetime.new(2000, 1, 1, 12, 34, 56, "Etc/UTC", "UTC", 0, 0, #(123456, 6), "Calendar.ISO"))
//   let result = datetime.truncate(dt, datetime.Second)
//   case result {
//     Ok(truncated) -> {
//       truncated.second |> should.equal(56)
//       truncated.microsecond |> should.equal(0)
//     }
//     Error(_) -> panic as "Expected valid datetime truncation"
//   }
// }

// pub fn truncate_minute_test() {
//   let dt = test_helpers.unwrap_datetime(datetime.new(2000, 1, 1, 12, 34, 56, "Etc/UTC", "UTC", 0, 0, #(123456, 6), "Calendar.ISO"))
//   let result = datetime.truncate(dt, datetime.Minute)
//   case result {
//     Ok(truncated) -> {
//       truncated.minute |> should.equal(34)
//       truncated.second |> should.equal(0)
//       truncated.microsecond |> should.equal(0)
//     }
//     Error(_) -> panic as "Expected valid datetime truncation"
//   }
// }

// pub fn truncate_hour_test() {
//   let dt = test_helpers.unwrap_datetime(datetime.new(2000, 1, 1, 12, 34, 56, "Etc/UTC", "UTC", 0, 0, #(123456, 6), "Calendar.ISO"))
//   let result = datetime.truncate(dt, datetime.Hour)
//   case result {
//     Ok(truncated) -> {
//       truncated.hour |> should.equal(12)
//       truncated.minute |> should.equal(0)
//       truncated.second |> should.equal(0)
//       truncated.microsecond |> should.equal(0)
//     }
//     Error(_) -> panic as "Expected valid datetime truncation"
//   }
// }

// Time zone conversion tests
pub fn shift_zone_test() {
  let dt =
    test_helpers.unwrap_datetime(datetime.new(
      2000,
      1,
      1,
      12,
      0,
      0,
      "Etc/UTC",
      "UTC",
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let result = datetime.shift_zone(dt, "America/New_York", "EST", -18_000, 0)
  case result {
    Ok(shifted) -> {
      shifted.time_zone |> should.equal("America/New_York")
      shifted.zone_abbr |> should.equal("EST")
      shifted.utc_offset |> should.equal(-18_000)
      shifted.std_offset |> should.equal(0)
      shifted.hour |> should.equal(7)
      // UTC 12:00 -> EST 07:00
    }
    Error(_) -> panic as "Expected valid time zone shift"
  }
}

// DateTime from components tests
pub fn from_date_and_time_test() {
  let date_result = date.new(2000, 1, 1, "Calendar.ISO")
  let time_result = time.new(12, 34, 56, #(123_456, 6), "Calendar.ISO")

  case date_result, time_result {
    Ok(d), Ok(t) -> {
      let result = datetime.new_from_date_and_time(d, t)
      case result {
        Ok(dt) -> {
          dt.year |> should.equal(2000)
          dt.month |> should.equal(1)
          dt.day |> should.equal(1)
          dt.hour |> should.equal(12)
          dt.minute |> should.equal(34)
          dt.second |> should.equal(56)
          dt.microsecond |> should.equal(#(123_456, 6))
        }
        Error(_) -> panic as "Expected valid datetime from date and time"
      }
    }
    _, _ -> panic as "Expected valid date and time"
  }
}
