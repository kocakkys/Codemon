import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'firebase_options.dart';
import 'models/game_state.dart';
import 'screens/auth_screen.dart';
import 'screens/bag_screen.dart';
import 'screens/computer_screen.dart';
import 'screens/home_screen.dart';
import 'screens/store_screen.dart';
import 'screens/world_screen.dart';
import 'services/game_save_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }

  runApp(const CodemonApp());
}

class CodemonApp extends StatelessWidget {
  const CodemonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Codemon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF38BDF8),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF071225),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF071225),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          return const AuthScreen();
        }

        return GameHome(
          key: ValueKey(user.uid),
          username: user.displayName,
        );
      },
    );
  }
}

class GameHome extends StatefulWidget {
  final String? username;

  const GameHome({
    super.key,
    this.username,
  });

  @override
  State<GameHome> createState() => _GameHomeState();
}

class _GameHomeState extends State<GameHome> {
  final GameState game = GameState();
  final GameSaveService _saveService = GameSaveService();

  int currentIndex = 0;
  bool _loadingProgress = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    if (!mounted) return;

    setState(() {
      _loadingProgress = true;
      _loadError = null;
    });

    try {
      // Muat progres berdasarkan UID akun yang sedang login.
      final hasSavedData = await _saveService.load(game);

      // Sinkronkan nama pemain dengan nama akun Firebase.
      final username = widget.username?.trim();

      if (username != null && username.isNotEmpty) {
        game.playerName = username;
      }

      // Akun baru akan menyimpan progres awal beserta Codemon starter.
      // Akun lama juga disimpan kembali untuk menyinkronkan nama pemain.
      if (!hasSavedData || (username != null && username.isNotEmpty)) {
        await _saveService.save(game);
      }

      if (!mounted) return;

      setState(() {
        _loadingProgress = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingProgress = false;
        _loadError = e.toString();
      });
    }
  }

  Future<bool> _saveProgress() async {
    try {
      await _saveService.save(game);
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan progres: $e'),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return false;
    }
  }

  void refresh() {
    if (!mounted) return;

    setState(() {});

    // Jangan menyimpan sebelum data akun selesai dimuat.
    if (!_loadingProgress && _loadError == null) {
      _saveProgress();
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Yakin ingin keluar dari akun Codemon?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    // Simpan progres sebelum keluar dari akun.
    final saved = await _saveProgress();

    if (!saved || !mounted) return;

    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingProgress) {
      return const Scaffold(
        backgroundColor: Color(0xFF071225),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memuat progres Codemon...'),
            ],
          ),
        ),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF071225),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off_rounded,
                  size: 56,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Gagal memuat progres',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _loadError!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _loadProgress,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final pages = <Widget>[
      HomeScreen(game: game, onChanged: refresh),
      WorldScreen(game: game, onChanged: refresh),
      ComputerScreen(game: game, onChanged: refresh),
      StoreScreen(game: game, onChanged: refresh),
      BagScreen(game: game, onChanged: refresh),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CODEMON',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              tooltip: 'Logout',
              onPressed: _logout,
              icon: const Icon(Icons.logout_rounded),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.public_outlined),
            selectedIcon: Icon(Icons.public_rounded),
            label: 'World',
          ),
          NavigationDestination(
            icon: Icon(Icons.catching_pokemon_outlined),
            selectedIcon: Icon(Icons.catching_pokemon_rounded),
            label: 'Computer',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront_rounded),
            label: 'Store',
          ),
          NavigationDestination(
            icon: Icon(Icons.backpack_outlined),
            selectedIcon: Icon(Icons.backpack_rounded),
            label: 'Bag',
          ),
        ],
      ),
    );
  }
}
