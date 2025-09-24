import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';

// =======================================================================
// !!! PENTING: Ganti URL di bawah ini dengan URL Web App dari Google Apps Script Anda !!!
const String googleAppScriptUrl =
    "https://script.google.com/macros/s/AKfycbz7NYjCYWMnwnnKZFryrWUnefhkVvo2iEEy_zjGhjPjO2uyzT42kjKPoQtx4Lv4Aye4Kw/exec";
// =======================================================================

// --- Data Model & State Management ---
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
      // --- BARIS INI DITAMBAHKAN UNTUK MENGHILANGKAN BANNER DEBUG ---
      debugShowCheckedModeBanner: false,
      // -----------------------------------------------------------
      title: 'Data Usulan App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: Consumer<AppState>(
        builder: (context, appState, _) {
          return appState.isLoggedIn ? const HomePage() : const LoginPage();
        },
      ),
    );
  }
}

// --- Screens ---

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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Utama'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                Provider.of<AppState>(context, listen: false).logout(),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Tambah Data Usulan'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddFormPage()),
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.search),
                label: const Text('Cek Data Usulan'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchPage()),
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
    // Daftar header yang ingin ditampilkan dan urutannya
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

// --- Form Page (using Stepper) ---
class AddFormPage extends StatefulWidget {
  const AddFormPage({super.key});

  @override
  State<AddFormPage> createState() => _AddFormPageState();
}

class _AddFormPageState extends State<AddFormPage> {
  int _currentStep = 0;
  final _formKeys = List.generate(4, (_) => GlobalKey<FormState>());

  // Form Data
  final Map<String, dynamic> _formData = {};
  final _nomorTiketController = TextEditingController();
  final _uraianPekerjaanController = TextEditingController();

  // Options (sama seperti di kode Python)
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
                  // Validasi form sebelum lanjut
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
