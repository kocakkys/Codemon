import 'package:flutter/material.dart';

import '../models/game_state.dart';

class BagScreen extends StatelessWidget {
  final GameState game;
  final VoidCallback onChanged;

  const BagScreen({
    super.key,
    required this.game,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/backgrounds/bag_bg.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(
              color: const Color(0xFF10182D),
            );
          },
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: .15),
                Colors.black.withValues(alpha: .75),
              ],
            ),
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'BAG',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Barang yang kamu miliki',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 25),
                _ItemCard(
                  icon: Icons.local_pharmacy,
                  title: 'Health Potion',
                  description: 'Memulihkan 40 HP saat battle.',
                  amount: game.potions,
                ),
                const SizedBox(height: 15),
                _ItemCard(
                  icon: Icons.monetization_on,
                  title: 'Coin',
                  description: 'Digunakan untuk membeli item.',
                  amount: game.coins,
                ),
                const SizedBox(height: 25),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .45),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white12,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.white70,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Potion hanya bisa digunakan ketika sedang bertarung.',
                          style: TextStyle(
                            color: Colors.white70,
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

class _ItemCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final int amount;

  const _ItemCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .48),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white12,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              size: 38,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'x$amount',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
