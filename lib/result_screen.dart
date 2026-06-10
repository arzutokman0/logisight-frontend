import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dashboard_screen.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;
  final String vehicleType;
  final String startCity;
  final String endCity;
  final LatLng startCoords;
  final LatLng endCoords;

  const ResultScreen({
    super.key,
    required this.result,
    required this.vehicleType,
    required this.startCity,
    required this.endCity,
    required this.startCoords,
    required this.endCoords,
  });

  @override
  Widget build(BuildContext context) {
    final double currentRiskScore = (result['risk_score'] ?? 22).toDouble();
    final String aiComment =
        result['ai_comment'] ??
        "Yapay Zeka analizi henüz tamamlanmadı. Bekleniyor...";
    final String speedText = result['speed'] ?? "82 km/h";
    final String distanceText = result['remaining_distance'] ?? "310 km";
    final String restText = result['last_rest'] ?? "4 saat önce";

    // YENİ: Backend'den gelen mola yerlerini dinamik olarak alıyoruz
    final List<dynamic> molaYerleriListesi =
        result['mola_yerleri'] ??
        [
          {"isim": "Rota hesaplanıyor...", "mesafe": "-"},
        ];

    const backgroundColor = Color(0xFF141A2D);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("CANLI TAKİP & RİSK ANALİZİ"),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 35,
                child: _buildMap(
                  vehicleType,
                  startCity,
                  endCity,
                  startCoords,
                  endCoords,
                ),
              ),
              Expanded(
                flex: 65,
                child: _buildDashboard(
                  context,
                  currentRiskScore: currentRiskScore,
                  aiComment: aiComment,
                  speedText: speedText,
                  distanceText: distanceText,
                  restText: restText,
                  molaYerleri:
                      molaYerleriListesi, // YENİ: Veriyi fonksiyona iletiyoruz
                ),
              ),
            ],
          ),
          Positioned(
            top: 20,
            right: -20,
            child: Transform.rotate(
              angle: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                color: const Color(0xFF14B8A6),
                child: const Text(
                  "SDR",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(
    String type,
    String startLabel,
    String endLabel,
    LatLng startPt,
    LatLng endPt,
  ) {
    Widget vehicleMarkerChild;
    switch (type) {
      case 'Tır - Çekici':
        vehicleMarkerChild = Image.asset('assets/images/tir_top.png');
        break;
      case 'Panelvan':
        vehicleMarkerChild = Image.asset('assets/images/van_top.png');
        break;
      case 'Kamyon':
      default:
        vehicleMarkerChild = Image.asset('assets/images/green_truck_top.png');
        break;
    }

    final double centerLat = (startPt.latitude + endPt.latitude) / 2;
    final double centerLon = (startPt.longitude + endPt.longitude) / 2;

    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(centerLat, centerLon),
        initialZoom: 6.5,
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: [startPt, endPt],
              color: const Color(0xFF14B8A6).withOpacity(0.8),
              strokeWidth: 4.0,
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: startPt,
              width: 80,
              height: 80,
              child: vehicleMarkerChild,
            ),
            Marker(
              point: startPt,
              child: Text(
                startLabel.length > 15
                    ? "${startLabel.substring(0, 15)}..."
                    : startLabel,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  backgroundColor: Colors.white70,
                ),
              ),
            ),
            Marker(
              point: endPt,
              child: Text(
                endLabel.length > 15
                    ? "${endLabel.substring(0, 15)}..."
                    : endLabel,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  backgroundColor: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDashboard(
    BuildContext context, {
    required double currentRiskScore,
    required String aiComment,
    required String speedText,
    required String distanceText,
    required String restText,
    required List<dynamic>
    molaYerleri, // YENİ: Asistan sayfasına taşımak için alıyoruz
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    decoration: const BoxDecoration(
      color: Color(0xFF1E293B),
      borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Expanded(child: _buildRiskGaugeCard(currentRiskScore)),
            const SizedBox(width: 12),
            Expanded(child: _buildAiCommentCard(aiComment)),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF14B8A6),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(
              Icons.arrow_forward_rounded,
              fontWeight: FontWeight.bold,
              size: 20,
            ),
            label: const Text(
              "Şoför Özetini & Asistanı Görüntüle",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LocalAiAssistantPage(
                    aiComment: aiComment,
                    startCity: startCity,
                    endCity: endCity,
                    molaYerleri:
                        molaYerleri, // YENİ: Dinamik listeyi asistana pasladık
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: const Color(0xFF14B8A6),
              side: const BorderSide(color: Color(0xFF14B8A6), width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(
              Icons.bar_chart_rounded,
              fontWeight: FontWeight.bold,
              size: 20,
            ),
            label: const Text(
              "Detaylı Dashboard Grafikleri",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildChartCard(),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStat("Hız:", speedText),
            _buildStat("Kalan Mesafe:", distanceText),
            _buildStat("Son Mola:", restText),
          ],
        ),
      ],
    ),
  );

  Widget _buildRiskGaugeCard(double score) => Container(
    height: 145,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFF0F172A),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      children: [
        const Text(
          "RİSK SKORU",
          style: TextStyle(
            fontSize: 9,
            color: Colors.white54,
            letterSpacing: 1,
          ),
        ),
        Expanded(
          child: SfRadialGauge(
            axes: <RadialAxis>[
              RadialAxis(
                minimum: 0,
                maximum: 100,
                startAngle: 180,
                endAngle: 0,
                showLabels: true,
                showTicks: false,
                labelOffset: 8,
                axisLineStyle: const AxisLineStyle(
                  thickness: 0,
                  cornerStyle: CornerStyle.bothCurve,
                ),
                pointers: <GaugePointer>[
                  RangePointer(
                    value: score,
                    cornerStyle: CornerStyle.bothCurve,
                    width: 10,
                    sizeUnit: GaugeSizeUnit.logicalPixel,
                    gradient: const SweepGradient(
                      colors: <Color>[
                        Color(0xFF22C55E),
                        Color(0xFFF97316),
                        Color(0xFFEF4444),
                      ],
                      stops: <double>[0.3, 0.6, 1.0],
                    ),
                  ),
                  MarkerPointer(
                    value: score,
                    markerType: MarkerType.rectangle,
                    color: Colors.black,
                    markerWidth: 2,
                    markerHeight: 14,
                    offsetUnit: GaugeSizeUnit.logicalPixel,
                    markerOffset: 4,
                  ),
                ],
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(
                    widget: Text(
                      score.toInt().toString(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    angle: 90,
                    positionFactor: 0.1,
                  ),
                  GaugeAnnotation(
                    widget: Text(
                      score < 40
                          ? "Düşük Risk"
                          : (score < 70 ? "Orta Risk" : "Yüksek Risk"),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: score < 40
                            ? const Color(0xFF22C55E)
                            : (score < 70
                                  ? const Color(0xFFF97316)
                                  : const Color(0xFFEF4444)),
                      ),
                    ),
                    angle: 90,
                    positionFactor: 0.85,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildAiCommentCard(String comment) => Container(
    height: 145,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFF0F172A),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Center(
      child: SingleChildScrollView(
        child: Text(
          comment,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white70,
            height: 1.35,
          ),
        ),
      ),
    ),
  );

  Widget _buildChartCard() => Container(
    height: 95,
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.02),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(0.04)),
    ),
    child: Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.only(top: 22, right: 10, bottom: 2),
            child: LineChart(
              LineChartData(
                lineTouchData: const LineTouchData(enabled: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) =>
                      const FlLine(color: Colors.white10, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 25,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}',
                        style: const TextStyle(
                          color: Colors.white30,
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 25,
                      reservedSize: 20,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}',
                        style: const TextStyle(
                          color: Colors.white30,
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 100,
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 50),
                      FlSpot(25, 50),
                      FlSpot(50, 50),
                      FlSpot(75, 50),
                      FlSpot(100, 50),
                    ],
                    isCurved: false,
                    color: const Color(0xFF14B8A6),
                    barWidth: 1.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: Text(
              "Yolculuk Risk Grafiği",
              style: TextStyle(color: Colors.white24, fontSize: 9),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildStat(String label, String value) => Row(
    children: [
      Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54)),
      const SizedBox(width: 4),
      Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: Colors.white,
        ),
      ),
    ],
  );
}

// ============================================================================
// HEDEF ASİSTAN SAYFASI (GÜNCELLENDİ: ARTIK DİNAMİK MOLA YERİ ALIYOR)
// ============================================================================
class LocalAiAssistantPage extends StatelessWidget {
  final String aiComment;
  final String startCity;
  final String endCity;
  final List<dynamic> molaYerleri; // YENİ: Gelen dinamik mola verisi

  const LocalAiAssistantPage({
    super.key,
    required this.aiComment,
    required this.startCity,
    required this.endCity,
    required this.molaYerleri, // YENİ: Kurucuya eklendi
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141A2D),
      appBar: AppBar(
        title: const Text("ŞOFÖR ÖZETİ & ASİSTAN"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rota Kartı
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            startCity,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Çıkış Noktası",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(
                        Icons.arrow_forward,
                        color: Color(0xFF14B8A6),
                        size: 24,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            endCity,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Varış Noktası",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // AI ASİSTAN ÖNERİSİ
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.volume_up,
                          color: Color(0xFF3B82F6),
                          size: 24,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "AI ASİSTAN ÖNERİSİ",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      aiComment,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // YENİ: DİNAMİK MOLA YERLERİ ÖNERİLERİ KARTINI OLUŞTURUYORUZ
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Mola Yerleri Önerileri",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 15),
                    // molaYerleri listesindeki her bir eleman için bir satır (_buildMolaRow) oluşturur.
                    ...molaYerleri.map((mola) {
                      return Column(
                        children: [
                          _buildMolaRow(
                            mola['isim']?.toString() ?? "Bilinmeyen Tesis",
                            mola['mesafe']?.toString() ?? "-",
                          ),
                          // Son eleman değilse araya çizgi (Divider) koy
                          if (mola != molaYerleri.last)
                            const Divider(color: Colors.white10),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMolaRow(String title, String distance) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.white54, size: 18),
          const SizedBox(width: 10),
          Expanded(
            // Tesis ismi uzun olursa taşmasın diye Expanded içine aldık
            child: Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            distance,
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
