import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tat/src/R.dart';
import 'package:tat/src/model/course/course_score_json.dart';
import 'package:tat/src/store/model.dart';
import 'package:tat/src/task/course/course_credit_info_task.dart';
import 'package:tat/src/task/course/course_department_task.dart';
import 'package:tat/src/task/course/course_division_task.dart';
import 'package:tat/src/task/course/course_year_task.dart';
import 'package:tat/src/task/task_flow.dart';

class GraduationPicker {
  late final GraduationPickerWidget _dialog;
  late final BuildContext _dismissingContext;
  bool _barrierDismissible = true;
  bool _isShowing = false;

  GraduationPicker(BuildContext context, {bool? isDismissible}) {
    _barrierDismissible = isDismissible ?? _barrierDismissible;
  }

  bool isShowing() {
    return _isShowing;
  }

  void dismiss() {
    if (_isShowing) {
      try {
        _isShowing = false;
        if (Navigator.of(_dismissingContext).canPop()) {
          Navigator.of(_dismissingContext).pop();
        }
      } catch (_) {}
    }
  }

  Future<bool> hide() {
    if (_isShowing) {
      try {
        _isShowing = false;
        Navigator.of(_dismissingContext).pop(true);
        return Future.value(true);
      } catch (_) {
        return Future.value(false);
      }
    } else {
      return Future.value(false);
    }
  }

  Future<bool> show(Function(GraduationInformationJson) finishCallBack) async {
    if (!_isShowing) {
      try {
        _dialog = GraduationPickerWidget();
        Get.dialog<GraduationInformationJson>(
          WillPopScope(
            onWillPop: () async => _barrierDismissible,
            child: Dialog(
                insetAnimationDuration: Duration(milliseconds: 100),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
                child: _dialog),
          ),
          barrierDismissible: false,
        ).then(
          (value) {
            finishCallBack(value!);
          },
        );
        // Delaying the function for 200 milliseconds
        // [Default transitionDuration of DialogRoute]
        await Future.delayed(Duration(milliseconds: 200));
        _isShowing = true;
        return true;
      } catch (_) {
        return false;
      }
    } else {
      return false;
    }
  }
}

class GraduationPickerWidget extends StatefulWidget {
  @override
  _GraduationPickerWidget createState() => _GraduationPickerWidget();
}

class _GraduationPickerWidget extends State<GraduationPickerWidget> {
  late GraduationInformationJson graduationInformation = GraduationInformationJson();
  late List<String> yearList = [];
  late List<Map> matrixList = [];
  late List<Map> divisionList = [];
  late double width;
  late String _selectedYear;
  late Map _selectedMatrix;
  late Map _selectedDivision;

  @override
  void initState() {
    super.initState();
    _addSelectTask();
  }

  Future<void> _addSelectTask() async {
    await _getYearList();
    for (final v in yearList) {
      if (v.contains(RegExp.escape(graduationInformation.selectYear!))) {
        _selectedYear = v;
        break;
      }
    }
    await _getMatrixList();
    for (final v in matrixList) {
      if (v["code"]["matric"] == graduationInformation.selectMatrix) {
        _selectedMatrix = v;
        break;
      }
    }
    await _getDivisionList();
    for (final v in divisionList) {
      if (v["code"]["division"] == graduationInformation.selectDivision) {
        _selectedDivision = v;
        break;
      }
    }
    await _getCreditInfo();
    setState(() {});
  }

  Widget buildText(String title) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Text(title, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  List<DropdownMenuItem<String>> buildYearList() {
    return yearList
        .map(
          (val) => DropdownMenuItem(
            value: val,
            child: buildText(val),
          ),
        )
        .toList();
  }

  List<DropdownMenuItem> buildDivisionList() {
    return matrixList
        .map(
          (val) => DropdownMenuItem(
            value: val,
            child: buildText(val["name"]!),
          ),
        )
        .toList();
  }

  List<DropdownMenuItem> buildDepartmentList() {
    return divisionList
        .map(
          (val) => DropdownMenuItem(
            value: val,
            child: buildText(val["name"]),
          ),
        )
        .toList();
  }

  Future<void> _getYearList() async {
    final taskFlow = TaskFlow();
    final task = CourseYearTask();
    taskFlow.addTask(task);
    if (await taskFlow.start()) {
      yearList = task.result;
      _selectedYear = yearList.first;
    }
    print(_selectedYear);
    setState(() {});
  }

  Future<void> _getMatrixList() async {
    final taskFlow = TaskFlow();
    final year = _selectedYear.split(" ")[1];
    final task = CourseDivisionTask(year);
    taskFlow.addTask(task);
    if (await taskFlow.start()) {
      matrixList = task.result;
      _selectedMatrix = matrixList.first;
    }
    setState(() {});
  }

  Future<void> _getDivisionList() async {
    final taskFlow = TaskFlow();
    final code = _selectedMatrix["code"];
    final task = CourseDepartmentTask(code);
    taskFlow.addTask(task);
    if (await taskFlow.start()) {
      divisionList = task.result;
      _selectedDivision = divisionList.first;
    }
    setState(() {});
  }

  Future<void> _getCreditInfo() async {
    final taskFlow = TaskFlow();
    final matricCode = _selectedMatrix["code"];
    final divisionName = _selectedDivision["code"];
    final task = CourseCreditInfoTask(matricCode, divisionName);
    taskFlow.addTask(task);
    if (await taskFlow.start()) {
      graduationInformation = task.result;
      graduationInformation.selectYear = _selectedYear;
      graduationInformation.selectMatrix = _selectedMatrix["code"]['matric'];
      graduationInformation.selectDivision = _selectedDivision["code"]['division'];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width * 0.8;
    return Container(
      width: width,
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  R.current.graduationSetting,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedYear,
                      items: buildYearList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedYear = value as String;
                          _getMatrixList();
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: DropdownButton<dynamic>(
                      isExpanded: true,
                      value: _selectedMatrix,
                      items: buildDivisionList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMatrix = value;
                          _getDivisionList();
                        });
                      },
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: DropdownButton<dynamic>(
                      isExpanded: true,
                      value: _selectedDivision,
                      items: buildDepartmentList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDivision = value;
                        });
                        _getCreditInfo();
                      },
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: Text(R.current.cancel),
                    onPressed: () {
                      _cancel();
                    },
                  ),
                  TextButton(
                    child: Text(R.current.save),
                    onPressed: () {
                      _save();
                    },
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  void _save() {
    _returnValue();
  }

  void _cancel() {
    graduationInformation = Model.instance.getGraduationInformation();
    _returnValue();
  }

  void _returnValue() {
    Get.back(result: graduationInformation);
  }
}
