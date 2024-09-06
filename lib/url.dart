import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Url {
  // final FlutterSecureStorage _storage = FlutterSecureStorage();

  // // Public variable to store the retrieved value
  // String? val;

  // // Method to retrieve the value from secure storage
  // Future<void> getValue() async {
  //   try {
  //     val = await _storage.read(key: 'ip');
  //   } catch (e) {
  //     print('Error retrieving value: $e');
  //   }
  // }

  // String val = "http://10.63.119.118/";
  // String valPic = "http://10.63.119.118";
  // String val = "http://103.37.125.192/";
  // String valPic = "http://103.37.125.192";
  String val = "http://192.168.1.32:8000/";
  String valPic = "http://192.168.1.32:8000";
  String getVal() {
    // getValue();
    return val ?? "";
  }
}
