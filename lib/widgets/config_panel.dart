import 'package:flutter/material.dart';

class ConfigPanel extends StatefulWidget {
  final Function(int batchSize, int delay, int pause) onConfigChanged;
  final bool isRunning;

  const ConfigPanel({super.key, required this.onConfigChanged, required this.isRunning});

  @override
  State<ConfigPanel> createState() => _ConfigPanelState();
}

class _ConfigPanelState extends State<ConfigPanel> {
  int _batchSize = 10;
  int _delaySeconds = 2;
  int _pauseSeconds = 10;

  final List<int> _batchOptions = [5, 10, 20, 50, 100];
  final List<int> _delayOptions = [1, 2, 3, 5, 10];
  final List<int> _pauseOptions = [5, 10, 30, 60, 120];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Settings / إعدادات", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    label: "Batch Size / الدفعة",
                    value: _batchSize,
                    items: _batchOptions,
                    onChanged: (v) {
                      setState(() => _batchSize = v!);
                      _notify();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDropdown(
                    label: "Delay(s) / تأخير",
                    value: _delaySeconds,
                    items: _delayOptions,
                    onChanged: (v) {
                      setState(() => _delaySeconds = v!);
                      _notify();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDropdown(
                    label: "Pause(s) / استراحة",
                    value: _pauseSeconds,
                    items: _pauseOptions,
                    onChanged: (v) {
                      setState(() => _pauseSeconds = v!);
                      _notify();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _notify() {
    widget.onConfigChanged(_batchSize, _delaySeconds, _pauseSeconds);
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        DropdownButtonFormField<T>(
          value: value,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.toString()))).toList(),
          onChanged: widget.isRunning ? null : onChanged,
          decoration: const InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
        ),
      ],
    );
  }
}
