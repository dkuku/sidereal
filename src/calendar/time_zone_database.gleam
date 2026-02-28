// Time zone database interface for calendar operations

pub type TimeZoneDatabase {
  TimeZoneDatabase
}

pub type TimeZoneInfo {
  TimeZoneInfo(abbreviation: String, utc_offset: Int, std_offset: Int)
}

pub type TimeZoneError {
  TimeZoneNotFound
  InvalidTimeZone
}

pub fn get_time_zone_info(
  _database: TimeZoneDatabase,
  _time_zone: String,
) -> Result(TimeZoneInfo, TimeZoneError) {
  // Default UTC timezone info
  Ok(TimeZoneInfo(abbreviation: "UTC", utc_offset: 0, std_offset: 0))
}

pub fn list_time_zones(_database: TimeZoneDatabase) -> List(String) {
  ["UTC"]
}
