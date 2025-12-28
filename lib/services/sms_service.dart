import 'dart:async';
import 'package:background_sms/background_sms.dart';
import '../models/sms_row.dart';
import 'log_service.dart';

class SmsService {
  final LogService _logService;
  
  // Job configuration
  int batchSize = 10;
  int delaySeconds = 2;
  int pauseAfterBatchSeconds = 10;
  
  bool _isStopping = false;
  
  SmsService(this._logService);

  void stop() {
    _isStopping = true;
  }

  Future<void> sendBatch(
    List<SmsRow> rows, {
    Function(int index, SmsRow row)? onRowUpdate,
    Function(int sent, int failed)? onProgress,
  }) async {
    _isStopping = false;
    int sentCount = 0;
    int failedCount = 0;
    
    int processedInBatch = 0;

    for (int i = 0; i < rows.length; i++) {
        if (_isStopping) break;
        
        final row = rows[i];
        if (row.status == AppSmsStatus.sent) continue; 
        
        row.status = AppSmsStatus.sending;
        onRowUpdate?.call(i, row);
        
        String messageToSend = row.finalMessage ?? "Error: No message content";

        bool success = await sendSingle(row, messageToSend);
        
        if (success) {
            row.status = AppSmsStatus.sent;
            sentCount++;
            await _logService.log(row.number, messageToSend, "SENT");
        } else {
            row.status = AppSmsStatus.failed;
            failedCount++;
            await _logService.log(row.number, messageToSend, "FAILED", error: row.error);
        }
        
        onRowUpdate?.call(i, row);
        onProgress?.call(sentCount, failedCount);
        
        processedInBatch++;
        
        if (i < rows.length - 1) {
            if (processedInBatch >= batchSize) {
                processedInBatch = 0; 
                await Future.delayed(Duration(seconds: pauseAfterBatchSeconds));
            } else {
                await Future.delayed(Duration(seconds: delaySeconds));
            }
        }
    }
  }

  Future<bool> sendSingle(SmsRow row, String message) async {
    int attempts = 0;
    int maxRetries = 2; 
    
    while (attempts <= maxRetries) {
        if (_isStopping) return false;
        
        try {
            // BackgroundSms.sendMessage returns SmsStatus
            SmsStatus result = await BackgroundSms.sendMessage(
                phoneNumber: row.number, 
                message: message,
            );
            
            if (result == SmsStatus.sent) {
                return true;
            } else {
                throw Exception("Start sending failed, status: $result");
            }
        } catch (e) {
            attempts++;
            String errorMsg = e.toString();
            row.error = errorMsg;
            if (attempts > maxRetries) return false;
            await Future.delayed(Duration(seconds: 2 * attempts));
        }
    }
    return false;
  }
}
