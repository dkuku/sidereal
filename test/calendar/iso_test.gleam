import calendar/iso.{Basic, Extended, Monday, Sunday}
import gleeunit
import gleeunit/should

pub fn main() -> Nil {
  gleeunit.main()
}

// Helper function for round-trip testing
fn iso_day_roundtrip(year: Int, month: Int, day: Int) -> #(Int, Int, Int) {
  let iso_days = iso.date_to_iso_days(year, month, day)
  let #(rt_year, rt_month, rt_day) = iso.date_from_iso_days(iso_days)
  #(rt_year, rt_month, rt_day)
}

// ISO day conversion tests with positive dates
pub fn iso_day_roundtrip_positive_dates_test() {
  iso_day_roundtrip(0, 1, 1) |> should.equal(#(0, 1, 1))
  iso_day_roundtrip(0, 12, 31) |> should.equal(#(0, 12, 31))
  iso_day_roundtrip(1, 12, 31) |> should.equal(#(1, 12, 31))
  iso_day_roundtrip(4, 1, 1) |> should.equal(#(4, 1, 1))
  iso_day_roundtrip(4, 12, 31) |> should.equal(#(4, 12, 31))
}

pub fn iso_day_roundtrip_large_dates_test() {
  iso_day_roundtrip(9999, 12, 31) |> should.equal(#(9999, 12, 31))
  iso_day_roundtrip(9999, 1, 1) |> should.equal(#(9999, 1, 1))
  iso_day_roundtrip(9996, 12, 31) |> should.equal(#(9996, 12, 31))
  iso_day_roundtrip(9996, 1, 1) |> should.equal(#(9996, 1, 1))
}

// ISO day conversion tests with negative dates
pub fn iso_day_roundtrip_negative_dates_test() {
  iso_day_roundtrip(-1, 1, 1) |> should.equal(#(-1, 1, 1))
  iso_day_roundtrip(-1, 12, 31) |> should.equal(#(-1, 12, 31))
  iso_day_roundtrip(-2, 1, 1) |> should.equal(#(-2, 1, 1))
  iso_day_roundtrip(-5, 12, 31) |> should.equal(#(-5, 12, 31))
}

pub fn iso_day_roundtrip_leap_year_negative_test() {
  iso_day_roundtrip(-4, 1, 1) |> should.equal(#(-4, 1, 1))
  iso_day_roundtrip(-4, 12, 31) |> should.equal(#(-4, 12, 31))
}

pub fn iso_day_roundtrip_large_negative_dates_test() {
  iso_day_roundtrip(-9999, 12, 31) |> should.equal(#(-9999, 12, 31))
  iso_day_roundtrip(-9996, 12, 31) |> should.equal(#(-9996, 12, 31))
  iso_day_roundtrip(-9996, 1, 1) |> should.equal(#(-9996, 1, 1))
}

// Date to string tests - basic format
pub fn date_to_string_basic_positive_test() {
  iso.date_to_string(1000, 1, 1, Basic) |> should.equal("10000101")
  iso.date_to_string(2023, 12, 25, Basic) |> should.equal("20231225")
}

pub fn date_to_string_basic_negative_test() {
  iso.date_to_string(-123, 1, 1, Basic) |> should.equal("-01230101")
  iso.date_to_string(-1, 12, 31, Basic) |> should.equal("-00011231")
}

// Date to string tests - extended format
pub fn date_to_string_extended_positive_test() {
  iso.date_to_string(1000, 1, 1, Extended) |> should.equal("1000-01-01")
  iso.date_to_string(2023, 12, 25, Extended) |> should.equal("2023-12-25")
}

pub fn date_to_string_extended_negative_test() {
  iso.date_to_string(-123, 1, 1, Extended) |> should.equal("-0123-01-01")
  iso.date_to_string(-1, 12, 31, Extended) |> should.equal("-0001-12-31")
}

// Large year handling
pub fn date_to_string_large_years_basic_test() {
  iso.date_to_string(10_000, 1, 1, Basic) |> should.equal("100000101")
  iso.date_to_string(99_999, 12, 31, Basic) |> should.equal("999991231")
}

pub fn date_to_string_large_years_extended_test() {
  iso.date_to_string(10_000, 1, 1, Extended) |> should.equal("10000-01-01")
  iso.date_to_string(99_999, 12, 31, Extended) |> should.equal("99999-12-31")
}

// Time to string tests
pub fn time_to_string_basic_test() {
  iso.time_to_string(12, 34, 56, 0, Basic) |> should.equal("123456")
  iso.time_to_string(0, 0, 0, 0, Basic) |> should.equal("000000")
}

pub fn time_to_string_extended_test() {
  iso.time_to_string(12, 34, 56, 0, Extended) |> should.equal("12:34:56")
  iso.time_to_string(0, 0, 0, 0, Extended) |> should.equal("00:00:00")
}

pub fn time_to_string_with_microseconds_test() {
  iso.time_to_string(12, 34, 56, 123_456, Extended)
  |> should.equal("12:34:56.123456")
  iso.time_to_string(23, 59, 59, 999_999, Basic)
  |> should.equal("235959.999999")
}

// Day of week tests
pub fn day_of_week_monday_test() {
  // Monday = 1
  iso.day_of_week(2023, 10, 30, Monday) |> should.equal(1)
}

pub fn day_of_week_tuesday_test() {
  // Tuesday = 2
  iso.day_of_week(2023, 10, 31, Monday) |> should.equal(2)
}

pub fn day_of_week_sunday_start_test() {
  // When starting with Sunday, Sunday = 1
  iso.day_of_week(2023, 10, 29, Sunday) |> should.equal(1)
  // Monday becomes 2
  iso.day_of_week(2023, 10, 30, Sunday) |> should.equal(2)
}

// Day of year tests
pub fn day_of_year_january_test() {
  iso.day_of_year(2023, 1, 1) |> should.equal(1)
  iso.day_of_year(2023, 1, 31) |> should.equal(31)
}

pub fn day_of_year_february_test() {
  // Non-leap year
  iso.day_of_year(2023, 2, 1) |> should.equal(32)
  iso.day_of_year(2023, 2, 28) |> should.equal(59)
}

pub fn day_of_year_february_leap_test() {
  // Leap year
  iso.day_of_year(2020, 2, 29) |> should.equal(60)
  iso.day_of_year(2020, 3, 1) |> should.equal(61)
}

pub fn day_of_year_december_test() {
  // Non-leap year
  iso.day_of_year(2023, 12, 31) |> should.equal(365)
  // Leap year
  iso.day_of_year(2020, 12, 31) |> should.equal(366)
}

// Day of era tests
pub fn day_of_era_positive_test() {
  // Era 1, positive years
  let #(days, era) = iso.day_of_era(1, 1, 1)
  days |> should.equal(1)
  era |> should.equal(1)
}

pub fn day_of_era_year_zero_test() {
  // Era 0, year 0
  let #(days, era) = iso.day_of_era(0, 1, 1)
  days |> should.equal(366)
  // Year 0 is a leap year
  era |> should.equal(0)
}

pub fn day_of_era_negative_test() {
  // Era 0, negative years
  let #(days, era) = iso.day_of_era(-1, 12, 31)
  days |> should.equal(367)
  era |> should.equal(0)
}

// Valid date tests
pub fn valid_date_test() {
  iso.valid_date(2023, 1, 1) |> should.equal(True)
  iso.valid_date(2023, 12, 31) |> should.equal(True)
  iso.valid_date(2020, 2, 29) |> should.equal(True)
  // Leap year
}

pub fn invalid_date_test() {
  iso.valid_date(2023, 2, 29) |> should.equal(False)
  // Not leap year
  iso.valid_date(2023, 13, 1) |> should.equal(False)
  // Invalid month
  iso.valid_date(2023, 1, 32) |> should.equal(False)
  // Invalid day
  iso.valid_date(2023, 0, 1) |> should.equal(False)
  // Invalid month
  iso.valid_date(2023, 1, 0) |> should.equal(False)
  // Invalid day
}

// Valid time tests
pub fn valid_time_test() {
  iso.valid_time(0, 0, 0, 0) |> should.equal(True)
  iso.valid_time(23, 59, 59, 999_999) |> should.equal(True)
  iso.valid_time(12, 30, 45, 123_456) |> should.equal(True)
}

pub fn invalid_time_test() {
  iso.valid_time(24, 0, 0, 0) |> should.equal(False)
  // Invalid hour
  iso.valid_time(12, 60, 0, 0) |> should.equal(False)
  // Invalid minute
  iso.valid_time(12, 30, 60, 0) |> should.equal(False)
  // Invalid second
  iso.valid_time(12, 30, 45, 1_000_000) |> should.equal(False)
  // Invalid microsecond
  iso.valid_time(-1, 0, 0, 0) |> should.equal(False)
  // Negative hour
}

// Leap year tests
pub fn leap_year_test() {
  iso.leap_year(2000) |> should.equal(True)
  // Divisible by 400
  iso.leap_year(2004) |> should.equal(True)
  // Divisible by 4, not by 100
  iso.leap_year(1900) |> should.equal(False)
  // Divisible by 100, not by 400
  iso.leap_year(2001) |> should.equal(False)
  // Not divisible by 4
  iso.leap_year(0) |> should.equal(True)
  // Year 0 is leap year
}

// Days in month tests
pub fn days_in_month_test() {
  // January
  iso.days_in_month(2023, 1) |> should.equal(31)
  // February non-leap
  iso.days_in_month(2023, 2) |> should.equal(28)
  // February leap
  iso.days_in_month(2020, 2) |> should.equal(29)
  // April (30 days)
  iso.days_in_month(2023, 4) |> should.equal(30)
  // December
  iso.days_in_month(2023, 12) |> should.equal(31)
}

// Months in year test
pub fn months_in_year_test() {
  iso.months_in_year(2023) |> should.equal(12)
  iso.months_in_year(0) |> should.equal(12)
  iso.months_in_year(-1) |> should.equal(12)
}

// Naive datetime to ISO days tests
pub fn naive_datetime_to_iso_days_test() {
  let #(iso_days, #(_day_fraction, _precision)) =
    iso.naive_datetime_to_iso_days(2000, 1, 1, 12, 0, 0, #(0, 0))
  let microseconds = iso.time_to_microseconds(12, 0, 0, 0)

  // Verify we can convert back
  let #(year, month, day) = iso.date_from_iso_days(iso_days)
  year |> should.equal(2000)
  month |> should.equal(1)
  day |> should.equal(1)

  // Verify the time conversion
  microseconds |> should.equal(43_200_000_000)
  // 12 hours in microseconds
}

// Time to microseconds conversion
pub fn time_to_microseconds_test() {
  iso.time_to_microseconds(0, 0, 0, 0) |> should.equal(0)
  iso.time_to_microseconds(1, 0, 0, 0) |> should.equal(3_600_000_000)
  // 1 hour
  iso.time_to_microseconds(0, 1, 0, 0) |> should.equal(60_000_000)
  // 1 minute
  iso.time_to_microseconds(0, 0, 1, 0) |> should.equal(1_000_000)
  // 1 second
  iso.time_to_microseconds(0, 0, 0, 123_456) |> should.equal(123_456)
  // microseconds
}

pub fn microseconds_to_time_test() {
  let #(h, m, s, us) = iso.microseconds_to_time(0)
  h |> should.equal(0)
  m |> should.equal(0)
  s |> should.equal(0)
  us |> should.equal(0)

  let #(h2, m2, s2, us2) = iso.microseconds_to_time(3_661_123_456)
  // 1h 1m 1s 123456us
  h2 |> should.equal(1)
  m2 |> should.equal(1)
  s2 |> should.equal(1)
  us2 |> should.equal(123_456)
}

// parse_date tests

pub fn parse_date_extended_test() {
  case iso.parse_date("2024-06-15") {
    iso.ParseOk(#(y, m, d)) -> {
      y |> should.equal(2024)
      m |> should.equal(6)
      d |> should.equal(15)
    }
    iso.ParseError(_) -> panic as "Expected ParseOk"
  }
}

pub fn parse_date_invalid_format_test() {
  case iso.parse_date("not-a-date") {
    iso.ParseOk(_) -> panic as "Expected ParseError"
    iso.ParseError(_) -> Nil
  }
}

pub fn parse_date_invalid_day_test() {
  case iso.parse_date("2024-02-30") {
    iso.ParseOk(_) -> panic as "Expected ParseError"
    iso.ParseError(_) -> Nil
  }
}

// parse_date_with_format tests

pub fn parse_date_basic_format_test() {
  case iso.parse_date_with_format("20240615", Basic) {
    iso.ParseOk(#(y, m, d)) -> {
      y |> should.equal(2024)
      m |> should.equal(6)
      d |> should.equal(15)
    }
    iso.ParseError(_) -> panic as "Expected ParseOk"
  }
}

pub fn parse_date_basic_too_short_test() {
  case iso.parse_date_with_format("2024", Basic) {
    iso.ParseOk(_) -> panic as "Expected ParseError"
    iso.ParseError(_) -> Nil
  }
}

// parse_time tests

pub fn parse_time_simple_test() {
  case iso.parse_time("14:30:45") {
    iso.ParseOk(#(h, m, s, ms)) -> {
      h |> should.equal(14)
      m |> should.equal(30)
      s |> should.equal(45)
      ms |> should.equal(#(0, 0))
    }
    iso.ParseError(_) -> panic as "Expected ParseOk"
  }
}

pub fn parse_time_with_microseconds_test() {
  case iso.parse_time("14:30:45.123456") {
    iso.ParseOk(#(h, m, s, #(us, precision))) -> {
      h |> should.equal(14)
      m |> should.equal(30)
      s |> should.equal(45)
      us |> should.equal(123_456)
      precision |> should.equal(6)
    }
    iso.ParseError(_) -> panic as "Expected ParseOk"
  }
}

pub fn parse_time_with_milliseconds_test() {
  case iso.parse_time("08:00:00.123") {
    iso.ParseOk(#(_, _, _, #(us, precision))) -> {
      us |> should.equal(123_000)
      precision |> should.equal(3)
    }
    iso.ParseError(_) -> panic as "Expected ParseOk"
  }
}

pub fn parse_time_invalid_hour_test() {
  case iso.parse_time("25:00:00") {
    iso.ParseOk(_) -> panic as "Expected ParseError"
    iso.ParseError(_) -> Nil
  }
}

pub fn parse_time_invalid_format_test() {
  case iso.parse_time("not-a-time") {
    iso.ParseOk(_) -> panic as "Expected ParseError"
    iso.ParseError(_) -> Nil
  }
}

// parse_time_with_format tests

pub fn parse_time_basic_format_test() {
  case iso.parse_time_with_format("143045", Basic) {
    iso.ParseOk(#(h, m, s, _)) -> {
      h |> should.equal(14)
      m |> should.equal(30)
      s |> should.equal(45)
    }
    iso.ParseError(_) -> panic as "Expected ParseOk"
  }
}

pub fn parse_time_with_t_prefix_test() {
  case iso.parse_time_with_format("T14:30:45", Extended) {
    iso.ParseOk(#(h, m, s, _)) -> {
      h |> should.equal(14)
      m |> should.equal(30)
      s |> should.equal(45)
    }
    iso.ParseError(_) -> panic as "Expected ParseOk"
  }
}

// parse_naive_datetime tests

pub fn parse_naive_datetime_test() {
  case iso.parse_naive_datetime("2024-06-15T14:30:45") {
    iso.ParseOk(#(y, m, d, h, min, s, _)) -> {
      y |> should.equal(2024)
      m |> should.equal(6)
      d |> should.equal(15)
      h |> should.equal(14)
      min |> should.equal(30)
      s |> should.equal(45)
    }
    iso.ParseError(_) -> panic as "Expected ParseOk"
  }
}

pub fn parse_naive_datetime_with_space_test() {
  case iso.parse_naive_datetime("2024-06-15 14:30:45") {
    iso.ParseOk(#(y, _, _, h, _, _, _)) -> {
      y |> should.equal(2024)
      h |> should.equal(14)
    }
    iso.ParseError(_) -> panic as "Expected ParseOk"
  }
}

pub fn parse_naive_datetime_with_microseconds_test() {
  case iso.parse_naive_datetime("2024-01-01T00:00:00.123456") {
    iso.ParseOk(#(_, _, _, _, _, _, #(us, precision))) -> {
      us |> should.equal(123_456)
      precision |> should.equal(6)
    }
    iso.ParseError(_) -> panic as "Expected ParseOk"
  }
}

pub fn parse_naive_datetime_invalid_test() {
  case iso.parse_naive_datetime("not-valid") {
    iso.ParseOk(_) -> panic as "Expected ParseError"
    iso.ParseError(_) -> Nil
  }
}

// parse_naive_datetime_with_format tests

pub fn parse_naive_datetime_basic_format_test() {
  case iso.parse_naive_datetime_with_format("20240615T143045", Basic) {
    iso.ParseOk(#(y, m, d, h, min, s, _)) -> {
      y |> should.equal(2024)
      m |> should.equal(6)
      d |> should.equal(15)
      h |> should.equal(14)
      min |> should.equal(30)
      s |> should.equal(45)
    }
    iso.ParseError(_) -> panic as "Expected ParseOk"
  }
}

// naive_datetime_from_iso_days tests

pub fn naive_datetime_from_iso_days_roundtrip_test() {
  let iso_days =
    iso.naive_datetime_to_iso_days(2024, 6, 15, 14, 30, 45, #(123_456, 6))
  let #(y, m, d, h, min, s, #(us, _)) =
    iso.naive_datetime_from_iso_days(iso_days)
  y |> should.equal(2024)
  m |> should.equal(6)
  d |> should.equal(15)
  h |> should.equal(14)
  min |> should.equal(30)
  s |> should.equal(45)
  us |> should.equal(123_456)
}

pub fn naive_datetime_from_iso_days_midnight_test() {
  let iso_days = iso.naive_datetime_to_iso_days(2024, 1, 1, 0, 0, 0, #(0, 0))
  let #(y, m, d, h, min, s, _) = iso.naive_datetime_from_iso_days(iso_days)
  y |> should.equal(2024)
  m |> should.equal(1)
  d |> should.equal(1)
  h |> should.equal(0)
  min |> should.equal(0)
  s |> should.equal(0)
}

// parse_utc_datetime tests

pub fn parse_utc_datetime_with_z_test() {
  case iso.parse_utc_datetime("2024-06-15T14:30:45Z") {
    iso.ParseOk(#(#(y, m, d, h, min, s, _), offset)) -> {
      y |> should.equal(2024)
      m |> should.equal(6)
      d |> should.equal(15)
      h |> should.equal(14)
      min |> should.equal(30)
      s |> should.equal(45)
      offset |> should.equal(0)
    }
    iso.ParseError(_) -> panic as "Expected ParseOk"
  }
}

pub fn parse_utc_datetime_positive_offset_test() {
  case iso.parse_utc_datetime("2024-06-15T14:30:45+05:30") {
    iso.ParseOk(#(#(y, _, _, h, _, _, _), offset)) -> {
      y |> should.equal(2024)
      h |> should.equal(14)
      offset |> should.equal(5 * 3600 + 30 * 60)
    }
    iso.ParseError(_) -> panic as "Expected ParseOk"
  }
}

pub fn parse_utc_datetime_negative_offset_test() {
  case iso.parse_utc_datetime("2024-06-15T14:30:45-05:00") {
    iso.ParseOk(#(_, offset)) -> {
      offset |> should.equal(-5 * 3600)
    }
    iso.ParseError(_) -> panic as "Expected ParseOk"
  }
}

pub fn parse_utc_datetime_invalid_test() {
  case iso.parse_utc_datetime("invalid") {
    iso.ParseOk(_) -> panic as "Expected ParseError"
    iso.ParseError(_) -> Nil
  }
}

// parse_utc_datetime_with_format tests

pub fn parse_utc_datetime_basic_format_test() {
  case iso.parse_utc_datetime_with_format("20240615T143045Z", Basic) {
    iso.ParseOk(#(#(y, m, d, h, min, s, _), offset)) -> {
      y |> should.equal(2024)
      m |> should.equal(6)
      d |> should.equal(15)
      h |> should.equal(14)
      min |> should.equal(30)
      s |> should.equal(45)
      offset |> should.equal(0)
    }
    iso.ParseError(_) -> panic as "Expected ParseOk"
  }
}

// time_to_day_fraction and time_from_day_fraction tests

pub fn time_to_day_fraction_midnight_test() {
  let #(parts, ppd) = iso.time_to_day_fraction(0, 0, 0, #(0, 0))
  parts |> should.equal(0)
  ppd |> should.equal(86_400_000_000)
}

pub fn time_to_day_fraction_noon_test() {
  let #(parts, _) = iso.time_to_day_fraction(12, 0, 0, #(0, 0))
  parts |> should.equal(43_200_000_000)
}

pub fn time_from_day_fraction_midnight_test() {
  let #(h, m, s, #(us, _)) = iso.time_from_day_fraction(#(0, 86_400_000_000))
  h |> should.equal(0)
  m |> should.equal(0)
  s |> should.equal(0)
  us |> should.equal(0)
}

pub fn time_day_fraction_roundtrip_test() {
  let fraction = iso.time_to_day_fraction(14, 30, 45, #(123_456, 6))
  let #(h, m, s, #(us, _)) = iso.time_from_day_fraction(fraction)
  h |> should.equal(14)
  m |> should.equal(30)
  s |> should.equal(45)
  us |> should.equal(123_456)
}

// iso_days_to_beginning_of_day tests

pub fn iso_days_to_beginning_of_day_test() {
  let iso_days = #(100, #(43_200_000_000, 86_400_000_000))
  let #(days, #(fraction, _)) = iso.iso_days_to_beginning_of_day(iso_days)
  days |> should.equal(100)
  fraction |> should.equal(0)
}

// iso_days_to_end_of_day tests

pub fn iso_days_to_end_of_day_test() {
  let iso_days = #(100, #(0, 86_400_000_000))
  let #(days, #(fraction, ppd)) = iso.iso_days_to_end_of_day(iso_days)
  days |> should.equal(100)
  fraction |> should.equal(ppd - 1)
}

// quarter_of_year tests

pub fn quarter_of_year_q1_test() {
  iso.quarter_of_year(2024, 1, 15) |> should.equal(1)
  iso.quarter_of_year(2024, 3, 31) |> should.equal(1)
}

pub fn quarter_of_year_q2_test() {
  iso.quarter_of_year(2024, 4, 1) |> should.equal(2)
  iso.quarter_of_year(2024, 6, 30) |> should.equal(2)
}

pub fn quarter_of_year_q3_test() {
  iso.quarter_of_year(2024, 7, 1) |> should.equal(3)
  iso.quarter_of_year(2024, 9, 30) |> should.equal(3)
}

pub fn quarter_of_year_q4_test() {
  iso.quarter_of_year(2024, 10, 1) |> should.equal(4)
  iso.quarter_of_year(2024, 12, 31) |> should.equal(4)
}

// year_of_era tests

pub fn year_of_era_ce_test() {
  let #(y, era) = iso.year_of_era(2024)
  y |> should.equal(2024)
  era |> should.equal(1)
}

pub fn year_of_era_bce_year_zero_test() {
  let #(y, era) = iso.year_of_era(0)
  y |> should.equal(1)
  era |> should.equal(0)
}

pub fn year_of_era_bce_negative_test() {
  let #(y, era) = iso.year_of_era(-1)
  y |> should.equal(2)
  era |> should.equal(0)
}

// year_of_era_from_date tests

pub fn year_of_era_from_date_test() {
  let #(y, era) = iso.year_of_era_from_date(2024, 6, 15)
  y |> should.equal(2024)
  era |> should.equal(1)
}

pub fn year_of_era_from_date_bce_test() {
  let #(y, era) = iso.year_of_era_from_date(-1, 1, 1)
  y |> should.equal(2)
  era |> should.equal(0)
}

// shift_date tests

pub fn shift_date_days_test() {
  let #(y, m, d) = iso.shift_date(2024, 1, 1, 0, 10)
  y |> should.equal(2024)
  m |> should.equal(1)
  d |> should.equal(11)
}

pub fn shift_date_months_test() {
  let #(y, m, d) = iso.shift_date(2024, 1, 15, 3, 0)
  y |> should.equal(2024)
  m |> should.equal(4)
  d |> should.equal(15)
}

pub fn shift_date_month_clamp_test() {
  // January 31 + 1 month = Feb, clamped to Feb 29 (2024 is leap)
  let #(y, m, d) = iso.shift_date(2024, 1, 31, 1, 0)
  y |> should.equal(2024)
  m |> should.equal(2)
  d |> should.equal(29)
}

pub fn shift_date_year_overflow_test() {
  let #(y, m, d) = iso.shift_date(2024, 12, 1, 1, 0)
  y |> should.equal(2025)
  m |> should.equal(1)
  d |> should.equal(1)
}

pub fn shift_date_negative_months_test() {
  let #(y, m, d) = iso.shift_date(2024, 3, 15, -2, 0)
  y |> should.equal(2024)
  m |> should.equal(1)
  d |> should.equal(15)
}

pub fn shift_date_negative_days_test() {
  let #(y, m, d) = iso.shift_date(2024, 1, 1, 0, -1)
  y |> should.equal(2023)
  m |> should.equal(12)
  d |> should.equal(31)
}

pub fn shift_date_no_shift_test() {
  let #(y, m, d) = iso.shift_date(2024, 6, 15, 0, 0)
  y |> should.equal(2024)
  m |> should.equal(6)
  d |> should.equal(15)
}

// shift_naive_datetime tests

pub fn shift_naive_datetime_seconds_test() {
  let #(y, m, d, h, min, s, _) =
    iso.shift_naive_datetime(2024, 1, 1, 0, 0, 0, #(0, 0), 0, 0, 3600, 0)
  y |> should.equal(2024)
  m |> should.equal(1)
  d |> should.equal(1)
  h |> should.equal(1)
  min |> should.equal(0)
  s |> should.equal(0)
}

pub fn shift_naive_datetime_day_overflow_test() {
  let #(y, m, d, h, _, _, _) =
    iso.shift_naive_datetime(2024, 1, 1, 23, 0, 0, #(0, 0), 0, 0, 7200, 0)
  y |> should.equal(2024)
  m |> should.equal(1)
  d |> should.equal(2)
  h |> should.equal(1)
}

pub fn shift_naive_datetime_months_and_time_test() {
  let #(y, m, d, h, min, _, _) =
    iso.shift_naive_datetime(2024, 1, 15, 10, 30, 0, #(0, 0), 2, 0, 1800, 0)
  y |> should.equal(2024)
  m |> should.equal(3)
  d |> should.equal(15)
  h |> should.equal(11)
  min |> should.equal(0)
}

pub fn shift_naive_datetime_no_shift_test() {
  let #(y, m, d, h, min, s, _) =
    iso.shift_naive_datetime(2024, 6, 15, 14, 30, 45, #(0, 0), 0, 0, 0, 0)
  y |> should.equal(2024)
  m |> should.equal(6)
  d |> should.equal(15)
  h |> should.equal(14)
  min |> should.equal(30)
  s |> should.equal(45)
}

// shift_time tests

pub fn shift_time_seconds_test() {
  let #(h, m, s, _) = iso.shift_time(10, 0, 0, #(0, 0), 3600, 0)
  h |> should.equal(11)
  m |> should.equal(0)
  s |> should.equal(0)
}

pub fn shift_time_wrap_around_test() {
  let #(h, _, _, _) = iso.shift_time(23, 0, 0, #(0, 0), 7200, 0)
  h |> should.equal(1)
}

pub fn shift_time_no_shift_test() {
  let #(h, m, s, _) = iso.shift_time(14, 30, 45, #(0, 0), 0, 0)
  h |> should.equal(14)
  m |> should.equal(30)
  s |> should.equal(45)
}

pub fn shift_time_microseconds_test() {
  let #(h, m, s, #(us, _)) = iso.shift_time(12, 0, 0, #(0, 6), 0, 500_000)
  h |> should.equal(12)
  m |> should.equal(0)
  s |> should.equal(0)
  us |> should.equal(500_000)
}

// time_unit_to_precision tests

pub fn time_unit_to_precision_second_test() {
  iso.time_unit_to_precision(iso.Second) |> should.equal(0)
}

pub fn time_unit_to_precision_millisecond_test() {
  iso.time_unit_to_precision(iso.Millisecond) |> should.equal(3)
}

pub fn time_unit_to_precision_microsecond_test() {
  iso.time_unit_to_precision(iso.Microsecond) |> should.equal(6)
}

pub fn time_unit_to_precision_nanosecond_test() {
  iso.time_unit_to_precision(iso.Nanosecond) |> should.equal(6)
}

// iso_days_to_unit tests

pub fn iso_days_to_unit_seconds_test() {
  let iso_days = #(1, #(0, 86_400_000_000))
  iso.iso_days_to_unit(iso_days, iso.Second) |> should.equal(86_400)
}

pub fn iso_days_to_unit_microseconds_test() {
  let iso_days = #(0, #(1_000_000, 86_400_000_000))
  iso.iso_days_to_unit(iso_days, iso.Microsecond) |> should.equal(1_000_000)
}

pub fn iso_days_to_unit_milliseconds_test() {
  let iso_days = #(0, #(1_000_000, 86_400_000_000))
  iso.iso_days_to_unit(iso_days, iso.Millisecond) |> should.equal(1000)
}

// add_day_fraction_to_iso_days tests

pub fn add_day_fraction_same_ppd_test() {
  let ppd = 86_400_000_000
  let iso_days = #(10, #(0, ppd))
  let #(days, #(parts, _)) =
    iso.add_day_fraction_to_iso_days(iso_days, ppd / 2, ppd)
  days |> should.equal(10)
  parts |> should.equal(ppd / 2)
}

pub fn add_day_fraction_overflow_test() {
  let ppd = 86_400_000_000
  let iso_days = #(10, #(ppd / 2, ppd))
  let #(days, #(parts, _)) =
    iso.add_day_fraction_to_iso_days(iso_days, ppd, ppd)
  days |> should.equal(11)
  parts |> should.equal(ppd / 2)
}

// naive_datetime_to_string tests

pub fn naive_datetime_to_string_extended_test() {
  iso.naive_datetime_to_string(2024, 6, 15, 14, 30, 45, #(0, 0), Extended)
  |> should.equal("2024-06-15 14:30:45")
}

pub fn naive_datetime_to_string_basic_test() {
  iso.naive_datetime_to_string(2024, 6, 15, 14, 30, 45, #(0, 0), Basic)
  |> should.equal("20240615 143045")
}

pub fn naive_datetime_to_string_with_microseconds_test() {
  iso.naive_datetime_to_string(2024, 6, 15, 14, 30, 45, #(123_456, 6), Extended)
  |> should.equal("2024-06-15 14:30:45.123456")
}

// datetime_to_string tests

pub fn datetime_to_string_utc_test() {
  iso.datetime_to_string(
    2024,
    6,
    15,
    14,
    30,
    45,
    #(0, 0),
    "Etc/UTC",
    "UTC",
    0,
    0,
    Extended,
  )
  |> should.equal("2024-06-15 14:30:45Z")
}

pub fn datetime_to_string_with_offset_test() {
  iso.datetime_to_string(
    2024,
    6,
    15,
    14,
    30,
    45,
    #(0, 0),
    "America/New_York",
    "EDT",
    -5 * 3600,
    3600,
    Extended,
  )
  |> should.equal("2024-06-15 14:30:45-04:00 EDT")
}

pub fn datetime_to_string_basic_utc_test() {
  iso.datetime_to_string(
    2024,
    6,
    15,
    14,
    30,
    45,
    #(0, 0),
    "Etc/UTC",
    "UTC",
    0,
    0,
    Basic,
  )
  |> should.equal("20240615 143045Z")
}

// parse_duration tests

pub fn parse_duration_full_test() {
  case iso.parse_duration("P1Y2M3DT4H5M6S") {
    iso.ParseOk(pairs) -> {
      pairs
      |> should.equal([
        #("year", 1),
        #("month", 2),
        #("day", 3),
        #("hour", 4),
        #("minute", 5),
        #("second", 6),
      ])
    }
    iso.ParseError(_) -> panic as "Expected ParseOk"
  }
}

pub fn parse_duration_days_only_test() {
  case iso.parse_duration("P30D") {
    iso.ParseOk(pairs) -> {
      pairs |> should.equal([#("day", 30)])
    }
    iso.ParseError(_) -> panic as "Expected ParseOk"
  }
}

pub fn parse_duration_time_only_test() {
  case iso.parse_duration("PT1H30M") {
    iso.ParseOk(pairs) -> {
      pairs |> should.equal([#("hour", 1), #("minute", 30)])
    }
    iso.ParseError(_) -> panic as "Expected ParseOk"
  }
}

pub fn parse_duration_weeks_test() {
  case iso.parse_duration("P2W") {
    iso.ParseOk(pairs) -> {
      pairs |> should.equal([#("week", 2)])
    }
    iso.ParseError(_) -> panic as "Expected ParseOk"
  }
}

pub fn parse_duration_negative_test() {
  case iso.parse_duration("-P1Y2M") {
    iso.ParseOk(pairs) -> {
      pairs |> should.equal([#("year", -1), #("month", -2)])
    }
    iso.ParseError(_) -> panic as "Expected ParseOk"
  }
}

pub fn parse_duration_positive_prefix_test() {
  case iso.parse_duration("+P1D") {
    iso.ParseOk(pairs) -> {
      pairs |> should.equal([#("day", 1)])
    }
    iso.ParseError(_) -> panic as "Expected ParseOk"
  }
}

pub fn parse_duration_invalid_test() {
  case iso.parse_duration("not-a-duration") {
    iso.ParseOk(_) -> panic as "Expected ParseError"
    iso.ParseError(_) -> Nil
  }
}

pub fn parse_duration_empty_test() {
  case iso.parse_duration("P") {
    iso.ParseOk(pairs) -> {
      pairs |> should.equal([])
    }
    iso.ParseError(_) -> panic as "Expected ParseOk for empty P"
  }
}

// gregorian_seconds_to_iso_days tests

pub fn gregorian_seconds_to_iso_days_one_day_test() {
  let #(days, #(us_in_day, _)) = iso.gregorian_seconds_to_iso_days(86_400, 0)
  days |> should.equal(1)
  us_in_day |> should.equal(0)
}

pub fn gregorian_seconds_to_iso_days_with_microsecond_test() {
  let #(days, #(us_in_day, _)) =
    iso.gregorian_seconds_to_iso_days(86_400 + 3600, 500_000)
  days |> should.equal(1)
  us_in_day |> should.equal(3_600_000_000 + 500_000)
}

pub fn gregorian_seconds_to_iso_days_zero_test() {
  let #(days, #(us_in_day, _)) = iso.gregorian_seconds_to_iso_days(0, 0)
  days |> should.equal(0)
  us_in_day |> should.equal(0)
}
