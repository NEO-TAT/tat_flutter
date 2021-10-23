import 'package:flutter/material.dart';
import 'package:tat/src/R.dart';
import 'package:tat/src/model/ntut/ntut_calendar_json.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sprintf/sprintf.dart';

class CalendarDetailDialog extends StatefulWidget {
  final NTUTCalendarJson calendarDetail;

  const CalendarDetailDialog({Key? key, required this.calendarDetail}) : super(key: key);

  @override
  _CalendarDetailDialogState createState() => _CalendarDetailDialogState();
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.access_time),
              SizedBox(
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
          SizedBox(
            height: 6,
          ),
          Row(
            children: [
              Icon(Icons.person_outline),
              SizedBox(
                width: 4,
              ),
              Expanded(
                child: Text(widget.calendarDetail.creatorName),
              )
            ],
          ),
          SizedBox(
            height: 6,
          ),
          if (widget.calendarDetail.calContent.isNotEmpty)
            Row(
              children: [
                Icon(Icons.info),
                SizedBox(
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
          onPressed: () {
            Get.back();
          },
        ),
      ],
    );
  }
}
