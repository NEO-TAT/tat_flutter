enum TaskStatus {
  success,
  shouldGiveUp,
  shouldRestart,
  shouldIgnore,
}

abstract class Task<T> {
  Task(this.name);

  T? result;
  final String name;

  Future<TaskStatus> execute();
}
