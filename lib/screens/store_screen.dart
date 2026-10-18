import 'package:flutter/material.dart';

import '../models/game_state.dart';

class StoreScreen extends StatelessWidget {
  final GameState game;
  final VoidCallback onChanged;

  const StoreScreen({super.key, required this.game, required this.onChanged});

  void buyPotion(BuildContext context) {
    final success = game.buyPotion();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Potion berhasil dibeli!' : 'Coin tidak cukup.',
        ),
      ),
    );

    if (success) {
      onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/backgrounds/store_bg.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(color: const Color(0xFF071225));
          },
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'STORE',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                Text(
                  'COIN  ${game.coins}',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .55),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.local_drink,
                        size: 100,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'HEAL POTION',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Memulihkan 40 HP',
                        style: TextStyle(color: Colors.white60),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '25 COIN',
                        style: TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: FilledButton(
                          onPressed: () => buyPotion(context),
                          child: const Text(
                            'BUY POTION',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
