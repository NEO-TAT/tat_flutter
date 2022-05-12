import 'package:flutter/material.dart';
import 'package:flutter_app/src/model/ntut/ntut_calendar_json.dart';
import 'package:flutter_app/src/r.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sprintf/sprintf.dart';

class CalendarDetailDialog extends StatefulWidget {
  final NTUTCalendarJson calendarDetail;

  const CalendarDetailDialog({Key key, this.calendarDetail}) : super(key: key);

  @override
  State<CalendarDetailDialog> createState() => _CalendarDetailDialogState();
}

class _CalendarDetailDialogState extends State<CalendarDetailDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Text(
          widget.calendarDetail.calTitle,
          textAlign: TextAlign.center,
        ),
      ),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time),
              const SizedBox(
                width: 4,
              ),
              Expanded(
                child: Text(sprintf("%s-%s", [
                  DateFormat.yMMMd().format(widget.calendarDetail.startTime),
                  DateFormat.yMMMd().format(widget.calendarDetail.endTime)
                ])),
              )
            ],
          ),
          const SizedBox(
            height: 6,
          ),
          Row(
            children: [
              const Icon(Icons.person_outline),
              const SizedBox(
                width: 4,
              ),
              Expanded(
                child: Text(widget.calendarDetail.creatorName),
              )
            ],
          ),
          const SizedBox(
            height: 6,
          ),
          if (widget.calendarDetail.calContent.isNotEmpty)
            Row(
              children: [
                const Icon(Icons.info),
                const SizedBox(
                  width: 4,
                ),
                Expanded(
                  child: Text(widget.calendarDetail.calContent),
                )
              ],
            ),
        ],
      ),
      actions: [
        TextButton(
          child: Text(R.current.sure),
          onPressed: () async {
            Get.back();
          },
        ),
      ],
    );
  }
}
