enum AppSmsStatus { pending, sending, sent, failed }

class SmsRow {
  final int index;
  final String number;
  final String? name; 
  final String? service;
  final String? location;
  final String? country;
  final String? tasdekFrom;
  final String? tasdekTo;
  
  AppSmsStatus status;
  String? error;
  
  // Computed final message after template application
  String? _finalMessage;

  SmsRow({
    required this.index,
    required this.number,
    this.name,
    this.service,
    this.location,
    this.country,
    this.tasdekFrom,
    this.tasdekTo,
    this.status = AppSmsStatus.pending,
    this.error,
  });

  // Calculate message based on template
  String getFormattedMessage(String template) {
    if (status == AppSmsStatus.sent && _finalMessage != null) {
       return _finalMessage!; // Return preserved message if already sent
    }
    
    String msg = template;
    // Standardize replacements to match user request: ${Name}, ${country}, etc.
    // Also keeping {name} for backward compat or flexibility if user types it.
    
    // Name
    msg = msg.replaceAll(RegExp(r'\{name\}|\$\{Name\}', caseSensitive: false), name ?? '');
    
    // Service
    msg = msg.replaceAll(RegExp(r'\{service\}|\$\{service\}', caseSensitive: false), service ?? '');
    
    // Location
    msg = msg.replaceAll(RegExp(r'\{location\}|\$\{location\}', caseSensitive: false), location ?? '');

    // Country
    msg = msg.replaceAll(RegExp(r'\{country\}|\$\{country\}', caseSensitive: false), country ?? '');

    // Tasdek Dates
    msg = msg.replaceAll(RegExp(r'\{tasdek_from\}|\$\{tasdek_from\}', caseSensitive: false), tasdekFrom ?? '');
    msg = msg.replaceAll(RegExp(r'\{tasdek_to\}|\$\{tasdek_to\}', caseSensitive: false), tasdekTo ?? '');

    msg = msg.replaceAll(RegExp(r'\{tasdek_to\}|\$\{tasdek_to\}', caseSensitive: false), tasdekTo ?? '');

    // Append mandatory link
    // msg += "\nhttps://tagned.mod.gov.eg/16militaryservice.aspx";

    return msg;
  }
  
  void setFinalMessage(String msg) {
      _finalMessage = msg;
  }
  
  String? get finalMessage => _finalMessage;
  
  // Helper to convert to Map for export
  Map<String, dynamic> toMap() {
    return {
      'index': index,
      'number': number,
      'name': name,
      'service': service,
      'location': location,
      'country': country,
      'error': error,
    };
  }
}
