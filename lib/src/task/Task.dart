enum TaskStatus { Success, GiveUp, Restart }

abstract class Task<T> {
  T result; //執行結果
  Map<String, dynamic> _arg;
  String name;

  Task(this.name, {Map<String, dynamic> arg}) {
    _arg = arg;
  }

  Future<TaskStatus> execute(); //true 繼續 false 結束

}
