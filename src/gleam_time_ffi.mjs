export function system_time() {
  // Return [0, total_nanoseconds] to match the Erlang FFI format
  const now = Date.now();
  const nanoseconds = now * 1_000_000;
  return [0, nanoseconds];
}

export function local_time_offset_seconds() {
  return new Date().getTimezoneOffset() * -60;
}