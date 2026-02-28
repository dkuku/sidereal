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
