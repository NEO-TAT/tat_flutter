import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/model/course/CourseScoreJson.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/task/TaskFlow.dart';
import 'package:flutter_app/src/task/course/CourseCreditInfoTask.dart';
import 'package:flutter_app/src/task/course/CourseDepartmentTask.dart';
import 'package:flutter_app/src/task/course/CourseDivisionTask.dart';
import 'package:flutter_app/src/task/course/CourseYearTask.dart';
import 'package:flutter_app/src/task/ntutapp/NTUTAPPDepartmentTask.dart';
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
  List<String> yearList = List();
  List<Map> divisionList = List();
  List<Map> departmentList = List();
  double width;
  String _selectedYear;
  Map _selectedDivision;
  Map _selectedDepartment;
  Map<String, String> _presetDepartment;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      _addPresetTask();
    });
  }

  Future<void> _addPresetTask() async {
    TaskFlow taskFlow = TaskFlow();
    var task = NTUTAPPDepartmentTask();
    taskFlow.addTask(task);
    if (await taskFlow.start()) {
      _presetDepartment = task.result;
    }
    _addSelectTask();
  }

  Future<void> _addSelectTask() async {
    if (_presetDepartment == null) {
      _presetDepartment = Map();
    }
    await _getYearList();
    //利用學號預設學年度
    if (graduationInformation.selectYear.isEmpty) {
      graduationInformation.selectYear =
          Model.instance.getAccount().substring(0, 3);
    }
    for (String v in yearList) {
      if (v.contains(graduationInformation.selectYear)) {
        _selectedYear = v;
        break;
      }
    }
    await _getDivisionList();
    //利用北科行動助理預設學制與系所
    if (graduationInformation.selectDivision.isEmpty) {
      graduationInformation.selectDivision = _presetDepartment["division"];
    }
    for (Map v in divisionList) {
      if (v["name"].contains(graduationInformation.selectDivision)) {
        _selectedDivision = v;
        break;
      }
    }
    await _getDepartmentList();
    if (graduationInformation.selectDepartment.isEmpty) {
      graduationInformation.selectDepartment = _presetDepartment["department"];
    }
    for (Map v in departmentList) {
      if (v["name"].contains(graduationInformation.selectDepartment)) {
        _selectedDepartment = v;
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
    return divisionList
        .map(
          (val) => DropdownMenuItem(
            value: val,
            child: buildText(val["name"]),
          ),
        )
        .toList();
  }

  List<DropdownMenuItem> buildDepartmentList() {
    return departmentList
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

  Future<void> _getDivisionList() async {
    TaskFlow taskFlow = TaskFlow();
    String year = _selectedYear.split(" ")[1];
    var task = CourseDivisionTask(year);
    taskFlow.addTask(task);
    if (await taskFlow.start()) {
      divisionList = task.result;
      _selectedDivision = divisionList.first;
    }
    setState(() {});
  }

  Future<void> _getDepartmentList() async {
    TaskFlow taskFlow = TaskFlow();
    Map<String, String> code = _selectedDivision["code"];
    var task = CourseDepartmentTask(code);
    taskFlow.addTask(task);
    if (await taskFlow.start()) {
      departmentList = task.result;
      _selectedDepartment = departmentList.first;
    }
    setState(() {});
  }

  Future<void> _getCreditInfo() async {
    TaskFlow taskFlow = TaskFlow();
    Map code = _selectedDivision["code"];
    String name = _selectedDepartment["name"];
    var task = CourseCreditInfoTask(code, name);
    taskFlow.addTask(task);
    if (await taskFlow.start()) {
      graduationInformation = task.result;
      graduationInformation.selectYear = _selectedYear;
      graduationInformation.selectDivision = _selectedDivision["name"];
      graduationInformation.selectDepartment = _selectedDepartment["name"];
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
                          _getDivisionList();
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: DropdownButton(
                      isExpanded: true,
                      value: _selectedDivision,
                      items: buildDivisionList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDivision = value;
                          _getDepartmentList();
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
                      value: _selectedDepartment,
                      items: buildDepartmentList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDepartment = value;
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
                  FlatButton(
                    child: Text(R.current.cancel),
                    onPressed: () {
                      _cancel();
                    },
                  ),
                  FlatButton(
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
