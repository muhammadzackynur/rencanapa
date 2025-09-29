import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:ui'; // Diperlukan untuk PathMetric
import 'package:http/http.dart' as http;
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

// --- KONFIGURASI ---
const String googleAppScriptUrl =
    "https://script.google.com/macros/s/AKfycbwYm7P6PcN3SphqCGn6AMFSEvMdHQDfehSLKSgRRyPEEc87rn6Ygu8ue3BIQQjlVJktWg/exec";

final GlobalKey<_MainPageState> mainPageKey = GlobalKey<_MainPageState>();

void main() {
  runApp(const MyApp());
}

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
      ),
      home: MainPage(key: mainPageKey),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final AddFormPage _addFormPage = const AddFormPage();
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [const HomePage(), const SearchPage(), _addFormPage];
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
                      const CircleAvatar(
                        backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/150?u=a042581f4e29026704d',
                        ),
                        radius: 25,
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

        return Card(
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
        );
      },
    );
  }
}

class AllDataPage extends StatefulWidget {
  const AllDataPage({super.key});

  @override
  State<AllDataPage> createState() => _AllDataPageState();
}

class _AllDataPageState extends State<AllDataPage> {
  bool _isLoading = true;
  List<dynamic> _allData = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    try {
      final uri = Uri.parse("$googleAppScriptUrl?action=getAll");
      final response = await http.get(uri).timeout(const Duration(seconds: 60));
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'success') {
          setState(() {
            _allData = result['data'];
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
      appBar: AppBar(title: const Text('Semua Data Usulan')),
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
    if (_allData.isEmpty) {
      return const Center(child: Text('Tidak ada data.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _allData.length,
      itemBuilder: (context, index) {
        final item = _allData[index];
        final no = item['NO']?.toString() ?? '-';
        final sto = item['STO']?.toString() ?? 'N/A';
        final uraian =
            item['URAIAN PEKERJAAN']?.toString() ?? 'Tidak ada uraian';

        return Card(
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
        );
      },
    );
  }
}

// =========================================================================
// WIDGET YANG HILANG (DIKEMBALIKAN)
// =========================================================================
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
// =========================================================================

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

    for (PathMetric pathMetric in path.computeMetrics()) {
      final Path extractPath = pathMetric.extractPath(
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

class AddFormPage extends StatefulWidget {
  const AddFormPage({super.key});
  @override
  State<AddFormPage> createState() => _AddFormPageState();
}

class _AddFormPageState extends State<AddFormPage> {
  int _currentStep = 0;
  final _formKeys = List.generate(4, (_) => GlobalKey<FormState>());
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 200,
            padding: const EdgeInsets.all(20.0),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SuccessCheckmarkAnimation(size: 80.0),
                SizedBox(height: 16),
                Text(
                  'Data Sudah Ditambah!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        mainPageKey.currentState?.changePage(0);

        _formData.clear();
        for (var key in _formKeys) {
          key.currentState?.reset();
        }
        setState(() {
          _currentStep = 0;
        });
      }
    });
  }

  Future<void> _submitForm() async {
    bool allFormsValid = _formKeys.every(
      (key) => key.currentState?.validate() ?? false,
    );

    if (!allFormsValid) {
      for (int i = 0; i < _formKeys.length; i++) {
        if (_formKeys[i].currentState?.validate() == false) {
          setState(() => _currentStep = i);
          break;
        }
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http
          .post(
            Uri.parse(googleAppScriptUrl),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: json.encode({'action': 'addData', 'data': _formData}),
          )
          .timeout(const Duration(seconds: 30));

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 302) {
        try {
          final data = json.decode(response.body);
          if (data['status'] == 'success') {
            _showSuccessDialog();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(data['message'] ?? 'Terjadi error di server'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } on FormatException {
          _showSuccessDialog();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menghubungi server. Kode: ${response.statusCode}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi masalah koneksi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                if (_formKeys[_currentStep].currentState?.validate() == true) {
                  if (isLastStep) {
                    _submitForm();
                  } else {
                    setState(() => _currentStep += 1);
                  }
                }
              },
              onStepCancel: _currentStep == 0
                  ? null
                  : () => setState(() => _currentStep -= 1),
              onStepTapped: (step) => setState(() => _currentStep = step),
              steps: getSteps(),
              controlsBuilder: (context, details) {
                final isLastStep = _currentStep == getSteps().length - 1;
                return Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: details.onStepContinue,
                          child: Text(isLastStep ? 'SIMPAN' : 'LANJUT'),
                        ),
                      ),
                      if (_currentStep != 0) const SizedBox(width: 12),
                      if (_currentStep != 0)
                        Expanded(
                          child: TextButton(
                            onPressed: details.onStepCancel,
                            child: const Text('KEMBALI'),
                          ),
                        ),
                    ],
                  ),
                );
              },
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
              decoration: const InputDecoration(
                labelText: 'NOMOR TIKET/SC',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
              onChanged: (v) => _formData['NOMOR TIKET/SC'] = v,
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
              decoration: const InputDecoration(
                labelText: 'URAIAN PEKERJAAN',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
              onChanged: (v) => _formData['URAIAN PEKERJAAN'] = v,
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
              "Mohon periksa kembali data Anda:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ..._formData.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: '${e.key}: ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: e.value.toString()),
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
          .map((o) => DropdownMenuItem(value: o, child: Text(o)))
          .toList(),
      onChanged: (v) => setState(() => _formData[fieldName] = v),
      validator: (v) => (v == null) ? 'Wajib dipilih' : null,
    );
  }
}
