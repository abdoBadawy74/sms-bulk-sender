import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class LogService {
  File? _logFile;

  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    // One log file per session or append? 
    // User Requirement: "Save a simple log file... Provide an Export Log button".
    // We'll append to a single file "sms_log.txt" or create a new one "sms_log_TIMESTAMP.txt".
    // Let's use a single rolling file for simplicity or appending.
    _logFile = File('${directory.path}/sms_log.txt');
  }

  Future<void> log(String number, String message, String status, {String? error}) async {
    if (_logFile == null) await init();
    
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final entry = '[$timestamp] $number | $status | ${error ?? ""} | "${message.substring(0, message.length > 20 ? 20 : message.length)}..."\n';
    
    try {
      await _logFile!.writeAsString(entry, mode: FileMode.append);
    } catch (e) {
      print("Failed to write log: $e");
    }
  }

  Future<String> getLogPath() async {
    if (_logFile == null) await init();
    return _logFile!.path;
  }
  
  Future<String> readLogs() async {
      if (_logFile == null) await init();
      if (await _logFile!.exists()) {
          return await _logFile!.readAsString();
      }
      return "No logs yet.";
  }
}
