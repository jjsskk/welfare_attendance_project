import 'package:flutter/material.dart';

class Calender extends StatefulWidget {
  const Calender({Key? key, this.restorationId, required this.selectedcalender})
      : super(key: key);
  final String? restorationId;
  final Function(String text) selectedcalender;

  @override
  State<Calender> createState() => _CalenderState();
}

class _CalenderState extends State<Calender> with RestorationMixin {
  @override
  String? get restorationId => widget.restorationId;

  final RestorableDateTime _selectedDate =
      RestorableDateTime(DateTime(2023, 4, 11));
  late final RestorableRouteFuture<DateTime?> _restorableDatePickerRouteFuture =
      RestorableRouteFuture<DateTime?>(
    onComplete: _selectDate,
    onPresent: (NavigatorState navigator, Object? arguments) {
      return navigator.restorablePush(
        _datePickerRoute,
        arguments: _selectedDate.value.millisecondsSinceEpoch,
      );
    },
  );

  static Route<DateTime> _datePickerRoute(
    BuildContext context,
    Object? arguments,
  ) {
    return DialogRoute<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return DatePickerDialog(
          restorationId: 'date_picker_dialog',
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: DateTime.fromMillisecondsSinceEpoch(arguments! as int),
          firstDate: DateTime(1950),
          lastDate: DateTime(2024),
        );
      },
    );
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedDate, 'selected_date');
    registerForRestoration(
        _restorableDatePickerRouteFuture, 'date_picker_route_future');
  }

  void _selectDate(DateTime? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(() {
        _selectedDate.value = newSelectedDate;
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //   content: Text(
        //       'Selected: ${_selectedDate.value.day}/${_selectedDate.value.month}/${_selectedDate.value.year}'),
        // ));
        widget.selectedcalender(
            '${_selectedDate.value.year}/${_selectedDate.value.month}/${_selectedDate.value.day}');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120.0,
      child: ElevatedButton(
        onPressed: () {
          _restorableDatePickerRouteFuture.present();
        },
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_month),
              SizedBox(width: 4.0),
              Text('달력'),
            ],
          ),
        ),
      ),
    );
  }
}
