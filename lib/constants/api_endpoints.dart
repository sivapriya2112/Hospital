class ApiEndpoints {
  static const String baseUrl = 'https://hospital-fitq.onrender.com';

  // Patient Endpoints
  static const String getAllPatients = '$baseUrl/patients/getall';
  static const String editPatient = '$baseUrl/patients/edit';

  //bills Endpoints
  static const String addBills = '$baseUrl/billing/add';
  static const String getBills = '$baseUrl/billing/get';
  static const String editBills = '$baseUrl/billing/update';

  //receptionist Endpoints
  static const String login = '$baseUrl/receptionist/login';
  static const String profileGet = '$baseUrl/receptionist/profile/get';
}
