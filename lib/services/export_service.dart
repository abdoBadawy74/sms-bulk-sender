import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import '../models/sms_row.dart';

class ExportService {
  Future<String> createFailedSheet(List<SmsRow> failedRows) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1']; // default sheet
    
    // Header
    sheetObject.appendRow([
        TextCellValue('Index'), 
        TextCellValue('Number'), 
        TextCellValue('Name'), 
        TextCellValue('Service'), 
        TextCellValue('Location'),
        TextCellValue('Country'),
        TextCellValue('Error')
    ]);
    
    // Data
    for (var row in failedRows) {
        sheetObject.appendRow([
            IntCellValue(row.index),
            TextCellValue(row.number),
            TextCellValue(row.name ?? ''),
            TextCellValue(row.service ?? ''),
            TextCellValue(row.location ?? ''),
            TextCellValue(row.country ?? ''),
            TextCellValue(row.error ?? 'Unknown Error'),
        ]);
    }
    
    // Save
    Directory? directory;
    if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory(); // App-specific folder
    } else {
        directory = await getApplicationDocumentsDirectory();
    }
    
    String path = "${directory!.path}/failed_numbers_${DateTime.now().millisecondsSinceEpoch}.xlsx";
    var fileBytes = excel.save();
    
    File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes!);
      
    return path;
  }
}
