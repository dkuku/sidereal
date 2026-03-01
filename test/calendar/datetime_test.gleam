import calendar/date
import calendar/datetime
import calendar/duration.{Duration}
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

// ISO 8601 parsing tests

pub fn from_iso8601_utc_test() {
  let result = datetime.from_iso8601("2024-03-15T12:34:56Z")
  case result {
    Ok(dt) -> {
      dt.year |> should.equal(2024)
      dt.month |> should.equal(3)
      dt.day |> should.equal(15)
      dt.hour |> should.equal(12)
      dt.minute |> should.equal(34)
      dt.second |> should.equal(56)
      dt.time_zone |> should.equal("Etc/UTC")
    }
    Error(_) -> panic as "Expected valid ISO8601 UTC datetime parse"
  }
}

pub fn from_iso8601_with_positive_offset_test() {
  let result = datetime.from_iso8601("2024-03-15T12:34:56+05:30")
  case result {
    Ok(dt) -> {
      dt.year |> should.equal(2024)
      dt.hour |> should.equal(12)
      dt.utc_offset |> should.equal(19_800)
    }
    Error(_) -> panic as "Expected valid ISO8601 datetime with positive offset"
  }
}

pub fn from_iso8601_with_negative_offset_test() {
  let result = datetime.from_iso8601("2024-03-15T12:34:56-05:00")
  case result {
    Ok(dt) -> {
      dt.year |> should.equal(2024)
      dt.hour |> should.equal(12)
      dt.utc_offset |> should.equal(-18_000)
    }
    Error(_) -> panic as "Expected valid ISO8601 datetime with negative offset"
  }
}

pub fn from_iso8601_invalid_test() {
  let result = datetime.from_iso8601("not-a-datetime")
  case result {
    Ok(_) -> panic as "Expected error for invalid datetime string"
    Error(_) -> Nil
  }
}

pub fn from_iso8601_with_microseconds_test() {
  let result = datetime.from_iso8601("2024-03-15T12:34:56.123456Z")
  case result {
    Ok(dt) -> {
      dt.year |> should.equal(2024)
      dt.second |> should.equal(56)
    }
    Error(_) -> panic as "Expected valid ISO8601 datetime with microseconds"
  }
}

// Timestamp round-trip tests

pub fn utc_timestamp_round_trip_test() {
  let dt =
    test_helpers.unwrap_datetime(datetime.new_utc(
      2024,
      6,
      15,
      12,
      30,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let ts = datetime.to_utc_timestamp(dt)
  let result = datetime.from_utc_timestamp(ts, "Etc/UTC")
  case result {
    Ok(dt2) -> {
      dt2.year |> should.equal(2024)
      dt2.month |> should.equal(6)
      dt2.day |> should.equal(15)
      dt2.hour |> should.equal(12)
      dt2.minute |> should.equal(30)
    }
    Error(_) -> panic as "Expected valid datetime from UTC timestamp"
  }
}

pub fn utc_timestamp_epoch_test() {
  let dt =
    test_helpers.unwrap_datetime(datetime.new_utc(
      1970,
      1,
      1,
      0,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let ts = datetime.to_utc_timestamp(dt)
  ts |> should.equal(0)
}

pub fn from_unix_seconds_test() {
  let result = datetime.from_unix(0, datetime.Second, "Calendar.ISO")
  case result {
    Ok(dt) -> {
      dt.year |> should.equal(1970)
      dt.month |> should.equal(1)
      dt.day |> should.equal(1)
      dt.hour |> should.equal(0)
    }
    Error(_) -> panic as "Expected valid datetime from unix 0"
  }
}

pub fn to_unix_seconds_test() {
  let dt =
    test_helpers.unwrap_datetime(datetime.new_utc(
      1970,
      1,
      1,
      0,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  datetime.to_unix(dt, datetime.Second) |> should.equal(0)
}

pub fn from_utc_timestamp_non_utc_test() {
  let result = datetime.from_utc_timestamp(0, "America/New_York")
  case result {
    Ok(_) -> panic as "Expected UtcOnlyTimeZoneDatabase error"
    Error(datetime.UtcOnlyTimeZoneDatabase) -> Nil
    Error(_) -> panic as "Expected UtcOnlyTimeZoneDatabase error"
  }
}

// Erlang interop tests

pub fn to_erl_test() {
  let dt =
    test_helpers.unwrap_datetime(datetime.new_utc(
      2024,
      3,
      15,
      12,
      34,
      56,
      #(0, 0),
      "Calendar.ISO",
    ))
  let erl = datetime.to_erl(dt)
  erl |> should.equal(#(#(2024, 3, 15), #(12, 34, 56)))
}

pub fn from_erl_test() {
  let result =
    datetime.from_erl(#(#(2024, 3, 15), #(12, 34, 56)), "Etc/UTC", "UTC", 0, 0)
  case result {
    Ok(dt) -> {
      dt.year |> should.equal(2024)
      dt.month |> should.equal(3)
      dt.day |> should.equal(15)
      dt.hour |> should.equal(12)
      dt.minute |> should.equal(34)
      dt.second |> should.equal(56)
      dt.time_zone |> should.equal("Etc/UTC")
    }
    Error(_) -> panic as "Expected valid datetime from Erlang tuple"
  }
}

pub fn from_erl_invalid_test() {
  let result =
    datetime.from_erl(#(#(2024, 13, 1), #(12, 0, 0)), "Etc/UTC", "UTC", 0, 0)
  case result {
    Ok(_) -> panic as "Expected error for invalid Erlang datetime tuple"
    Error(_) -> Nil
  }
}

// new_utc_simple test

pub fn new_utc_simple_test() {
  let result = datetime.new_utc_simple(2024, 3, 15, 12, 34, 56)
  case result {
    Ok(dt) -> {
      dt.year |> should.equal(2024)
      dt.microsecond |> should.equal(#(0, 0))
      dt.calendar |> should.equal("Calendar.ISO")
      dt.time_zone |> should.equal("Etc/UTC")
    }
    Error(_) -> panic as "Expected valid new_utc_simple datetime"
  }
}

// to_naive_datetime, to_date, to_time extraction tests

pub fn to_naive_datetime_test() {
  let dt =
    test_helpers.unwrap_datetime(datetime.new_utc(
      2024,
      3,
      15,
      12,
      34,
      56,
      #(0, 0),
      "Calendar.ISO",
    ))
  let ndt = datetime.to_naive_datetime(dt)
  ndt.year |> should.equal(2024)
  ndt.month |> should.equal(3)
  ndt.day |> should.equal(15)
  ndt.hour |> should.equal(12)
}

pub fn to_date_extraction_test() {
  let dt =
    test_helpers.unwrap_datetime(datetime.new_utc(
      2024,
      3,
      15,
      12,
      34,
      56,
      #(0, 0),
      "Calendar.ISO",
    ))
  let d = datetime.to_date(dt)
  d.year |> should.equal(2024)
  d.month |> should.equal(3)
  d.day |> should.equal(15)
}

pub fn to_time_extraction_test() {
  let dt =
    test_helpers.unwrap_datetime(datetime.new_utc(
      2024,
      3,
      15,
      12,
      34,
      56,
      #(123_456, 6),
      "Calendar.ISO",
    ))
  let t = datetime.to_time(dt)
  t.hour |> should.equal(12)
  t.minute |> should.equal(34)
  t.second |> should.equal(56)
  t.microsecond |> should.equal(#(123_456, 6))
}

// from_naive_utc test

pub fn from_naive_utc_test() {
  let assert Ok(ndt) =
    naive_datetime.new(2024, 3, 15, 12, 0, 0, #(0, 0), "Calendar.ISO")
  let dt = datetime.from_naive_utc(ndt)
  dt.year |> should.equal(2024)
  dt.time_zone |> should.equal("Etc/UTC")
  dt.zone_abbr |> should.equal("UTC")
  dt.utc_offset |> should.equal(0)
}

// add with units test

pub fn add_with_unit_test() {
  let dt =
    test_helpers.unwrap_datetime(datetime.new_utc(
      2024,
      1,
      1,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let result = datetime.add(dt, 3600, datetime.Second)
  case result {
    Ok(dt2) -> {
      dt2.hour |> should.equal(13)
    }
    Error(_) -> panic as "Expected valid datetime add"
  }
}

// Truncate tests

pub fn truncate_to_second_test() {
  let dt =
    test_helpers.unwrap_datetime(datetime.new_utc(
      2024,
      1,
      1,
      12,
      34,
      56,
      #(123_456, 6),
      "Calendar.ISO",
    ))
  let truncated = datetime.truncate(dt, 0)
  truncated.microsecond |> should.equal(#(0, 0))
  truncated.second |> should.equal(56)
}

pub fn truncate_to_millisecond_test() {
  let dt =
    test_helpers.unwrap_datetime(datetime.new_utc(
      2024,
      1,
      1,
      12,
      34,
      56,
      #(123_456, 6),
      "Calendar.ISO",
    ))
  let truncated = datetime.truncate(dt, 3)
  truncated.microsecond |> should.equal(#(123_000, 3))
}

// Compare with different timezones test

pub fn compare_different_tz_same_utc_test() {
  let dt1 =
    test_helpers.unwrap_datetime(datetime.new(
      2024,
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
  // Same UTC time but expressed in UTC+5
  let dt2 =
    test_helpers.unwrap_datetime(datetime.new(
      2024,
      1,
      1,
      17,
      0,
      0,
      "Asia/Karachi",
      "PKT",
      18_000,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let result = datetime.compare(dt1, dt2)
  result |> should.equal(order.Eq)
}

// Calendar conversion tests

pub fn convert_same_calendar_test() {
  let dt =
    test_helpers.unwrap_datetime(datetime.new_utc(
      2024,
      3,
      15,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let result = datetime.convert(dt, "Calendar.ISO")
  case result {
    Ok(dt2) -> {
      dt2.calendar |> should.equal("Calendar.ISO")
      dt2.year |> should.equal(2024)
    }
    Error(_) -> panic as "Expected same calendar conversion to succeed"
  }
}

pub fn convert_different_calendar_test() {
  let dt =
    test_helpers.unwrap_datetime(datetime.new_utc(
      2024,
      3,
      15,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let result = datetime.convert(dt, "Calendar.Other")
  case result {
    Ok(dt2) -> {
      dt2.calendar |> should.equal("Calendar.Other")
      dt2.time_zone |> should.equal("Etc/UTC")
    }
    Error(_) -> panic as "Expected calendar conversion to succeed"
  }
}

// from_naive_with_timezone test

pub fn from_naive_with_timezone_test() {
  let assert Ok(ndt) =
    naive_datetime.new(2024, 3, 15, 12, 0, 0, #(0, 0), "Calendar.ISO")
  let result =
    datetime.from_naive_with_timezone(
      ndt,
      "America/New_York",
      "EST",
      -18_000,
      0,
    )
  case result {
    Ok(dt) -> {
      dt.year |> should.equal(2024)
      dt.time_zone |> should.equal("America/New_York")
      dt.zone_abbr |> should.equal("EST")
      dt.utc_offset |> should.equal(-18_000)
    }
    Error(_) -> panic as "Expected valid datetime from naive with timezone"
  }
}

// from_naive_datetime test

pub fn from_naive_datetime_test() {
  let assert Ok(ndt) =
    naive_datetime.new(2024, 3, 15, 12, 0, 0, #(0, 0), "Calendar.ISO")
  let dt = datetime.from_naive_datetime(ndt, "Europe/London", "GMT", 0, 0)
  dt.year |> should.equal(2024)
  dt.time_zone |> should.equal("Europe/London")
  dt.zone_abbr |> should.equal("GMT")
}

// new_from_date_and_time_with_tz test

pub fn new_from_date_and_time_with_tz_test() {
  let assert Ok(d) = date.new(2024, 3, 15, "Calendar.ISO")
  let assert Ok(t) = time.new(12, 0, 0, #(0, 0), "Calendar.ISO")
  let result =
    datetime.new_from_date_and_time_with_tz(
      d,
      t,
      "Europe/Berlin",
      "CET",
      3600,
      0,
    )
  case result {
    Ok(dt) -> {
      dt.year |> should.equal(2024)
      dt.hour |> should.equal(12)
      dt.time_zone |> should.equal("Europe/Berlin")
      dt.utc_offset |> should.equal(3600)
    }
    Error(_) -> panic as "Expected valid datetime from date and time with tz"
  }
}

pub fn new_from_date_and_time_with_tz_incompatible_test() {
  let assert Ok(d) = date.new(2024, 3, 15, "Calendar.ISO")
  let assert Ok(t) = time.new(12, 0, 0, #(0, 0), "Calendar.Other")
  let result =
    datetime.new_from_date_and_time_with_tz(d, t, "Etc/UTC", "UTC", 0, 0)
  case result {
    Ok(_) -> panic as "Expected error for incompatible calendars"
    Error(_) -> Nil
  }
}

// shift_zone additional test

pub fn shift_zone_same_zone_test() {
  let dt =
    test_helpers.unwrap_datetime(datetime.new(
      2024,
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
  let result = datetime.shift_zone(dt, "Etc/UTC", "UTC", 0, 0)
  case result {
    Ok(dt2) -> {
      dt2.hour |> should.equal(12)
      dt2.time_zone |> should.equal("Etc/UTC")
    }
    Error(_) -> panic as "Expected same zone shift to succeed"
  }
}

// Shift with Duration test

pub fn shift_duration_days_test() {
  let dt =
    test_helpers.unwrap_datetime(datetime.new_utc(
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
  let result = datetime.shift(dt, dur)
  case result {
    Ok(dt2) -> {
      dt2.day |> should.equal(11)
      dt2.hour |> should.equal(12)
    }
    Error(_) -> panic as "Expected valid datetime shift"
  }
}

pub fn shift_duration_months_test() {
  let dt =
    test_helpers.unwrap_datetime(datetime.new_utc(
      2024,
      1,
      31,
      12,
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
      hour: 0,
      minute: 0,
      second: 0,
      microsecond: #(0, 0),
    )
  let result = datetime.shift(dt, dur)
  case result {
    Ok(dt2) -> {
      dt2.month |> should.equal(2)
      // Feb 2024 has 29 days (leap year), so Jan 31 clamps to Feb 29
      dt2.day |> should.equal(29)
    }
    Error(_) -> panic as "Expected valid month shift"
  }
}

// Gregorian seconds tests

pub fn gregorian_seconds_round_trip_test() {
  let dt =
    test_helpers.unwrap_datetime(datetime.new_utc(
      2024,
      6,
      15,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let #(greg_secs, _ms) = datetime.to_gregorian_seconds(dt)
  let result =
    datetime.from_gregorian_seconds(greg_secs, #(0, 0), "Calendar.ISO")
  case result {
    Ok(dt2) -> {
      dt2.year |> should.equal(2024)
      dt2.month |> should.equal(6)
      dt2.day |> should.equal(15)
      dt2.hour |> should.equal(12)
    }
    Error(_) -> panic as "Expected valid Gregorian seconds round trip"
  }
}

// diff with different units test

pub fn diff_milliseconds_test() {
  let dt1 =
    test_helpers.unwrap_datetime(datetime.new_utc(
      2024,
      1,
      1,
      12,
      0,
      1,
      #(0, 0),
      "Calendar.ISO",
    ))
  let dt2 =
    test_helpers.unwrap_datetime(datetime.new_utc(
      2024,
      1,
      1,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  datetime.diff(dt1, dt2, datetime.Millisecond) |> should.equal(1000)
}

// from_iso8601_with_calendar test

pub fn from_iso8601_with_calendar_test() {
  let result =
    datetime.from_iso8601_with_calendar(
      "2024-03-15T12:00:00Z",
      "Calendar.Other",
    )
  case result {
    Ok(dt) -> {
      dt.year |> should.equal(2024)
      dt.calendar |> should.equal("Calendar.Other")
    }
    Error(_) -> panic as "Expected valid ISO8601 with calendar"
  }
}

// to_iso8601_basic test

pub fn to_iso8601_basic_utc_test() {
  let dt =
    test_helpers.unwrap_datetime(datetime.new_utc(
      2024,
      3,
      15,
      12,
      34,
      56,
      #(0, 0),
      "Calendar.ISO",
    ))
  let basic = datetime.to_iso8601_basic(dt)
  basic |> should.equal("20240315T123456Z")
}

// to_local_timestamp test

pub fn to_local_timestamp_test() {
  let dt =
    test_helpers.unwrap_datetime(datetime.new_utc(
      2024,
      1,
      1,
      12,
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    ))
  let local_ts = datetime.to_local_timestamp(dt)
  let utc_ts = datetime.to_utc_timestamp(dt)
  // For UTC, local and UTC timestamps should be the same
  local_ts |> should.equal(utc_ts)
}

// utc_now tests

pub fn utc_now_dt_test() {
  let result = datetime.utc_now()
  case result {
    Ok(dt) -> {
      { dt.year >= 2024 } |> should.equal(True)
      dt.time_zone |> should.equal("Etc/UTC")
      dt.zone_abbr |> should.equal("UTC")
      dt.utc_offset |> should.equal(0)
      dt.std_offset |> should.equal(0)
      { dt.hour >= 0 && dt.hour <= 23 } |> should.equal(True)
    }
    Error(_) -> panic as "Expected Ok for utc_now"
  }
}

pub fn utc_now_with_precision_second_dt_test() {
  let result = datetime.utc_now_with_precision(datetime.Second, "Calendar.ISO")
  case result {
    Ok(dt) -> {
      dt.time_zone |> should.equal("Etc/UTC")
      { dt.year >= 2024 } |> should.equal(True)
    }
    Error(_) -> panic as "Expected Ok"
  }
}

pub fn utc_now_with_precision_millisecond_dt_test() {
  let result =
    datetime.utc_now_with_precision(datetime.Millisecond, "Calendar.ISO")
  case result {
    Ok(dt) -> {
      dt.time_zone |> should.equal("Etc/UTC")
      { dt.year >= 2024 } |> should.equal(True)
    }
    Error(_) -> panic as "Expected Ok"
  }
}

// now tests

pub fn now_utc_test() {
  let result = datetime.now("Etc/UTC", "UTC", 0, 0)
  case result {
    Ok(dt) -> {
      dt.time_zone |> should.equal("Etc/UTC")
      dt.zone_abbr |> should.equal("UTC")
      { dt.year >= 2024 } |> should.equal(True)
    }
    Error(_) -> panic as "Expected Ok for now with UTC"
  }
}

import calendar/naive_datetime
