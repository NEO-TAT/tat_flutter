// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
enum TaskStatus { success, giveUp, restart }

abstract class Task<T> {
  T result;
  String name;

  Task(this.name, {Map<String, dynamic> arg});

  Future<TaskStatus> execute();
}
