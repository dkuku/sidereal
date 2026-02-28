export function system_time() {
  // Return current time in seconds since Unix epoch
  return Math.floor(Date.now() / 1000);
}