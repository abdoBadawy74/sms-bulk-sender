# SMS Bulk Sender

A Flutter application for sending bulk SMS messages from Excel or CSV files directly from your Android device.

## Features
- **File Support**: Import contacts from `.xlsx`, `.csv`, or `.txt`.
- **Templating**: Use `{name}` in your message to personalize it from the file.
- **Batching & Delays**: Configure batch size, delay between messages, and pause duration between batches to avoid carrier spam triggers.
- **Retry Logic**: Automatically retries failed messages.
- **Logging**: Tracks sent/failed status and exports logs to a file.
- **Material 3 Design**: Clean, responsive UI with Arabic/English labels.

## Prerequisites
- **Flutter SDK**: [Install Flutter](https://docs.flutter.dev/get-started/install/windows)
- **Android Device**: Connected via USB with Developer Mode enabled.
- **Target OS**: Android 13 (API 33) or higher recommended.

## Setup & Run

1. **Get dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run on device (Debug)**:
   ```bash
   flutter run
   ```

3. **Build Release APK**:
   ```bash
   flutter build apk --release
   ```
   The APK will be located at: `build/app/outputs/flutter-apk/app-release.apk`

## Input File Format

### CSV (comma separated)
```csv
number,message,name
+1234567890,Hello {name},John
0987654321,Test msg,Jane
```

### Excel (.xlsx)
- **Column A**: Phone Number (required)
- **Column B**: Message (optional, overrides default)
- **Column C**: Name (optional, for `{name}` placeholder)

*An example file is provided at `assets/examples/numbers.csv`.*

## Important Notes

### SMS Limits & Default App
Android limits the number of SMS messages an app can send in the background to prevent abuse. If you are sending many messages:
- You may need to set this app as the **Default SMS App** temporarily.
- If prompted by the system "Allow app to send X messages?", you must approve it.
- **Cost Warning**: Standard carrier SMS rates apply.

### Permissions
The app requires `SEND_SMS`, `READ_PHONE_STATE`, and sometimes storage permissions. Grant them when prompted.

## Troubleshooting

### Build Errors (Gradle / Namespace)
If `flutter build` fails with `Namespace not specified` or generic `AssemblerRelease` errors:
1. **Open in Android Studio**: Open the `android/` folder in Android Studio.
2. **Sync Project**: Let Gradle sync. It will often auto-fix namespace issues or provide a one-click solution.
3. **Upgrade AGP**: If suggested by Android Studio, upgrade the Android Gradle Plugin.
4. **Clean**: Run `flutter clean` then `flutter pub get`.

### Dependency Conflicts
If `another_telephony` causes issues, try downgrading to `0.2.1` or checking for a newer version on pub.dev. The current setup uses `^0.4.1` to support Dart 3+ but local Gradle versions vary.

### File Loading Issues
- Ensure CSV is UTF-8 encoded.
- Ensure the file is not open in Excel on your computer while transferring.

### Sending Stops
- Check if you ran out of credit.
- Check if the system put the app to sleep (keep screen on or disable battery optimization).
