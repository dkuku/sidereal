# Optional Modules

This directory contains optional modules that provide additional functionality but require extra dependencies.

## gleam_time Interoperability

### Files:
- `gleam_time_interop.gleam` - Conversion functions between glcalendar types and gleam_time types
- `gleam_time_interop_test.gleam` - Tests for the interop functions

### How to use:

1. **Add gleam_time to your project dependencies:**
   ```toml
   [dependencies]
   gleam_stdlib = ">= 0.44.0 and < 2.0.0"
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
   
   // Convert our date to gleam_time format
   let our_date = date.new_unchecked(2024, 1, 15, "Calendar.ISO")
   let gleam_date = interop.date_to_gleam(our_date)
   
   // Convert timestamp to our datetime  
   let timestamp = timestamp.system_time()
   let our_datetime = interop.datetime_from_timestamp(timestamp)
   ```

### Available Conversions:

- **Date**: `date_to_gleam/1`, `date_from_gleam/1`
- **Time**: `time_to_gleam/1`, `time_from_gleam/1`  
- **DateTime/Timestamp**: `datetime_to_timestamp/1`, `datetime_from_timestamp/1`
- **NaiveDateTime**: `naive_datetime_to_gleam/1`, `naive_datetime_from_gleam/2`
- **Duration**: `duration_to_gleam/1`, `duration_from_gleam/1`
- **RFC3339**: `datetime_to_rfc3339/1`, `datetime_from_rfc3339/1`

### Why Optional?

This approach ensures that:
- ✅ Core glcalendar functionality works without any extra dependencies
- ✅ Users only install gleam_time if they need interoperability
- ✅ No dependency conflicts or forced installations
- ✅ Clean separation of concerns