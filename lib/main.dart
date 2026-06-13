import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'result_screen.dart';
import 'login_screen.dart'; // 💡 İŞTE EKSİK OLAN VE HATAYA SEBEP OLAN SİHİRLİ SATIR BUYDU!

void main() => runApp(const LogiSightApp());

class LogiSightApp extends StatelessWidget {
  const LogiSightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LogiSight',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF141A2D),
      ),
      // Uygulama artık tıkır tıkır yeni yaptığımız o çift butonlu giriş ekranıyla başlayacak!
      home: const LoginScreen(),
    );
  }
}

class TripFormScreen extends StatefulWidget {
  const TripFormScreen({super.key});

  @override
  State<TripFormScreen> createState() => _TripFormScreenState();
}

class _TripFormScreenState extends State<TripFormScreen> {
  final _plakaController = TextEditingController(text: "34 AB 123");

  // Kullanıcının özgürce yazacağı detaylı adres kutuları
  final _startAddressController = TextEditingController(
    text: "Sancaktepe, İstanbul",
  );
  final _endAddressController = TextEditingController(text: "Kazan, Ankara");

  String? selectedAracTipi = 'Tır - Çekici';
  String? selectedYukTuru = 'Soğuk Zincir';
  double molaSikligi = 4.0;
  bool _isLoading = false;

  final List<String> aracTipleri = ['Tır - Çekici', 'Kamyon', 'Panelvan'];
  final List<String> yukTurleri = [
    'Hassas Kargo',
    'Soğuk Zincir',
    'Tehlikeli Madde',
  ];

  // Yazılan metinden canlı koordinat çeker (Geocoding API)
  Future<LatLng?> _getCoordinatesFromAddress(String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$encodedAddress&format=json&limit=1',
    );

    try {
      final response = await http.get(
        url,
        headers: {'User-Agent': 'LogiSight_App'},
      );
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          return LatLng(lat, lon);
        }
      }
    } catch (e) {
      debugPrint("Adres bulma hatası: $e");
    }
    return null;
  }

  Future<void> _seferiBaslat() async {
    final startTxt = _startAddressController.text.trim();
    final endTxt = _endAddressController.text.trim();

    if (startTxt.isEmpty || endTxt.isEmpty) {
      _showSnackBar("Lütfen başlangıç ve varış adreslerini eksiksiz yazın.");
      return;
    }

    setState(() => _isLoading = true);

    final LatLng? startLatLng = await _getCoordinatesFromAddress(startTxt);
    final LatLng? endLatLng = await _getCoordinatesFromAddress(endTxt);

    if (startLatLng == null || endLatLng == null) {
      _showSnackBar(
        "Yazdığınız adresler haritada bulunamadı. Lütfen daha net yazın (İlçe, İl şeklinde).",
      );
      setState(() => _isLoading = false);
      return;
    }

    final url = Uri.parse(
      'https://logisight-backend.onrender.com/analyze-trip',
    );
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "trip_id": "LOGI-001",
          "start_point": startTxt,
          "end_point": endTxt,
          "vehicle_type": selectedAracTipi,
          "load_type": selectedYukTuru,
          "driver_sleep_hours": 8.0,
          "mola_preferences": ["${molaSikligi.toInt()} saat"],
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(
                result: data,
                vehicleType: selectedAracTipi ?? "Tır - Çekici",
                startCity: startTxt,
                endCity: endTxt,
                startCoords: startLatLng,
                endCoords: endLatLng,
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Hata: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF141A2D);
    const cardColor = Color(0xFF1E293B);
    const sdrGreen = Color(0xFF14B8A6);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.route_rounded, color: sdrGreen, size: 28),
                  SizedBox(width: 10),
                  Text(
                    "LogiSight",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                "SEFER PLANLAMA",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white70,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),

              /// HARİTA ÖNİZLEME
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: FlutterMap(
                    options: const MapOptions(
                      initialCenter: LatLng(39.9334, 32.8597),
                      initialZoom: 5,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _buildInputLabel("Kalkış Noktası Detaylı Adresi"),
              _buildAddressInputField(
                _startAddressController,
                "Örn: Sancaktepe, İstanbul",
              ),
              const SizedBox(height: 14),

              _buildInputLabel("Varış Noktası Detaylı Adresi"),
              _buildAddressInputField(
                _endAddressController,
                "Örn: Bornova, İzmir",
              ),
              const SizedBox(height: 14),

              _buildInputLabel("Araç Plakası"),
              Container(
                margin: const EdgeInsets.only(bottom: 18, top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _plakaController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Örn: 34 AB 123",
                  ),
                ),
              ),

              _buildFormDropdown(
                "Araç Tipi",
                aracTipleri,
                selectedAracTipi,
                (v) => setState(() => selectedAracTipi = v),
              ),
              _buildFormDropdown(
                "Yük Türü",
                yukTurleri,
                selectedYukTuru,
                (v) => setState(() => selectedYukTuru = v),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInputLabel("Şoför Mola Sıklığı"),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: sdrGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: sdrGreen.withOpacity(0.3)),
                    ),
                    child: Text(
                      "${molaSikligi.toInt()} Saat",
                      style: const TextStyle(
                        color: sdrGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: sdrGreen,
                  inactiveTrackColor: Colors.white10,
                  trackHeight: 4,
                  thumbColor: Colors.white,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10,
                  ),
                ),
                child: Slider(
                  value: molaSikligi,
                  min: 2,
                  max: 8,
                  divisions: 6,
                  onChanged: (v) => setState(() => molaSikligi = v),
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _seferiBaslat,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sdrGreen,
                    foregroundColor: backgroundColor,
                    elevation: 4,
                    shadowColor: sdrGreen.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: backgroundColor,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          "SEFERİ BAŞLAT",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildAddressInputField(
    TextEditingController controller,
    String hint,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4, top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24),
        ),
      ),
    );
  }

  Widget _buildFormDropdown(
    String label,
    List<String> items,
    String? value,
    Function(String?) onChanged,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildInputLabel(label),
      Container(
        margin: const EdgeInsets.only(bottom: 18, top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: value,
            dropdownColor: const Color(0xFF1E293B),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            items: items
                .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    ],
  );
}
