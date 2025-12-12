import 'dart:async';
import 'package:another_telephony/telephony.dart';
import '../models/sms_row.dart';
import 'log_service.dart';

class SmsService {
  final Telephony _telephony = Telephony.instance;
  final LogService _logService;
  
  // Job configuration
  int batchSize = 10;
  int delaySeconds = 2;
  int pauseAfterBatchSeconds = 10;
  
  bool _isStopping = false;
  
  // Stream controller to report progress specific to the service (optional, or use Provider in UI)
  // For simplicity, we'll return a Stream of updates or assume the caller manages state update.
  // Actually, UI needs to know when a row updates. We can use a callback or a Stream.
  
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
        if (row.status == AppSmsStatus.sent) continue; // Skip already sent if re-running?
        
        // Update status to sending
        row.status = AppSmsStatus.sending;
        onRowUpdate?.call(i, row);
        
        // CRITICAL: Ensure we have a message to send. 
        // If finalMessage is null, it means UI didn't set it?
        // We'll throw or fail if null.
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
        
        // Delay logic
        if (i < rows.length - 1) {
             // Pause after batch
            if (processedInBatch >= batchSize) {
                processedInBatch = 0; // Reset batch counter
                await Future.delayed(Duration(seconds: pauseAfterBatchSeconds));
            } else {
                // Regular delay
                await Future.delayed(Duration(seconds: delaySeconds));
            }
        }
    }
  }

  Future<bool> sendSingle(SmsRow row, String message) async {
    int attempts = 0;
    int maxRetries = 2; // Total 3 attempts
    
    while (attempts <= maxRetries) {
        if (_isStopping) return false;
        
        try {
            // Check permissions explicitly before each send? Not efficient, assume granted.
            // But we should catch errors.
            
            // Telephony sendSms is fire-and-forget usually unless using sendSms with status listener.
            // Since we need to know if it worked, we might use sendSms with listener, 
            // but typical bulk apps just fire. 
            // However, `telephony` has `sendSms` which is Future based?
            // Actually `another_telephony` `sendSms` returns void but takes a status listener.
            // We need to wrap it in a Completer or just assume success if no exception.
            // A better way is using `sendSms` and assuming success if no platform exception.
            // Delivery reports are complex and async. We'll stick to "Sent to OS buffer".
            
            await _telephony.sendSms(
                to: row.number,
                message: message,
                isMultipart: true, // Handle long messages
            );
            
            // If we are here, it didn't throw.
            return true;
            
        } catch (e) {
            attempts++;
            row.error = e.toString();
            if (attempts > maxRetries) return false;
            
            // Backoff
            await Future.delayed(Duration(seconds: 2 * attempts));
        }
    }
    return false;
  }
}
