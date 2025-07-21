import 'package:phrazy/core/ext_ymd.dart';
import 'package:phrazy/data/web_storage/board_save.dart';
import 'package:phrazy/data/web_storage/timer_save.dart';
import 'package:phrazy/data/web_storage/web_storage.dart';

class LocalDataSource {
  void saveBoardForDate(BoardSave state, DateTime date) {
    WebStorage.saveBoardForDate(state, date.toYMD);
  }

  BoardSave? loadBoardForDate(DateTime date) {
    return WebStorage.loadBoardForDate(date.toYMD);
  }

  void saveTimeForDate(TimerSave state, DateTime date) {
    WebStorage.saveTimeForDate(state, date.toYMD);
  }

  TimerSave? loadTimeForDate(DateTime date) {
    return WebStorage.loadTimeForDate(date.toYMD);
  }
}
