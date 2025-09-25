import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';

// URL Google Apps Script Anda
const String googleAppScriptUrl =
    "https://script.google.com/macros/s/AKfycbz7NYjCYWMnwnnKZFryrWUnefhkVvo2iEEy_zjGhjPjO2uyzT42kjKPoQtx4Lv4Aye4Kw/exec";

// --- State Management ---
class AppState extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> login(String userId) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final response = await http.get(
        Uri.parse('$googleAppScriptUrl?action=login&id=$userId'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          _isLoggedIn = true;
          notifyListeners();
          return true;
        } else {
          _errorMessage = data['message'] ?? 'ID tidak valid.';
        }
      } else {
        _errorMessage = 'Gagal terhubung ke server.';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
    }
    _setLoading(false);
    return false;
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const MyApp(),
    ),
  );
}

// --- Main App Widget ---
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
      ),
      home: Consumer<AppState>(
        builder: (context, appState, _) {
          return appState.isLoggedIn ? const HomePage() : const LoginPage();
        },
      ),
    );
  }
}

// --- HomePage ---
class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
            colors: [
              Color(0xFFE0F2F1), // Warna Teal Muda di atas
              Colors.white, // Warna Putih Tulang di bawah
            ],
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
                  // Header Kustom
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
                      const CircleAvatar(
                        backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/150?u=a042581f4e29026704d',
                        ),
                        radius: 25,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Kartu Statistik
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
                      Expanded(
                        child: StatCard(
                          title: 'Recent Digestion',
                          value: '13.8%',
                          icon: PhosphorIcons.arrowClockwise(
                            PhosphorIconsStyle.regular,
                          ),
                          iconColor: Colors.white,
                          iconBgColor: const Color(0xFFF2994A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ======================================================
                  // == PERBAIKAN BARU DIMULAI DARI SINI ==
                  // ======================================================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kartu Kiri: Account Suplant
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
                                'Account Suplant',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B1D28),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Text(
                                    '278%',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1B1D28),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0x3327AE60),
                                    ),
                                    child: Icon(
                                      PhosphorIcons.arrowUp(),
                                      size: 16,
                                      color: const Color(0xFF27AE60),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 20), // Jarak antar kartu
                      // Kartu Kanan: Grafik
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
                                height:
                                    50, // Sesuaikan tinggi grafik jika perlu
                                child: LineChart(
                                  LineChartData(
                                    gridData: FlGridData(show: false),
                                    titlesData: FlTitlesData(show: false),
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
                                        dotData: FlDotData(show: false),
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

                  // ======================================================
                  // == AKHIR DARI BAGIAN YANG DIPERBAIKI ==
                  // ======================================================
                  const SizedBox(height: 30),

                  // Quick Actions
                  const Text(
                    'Recent Activities',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B1D28),
                    ),
                  ),
                  const SizedBox(height: 15),
                  QuickActionCard(
                    icon: PhosphorIcons.lightning(PhosphorIconsStyle.fill),
                    title: 'Quick Action',
                    subtitle: 'Tambah Data Usulan',
                    iconBgColor: const Color(0xFF00BFA5),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddFormPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Tombol Bawah
                  Row(
                    children: [
                      Expanded(
                        child: BottomButton(
                          text: 'Tambah Data',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddFormPage(),
                              ),
                            );
                          },
                          isPrimary: false,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: BottomButton(
                          text: 'Cek Data',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SearchPage(),
                              ),
                            );
                          },
                          isPrimary: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: Color(0xFF00BFA5),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                PhosphorIcons.house(PhosphorIconsStyle.fill),
                color: Colors.white,
                size: 28,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(
                PhosphorIcons.squaresFour(),
                color: Colors.white.withOpacity(0.6),
                size: 28,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(
                PhosphorIcons.magnifyingGlass(),
                color: Colors.white.withOpacity(0.6),
                size: 28,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(
                PhosphorIcons.user(),
                color: Colors.white.withOpacity(0.6),
                size: 28,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

// --- Widget Kustom dan Halaman Lainnya (TIDAK ADA PERUBAHAN) ---

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

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
  final String title;
  final String subtitle;
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
                    color: Color(0xFF1B1D28),
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

class BottomButton extends StatelessWidget {
  final String text;
  final bool isPrimary;
  final VoidCallback onTap;

  const BottomButton({
    Key? key,
    required this.text,
    required this.isPrimary,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF00BFA5) : const Color(0x1A00BFA5),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isPrimary ? Colors.white : const Color(0xFF00BFA5),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _controller = TextEditingController();

  void _performLogin() async {
    if (_controller.text.isEmpty) return;
    final success = await Provider.of<AppState>(
      context,
      listen: false,
    ).login(_controller.text);
    if (!success && mounted) {
      final errorMessage = Provider.of<AppState>(
        context,
        listen: false,
      ).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? 'Login Gagal'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shield_outlined, size: 80, color: Colors.teal),
              const SizedBox(height: 20),
              const Text(
                'Selamat Datang',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Silakan masukkan ID Anda untuk melanjutkan',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'ID Pengguna',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 20),
              Consumer<AppState>(
                builder: (context, appState, _) {
                  return appState.isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _performLogin,
                            child: const Text('LOGIN'),
                          ),
                        );
                },
              ),
            ],
          ),
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
  final _controller = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _searchResult;
  String? _message;

  Future<void> _performSearch() async {
    if (_controller.text.isEmpty) return;
    setState(() {
      _isLoading = true;
      _searchResult = null;
      _message = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
          '$googleAppScriptUrl?action=search&keyword=${_controller.text}',
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          _searchResult = data['data'];
        } else {
          _message = data['message'] ?? 'Data tidak ditemukan.';
        }
      } else {
        _message = 'Gagal terhubung ke server.';
      }
    } catch (e) {
      _message = 'Terjadi kesalahan: $e';
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cek Data')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Cari No, Tiket/SC, atau Nama IHLD',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _performSearch,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _searchResult != null
                  ? SearchResultView(data: _searchResult!)
                  : Center(
                      child: Text(
                        _message ?? 'Hasil pencarian akan tampil di sini.',
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchResultView extends StatelessWidget {
  final Map<String, dynamic> data;
  const SearchResultView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    const displayOrder = [
      "NO",
      "DISTRICT",
      "WITEL",
      "STO",
      "NAMA IHLD",
      "NOMOR SC",
      "TIKET INFRACARE",
      "TIKET GANGGUAN",
      "URAIAN PEKERJAAN",
      "MITRA PELAKSANA",
      "KATEGORI KEGIATAN",
      "STATUS PEKERJAAN",
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            "✅ Data Ditemukan",
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.teal),
          ),
          const Divider(thickness: 1.5, height: 20),
          for (var header in displayOrder)
            if (data.containsKey(header) && data[header].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: '$header: ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: data[header].toString()),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class AddFormPage extends StatefulWidget {
  const AddFormPage({super.key});
  @override
  State<AddFormPage> createState() => _AddFormPageState();
}

class _AddFormPageState extends State<AddFormPage> {
  int _currentStep = 0;
  final _formKeys = List.generate(4, (_) => GlobalKey<FormState>());
  final Map<String, dynamic> _formData = {};
  final _nomorTiketController = TextEditingController();
  final _uraianPekerjaanController = TextEditingController();
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
  final kategoriKegiatanOptions = [
    "PENGAWALAN",
    "GAMAS",
    "TIANG KEROPOS",
    "BENJAR",
    "MH RUSAK",
    "TERJUNTAI",
    "PENEGAKAN ODC",
    "GANTI ODP",
    "PENINGGIAN KU",
    "RELOKASI ALPRO",
    "TAMBAH TIANG",
    "PSB",
    "TIANG PATAH",
    "PERMANENISASI",
    "TUTUP MH",
    "PEMBONGKARAN ALPRO",
    "DUAL HOMING",
  ];
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
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse(googleAppScriptUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(_formData),
      );
      String message = 'Terjadi kesalahan.';
      Color color = Colors.red;
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        message = data['message'] ?? 'Status tidak diketahui.';
        if (data['status'] == 'success') {
          color = Colors.green;
          if (mounted) Navigator.pop(context);
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: color),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Data Usulan')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stepper(
              currentStep: _currentStep,
              onStepContinue: () {
                final isLastStep = _currentStep == getSteps().length - 1;
                if (isLastStep) {
                  _submitForm();
                } else {
                  if (_formKeys[_currentStep].currentState!.validate()) {
                    setState(() => _currentStep += 1);
                  }
                }
              },
              onStepCancel: _currentStep == 0
                  ? null
                  : () => setState(() => _currentStep -= 1),
              onStepTapped: (step) => setState(() => _currentStep = step),
              steps: getSteps(),
            ),
    );
  }

  List<Step> getSteps() => [
    Step(
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      isActive: _currentStep >= 0,
      title: const Text('Info Dasar'),
      content: Form(
        key: _formKeys[0],
        child: Column(
          children: [
            _buildDropdown("STO", stoOptions),
            const SizedBox(height: 16),
            _buildDropdown("JENIS TIKET", jenisTiketOptions),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nomorTiketController,
              decoration: const InputDecoration(
                labelText: 'NOMOR TIKET/SC',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Wajib diisi' : null,
              onChanged: (value) => _formData['NOMOR TIKET/SC'] = value,
            ),
          ],
        ),
      ),
    ),
    Step(
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      isActive: _currentStep >= 1,
      title: const Text('Detail Pekerjaan'),
      content: Form(
        key: _formKeys[1],
        child: Column(
          children: [
            TextFormField(
              controller: _uraianPekerjaanController,
              decoration: const InputDecoration(
                labelText: 'URAIAN PEKERJAAN',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Wajib diisi' : null,
              onChanged: (value) => _formData['URAIAN PEKERJAAN'] = value,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildDropdown("KATEGORI KEGIATAN", kategoriKegiatanOptions),
          ],
        ),
      ),
    ),
    Step(
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      isActive: _currentStep >= 2,
      title: const Text('Pelaksana'),
      content: Form(
        key: _formKeys[2],
        child: Column(
          children: [_buildDropdown("MITRA PELAKSANA", mitraPelaksanaOptions)],
        ),
      ),
    ),
    Step(
      isActive: _currentStep >= 3,
      title: const Text('Konfirmasi'),
      content: Form(
        key: _formKeys[3],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Mohon periksa kembali data Anda sebelum disimpan:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ..._formData.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: '${entry.key}: ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: entry.value.toString()),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ];

  Widget _buildDropdown(String fieldName, List<String> options) {
    return DropdownButtonFormField<String>(
      value: _formData[fieldName],
      decoration: InputDecoration(
        labelText: fieldName,
        border: const OutlineInputBorder(),
      ),
      items: options
          .map((option) => DropdownMenuItem(value: option, child: Text(option)))
          .toList(),
      onChanged: (value) {
        setState(() {
          _formData[fieldName] = value;
        });
      },
      validator: (value) => (value == null) ? 'Wajib dipilih' : null,
    );
  }
}
