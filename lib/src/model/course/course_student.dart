class CourseStudent {
  final String department;
  final String id;
  final String name;

  CourseStudent.origin()
      : department = "",
        id = "",
        name = "";
  CourseStudent({required this.department, required this.id, required this.name});
}
