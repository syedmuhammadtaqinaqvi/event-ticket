/// Drives lookup error footnotes — avoids mixing "not found" and "wrong device" copy.
enum LookupErrorKind {
  none,
  validation,
  notFound,
  wrongDevice,
  checkedIn,
  network,
  generic,
}
