class AttendanceModel {
  final String id;
  final String date;
  final String checkIn;
  final String? checkOut;
  final DateTime createdAt;
  final Map? checkInLocation;
  final Map? checkOutLocation;
  final String? checkIn2;
  final String? checkOut2;
 final Map? checkInLocation2;
 final Map? checkOutLocation2;
  final String? obra;
  final String? obra2;
  final String? usuario;

  AttendanceModel({
    required this.id,
    required this.date,
    required this.checkIn,
    this.checkOut,
    required this.createdAt,
    this.checkInLocation,
    this.checkOutLocation,
    this.checkIn2,
    this.checkOut2,
   this.checkInLocation2,
   this.checkOutLocation2,
    this.obra,
    this.obra2,
    this.usuario
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> data) {
    return AttendanceModel(
      id: data['employee_id'],
      date: data['date'],
      checkIn: data['check_in'],
      checkOut: data['check_out'],
      createdAt: DateTime.parse(data['created_at']),
      checkInLocation: data['check_in_location'],
      checkOutLocation: data['check_out_location'],
      checkIn2: data['check_in2'],
      checkOut2: data['check_out2'],
      checkInLocation2: data['check_in_location2'],
      checkOutLocation2: data['check_out_location2'],
      obra: data['obraid'],
      obra2: data['obraid2'],
      usuario: data['nombre_asis'],
    );
  }
}
