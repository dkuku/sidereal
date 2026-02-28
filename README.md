# sidereal

[![Package Version](https://img.shields.io/hexpm/v/sidereal)](https://hex.pm/packages/sidereal)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/sidereal/)

A comprehensive calendar library for Gleam, providing robust date, time, and datetime operations with full ISO 8601 support. Ported from Elixir's `Calendar` modules.

> **sidereal** /saɪˈdɪəriəl/ — *of or relating to the stars.* Sidereal time is the ancient
> astronomical method of measuring time by the apparent motion of the stars rather than
> the Sun. Just as astronomers rely on the stars for precise timekeeping, this library
> provides precise and complete date, time, and datetime operations for Gleam.

## Installation

```sh
gleam add sidereal@1
```

## Quick Start

```gleam
import calendar/date
import calendar/time
import calendar/datetime
import calendar/duration

pub fn main() {
  // Create and validate dates
  let assert Ok(d) = date.new_simple(2024, 12, 25)

  // Work with time (microsecond precision)
  let assert Ok(t) = time.new_simple(14, 30, 0)

  // Combine into a UTC datetime
  let assert Ok(dt) = datetime.new_utc_simple(2024, 12, 25, 14, 30, 0)

  // Parse ISO 8601 strings
  let assert Ok(d2) = date.from_iso8601("2024-06-15")

  // Date arithmetic
  let assert Ok(tomorrow) = date.add_days(d, 1)
  let diff = date.diff(d, d2)

  // Durations with ISO 8601 support
  let assert Ok(dur) = duration.from_iso8601("P1Y2M3DT4H5M6S")
  let assert Ok(shifted) = date.shift(d, dur)
}
```

## Features

- **Date Operations**: Creation, validation, arithmetic, and formatting
- **Time Handling**: Precise time with microsecond support
- **DateTime Management**: Combined date and time with timezone awareness
- **Naive DateTime**: DateTime without timezone for local representations
- **Duration Arithmetic**: Add, subtract, multiply, and parse time durations
- **ISO 8601 Support**: Full parsing and formatting compliance
- **Date Ranges**: Iterate over date sequences with custom steps
- **Type Safety**: Comprehensive error handling with Result types
- **Zero Dependencies**: Only requires `gleam_stdlib`
- **Cross-Platform**: Works on both Erlang and JavaScript targets

## Core Modules

- `calendar/date` - Date creation, validation, arithmetic, and formatting
- `calendar/time` - Time handling with microsecond precision
- `calendar/datetime` - Combined date and time with timezone support
- `calendar/naive_datetime` - DateTime without timezone awareness
- `calendar/duration` - Duration arithmetic with ISO 8601 parsing
- `calendar/iso` - ISO 8601 calendar system utilities
- `calendar/date_range` - Date range iteration and membership

## Optional gleam_time Interoperability

This library provides **optional** interoperability with the `gleam_time` package for users who need it.

### Core Library Works Independently

- All calendar functions work without any additional dependencies
- No compilation errors or runtime dependencies on gleam_time
- Self-contained — use sidereal with just `gleam_stdlib`

### How to Add Interop (Optional)

1. **Add gleam_time to your project:**
   ```toml
   [dependencies]
   gleam_time = ">= 1.0.0 and < 2.0.0"
   ```

2. **Copy the interop module to your project:**
   ```bash
   cp optional_modules/gleam_time_interop.gleam src/calendar/
   ```

3. **Use the conversion functions:**
   ```gleam
   import calendar/date
   import calendar/gleam_time_interop as interop
   import gleam/time/timestamp

   let assert Ok(our_date) = date.new_simple(2024, 1, 15)
   let gleam_date = interop.date_to_gleam(our_date)

   let timestamp = timestamp.system_time()
   let our_datetime = interop.datetime_from_timestamp(timestamp)
   ```

### Available Conversions

- **Date**: `date_to_gleam`, `date_from_gleam`
- **Time**: `time_to_gleam`, `time_from_gleam`
- **DateTime/Timestamp**: `datetime_to_timestamp`, `datetime_from_timestamp`
- **NaiveDateTime**: `naive_datetime_to_gleam`, `naive_datetime_from_gleam`
- **Duration**: `duration_to_gleam`, `duration_from_gleam`

## Documentation

Further documentation can be found at <https://hexdocs.pm/sidereal>.

## Development

```sh
gleam test  # Run the tests
gleam build # Build the project
```

## Acknowledgements

This library is a Gleam port of Elixir's `Calendar` modules. The date/time algorithms and API design are derived from the work of the Elixir Team and Plataformatec.

## License

Apache License 2.0
