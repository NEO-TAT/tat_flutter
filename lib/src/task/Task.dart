enum TaskStatus { Success, GiveUp, Restart }

abstract class Task<T> {
  late final T result;
  late final String name;

  Task(this.name, {Map<String, dynamic>? arg});

  Future<TaskStatus> execute();
}
