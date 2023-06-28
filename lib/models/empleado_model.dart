class AttendanceModel2{
  final String id;
  final String date;
  final String? usuario;

  AttendanceModel2({
    required this.id,
    required this.date,
    this.usuario
  });

  factory AttendanceModel2.fromJson(Map<String, dynamic> data) {
    return AttendanceModel2(
      id: data['employee_id'],
      date: data['date'],
      usuario: data['nombre_asis'],
    );
  }
}
