import calendar/time_zone_database
import gleam/list
import gleeunit
import gleeunit/should

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn get_time_zone_info_utc_test() {
  let db = time_zone_database.TimeZoneDatabase
  let result = time_zone_database.get_time_zone_info(db, "Etc/UTC")
  case result {
    Ok(info) -> {
      info.abbreviation |> should.equal("UTC")
      info.utc_offset |> should.equal(0)
      info.std_offset |> should.equal(0)
    }
    Error(_) -> panic as "Expected UTC timezone info"
  }
}

pub fn get_time_zone_info_any_zone_test() {
  // Current implementation returns UTC for any zone
  let db = time_zone_database.TimeZoneDatabase
  let result = time_zone_database.get_time_zone_info(db, "America/New_York")
  case result {
    Ok(info) -> {
      info.abbreviation |> should.equal("UTC")
    }
    Error(_) -> panic as "Expected timezone info"
  }
}

pub fn list_time_zones_test() {
  let db = time_zone_database.TimeZoneDatabase
  let zones = time_zone_database.list_time_zones(db)
  zones |> should.equal(["UTC"])
  list.length(zones) |> should.equal(1)
}
