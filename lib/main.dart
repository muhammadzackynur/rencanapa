import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:fl_chart/fl_chart.dart'; // Pastikan fl_chart diimpor

// --- KONFIGURASI ---
// !!! GANTI DENGAN URL BARU DARI LANGKAH 2 !!!
const String googleAppScriptUrl =
    "https://script.google.com/macros/s/AKfycbxSm8xxBjdtrHYle_ix7t5ASiRZAIXi4UxCVy1w__Qa0bIIj_tFrAoGYzYi5nTtPXNoNQ/exec";

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
  final List<Widget> _pages = const [HomePage(), SearchPage(), AddFormPage()];

  void changePage(int index) {
    if (mounted) setState(() => _selectedIndex = index);
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
    // TAMPILAN ASLI ANDA DIKEMBALIKAN SEPENUHNYA
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
  // Kode SearchPage tidak diubah
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

  Future<void> _submitForm() async {
    bool allFormsValid = true;
    for (var key in _formKeys) {
      if (key.currentState?.validate() == false) allFormsValid = false;
    }
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

      String message;
      Color color;

      if (response.statusCode == 200 || response.statusCode == 302) {
        final data = json.decode(response.body);
        message = data['message'] ?? 'Status tidak diketahui.';
        color = data['status'] == 'success' ? Colors.green : Colors.red;

        if (data['status'] == 'success') {
          mainPageKey.currentState?.changePage(0);
        }
      } else {
        message = 'Terjadi kesalahan server. Kode: ${response.statusCode}';
        color = Colors.red;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal terhubung: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
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
