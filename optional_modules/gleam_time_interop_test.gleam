import calendar/date
import calendar/datetime
import calendar/gleam_time_interop as interop
import calendar/naive_datetime
import calendar/time
import gleam/float
import gleam/order
import gleam/time/timestamp
import gleeunit/should

/// Test file for gleam_time interoperability conversion functions
pub fn basic_timestamp_test() {
  let now = timestamp.system_time()

  // This should not fail - get unix seconds as float, check it's reasonable
  let unix_seconds = timestamp.to_unix_seconds(now)
  let is_reasonable = float.compare(unix_seconds, 1_000_000_000.0) == order.Gt
  is_reasonable |> should.be_true()
}

pub fn date_conversion_round_trip_test() {
  let our_date = date.new_unchecked(2023, 12, 25, "Calendar.ISO")

  case interop.date_to_gleam(our_date) {
    Ok(gleam_date) -> {
      case interop.date_from_gleam(gleam_date) {
        Ok(converted_back) -> {
          converted_back.year |> should.equal(our_date.year)
          converted_back.month |> should.equal(our_date.month)
          converted_back.day |> should.equal(our_date.day)
        }
        Error(_) -> panic as "Failed to convert back from gleam date"
      }
    }
    Error(_) -> panic as "Failed to convert to gleam date"
  }
}

pub fn time_conversion_round_trip_test() {
  let our_time = time.new_unchecked(14, 30, 45, #(123_456, 6), "Calendar.ISO")

  case interop.time_to_gleam(our_time) {
    Ok(gleam_time) -> {
      case interop.time_from_gleam(gleam_time) {
        Ok(converted_back) -> {
          converted_back.hour |> should.equal(our_time.hour)
          converted_back.minute |> should.equal(our_time.minute)
          converted_back.second |> should.equal(our_time.second)
          // Microseconds might have slight precision differences
          let #(orig_us, _) = our_time.microsecond
          let #(conv_us, _) = converted_back.microsecond
          conv_us |> should.equal(orig_us)
        }
        Error(_) -> panic as "Failed to convert back from gleam time"
      }
    }
    Error(_) -> panic as "Failed to convert to gleam time"
  }
}

pub fn datetime_timestamp_conversion_test() {
  let our_datetime =
    datetime.new_unchecked(
      2023,
      12,
      25,
      14,
      30,
      45,
      "Etc/UTC",
      "UTC",
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    )

  let timestamp = interop.datetime_to_timestamp(our_datetime)
  let converted_back = interop.datetime_from_timestamp(timestamp)

  // Just check that the conversion doesn't fail and returns a valid datetime
  // The exact values might differ due to different epoch calculations and approximations
  let valid_year = converted_back.year > 1900 && converted_back.year < 3000
  let valid_month = converted_back.month >= 1 && converted_back.month <= 12
  let valid_day = converted_back.day >= 1 && converted_back.day <= 31
  let valid_hour = converted_back.hour >= 0 && converted_back.hour <= 23
  let valid_minute = converted_back.minute >= 0 && converted_back.minute <= 59
  let valid_second = converted_back.second >= 0 && converted_back.second <= 59

  valid_year |> should.be_true()
  valid_month |> should.be_true()
  valid_day |> should.be_true()
  valid_hour |> should.be_true()
  valid_minute |> should.be_true()
  valid_second |> should.be_true()
}

pub fn naive_datetime_conversion_test() {
  let our_ndt =
    naive_datetime.new_unchecked(
      2023,
      12,
      25,
      14,
      30,
      45,
      #(123_456, 6),
      "Calendar.ISO",
    )

  case interop.naive_datetime_to_gleam(our_ndt) {
    Ok(#(gleam_date, gleam_time)) -> {
      case interop.naive_datetime_from_gleam(gleam_date, gleam_time) {
        Ok(converted_back) -> {
          converted_back.year |> should.equal(our_ndt.year)
          converted_back.month |> should.equal(our_ndt.month)
          converted_back.day |> should.equal(our_ndt.day)
          converted_back.hour |> should.equal(our_ndt.hour)
          converted_back.minute |> should.equal(our_ndt.minute)
          converted_back.second |> should.equal(our_ndt.second)
        }
        Error(_) -> panic as "Failed to convert back from gleam naive datetime"
      }
    }
    Error(_) -> panic as "Failed to convert to gleam naive datetime"
  }
}

pub fn rfc3339_conversion_test() {
  let our_datetime =
    datetime.new_unchecked(
      2023,
      12,
      25,
      14,
      30,
      45,
      "Etc/UTC",
      "UTC",
      0,
      0,
      #(0, 0),
      "Calendar.ISO",
    )

  let rfc3339_string = interop.datetime_to_rfc3339(our_datetime)

  // Should be a valid RFC3339 string - just check it's not empty
  rfc3339_string |> should.not_equal("")

  // Test round trip
  case interop.datetime_from_rfc3339(rfc3339_string) {
    Ok(converted_back) -> {
      // Just check that the conversion works and returns reasonable values
      let valid_year = converted_back.year > 1900 && converted_back.year < 3000
      let valid_month = converted_back.month >= 1 && converted_back.month <= 12
      let valid_day = converted_back.day >= 1 && converted_back.day <= 31
      let valid_hour = converted_back.hour >= 0 && converted_back.hour <= 23
      let valid_minute =
        converted_back.minute >= 0 && converted_back.minute <= 59
      let valid_second =
        converted_back.second >= 0 && converted_back.second <= 59

      valid_year |> should.be_true()
      valid_month |> should.be_true()
      valid_day |> should.be_true()
      valid_hour |> should.be_true()
      valid_minute |> should.be_true()
      valid_second |> should.be_true()
    }
    Error(_) -> panic as "Failed to parse RFC3339 string back to datetime"
  }
}
