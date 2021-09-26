import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tat/src/R.dart';
import 'package:tat/src/model/course/course_score_json.dart';
import 'package:tat/src/store/model.dart';
import 'package:tat/src/task/course/course_credit_info_task.dart';
import 'package:tat/src/task/course/course_department_task.dart';
import 'package:tat/src/task/course/course_division_task.dart';
import 'package:tat/src/task/course/course_year_task.dart';
import 'package:tat/src/task/task_flow.dart';
import 'package:get/get.dart';

class GraduationPicker {
  GraduationPickerWidget _dialog;
  BuildContext _context;
  BuildContext _dismissingContext;
  bool _barrierDismissible = true;
  bool _isShowing = false;

  GraduationPicker(BuildContext context, {bool isDismissible}) {
    _context = context;
    _barrierDismissible = isDismissible ?? _barrierDismissible; //是否之支援返回關閉
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
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        child: _dialog)),
                barrierDismissible: false,
                useRootNavigator: false)
            .then((value) {
          finishCallBack(value);
        });
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
  GraduationInformationJson graduationInformation = GraduationInformationJson();
  List<String> yearList = [];
  List<Map> matricList = [];
  List<Map> divisionList = [];
  double width;
  String _selectedYear;
  Map _selectedMatric;
  Map _selectedDivision;

  @override
  void initState() {
    super.initState();
    _addSelectTask();
  }

  Future<void> _addSelectTask() async {
    await _getYearList();
    for (String v in yearList) {
      if (v.contains(graduationInformation.selectYear)) {
        _selectedYear = v;
        break;
      }
    }
    await _getMatricList();
    for (Map v in matricList) {
      if (v["code"]["matric"] == graduationInformation.selectMatric) {
        _selectedMatric = v;
        break;
      }
    }
    await _getDivisionList();
    for (Map v in divisionList) {
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
      children: <Widget>[
        Expanded(
          child: Text(title, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  List<DropdownMenuItem> buildYearList() {
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
    return matricList
        .map(
          (val) => DropdownMenuItem(
            value: val,
            child: buildText(val["name"]),
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
    TaskFlow taskFlow = TaskFlow();
    var task = CourseYearTask();
    taskFlow.addTask(task);
    if (await taskFlow.start()) {
      yearList = task.result;
      _selectedYear = yearList.first;
    }
    print(_selectedYear);
    setState(() {});
  }

  Future<void> _getMatricList() async {
    TaskFlow taskFlow = TaskFlow();
    String year = _selectedYear.split(" ")[1];
    var task = CourseDivisionTask(year);
    taskFlow.addTask(task);
    if (await taskFlow.start()) {
      matricList = task.result;
      _selectedMatric = matricList.first;
    }
    setState(() {});
  }

  Future<void> _getDivisionList() async {
    TaskFlow taskFlow = TaskFlow();
    Map<String, String> code = _selectedMatric["code"];
    var task = CourseDepartmentTask(code);
    taskFlow.addTask(task);
    if (await taskFlow.start()) {
      divisionList = task.result;
      _selectedDivision = divisionList.first;
    }
    setState(() {});
  }

  Future<void> _getCreditInfo() async {
    TaskFlow taskFlow = TaskFlow();
    Map matricCode = _selectedMatric["code"];
    Map divisionName = _selectedDivision["code"];
    var task = CourseCreditInfoTask(matricCode, divisionName);
    taskFlow.addTask(task);
    if (await taskFlow.start()) {
      graduationInformation = task.result;
      graduationInformation.selectYear = _selectedYear;
      graduationInformation.selectMatric = _selectedMatric["code"]['matric'];
      graduationInformation.selectDivision =
          _selectedDivision["code"]['division'];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    width = width * 0.8;
    return Container(
      width: width,
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
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
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: DropdownButton(
                      isExpanded: true, //裡面元素是否要Expanded
                      value: _selectedYear,
                      items: buildYearList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedYear = value;
                          _getMatricList();
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: DropdownButton(
                      isExpanded: true,
                      value: _selectedMatric,
                      items: buildDivisionList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMatric = value;
                          _getDivisionList();
                        });
                      },
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: DropdownButton(
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
                children: <Widget>[
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
