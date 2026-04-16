import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_palette.dart';
import '../core/utils/profile_utils.dart';

Future<DateTime?> showBirthDatePickerDialog({
  required BuildContext context,
  DateTime? initialDate,
}) {
  return showDialog<DateTime>(
    context: context,
    builder: (_) => _BirthDatePickerDialog(initialDate: initialDate),
  );
}

class _BirthDatePickerDialog extends StatefulWidget {
  const _BirthDatePickerDialog({required this.initialDate});

  final DateTime? initialDate;

  @override
  State<_BirthDatePickerDialog> createState() => _BirthDatePickerDialogState();
}

class _BirthDatePickerDialogState extends State<_BirthDatePickerDialog> {
  late DateTime _selectedDate;
  late TextEditingController _controller;
  bool _inputMode = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = _safeInitialDate(widget.initialDate);
    _controller = TextEditingController(
      text: formatBirthDateDisplay(_selectedDate),
    );
  }

  DateTime _safeInitialDate(DateTime? date) {
    if (date != null && isBirthDateInAllowedRange(date)) {
      return DateTime(date.year, date.month, date.day);
    }
    final max = birthDateMax();
    final suggested = DateTime(max.year - 18, max.month, max.day);
    if (isBirthDateInAllowedRange(suggested)) {
      return suggested;
    }
    return max;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  DateTime? get _typedDate => parseBirthDate(_controller.text);

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide:
          BorderSide(color: AppPalette.color300.withValues(alpha: 0.45)),
    );

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
      title: Row(
        children: [
          const Expanded(child: Text('Birthday')),
          IconButton(
            tooltip: _inputMode ? 'Show calendar' : 'Type date',
            onPressed: () {
              setState(() {
                if (_inputMode && _typedDate != null) {
                  _selectedDate = _typedDate!;
                } else if (!_inputMode) {
                  _controller.text = formatBirthDateDisplay(_selectedDate);
                }
                _inputMode = !_inputMode;
              });
            },
            icon: Icon(
                _inputMode ? Icons.calendar_month_rounded : Icons.edit_rounded),
          ),
        ],
      ),
      content: SizedBox(
        width: 360,
        child: _inputMode
            ? TextField(
                controller: _controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  BirthDateTextInputFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'Birthday',
                  hintText: 'dd/mm/yyyy',
                  errorText: _controller.text.isEmpty || _typedDate != null
                      ? null
                      : 'Please enter a valid date',
                  filled: true,
                  fillColor: AppPalette.color100.withValues(alpha: 0.12),
                  border: border,
                  enabledBorder: border,
                  focusedBorder: border.copyWith(
                    borderSide: const BorderSide(
                        color: AppPalette.color500, width: 1.4),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              )
            : CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: birthDateMin(),
                lastDate: birthDateMax(),
                onDateChanged: (date) {
                  setState(() {
                    _selectedDate = date;
                    _controller.text = formatBirthDateDisplay(date);
                  });
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _inputMode
              ? (_typedDate == null
                  ? null
                  : () => Navigator.of(context).pop(_typedDate))
              : () => Navigator.of(context).pop(_selectedDate),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
