import 'src/main_stub.dart'
  // ignore: uri_does_not_exist
  if (dart.library.html) 'src/main_web.dart'
  // ignore: uri_does_not_exist
  if (dart.library.io) 'src/main_io.dart';

/// Universal router for platform specific entry point
void main() =>
  runner();