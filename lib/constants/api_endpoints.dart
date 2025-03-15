class ApiEndpoints {
  static const String baseUrl = 'https://hospital-fitq.onrender.com';

  // Doctors
  static const String getDoctors = '$baseUrl/doctor/getall';
  static const String doctorLogin = '$baseUrl/doctor/login';

  // Apointme
  static const String getAppointments = '$baseUrl/appointment/get';

  // Patient Endpoints
  static const String getAllPatients = '$baseUrl/patients/getall';
  static const String editPatient = '$baseUrl/patients/edit';

  //bills Endpoints
  static const String addBills = '$baseUrl/billing/add';
  static const String getBills = '$baseUrl/billing/get';
  static const String editBills = '$baseUrl/billing/update';

  //receptionist Endpoints
  static const String recepLogin = '$baseUrl/receptionist/login';
  static const String profileGet = '$baseUrl/receptionist/profile/get';
}
