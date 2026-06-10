// lib/manager_home.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:fl_chart/fl_chart.dart';
import 'login_screen.dart';

class ManagerHomeScreen extends StatefulWidget {
  const ManagerHomeScreen({super.key});

  @override
  State<ManagerHomeScreen> createState() => _ManagerHomeScreenState();
}

class _ManagerHomeScreenState extends State<ManagerHomeScreen> {
  final Color backgroundColor = const Color(0xFF141A2D);
  final Color cardColor = const Color(0xFF1E293B);
  final Color sdrGreen = const Color(0xFF14B8A6);

  // Sayfa kaydırma kontrolcüsü ve mevcut sayfa index'i
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(context),

      // YANA KAYDIRMALI SAYFA YAPISI (PAGEVIEW)
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(), // Şık bir kaydırma animasyonu
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [_buildOperasyonSayfasi(), _buildAnalizSayfasi()],
      ),
    );
  }

  // --- APP BAR ---
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        "LogiSight",
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 18,
          letterSpacing: 1,
          color: Colors.white,
        ),
      ),
      actions: [
        // SAĞ ÜSTTEKİ YÖNLENDİRME OKU
        IconButton(
          icon: Icon(
            _currentPage == 0
                ? Icons.arrow_forward_ios_rounded
                : Icons.arrow_back_ios_new_rounded,
            color: sdrGreen,
            size: 22,
          ),
          onPressed: () {
            if (_currentPage == 0) {
              _pageController.animateToPage(
                1,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            } else {
              _pageController.animateToPage(
                0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            }
          },
        ),
        // ÇIKIŞ YAP BUTONU
        IconButton(
          icon: const Icon(
            Icons.logout_rounded,
            color: Colors.white70,
            size: 22,
          ),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // =======================================================================
  // 1. SAYFA: OPERASYON VE HARİTA (Index 0)
  // =======================================================================
  Widget _buildOperasyonSayfasi() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader("SDR Filo Genel Durumu", Icons.public_rounded),
          const SizedBox(height: 24),

          _buildSectionTitle(Icons.radar, "Canlı Filo Radarı"),
          const SizedBox(height: 12),
          _buildLiveMap(),
          const SizedBox(height: 32),

          _buildSectionTitle(Icons.emoji_events, "Şoför Performans Ligi"),
          const SizedBox(height: 12),
          _buildDriverLeague(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // =======================================================================
  // 2. SAYFA: YAPAY ZEKA VE VERİ ANALİZİ (Index 1)
  // =======================================================================
  Widget _buildAnalizSayfasi() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader("Yapay Zeka Analizleri", Icons.memory_rounded),
          const SizedBox(height: 24),

          _buildSectionTitle(
            Icons.psychology,
            "Model Açıklanabilirliği (SHAP)",
          ),
          const SizedBox(height: 12),
          _buildXAISummary(),
          const SizedBox(height: 32),

          _buildSectionTitle(
            Icons.auto_graph,
            "Haftalık Yakıt & Gecikme Grafiği",
          ),
          const SizedBox(height: 12),
          _buildChartCard(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- KARŞILAMA HEADER ---
  Widget _buildWelcomeHeader(String title, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "İyi çalışmalar, Arzu",
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: sdrGreen.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: sdrGreen, size: 28),
        ),
      ],
    );
  }

  // --- SEKSİYON BAŞLIĞI YARDIMCISI ---
  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: sdrGreen, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // --- CANLI HARİTA MODÜLÜ ---
  Widget _buildLiveMap() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(39.9, 32.8),
            initialZoom: 5.5,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: const LatLng(41.0, 29.0),
                  child: _buildPulsingMarker(sdrGreen),
                ),
                Marker(
                  point: const LatLng(39.9, 32.8),
                  child: _buildPulsingMarker(Colors.amber),
                ),
                Marker(
                  point: const LatLng(38.4, 27.1),
                  child: _buildPulsingMarker(Colors.redAccent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPulsingMarker(Color color) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.8),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.6),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(Icons.local_shipping, color: Colors.white, size: 16),
    );
  }

  // --- XAI RİSK ÖZETİ MODÜLÜ ---
  Widget _buildXAISummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Algoritma 'Kırmızı' aracı neden riskli buldu?",
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          _buildProgressRow("Şoför Uykusuzluk Endeksi", 0.75, Colors.redAccent),
          const SizedBox(height: 12),
          _buildProgressRow("Güzergah Hava Koşulları", 0.45, Colors.amber),
          const SizedBox(height: 12),
          _buildProgressRow("Araç-Yük Uyumsuzluğu", 0.15, sdrGreen),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "%${(value * 100).toInt()}",
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.white10,
          color: color,
          minHeight: 6,
          borderRadius: BorderRadius.circular(10),
        ),
      ],
    );
  }

  // --- BÜYÜK VERİ GRAFİKLERİ MODÜLÜ ---
  Widget _buildChartCard() {
    return Container(
      height: 250,
      padding: const EdgeInsets.only(right: 20, left: 10, top: 20, bottom: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  const style = TextStyle(color: Colors.white54, fontSize: 11);
                  Widget text;
                  switch (value.toInt()) {
                    case 1:
                      text = const Text('Pzt', style: style);
                      break;
                    case 3:
                      text = const Text('Çar', style: style);
                      break;
                    case 5:
                      text = const Text('Cum', style: style);
                      break;
                    case 7:
                      text = const Text('Paz', style: style);
                      break;
                    default:
                      text = const Text('', style: style);
                      break;
                  }
                  return SideTitleWidget(meta: meta, child: text);
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                interval: 20,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      "${value.toInt()}",
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
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              color: sdrGreen,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: sdrGreen.withOpacity(0.15),
              ),
              spots: const [
                FlSpot(1, 45),
                FlSpot(2, 60),
                FlSpot(3, 55),
                FlSpot(4, 80),
                FlSpot(5, 65),
                FlSpot(6, 90),
                FlSpot(7, 85),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- ŞOFÖR PERFORMANS LİGİ MODÜLÜ ---
  Widget _buildDriverLeague() {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildDriverListTile(
            "Oğuzhan Kaptan",
            "Risk Skoru: 12 (Çok Güvenli)",
            Icons.workspace_premium,
            sdrGreen,
          ),
          Divider(color: Colors.white.withOpacity(0.05), height: 1),
          _buildDriverListTile(
            "Ahmet Yılmaz",
            "Risk Skoru: 45 (Orta)",
            Icons.trending_flat,
            Colors.amber,
          ),
          Divider(color: Colors.white.withOpacity(0.05), height: 1),
          _buildDriverListTile(
            "Mehmet Demir",
            "Risk Skoru: 88 (Kritik!)",
            Icons.warning_rounded,
            Colors.redAccent,
          ),
        ],
      ),
    );
  }

  // 💡 GÜNCELLENEN KISIM: Tıklanınca Alttan Şoför Paneli Açılır
  Widget _buildDriverListTile(
    String name,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      onTap: () {
        // 1. Önce "Yükleniyor" bildirimini gösteriyoruz
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "$name adlı personelin detaylı verileri getiriliyor...",
            ),
            backgroundColor: sdrGreen,
            duration: const Duration(seconds: 1),
          ),
        );

        // 2. Bir saniye bekledikten sonra o havalı pencereyi alttan açıyoruz!
        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;

          showModalBottomSheet(
            context: context,
            backgroundColor: cardColor,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (context) =>
                _buildDriverDetailSheet(name, subtitle, icon, color),
          );
        });
      },
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        name,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        color: Colors.white.withOpacity(0.2),
        size: 14,
      ),
    );
  }

  // 💡 YENİ EKLENEN: Alttan açılan o havalı detay ekranının tasarımı
  Widget _buildDriverDetailSheet(
    String name,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      height: 320,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),

          // Uydurma ama çok gerçekçi duran şoför verileri
          Row(
            children: [
              const Icon(Icons.route, color: Colors.white54, size: 20),
              const SizedBox(width: 12),
              Text(
                "Son Tamamlanan Sefer: İstanbul -> İzmir",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.timer, color: Colors.white54, size: 20),
              const SizedBox(width: 12),
              Text(
                "Toplam Sürüş Saati: 1,420 Saat",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.psychology, color: Colors.white54, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Yapay Zeka Notu: Genel olarak kurallara uyumlu ancak gece sürüşlerinde frenleme reaksiyon süresi %15 düşüyor.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
