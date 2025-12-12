import 'package:flutter/material.dart';
import '../models/sms_row.dart';
import '../services/sms_service.dart';

class MessagePreviewDialog extends StatefulWidget {
  final SmsRow row;
  final String template;
  final SmsService smsService;

  const MessagePreviewDialog({
    super.key,
    required this.row,
    required this.template,
    required this.smsService,
  });

  @override
  State<MessagePreviewDialog> createState() => _MessagePreviewDialogState();
}

class _MessagePreviewDialogState extends State<MessagePreviewDialog> {
  bool _isSending = false;
  late String _finalMessage;

  @override
  void initState() {
    super.initState();
    _finalMessage = widget.row.getFormattedMessage(widget.template);
  }

  Future<void> _sendNow() async {
    setState(() => _isSending = true);
    
    // Update local row logic if needed, but service handles logging
    bool success = await widget.smsService.sendSingle(widget.row, _finalMessage);
    
    if (mounted) {
      setState(() => _isSending = false);
      if (success) {
          widget.row.status = AppSmsStatus.sent;
          widget.row.setFinalMessage(_finalMessage); // Persist
          Navigator.pop(context, true); // Return success
      } else {
          widget.row.status = AppSmsStatus.failed;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to send")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("${widget.row.name ?? 'No Name'} (${widget.row.number})"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Draft Message:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.shade300)
            ),
            child: Text(_finalMessage),
          ),
          if (widget.row.error != null) ...[
              const SizedBox(height: 8),
              Text("Last Error: ${widget.row.error}", style: const TextStyle(color: Colors.red)),
          ]
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ElevatedButton.icon(
            onPressed: _isSending ? null : _sendNow,
            icon: _isSending ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send),
            label: const Text("Send Now")
        )
      ],
    );
  }
}
