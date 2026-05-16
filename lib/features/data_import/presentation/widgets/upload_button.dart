import 'package:http/http.dart' as http;
import 'dart:io';

class UploadService {
  static Future<void> uploadFile(File file) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("http://10.0.2.2:8000/upload"),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
      ),
    );

    var response = await request.send();

    print("Status Code: ${response.statusCode}");
  }
}
