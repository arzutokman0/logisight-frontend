import 'dart:async';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'sensor_service.dart';
import 'login_screen.dart'; // YENİ: Çıkış yapabilmek için login ekranını dahil ettik

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final MapController _mapController = MapController();
  double currentZoom = 6;

  final SensorService _sensorService = SensorService();
  String _aiStatus = "Sürüş bekleniyor...";
  Timer? _mockTimer;

  @override
  void initState() {
    super.initState();

    // BİLGİSAYAR (CHROME) İÇİN SİMÜLATÖR
    _mockTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        final random = Random();
        double mockAccX = random.nextDouble() * 4.0;

        _sensorService.sendSensorData(0.5, 0.1, 0.2, mockAccX, 1.2, 0.0).then((
          response,
        ) {
          if (mounted) {
            setState(() {
              _aiStatus = response['ai_status'] ?? "Normal Sürüş";
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _mockTimer?.cancel();
    super.dispose();
  }

  void zoomIn() {
    currentZoom++;
    _mapController.move(_mapController.camera.center, currentZoom);
  }

  void zoomOut() {
    currentZoom--;
    _mapController.move(_mapController.camera.center, currentZoom);
  }

  // --- GÜNCELLENEN: ALTTAN AÇILAN AYARLAR MENÜSÜ ---
  void _showSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Text(
                "Sistem Ayarları",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // YENİ: Çalışan Profil Butonu
              ListTile(
                leading: const Icon(Icons.person, color: Color(0xff14B8A6)),
                title: const Text(
                  "Profil Bilgileri",
                  style: TextStyle(color: Colors.white),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white54,
                  size: 16,
                ),
                onTap: () {
                  Navigator.pop(context); // Önce alttan açılan menüyü kapat
                  Navigator.push(
                    // Sonra profil sayfasına git
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.notifications_active,
                  color: Color(0xff14B8A6),
                ),
                title: const Text(
                  "Bildirim Uyarıları",
                  style: TextStyle(color: Colors.white),
                ),
                trailing: Switch(
                  value: true,
                  onChanged: (val) {},
                  activeColor: const Color(0xff14B8A6),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.language, color: Color(0xff14B8A6)),
                title: const Text(
                  "Dil Seçeneği",
                  style: TextStyle(color: Colors.white),
                ),
                trailing: const Text(
                  "Türkçe",
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
                onTap: () {},
              ),
              const Divider(color: Colors.white10, thickness: 1),

              // YENİ: Gerçek Çıkış Yap Butonu
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  "Güvenli Çıkış",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  // pushAndRemoveUntil: Geriye dönük tüm sayfaları kapatıp en başa (Login) atar.
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xff111827);
    const card = Color(0xff1F2937);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xff0F172A),
                        child: Icon(Icons.route, color: Color(0xff14B8A6)),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "LogiSight",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: card,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          _showSettingsModal(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: card,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.settings,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.psychology, color: Colors.tealAccent),
                    const SizedBox(width: 10),
                    Text(
                      "Yapay Zeka Analizi: $_aiStatus",
                      style: const TextStyle(
                        color: Colors.tealAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              WidgetMapSection(
                card: card,
                mapController: _mapController,
                currentZoom: currentZoom,
                zoomIn: zoomIn,
                zoomOut: zoomOut,
              ),
              const SizedBox(height: 18),
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: statCard(
                            title: "Toplam Sefer Sayısı",
                            value: "14",
                            color: const Color(0xff22D3EE),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: statCard(
                            title: "Ortalama Risk Skoru",
                            value: "35 - Orta",
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Flexible(
                                  flex: 1,
                                  child: statCard(
                                    title: "Aktif Araçlar",
                                    value: "6",
                                    color: Colors.greenAccent,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Flexible(
                                  flex: 1,
                                  child: statCard(
                                    title: "Aktif Alarm",
                                    value: "0",
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: card,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Aylık Yakıt Tüketimi",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Expanded(
                                    child: BarChart(
                                      BarChartData(
                                        maxY: 120,
                                        alignment:
                                            BarChartAlignment.spaceAround,
                                        gridData: FlGridData(
                                          show: true,
                                          drawVerticalLine: false,
                                          horizontalInterval: 30,
                                          getDrawingHorizontalLine: (value) {
                                            return const FlLine(
                                              color: Colors.white10,
                                              strokeWidth: 1,
                                            );
                                          },
                                        ),
                                        borderData: FlBorderData(show: false),
                                        titlesData: FlTitlesData(
                                          topTitles: const AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                            ),
                                          ),
                                          rightTitles: const AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                            ),
                                          ),
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              reservedSize: 28,
                                              showTitles: true,
                                              interval: 30,
                                              getTitlesWidget: (value, meta) {
                                                return Text(
                                                  value.toInt().toString(),
                                                  style: const TextStyle(
                                                    color: Colors.white54,
                                                    fontSize: 10,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              getTitlesWidget: (value, meta) {
                                                const months = [
                                                  "J",
                                                  "F",
                                                  "M",
                                                  "A",
                                                  "T",
                                                ];
                                                if (value.toInt() < 0 ||
                                                    value.toInt() >=
                                                        months.length)
                                                  return const SizedBox.shrink();
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 8,
                                                      ),
                                                  child: Text(
                                                    months[value.toInt()],
                                                    style: const TextStyle(
                                                      color: Colors.white54,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        barGroups: [
                                          _buildBarGroup(0, 70),
                                          _buildBarGroup(1, 110),
                                          _buildBarGroup(2, 60),
                                          _buildBarGroup(3, 95),
                                          _buildBarGroup(4, 80),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange,
                            size: 30,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "Son Uyarılar:",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Plaka 34 AB 123 (Sarı) - Mola Gecikmesi",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 16,
          borderRadius: BorderRadius.circular(6),
          color: const Color(0xff22D3EE),
        ),
      ],
    );
  }

  Widget statCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xff1F2937),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _mapBubble(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(.6),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 11),
    ),
  );
}

Widget _zoomButton(IconData icon, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: Colors.white),
    ),
  );
}

class WidgetMapSection extends StatelessWidget {
  const WidgetMapSection({
    super.key,
    required this.card,
    required MapController mapController,
    required this.currentZoom,
    required this.zoomIn,
    required this.zoomOut,
  }) : _mapController = mapController;

  final Color card;
  final MapController _mapController;
  final double currentZoom;
  final VoidCallback zoomIn;
  final VoidCallback zoomOut;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 4,
      child: Container(
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(24),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(39.0, 35.0),
                initialZoom: currentZoom,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: const [
                        LatLng(41.0082, 28.9784),
                        LatLng(40.7654, 29.9408),
                        LatLng(39.9334, 32.8597),
                      ],
                      strokeWidth: 4,
                      color: const Color(0xff14B8A6),
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: const LatLng(41.0082, 28.9784),
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.cyan,
                        size: 35,
                      ),
                    ),
                    Marker(
                      point: const LatLng(39.9334, 32.8597),
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 35,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(top: 18, left: 18, child: _mapBubble("İstanbul")),
            Positioned(top: 95, left: 140, child: _mapBubble("Checkpoint")),
            Positioned(bottom: 30, right: 25, child: _mapBubble("Ankara")),
            Positioned(
              right: 12,
              bottom: 12,
              child: Column(
                children: [
                  _zoomButton(Icons.add, zoomIn),
                  const SizedBox(height: 8),
                  _zoomButton(Icons.remove, zoomOut),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// YENİ: ŞIK BİR PROFİL SAYFASI EKLENTİSİ
// ============================================================================
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xff111827);
    const card = Color(0xff1F2937);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Profil Bilgileri",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Profil Fotoğrafı Alanı
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xff14B8A6), width: 2),
              ),
              child: const CircleAvatar(
                radius: 60,
                backgroundColor: card,
                child: Icon(Icons.person, size: 60, color: Colors.white54),
              ),
            ),
            const SizedBox(height: 20),

            // İsim ve Unvan
            const Text(
              "Oğuzhan Kaptan",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xff14B8A6).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Kıdemli Şoför",
                style: TextStyle(
                  color: Color(0xff14B8A6),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Detaylı Bilgiler
            _buildInfoCard(
              icon: Icons.badge,
              title: "Sicil No",
              value: "LGS-1453",
              cardColor: card,
            ),
            _buildInfoCard(
              icon: Icons.phone,
              title: "Telefon",
              value: "+90 555 123 45 67",
              cardColor: card,
            ),
            _buildInfoCard(
              icon: Icons.local_shipping,
              title: "Zimmetli Araç",
              value: "34 AB 123 (Panelvan)",
              cardColor: card,
            ),
            _buildInfoCard(
              icon: Icons.star,
              title: "Sürüş Puanı",
              value: "98 / 100",
              cardColor: card,
            ),
          ],
        ),
      ),
    );
  }

  // Profil sayfası için küçük şık kart yapısı
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color cardColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xff14B8A6), size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
