// lib/login_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'main.dart'; // Personel için TripFormScreen burada
import 'manager_home.dart'; // Yönetici için boş sayfamız burada

// ============================================================================
// 1. EKRAN: ROL SEÇİMİ (Sadece 2 Butonun Olduğu Karşılama Ekranı)
// ============================================================================
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF141A2D);
    const sdrGreen = Color(0xFF14B8A6);
    const cardColor = Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: sdrGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_shipping_rounded,
                    color: sdrGreen,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "LogiSight",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Yapay Zeka Destekli Risk Yönetim Sistemi",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
                const SizedBox(height: 50),

                const Text(
                  "LÜTFEN GİRİŞ YAPMAK İSTEDİĞİNİZ PANELİ SEÇİN",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white54,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 24),

                // YÖNETİCİ BUTONU -> Tıklayınca Yönetici Formuna Gider
                _buildRoleButton(
                  title: "YÖNETİCİ PANELİ GİRİŞİ",
                  subtitle: "Filo Analizleri & Genel Dashboard",
                  icon: Icons.admin_panel_settings_rounded,
                  primaryColor: sdrGreen,
                  textColor: backgroundColor,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginFormScreen(isManager: true),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // PERSONEL BUTONU -> Tıklayınca Personel Formuna Gider
                _buildRoleButton(
                  title: "ÇALIŞAN / ŞOFÖR GİRİŞİ",
                  subtitle: "Canlı Sefer Takibi & AI Sürüş Asistanı",
                  icon: Icons.airline_seat_recline_normal_rounded,
                  primaryColor: cardColor,
                  textColor: Colors.white,
                  hasBorder: true,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginFormScreen(isManager: false),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color primaryColor,
    required Color textColor,
    required VoidCallback onPressed,
    bool hasBorder = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 82,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: hasBorder
                ? const BorderSide(color: Color(0xFF14B8A6), width: 1.5)
                : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: textColor.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 2. EKRAN: DETAYLI GİRİŞ FORMU (Kullanıcı Adı, Şifre ve Kayıt Ol seçeneği)
// ============================================================================
class LoginFormScreen extends StatefulWidget {
  final bool isManager; // Hangi rolden gelindiğini tutar
  const LoginFormScreen({super.key, required this.isManager});

  @override
  State<LoginFormScreen> createState() => _LoginFormScreenState();
}

class _LoginFormScreenState extends State<LoginFormScreen> {
  late TextEditingController _usernameController;
  final _passwordController = TextEditingController(text: "123456");
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    // Gelen role göre varsayılan kullanıcı adı yazılı gelsin (Sunum kolaylığı için)
    _usernameController = TextEditingController(
      text: widget.isManager ? "arzu" : "sofor",
    );
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://logisight-backend-xxxx.onrender.com/login'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String returnedRole = data['role'] ?? 'driver';

        if (mounted) {
          // GİRİŞ BAŞARILI İSE İSTENİLEN SAYFAYA YÖNLENDİRME YAPILIR
          if (returnedRole == 'manager') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const ManagerHomeScreen(),
              ),
              (route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const TripFormScreen()),
              (route) => false,
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Giriş başarısız. Kullanıcı adı veya şifre hatalı."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sunucuya bağlanılamadı."),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String pageTitle = widget.isManager
        ? "YÖNETİCİ GİRİŞİ"
        : "PERSONEL GİRİŞİ";
    const backgroundColor = Color(0xFF141A2D);
    const cardColor = Color(0xFF1E293B);
    const sdrGreen = Color(0xFF14B8A6);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                pageTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Lütfen sistem bilgilerinizi giriniz.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 40),

              // KULLANICI ADI
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                child: Text(
                  "Kullanıcı Adı",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _usernameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),

              // ŞİFRE
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                child: Text(
                  "Şifre",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 30),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.white38,
                      ),
                      onPressed: () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible,
                      ),
                    ),
                  ),
                ),
              ),

              // GİRİŞ YAP BUTONU
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sdrGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: backgroundColor)
                      : const Text(
                          "GİRİŞ YAP",
                          style: TextStyle(
                            color: backgroundColor,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // YENİ KAYIT OL & ŞİFREMİ UNUTTUM SEÇENEKLERİ (UYARI BİLDİRİMLİ)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Şifre sıfırlama bağlantısı sistemde kayıtlı kurumsal e-posta adresinize gönderildi.",
                          ),
                          backgroundColor: Color(0xFF14B8A6),
                        ),
                      );
                    },
                    child: Text(
                      "Şifremi Unuttum",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Sisteme yeni personel kaydı dışarıdan yapılamaz. Lütfen İnsan Kaynakları departmanı ile iletişime geçin.",
                          ),
                          backgroundColor: Colors.redAccent,
                          duration: Duration(seconds: 4),
                        ),
                      );
                    },
                    child: const Text(
                      "Yeni Kayıt Oluştur",
                      style: TextStyle(
                        color: sdrGreen,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
