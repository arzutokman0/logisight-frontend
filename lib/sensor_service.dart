// Bu kodu kopyala ve yeni oluşturduğun sensor_service.dart dosyasının içine yapıştır
import 'dart:convert';
import 'package:http/http.dart' as http;

class SensorService {
  final String baseUrl = "https://logisight-backend.onrender.com";

  Future<Map<String, dynamic>> sendSensorData(
    double gx,
    double gy,
    double gz,
    double ax,
    double ay,
    double az,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/analyze-driver'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "GyroX": gx,
          "GyroY": gy,
          "GyroZ": gz,
          "AccX": ax,
          "AccY": ay,
          "AccZ": az,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("❌ Hata: $e");
    }
    return {"prediction_class": -1};
  }
}
