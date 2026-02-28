// Test helpers for unwrapping Result types in tests
import calendar/date
import calendar/datetime
import calendar/naive_datetime
import calendar/time

// Helper functions to unwrap results in tests - these will panic on error which is fine for tests
pub fn unwrap_date(result: Result(date.Date, date.DateError)) -> date.Date {
  case result {
    Ok(d) -> d
    Error(_) -> panic as "Test date creation failed"
  }
}

pub fn unwrap_time(result: Result(time.Time, time.TimeError)) -> time.Time {
  case result {
    Ok(t) -> t
    Error(_) -> panic as "Test time creation failed"
  }
}

pub fn unwrap_naive_datetime(
  result: Result(
    naive_datetime.NaiveDateTime,
    naive_datetime.NaiveDateTimeError,
  ),
) -> naive_datetime.NaiveDateTime {
  case result {
    Ok(ndt) -> ndt
    Error(_) -> panic as "Test naive datetime creation failed"
  }
}

pub fn unwrap_datetime(
  result: Result(datetime.DateTime, datetime.DateTimeError),
) -> datetime.DateTime {
  case result {
    Ok(dt) -> dt
    Error(_) -> panic as "Test datetime creation failed"
  }
}
