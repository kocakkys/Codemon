import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'models/game_state.dart';
import 'screens/bag_screen.dart';
import 'screens/computer_screen.dart';
import 'screens/home_screen.dart';
import 'screens/store_screen.dart';
import 'screens/world_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final GameState game = GameState();

  int currentIndex = 0;

  void refresh() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(game: game, onChanged: refresh),
      WorldScreen(game: game, onChanged: refresh),
      ComputerScreen(game: game, onChanged: refresh),
      StoreScreen(game: game, onChanged: refresh),
      BagScreen(game: game, onChanged: refresh),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Codemon',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF071225),
      ),
      home: Scaffold(
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
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.public),
              selectedIcon: Icon(Icons.public),
              label: 'World',
            ),
            NavigationDestination(
              icon: Icon(Icons.computer),
              selectedIcon: Icon(Icons.computer),
              label: 'Computer',
            ),
            NavigationDestination(
              icon: Icon(Icons.storefront),
              selectedIcon: Icon(Icons.storefront),
              label: 'Store',
            ),
            NavigationDestination(
              icon: Icon(Icons.backpack_outlined),
              selectedIcon: Icon(Icons.backpack),
              label: 'Bag',
            ),
          ],
        ),
      ),
    );
  }
}
