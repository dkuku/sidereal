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

import calendar/naive_datetime
