enum TaskStatus { Success, GiveUp, Restart }

abstract class Task<T> {
  T result;
  String name;

  Task(this.name, {Map<String, dynamic> arg});

  Future<TaskStatus> execute();
}
