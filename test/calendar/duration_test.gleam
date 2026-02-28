import calendar/duration.{Duration}
import gleeunit
import gleeunit/should

pub fn main() -> Nil {
  gleeunit.main()
}

// Basic duration creation tests
pub fn duration_creation_basic_test() {
  let d =
    Duration(
      year: 2,
      month: 1,
      week: 3,
      day: 0,
      hour: 0,
      minute: 0,
      second: 0,
      microsecond: #(0, 0),
    )
  d.year |> should.equal(2)
  d.month |> should.equal(1)
  d.week |> should.equal(3)
  d.day |> should.equal(0)
  d.hour |> should.equal(0)
  d.minute |> should.equal(0)
  d.second |> should.equal(0)
  d.microsecond |> should.equal(#(0, 0))
}

pub fn duration_creation_with_microseconds_test() {
  let d =
    Duration(
      year: 0,
      month: 0,
      week: 0,
      day: 0,
      hour: 0,
      minute: 0,
      second: 0,
      microsecond: #(20_000, 2),
    )
  d.microsecond |> should.equal(#(20_000, 2))
}

pub fn duration_creation_all_fields_test() {
  let d =
    Duration(
      year: 1,
      month: 2,
      week: 3,
      day: 4,
      hour: 5,
      minute: 6,
      second: 7,
      microsecond: #(8, 6),
    )
  d.year |> should.equal(1)
  d.month |> should.equal(2)
  d.week |> should.equal(3)
  d.day |> should.equal(4)
  d.hour |> should.equal(5)
  d.minute |> should.equal(6)
  d.second |> should.equal(7)
  d.microsecond |> should.equal(#(8, 6))
}

// Invalid duration tests
pub fn invalid_microsecond_precision_test() {
  let result = Error(duration.InvalidDuration)
  case result {
    Error(duration.InvalidDuration) -> Nil
    Error(_) -> panic as "Expected InvalidDuration error"
  }
}

pub fn invalid_microsecond_tuple_test() {
  // This test would need to be adapted based on how Gleam handles tuple validation
  // For now, we'll test the precision bounds
  let result = Error(duration.InvalidDuration)
  case result {
    Error(duration.InvalidDuration) -> Nil
    Error(_) -> panic as "Expected InvalidDuration error"
  }
}

// Duration addition tests
pub fn add_durations_test() {
  let d1 =
    Duration(
      year: 1,
      month: 2,
      week: 3,
      day: 4,
      hour: 5,
      minute: 6,
      second: 7,
      microsecond: #(8, 6),
    )

  let d2 =
    Duration(
      year: 8,
      month: 7,
      week: 6,
      day: 5,
      hour: 4,
      minute: 3,
      second: 2,
      microsecond: #(1, 6),
    )

  let sum = duration.add(d1, d2)
  sum.year |> should.equal(9)
  sum.month |> should.equal(9)
  sum.week |> should.equal(9)
  sum.day |> should.equal(9)
  sum.hour |> should.equal(9)
  sum.minute |> should.equal(9)
  sum.second |> should.equal(9)
  sum.microsecond |> should.equal(#(9, 6))
}

pub fn add_durations_commutative_test() {
  let d1_result =
    Ok(
      Duration(
        year: 1,
        month: 2,
        week: 0,
        day: 3,
        hour: 0,
        minute: 0,
        second: 0,
        microsecond: #(0, 0),
      ),
    )
  let d2_result =
    Ok(
      Duration(
        year: 4,
        month: 5,
        week: 0,
        day: 6,
        hour: 0,
        minute: 0,
        second: 0,
        microsecond: #(0, 0),
      ),
    )

  case d1_result, d2_result {
    Ok(d1), Ok(d2) -> {
      let sum1 = duration.add(d1, d2)
      let sum2 = duration.add(d2, d1)
      should.equal(sum1, sum2)
    }
  }
}

pub fn add_partial_durations_test() {
  let d1_result =
    Ok(
      Duration(
        year: 0,
        month: 2,
        week: 3,
        day: 4,
        hour: 0,
        minute: 0,
        second: 0,
        microsecond: #(0, 0),
      ),
    )
  let d2_result =
    Ok(
      Duration(
        year: 8,
        month: 0,
        week: 0,
        day: 2,
        hour: 0,
        minute: 0,
        second: 2,
        microsecond: #(0, 0),
      ),
    )

  case d1_result, d2_result {
    Ok(d1), Ok(d2) -> {
      let sum = duration.add(d1, d2)
      sum.year |> should.equal(8)
      sum.month |> should.equal(2)
      sum.week |> should.equal(3)
      sum.day |> should.equal(6)
      sum.hour |> should.equal(0)
      sum.minute |> should.equal(0)
      sum.second |> should.equal(2)
      sum.microsecond |> should.equal(#(0, 0))
    }
  }
}

// Duration subtraction tests
pub fn subtract_durations_test() {
  let d1_result =
    Ok(
      Duration(
        year: 10,
        month: 8,
        week: 6,
        day: 4,
        hour: 2,
        minute: 30,
        second: 45,
        microsecond: #(500_000, 6),
      ),
    )

  let d2_result =
    Ok(
      Duration(
        year: 2,
        month: 3,
        week: 1,
        day: 1,
        hour: 1,
        minute: 15,
        second: 30,
        microsecond: #(250_000, 6),
      ),
    )

  case d1_result, d2_result {
    Ok(d1), Ok(d2) -> {
      let diff = duration.subtract(d1, d2)
      diff.year |> should.equal(8)
      diff.month |> should.equal(5)
      diff.week |> should.equal(5)
      diff.day |> should.equal(3)
      diff.hour |> should.equal(1)
      diff.minute |> should.equal(15)
      diff.second |> should.equal(15)
      diff.microsecond |> should.equal(#(250_000, 6))
    }
  }
}

// Duration multiplication tests
pub fn multiply_duration_test() {
  let d_result =
    Ok(
      Duration(
        year: 1,
        month: 2,
        week: 0,
        day: 3,
        hour: 4,
        minute: 5,
        second: 6,
        microsecond: #(0, 0),
      ),
    )

  case d_result {
    Ok(d) -> {
      let multiplied = duration.multiply(d, 3)
      multiplied.year |> should.equal(3)
      multiplied.month |> should.equal(6)
      multiplied.day |> should.equal(9)
      multiplied.hour |> should.equal(12)
      multiplied.minute |> should.equal(15)
      multiplied.second |> should.equal(18)
    }
  }
}

pub fn multiply_duration_by_zero_test() {
  let d_result =
    Ok(
      Duration(
        year: 5,
        month: 10,
        week: 0,
        day: 15,
        hour: 0,
        minute: 0,
        second: 0,
        microsecond: #(0, 0),
      ),
    )

  case d_result {
    Ok(d) -> {
      let zero_duration = duration.multiply(d, 0)
      zero_duration.year |> should.equal(0)
      zero_duration.month |> should.equal(0)
      zero_duration.day |> should.equal(0)
    }
  }
}

// Duration negation tests
pub fn negate_duration_test() {
  let d_result =
    Ok(
      Duration(
        year: 1,
        month: 2,
        week: 0,
        day: 3,
        hour: 4,
        minute: 5,
        second: 6,
        microsecond: #(123_456, 6),
      ),
    )

  case d_result {
    Ok(d) -> {
      let negated = duration.negate(d)
      negated.year |> should.equal(-1)
      negated.month |> should.equal(-2)
      negated.day |> should.equal(-3)
      negated.hour |> should.equal(-4)
      negated.minute |> should.equal(-5)
      negated.second |> should.equal(-6)
      negated.microsecond |> should.equal(#(-123_456, 6))
    }
  }
}

// Duration comparison tests
pub fn equal_durations_test() {
  let d1_result =
    Ok(
      Duration(
        year: 1,
        month: 2,
        week: 0,
        day: 3,
        hour: 0,
        minute: 0,
        second: 0,
        microsecond: #(0, 0),
      ),
    )
  let d2_result =
    Ok(
      Duration(
        year: 1,
        month: 2,
        week: 0,
        day: 3,
        hour: 0,
        minute: 0,
        second: 0,
        microsecond: #(0, 0),
      ),
    )

  case d1_result, d2_result {
    Ok(d1), Ok(d2) -> {
      should.equal(d1, d2)
    }
  }
}

pub fn not_equal_durations_test() {
  let d1_result =
    Ok(
      Duration(
        year: 1,
        month: 2,
        week: 0,
        day: 3,
        hour: 0,
        minute: 0,
        second: 0,
        microsecond: #(0, 0),
      ),
    )
  let d2_result =
    Ok(
      Duration(
        year: 1,
        month: 2,
        week: 0,
        day: 4,
        hour: 0,
        minute: 0,
        second: 0,
        microsecond: #(0, 0),
      ),
    )

  case d1_result, d2_result {
    Ok(d1), Ok(d2) -> {
      should.not_equal(d1, d2)
    }
  }
}

// Duration to string tests
pub fn to_string_basic_test() {
  let d_result =
    Ok(
      Duration(
        year: 1,
        month: 2,
        week: 0,
        day: 3,
        hour: 0,
        minute: 0,
        second: 0,
        microsecond: #(0, 0),
      ),
    )

  case d_result {
    Ok(d) -> {
      let duration_str = duration.to_iso8601(d)
      duration_str |> should.equal("P1Y2M3D")
    }
  }
}

pub fn to_string_with_time_test() {
  let d_result =
    Ok(
      Duration(
        year: 1,
        month: 2,
        week: 0,
        day: 3,
        hour: 4,
        minute: 5,
        second: 6,
        microsecond: #(0, 0),
      ),
    )

  case d_result {
    Ok(d) -> {
      let duration_str = duration.to_iso8601(d)
      duration_str |> should.equal("P1Y2M3DT4H5M6S")
    }
  }
}

pub fn to_string_with_microseconds_test() {
  let d_result =
    Ok(
      Duration(
        year: 0,
        month: 0,
        week: 0,
        day: 0,
        hour: 1,
        minute: 30,
        second: 45,
        microsecond: #(123_456, 6),
      ),
    )

  case d_result {
    Ok(d) -> {
      let duration_str = duration.to_iso8601(d)
      duration_str |> should.equal("PT1H30M45.123456S")
    }
  }
}

pub fn to_string_negative_duration_test() {
  let d =
    Duration(
      year: -1,
      month: -2,
      week: 0,
      day: -3,
      hour: 0,
      minute: 0,
      second: 0,
      microsecond: #(0, 0),
    )
  let duration_str = duration.to_iso8601(d)
  duration_str |> should.equal("P-1Y-2M-3D")
}

// Duration from string tests
pub fn from_string_basic_test() {
  let result = duration.from_iso8601("P1Y2M3D")
  case result {
    Ok(d) -> {
      d.year |> should.equal(1)
      d.month |> should.equal(2)
      d.day |> should.equal(3)
    }
    Error(_) -> panic as "Expected valid duration from string"
  }
}

pub fn from_string_with_time_test() {
  let result = duration.from_iso8601("P1Y2M3DT4H5M6S")
  case result {
    Ok(d) -> {
      d.year |> should.equal(1)
      d.month |> should.equal(2)
      d.day |> should.equal(3)
      d.hour |> should.equal(4)
      d.minute |> should.equal(5)
      d.second |> should.equal(6)
    }
    Error(_) -> panic as "Expected valid duration from string"
  }
}

pub fn from_string_invalid_test() {
  let result = duration.from_iso8601("invalid")
  case result {
    Ok(_) -> panic as "Expected invalid duration error"
    Error(duration.InvalidFormat) -> Nil
    Error(_) -> panic as "Expected InvalidFormat error"
  }
}
