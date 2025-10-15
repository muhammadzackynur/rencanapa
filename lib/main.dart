import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// --- KONFIGURASI ---
const String apiUrl = "http://192.168.1.12:8000/api";
const String googleAppScriptUrl =
    "https://script.google.com/macros/s/AKfycbwgY5dveK0qoWYSzZRad1KC6bTDeHWtAB7YlxJnatztZeCenFfq33dw0oPKuY7dnpQGYA/exec";

final GlobalKey<_MainPageState> mainPageKey = GlobalKey<_MainPageState>();

// --- FUNGSI BARU UNTUK NOTIFIKASI SUKSES MENGAMBANG ---
void showSuccessOverlay(BuildContext context, String message) {
  OverlayState? overlayState = Overlay.of(context);
  OverlayEntry? overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) {
      return SuccessOverlayAnimation(
        message: message,
        onFinish: () {
          overlayEntry?.remove();
        },
      );
    },
  );

  overlayState.insert(overlayEntry);
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(const MyApp());
}

// --- WIDGETS ANIMASI ---

class SuccessAnimation extends StatefulWidget {
  const SuccessAnimation({super.key});

  @override
  State<SuccessAnimation> createState() => _SuccessAnimationState();
}

class _SuccessAnimationState extends State<SuccessAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Image.asset(
          'assets/check-19009726-unscreen.gif', // Path ke GIF Anda
          width: 120,
          height: 120,
          errorBuilder: (context, error, stackTrace) {
            // Jika GIF gagal dimuat, tampilkan icon error merah
            print("Error loading asset: $error");
            return const Icon(Icons.error, color: Colors.red, size: 80);
          },
        ),
      ),
    );
  }
}

class SuccessCheckmarkAnimation extends StatefulWidget {
  const SuccessCheckmarkAnimation({super.key, this.size = 150.0});
  final double size;

  @override
  State<SuccessCheckmarkAnimation> createState() =>
      _SuccessCheckmarkAnimationState();
}

class _SuccessCheckmarkAnimationState extends State<SuccessCheckmarkAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: CheckmarkPainter(progress: _animation.value),
          );
        },
      ),
    );
  }
}

class CheckmarkPainter extends CustomPainter {
  final double progress;

  CheckmarkPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 10.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Path path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.5);
    path.lineTo(size.width * 0.45, size.height * 0.7);
    path.lineTo(size.width * 0.8, size.height * 0.3);

    for (ui.PathMetric pathMetric in path.computeMetrics()) {
      final ui.Path extractPath = pathMetric.extractPath(
        0.0,
        pathMetric.length * progress,
      );
      canvas.drawPath(extractPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// --- WIDGET BARU UNTUK TAMPILAN OVERLAY ---
class SuccessOverlayAnimation extends StatefulWidget {
  final String message;
  final VoidCallback onFinish;

  const SuccessOverlayAnimation({
    Key? key,
    required this.message,
    required this.onFinish,
  }) : super(key: key);

  @override
  State<SuccessOverlayAnimation> createState() =>
      _SuccessOverlayAnimationState();
}

class _SuccessOverlayAnimationState extends State<SuccessOverlayAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    // Tunggu beberapa saat, lalu animasikan keluar dan panggil onFinish
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onFinish();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        alignment: Alignment.center,
        color: Colors.black.withOpacity(0.3),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: const Color.fromARGB(240, 48, 48, 48),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SuccessAnimation(),
                  const SizedBox(height: 16),
                  Text(
                    widget.message,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- APLIKASI UTAMA ---

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Data Usulan App',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF0F8F7),
        fontFamily: 'Inter',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00BFA5),
          primary: const Color(0xFF00BFA5),
          secondary: const Color(0xFF00897B),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00BFA5),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

// --- GERBANG OTENTIKASI ---

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  _AuthGateState createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getBool('isLoggedIn') ?? false) ||
        (prefs.getBool('isAdminLoggedIn') ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          if (snapshot.data == true) {
            return MainPage(key: mainPageKey);
          } else {
            return const RoleSelectionPage();
          }
        }
      },
    );
  }
}

// --- HALAMAN PEMILIHAN PERAN ---
class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE0F2F1), Colors.white],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Selamat Datang',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Silakan pilih tipe akun Anda',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: 250,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text('Masuk sebagai Pengguna'),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 250,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00897B),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AdminLoginPage(),
                    ),
                  );
                },
                child: const Text('Masuk sebagai Admin'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- HALAMAN LOGIN PENGGUNA ---

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await http.post(
          Uri.parse("$apiUrl/login"),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: json.encode({'email': _email, 'password': _password}),
        );

        if (!mounted) return;

        final responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MainPage(key: mainPageKey)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message'] ?? 'Login Gagal!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan koneksi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE0F2F1), Colors.white],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PhosphorIcon(
                    PhosphorIcons.shieldCheck(),
                    color: Theme.of(context).primaryColor,
                    size: 80,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Selamat Datang',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Masuk untuk melanjutkan',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(PhosphorIcons.envelope()),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !value.contains('@')) {
                        return 'Masukkan email yang valid';
                      }
                      return null;
                    },
                    onChanged: (value) => _email = value.trim(),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(PhosphorIcons.lock()),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null;
                    },
                    onChanged: (value) => _password = value,
                  ),
                  const SizedBox(height: 30),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _login,
                            child: const Text('MASUK'),
                          ),
                        ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Belum punya akun?"),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const RegistrationPage(),
                            ),
                          );
                        },
                        child: const Text('Daftar di sini'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- HALAMAN LOGIN ADMIN DENGAN ID ---

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  _AdminLoginPageState createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _adminId = '';
  bool _isLoading = false;

  // =======================================================================
  // INI ADALAH FUNGSI YANG DIPERBAIKI
  // =======================================================================
  Future<void> _loginAdmin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);

    var client = http.Client();
    try {
      // Membuat request manual untuk bisa mengontrol redirect
      var request = http.Request('POST', Uri.parse(googleAppScriptUrl))
        ..followRedirects =
            false // Penting: jangan ikuti redirect otomatis
        ..headers['Content-Type'] = 'application/json; charset=UTF-8'
        ..body = json.encode({'action': 'adminLogin', 'admin_id': _adminId});

      final streamedResponse = await client
          .send(request)
          .timeout(const Duration(seconds: 45));

      // Jika server merespons dengan redirect (status code 3xx)
      if (streamedResponse.statusCode >= 300 &&
          streamedResponse.statusCode < 400) {
        final newLocation = streamedResponse.headers['location'];
        if (newLocation == null) {
          throw Exception(
            "Server melakukan redirect tetapi tidak memberikan lokasi baru.",
          );
        }

        print('[LOG] Redirecting to: $newLocation');
        // Lakukan GET request ke URL baru yang diberikan oleh server
        final secondResponse = await client.get(Uri.parse(newLocation));

        if (secondResponse.statusCode == 200) {
          _handleLoginResponse(secondResponse.body);
        } else {
          throw Exception(
            'Gagal mengambil data dari URL redirect. Status: ${secondResponse.statusCode}',
          );
        }
      }
      // Jika server merespons dengan sukses (status code 200)
      else if (streamedResponse.statusCode == 200) {
        final response = await http.Response.fromStream(streamedResponse);
        _handleLoginResponse(response.body);
      }
      // Jika server merespons dengan error lain
      else {
        throw Exception(
          'Gagal menghubungi server. Status: ${streamedResponse.statusCode}',
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan koneksi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      client.close();
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Fungsi bantuan untuk memproses respons JSON setelah berhasil didapat
  void _handleLoginResponse(String responseBody) async {
    if (!mounted) return;
    final responseData = json.decode(responseBody);

    if (responseData['status'] == 'success') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAdminLoggedIn', true);
      await prefs.setString('adminId', _adminId);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainPage(key: mainPageKey)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(responseData['message'] ?? 'Login Admin Gagal!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  // =======================================================================
  // AKHIR DARI FUNGSI YANG DIPERBAIKI
  // =======================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Administrator'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE0F2F1), Colors.white],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PhosphorIcon(
                    PhosphorIcons.key(),
                    color: Theme.of(context).colorScheme.secondary,
                    size: 80,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Akses Khusus Admin',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Masukkan ID Admin',
                      prefixIcon: Icon(PhosphorIcons.qrCode()),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'ID Admin tidak boleh kosong';
                      }
                      return null;
                    },
                    onChanged: (value) => _adminId = value.trim(),
                  ),
                  const SizedBox(height: 30),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00897B),
                            ),
                            onPressed: _loginAdmin,
                            child: const Text('MASUK'),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- HALAMAN REGISTRASI ---

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String? fcmToken;
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
        print('===================================================');
        print('FCM Token yang didapat: $fcmToken');
        print('===================================================');
      } catch (e) {
        print('Gagal mendapatkan FCM Token: $e');
      }

      try {
        final response = await http.post(
          Uri.parse(googleAppScriptUrl), // Langsung ke GAS
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: json.encode({
            'action': 'register',
            'email': _email,
            'password': _password,
            'fcm_token': fcmToken,
          }),
        );

        if (!mounted) return;

        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registrasi Berhasil! Silakan masuk.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message'] ?? 'Registrasi Gagal!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan koneksi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Akun Baru'),
        backgroundColor: const Color(0xFFF0F8F7),
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0F8F7), Colors.white],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(PhosphorIcons.envelope()),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !value.contains('@')) {
                        return 'Masukkan email yang valid';
                      }
                      return null;
                    },
                    onChanged: (value) => _email = value.trim(),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(PhosphorIcons.lock()),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null;
                    },
                    onChanged: (value) => _password = value,
                  ),
                  const SizedBox(height: 30),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _register,
                            child: const Text('DAFTAR'),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- CONTAINER HALAMAN UTAMA (DENGAN BOTTOM NAV) ---

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [const HomePage(), const SearchPage(), const AddFormPage()];

    _requestNotificationPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      print('Menerima notifikasi saat aplikasi terbuka!');

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              channelDescription:
                  'This channel is used for important notifications.',
              icon: 'launch_background',
            ),
          ),
        );
      }
    });
  }

  Future<void> _requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Izin notifikasi diberikan oleh pengguna.');
    } else {
      print('Pengguna menolak atau belum memberikan izin notifikasi.');
    }
  }

  void changePage(int index) {
    if (mounted) {
      setState(() => _selectedIndex = index);
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF00BFA5),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(PhosphorIcons.house()),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(PhosphorIcons.magnifyingGlass()),
            label: 'Cek Data',
          ),
          BottomNavigationBarItem(
            icon: Icon(PhosphorIcons.plusCircle()),
            label: 'Tambah Data',
          ),
        ],
      ),
    );
  }
}

// --- HALAMAN-HALAMAN KONTEN ---

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('isAdminLoggedIn');
    await prefs.remove('adminId');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const RoleSelectionPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE0F2F1), Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 40.0,
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00BFA5),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          PhosphorIcons.user(),
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Text(
                        'Menu Utama',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B1D28),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(PhosphorIcons.signOut()),
                        onPressed: () => _logout(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Menu Utama',
                          value: '14.5%',
                          icon: PhosphorIcons.checkCircle(
                            PhosphorIconsStyle.fill,
                          ),
                          iconColor: Colors.white,
                          iconBgColor: const Color(0xFF27AE60),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // --- PERUBAHAN: Mengubah StatCard menjadi tombol ---
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AllDataPage(startInHistoryView: true),
                              ),
                            );
                          },
                          child: StatCard(
                            title: 'Riwayat Edit Saya',
                            value: 'Lihat Data',
                            icon: PhosphorIcons.arrowClockwise(
                              PhosphorIconsStyle.regular,
                            ),
                            iconColor: Colors.white,
                            iconBgColor: const Color(0xFFF2994A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AllDataPage(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Semua Data',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1B1D28),
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Lihat & Kelola',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Grafik Penjualan',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B1D28),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 50,
                                child: LineChart(
                                  LineChartData(
                                    gridData: const FlGridData(show: false),
                                    titlesData: const FlTitlesData(show: false),
                                    borderData: FlBorderData(show: false),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: const [
                                          FlSpot(0, 1),
                                          FlSpot(1, 1.5),
                                          FlSpot(2, 1.4),
                                          FlSpot(3, 3.4),
                                          FlSpot(4, 2),
                                          FlSpot(5, 2.2),
                                          FlSpot(6, 1.8),
                                        ],
                                        isCurved: true,
                                        color: const Color(0xFF00BFA5),
                                        barWidth: 4,
                                        isStrokeCapRound: true,
                                        dotData: const FlDotData(show: false),
                                        belowBarData: BarAreaData(show: false),
                                      ),
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
                  const SizedBox(height: 30),
                  const Text(
                    'Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B1D28),
                    ),
                  ),
                  const SizedBox(height: 15),
                  QuickActionCard(
                    icon: PhosphorIcons.clockCounterClockwise(
                      PhosphorIconsStyle.fill,
                    ),
                    title: 'Recent Activities',
                    subtitle: 'Lihat data usulan terakhir',
                    iconBgColor: const Color(0xFF56CCF2),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RecentActivitiesPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  QuickActionCard(
                    icon: PhosphorIcons.plusCircle(PhosphorIconsStyle.fill),
                    title: 'Quick Action',
                    subtitle: 'Tambah Data Usulan',
                    iconBgColor: const Color(0xFF00BFA5),
                    onTap: () => mainPageKey.currentState?.changePage(2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RecentActivitiesPage extends StatefulWidget {
  const RecentActivitiesPage({super.key});

  @override
  State<RecentActivitiesPage> createState() => _RecentActivitiesPageState();
}

class _RecentActivitiesPageState extends State<RecentActivitiesPage> {
  bool _isLoading = true;
  List<dynamic> _activities = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRecentActivities();
  }

  Future<void> _fetchRecentActivities() async {
    try {
      final response = await http
          .get(Uri.parse(googleAppScriptUrl))
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'success') {
          setState(() {
            _activities = result['data'];
            _isLoading = false;
          });
        } else {
          throw Exception(result['message']);
        }
      } else {
        throw Exception('Gagal memuat data dari server');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aktivitas Terakhir')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Terjadi error: $_error'),
        ),
      );
    }
    if (_activities.isEmpty) {
      return const Center(child: Text('Tidak ada data terbaru.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _activities.length,
      itemBuilder: (context, index) {
        final activity = _activities[index];
        final no = activity['NO']?.toString() ?? '-';
        final sto = activity['STO']?.toString() ?? 'N/A';
        final uraian =
            activity['URAIAN PEKERJAAN']?.toString() ?? 'Tidak ada uraian';

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailPage(data: activity),
              ),
            );
          },
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: ListTile(
              leading: CircleAvatar(child: Text(no)),
              title: Text(
                "STO: $sto",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(uraian),
            ),
          ),
        );
      },
    );
  }
}

class AllDataPage extends StatefulWidget {
  final bool startInHistoryView;

  const AllDataPage({super.key, this.startInHistoryView = false});

  @override
  State<AllDataPage> createState() => _AllDataPageState();
}

class _AllDataPageState extends State<AllDataPage> {
  bool _isLoading = true;
  List<dynamic> _allData = [];
  List<dynamic> _filteredData = [];
  String? _error;

  bool _isHistoryView = false;
  String? _currentAdminId;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showScrollButtons = false;

  @override
  void initState() {
    super.initState();
    _isHistoryView = widget.startInHistoryView;

    _loadAdminId().then((_) {
      _fetchAllData();
    });

    _searchController.addListener(() {
      _runFilter();
    });

    _scrollController.addListener(() {
      if (_scrollController.offset > 300 && !_showScrollButtons) {
        setState(() {
          _showScrollButtons = true;
        });
      } else if (_scrollController.offset <= 300 && _showScrollButtons) {
        setState(() {
          _showScrollButtons = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminId() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _currentAdminId = prefs.getString('adminId');
      });
    }
  }

  Future<void> _fetchAllData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      Uri uri;
      if (_isHistoryView && _currentAdminId != null) {
        uri = Uri.parse(
          "$googleAppScriptUrl?action=getEditHistory&adminId=$_currentAdminId",
        );
      } else {
        uri = Uri.parse("$googleAppScriptUrl?action=getAll");
      }

      final response = await http.get(uri).timeout(const Duration(seconds: 60));
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'success') {
          if (!mounted) return;
          setState(() {
            _allData = result['data'];
          });
          _runFilter();
        } else {
          throw Exception(result['message']);
        }
      } else {
        throw Exception('Gagal memuat data dari server');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _runFilter() {
    List<dynamic> results = List.from(_allData);
    final query = _searchController.text.toLowerCase();

    if (query.isNotEmpty) {
      results = results.where((item) {
        final tiket = item['NOMOR TIKET/SC']?.toString().toLowerCase() ?? '';
        final uraian = item['URAIAN PEKERJAAN']?.toString().toLowerCase() ?? '';
        final idHld = item['ID/HLD']?.toString().toLowerCase() ?? '';
        final kategori =
            item['KATEGORI KEGIATAN']?.toString().toLowerCase() ?? '';
        final sto = item['STO']?.toString().toLowerCase() ?? '';
        final user = item['USER']?.toString().toLowerCase() ?? '';

        return tiket.contains(query) ||
            uraian.contains(query) ||
            idHld.contains(query) ||
            kategori.contains(query) ||
            user.contains(query) ||
            sto.contains(query);
      }).toList();
    }

    setState(() {
      _filteredData = results;
    });
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    switch (status.toLowerCase()) {
      case 'belum dikerjakan':
        return Colors.grey.shade600;
      case 'order eksekusi':
        return Colors.blue.shade600;
      case 'sudah dikerjakan':
        return Colors.green.shade600;
      case 'cancle':
        return Colors.red.shade600;
      case 'waiting list':
        return Colors.orange.shade600;
      default:
        return Colors.black;
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isHistoryView ? 'Riwayat Saya' : 'Semua Data Usulan'),
        actions: [
          if (_currentAdminId != null)
            IconButton(
              icon: Icon(
                PhosphorIcons.clockCounterClockwise(),
                color: _isHistoryView
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _isHistoryView = !_isHistoryView;
                  _fetchAllData();
                });
              },
              tooltip: 'Tampilkan Riwayat Saya',
            ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari (No. Tiket, Uraian, User, dll)',
                    prefixIcon: Icon(PhosphorIcons.magnifyingGlass()),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(child: _buildGridBody()),
            ],
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: AnimatedOpacity(
              opacity: _showScrollButtons ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton.small(
                    onPressed: _scrollToTop,
                    heroTag: 'scrollTop',
                    child: const Icon(Icons.arrow_upward),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    onPressed: _scrollToBottom,
                    heroTag: 'scrollBottom',
                    child: const Icon(Icons.arrow_downward),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Terjadi error: $_error'),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _fetchAllData,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }
    if (_filteredData.isEmpty) {
      return Center(
        child: Text(
          _isHistoryView
              ? 'Anda belum memiliki riwayat.'
              : 'Data tidak ditemukan.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchAllData,
      child: GridView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: (2 / 2.8),
        ),
        itemCount: _filteredData.length,
        itemBuilder: (context, index) {
          final item = _filteredData[index];
          final no = item['NO']?.toString() ?? '-';
          final sto = item['STO']?.toString() ?? 'N/A';
          final String mainUraian =
              item['URAIAN PEKERJAAN']?.toString() ?? 'Tidak ada uraian';
          final String? kategori = item['KATEGORI KEGIATAN']?.toString();
          final String? status = item['STATUS']?.toString();

          return GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DetailPage(data: item)),
              );
              if (result == true) {
                _fetchAllData();
              }
            },
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              shadowColor: Colors.black.withOpacity(0.1),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              constraints: const BoxConstraints(minWidth: 32),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                no,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "STO: $sto",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          mainUraian,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        if (kategori != null && kategori.isNotEmpty)
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.teal.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                kategori.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.teal,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (status != null && status.isNotEmpty)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- HALAMAN DETAIL ---

class DetailPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const DetailPage({Key? key, required this.data}) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool _isAdmin = false;
  late Map<String, dynamic> _currentData;
  bool _dataHasChanged = false;

  @override
  void initState() {
    super.initState();
    _currentData = Map<String, dynamic>.from(widget.data);
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAdmin = prefs.getBool('isAdminLoggedIn') ?? false;
    });
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String label1,
    required String value1,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label1.toUpperCase(),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value1,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B1D28),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _dataHasChanged);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detail Data'),
          backgroundColor: const Color(0xFFF0F8F7),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, _dataHasChanged);
            },
          ),
          iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        ),
        floatingActionButton: _isAdmin
            ? FloatingActionButton.extended(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditDataPage(initialData: _currentData),
                    ),
                  );

                  if (result != null && result is Map<String, dynamic>) {
                    setState(() {
                      _currentData = result;
                      _dataHasChanged = true;
                    });
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Data'),
                backgroundColor: Theme.of(context).colorScheme.secondary,
              )
            : null,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF0F8F7), Colors.white],
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0),
            children: _currentData.entries.map((entry) {
              final key = entry.key;
              final value = entry.value?.toString() ?? 'N/A';
              if (value.isEmpty || key == 'NO') return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildInfoCard(context, label1: key, value1: value),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// --- HALAMAN UNTUK EDIT DATA ---

class EditDataPage extends StatefulWidget {
  final Map<String, dynamic> initialData;
  const EditDataPage({Key? key, required this.initialData}) : super(key: key);

  @override
  State<EditDataPage> createState() => _EditDataPageState();
}

class _EditDataPageState extends State<EditDataPage> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, TextEditingController> _controllers;
  bool _isLoading = false;

  late Map<String, dynamic> _editableData;

  final List<String> _statusPekerjaanOptions = [
    'Waiting List',
    'Order Eksekusi',
    'Cancel',
    'Sudah Dikerjakan',
  ];
  final List<String> _approvalOptions = ['Approved', 'Cancle', 'Pengajuan'];
  final List<String> _wbsOptions = ['Qe Access', 'Qe Recovery', 'Qe Relokasi'];

  // Opsi untuk Autocomplete Kategori
  final List<String> _kategoriKegiatanOptions = ['CANCEL', 'REKON', 'USULAN'];

  @override
  void initState() {
    super.initState();
    _editableData = Map<String, dynamic>.from(widget.initialData);
    _controllers = {};

    _editableData.forEach((key, value) {
      if (key != 'NO' &&
          key != 'STATUS PEKERJAAN' &&
          key != 'APPROVAL RAM' &&
          key != 'APPROVAL ED' &&
          key != 'WBS' &&
          key != 'KATEGORI KEGIATAN') {
        // Tambahkan KATEGORI KEGIATAN
        _controllers[key] = TextEditingController(
          text: value?.toString() ?? '',
        );
      }
    });

    // Inisialisasi controller terpisah untuk Autocomplete
    _controllers['KATEGORI KEGIATAN'] = TextEditingController(
      text: _editableData['KATEGORI KEGIATAN']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final adminId = prefs.getString('adminId');

    _controllers.forEach((key, controller) {
      _editableData[key] = controller.text;
    });

    _editableData['USER'] = adminId;

    final requestBody = json.encode({
      'action': 'updateData',
      'data': _editableData,
    });

    var client = http.Client();
    try {
      var request = http.Request('POST', Uri.parse(googleAppScriptUrl))
        ..followRedirects = false
        ..headers['Content-Type'] = 'application/json; charset=UTF-8'
        ..body = requestBody;

      final streamedResponse = await client
          .send(request)
          .timeout(const Duration(seconds: 45));

      if (streamedResponse.statusCode >= 300 &&
          streamedResponse.statusCode < 400) {
        final newLocation = streamedResponse.headers['location'];
        if (newLocation == null) {
          throw Exception(
            "Server melakukan redirect tetapi tidak memberikan lokasi baru.",
          );
        }

        print('[LOG] Redirecting to: $newLocation');

        final secondResponse = await client.get(Uri.parse(newLocation));

        if (secondResponse.statusCode == 200) {
          final responseData = json.decode(secondResponse.body);
          if (responseData['status'] == 'success') {
            if (!mounted) return;
            showSuccessOverlay(context, 'Data berhasil diperbarui!');
            Future.delayed(const Duration(milliseconds: 2500), () {
              if (mounted) {
                Navigator.of(context).pop(_editableData);
              }
            });
          } else {
            throw Exception(
              responseData['message'] ??
                  'Gagal memperbarui data setelah redirect.',
            );
          }
        } else {
          throw Exception(
            'Gagal mengambil data dari URL redirect. Status: ${secondResponse.statusCode}',
          );
        }
      } else if (streamedResponse.statusCode == 200) {
        final response = await http.Response.fromStream(streamedResponse);
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          if (!mounted) return;
          showSuccessOverlay(context, 'Data berhasil diperbarui!');
          Future.delayed(const Duration(milliseconds: 2500), () {
            if (mounted) {
              Navigator.of(context).pop(_editableData);
            }
          });
        } else {
          throw Exception(responseData['message'] ?? 'Gagal memperbarui data.');
        }
      } else {
        throw Exception(
          'Gagal menghubungi server. Status: ${streamedResponse.statusCode}',
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      client.close();
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Data #${widget.initialData["NO"]}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveChanges,
            tooltip: 'Simpan Perubahan',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  ..._editableData.entries.map((entry) {
                    if (entry.key == 'NO' || entry.key == 'USER') {
                      return const SizedBox.shrink();
                    }
                    // ... (kode dropdown STATUS PEKERJAAN, WBS, APPROVAL tetap sama)
                    else if (entry.key == 'KATEGORI KEGIATAN') {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text == '') {
                              return const Iterable<String>.empty();
                            }
                            return _kategoriKegiatanOptions.where((
                              String option,
                            ) {
                              return option.toLowerCase().contains(
                                textEditingValue.text.toLowerCase(),
                              );
                            });
                          },
                          onSelected: (String selection) {
                            setState(() {
                              _editableData['KATEGORI KEGIATAN'] = selection;
                              _controllers['KATEGORI KEGIATAN']!.text =
                                  selection;
                            });
                          },
                          fieldViewBuilder:
                              (
                                BuildContext context,
                                TextEditingController fieldController,
                                FocusNode fieldFocusNode,
                                VoidCallback onFieldSubmitted,
                              ) {
                                // Sync controller
                                fieldController.text =
                                    _controllers['KATEGORI KEGIATAN']!.text;
                                return TextFormField(
                                  controller: fieldController,
                                  focusNode: fieldFocusNode,
                                  decoration: const InputDecoration(
                                    labelText: 'KATEGORI KEGIATAN',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    _editableData['KATEGORI KEGIATAN'] = value;
                                  },
                                );
                              },
                        ),
                      );
                    } else if (_controllers.containsKey(entry.key)) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: TextFormField(
                          controller: _controllers[entry.key],
                          decoration: InputDecoration(
                            labelText: entry.key,
                            border: const OutlineInputBorder(),
                          ),
                          maxLines: entry.key.contains('URAIAN') ? 3 : 1,
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }).toList(),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                    child: const Text('SIMPAN PERUBAHAN'),
                  ),
                ],
              ),
            ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color iconColor, iconBgColor;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B1D28),
            ),
          ),
        ],
      ),
    );
  }
}

class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final String title, subtitle;
  final VoidCallback onTap;

  const QuickActionCard({
    Key? key,
    required this.icon,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 28),
          ],
        ),
      ),
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Cek Data')),
    body: const Center(child: Text('Halaman Pencarian')),
  );
}

class AddFormPage extends StatefulWidget {
  const AddFormPage({super.key});
  @override
  State<AddFormPage> createState() => _AddFormPageState();
}

class _AddFormPageState extends State<AddFormPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  final stoOptions = [
    "LMG",
    "SDD",
    "BBA",
    "BDG",
    "MGO",
    "KBL",
    "KPS",
    "KJR",
    "KLN",
    "TNS",
    "LKI",
    "KNN",
    "BBE",
    "KRP",
    "GSK",
    "CRM",
    "KDE",
    "SDY",
    "BPG",
    "BWN",
    "DDS",
  ];
  final jenisTiketOptions = [
    "NOMOR SC",
    "TIKET INFRACARE",
    "TIKET GANGGUAN/SQM",
  ];

  // --- PERUBAHAN: Opsi baru untuk kategori ---
  final List<String> kategoriKegiatanOptions = ['CANCEL', 'REKON', 'USULAN'];

  final mitraPelaksanaOptions = [
    "PT. Cipta Akses Indotama",
    "PT. Bangtelindo",
    "PT. OPMC Indonesia",
    "PT. Centralindo Panca Sakti",
    "PT. Prima Akses Solusi Global",
    "PT. Akses Kwalitas Unggul",
    "PT. Telkom Akses",
  ];
  bool _isLoading = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save(); // Simpan semua nilai dari form
      setState(() => _isLoading = true);

      final prefs = await SharedPreferences.getInstance();
      final adminId = prefs.getString('adminId');
      _formData['USER'] = adminId;

      try {
        final response = await http
            .post(
              Uri.parse(googleAppScriptUrl),
              headers: {'Content-Type': 'application/json; charset=UTF-8'},
              body: json.encode({'action': 'addData', 'data': _formData}),
            )
            .timeout(const Duration(seconds: 30));

        if (!mounted) return;

        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          showSuccessOverlay(context, 'Data berhasil ditambahkan!');

          Future.delayed(const Duration(milliseconds: 2500), () {
            if (mounted) {
              _formKey.currentState?.reset();
              setState(() => _formData.clear());
              mainPageKey.currentState?.changePage(0);
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message'] ?? 'Gagal menyimpan data.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Data Usulan'),
        backgroundColor: const Color(0xFFF0F8F7),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF0F8F7), Colors.white],
                ),
              ),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildSectionCard(
                      title: 'Informasi Dasar',
                      icon: PhosphorIcons.info(),
                      children: [
                        _buildDropdown("STO", stoOptions),
                        const SizedBox(height: 16),
                        _buildDropdown("JENIS TIKET", jenisTiketOptions),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'NOMOR TIKET/SC',
                            prefixIcon: Icon(PhosphorIcons.ticket()),
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                          onSaved: (v) => _formData['NOMOR TIKET/SC'] = v,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSectionCard(
                      title: 'Detail Pekerjaan',
                      icon: PhosphorIcons.clipboardText(),
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'URAIAN PEKERJAAN',
                            prefixIcon: Icon(PhosphorIcons.pencil()),
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                          onSaved: (v) => _formData['URAIAN PEKERJAAN'] = v,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        // --- PERUBAHAN: Gunakan Autocomplete untuk Kategori ---
                        Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text == '') {
                              return const Iterable<String>.empty();
                            }
                            return kategoriKegiatanOptions.where((
                              String option,
                            ) {
                              return option.toLowerCase().contains(
                                textEditingValue.text.toLowerCase(),
                              );
                            });
                          },
                          onSelected: (String selection) {
                            _formData['KATEGORI KEGIATAN'] = selection;
                          },
                          fieldViewBuilder:
                              (
                                BuildContext context,
                                TextEditingController fieldController,
                                FocusNode fieldFocusNode,
                                VoidCallback onFieldSubmitted,
                              ) {
                                return TextFormField(
                                  controller: fieldController,
                                  focusNode: fieldFocusNode,
                                  decoration: InputDecoration(
                                    labelText: 'KATEGORI KEGIATAN',
                                    prefixIcon: Icon(
                                      _getIconForField('KATEGORI KEGIATAN'),
                                    ),
                                  ),
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? 'Wajib diisi'
                                      : null,
                                  onSaved: (value) {
                                    _formData['KATEGORI KEGIATAN'] = value;
                                  },
                                );
                              },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSectionCard(
                      title: 'Pelaksana',
                      icon: PhosphorIcons.users(),
                      children: [
                        _buildDropdown(
                          "MITRA PELAKSANA",
                          mitraPelaksanaOptions,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('SIMPAN DATA'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String fieldName, List<String> options) {
    return DropdownButtonFormField<String>(
      value: _formData[fieldName],
      decoration: InputDecoration(
        labelText: fieldName,
        prefixIcon: Icon(_getIconForField(fieldName)),
      ),
      items: options
          .map((o) => DropdownMenuItem(value: o, child: Text(o)))
          .toList(),
      onChanged: (v) => setState(() => _formData[fieldName] = v),
      validator: (v) => (v == null) ? 'Wajib diisi' : null,
    );
  }

  IconData _getIconForField(String fieldName) {
    switch (fieldName) {
      case 'STO':
        return PhosphorIcons.buildings();
      case 'JENIS TIKET':
        return PhosphorIcons.tag();
      case 'KATEGORI KEGIATAN':
        return PhosphorIcons.listChecks();
      case 'MITRA PELAKSANA':
        return PhosphorIcons.users();
      default:
        return PhosphorIcons.question();
    }
  }
}
