import 'package:flutter/material.dart';

class NumberPickerDialog extends StatefulWidget {
  final int minValue;
  final int maxValue;
  final int initialValue;

  const NumberPickerDialog({
    Key? key,
    required this.minValue,
    required this.maxValue,
    required this.initialValue,
  }) : super(key: key);

  @override
  _NumberPickerDialogState createState() => _NumberPickerDialogState();
}

class _NumberPickerDialogState extends State<NumberPickerDialog> {
  late int _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Progress'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: _currentValue > widget.minValue
                    ? () => setState(() => _currentValue--)
                    : null,
                color: const Color(0xFF667eea),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFe5e7eb)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _currentValue.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: _currentValue < widget.maxValue
                    ? () => setState(() => _currentValue++)
                    : null,
                color: const Color(0xFF667eea),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_currentValue}/${widget.maxValue} units completed',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _currentValue),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667eea),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Update'),
        ),
      ],
    );
  }
}