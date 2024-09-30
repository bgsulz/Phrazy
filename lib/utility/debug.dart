import 'package:flutter/foundation.dart';

void debug(String string) {
  if (kDebugMode) {
    print(string);
  }
}
