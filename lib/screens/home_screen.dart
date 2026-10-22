import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/game_state.dart';

class HomeScreen extends StatefulWidget {
  final GameState game;
  final VoidCallback onChanged;

  const HomeScreen({
    super.key,
    required this.game,
    required this.onChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker picker = ImagePicker();

  // Mengubah foto profil player.
  Future<void> changePhoto() async {
    try {
      final file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 60,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (file == null || !mounted) return;

      final bytes = await file.readAsBytes();

      if (!mounted) return;

      setState(() {
        widget.game.playerPhoto = bytes;
      });

      widget.onChanged();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto player berhasil diperbarui!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih foto: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;

    // XP untuk level berikutnya.
    final int xpTarget = game.expNeeded;
    final int currentXp = game.exp.clamp(0, xpTarget);
    final double xpProgress =
        xpTarget > 0 ? (currentXp / xpTarget).clamp(0.0, 1.0) : 0.0;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Home.
        Image.asset(
          'assets/backgrounds/home_bg.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(
              color: const Color(0xFF09152E),
            );
          },
        ),

        // Lapisan gelap agar tulisan mudah dibaca.
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: .15),
                Colors.black.withValues(alpha: .65),
              ],
            ),
          ),
        ),

        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 15),

                const SizedBox(height: 5),

                const Text(
                  'CODING ADVENTURE',
                  style: TextStyle(
                    color: Colors.white70,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 35),

                // Foto profil player.
                GestureDetector(
                  onTap: changePhoto,
                  child: CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.white,
                    backgroundImage: game.playerPhoto != null
                        ? MemoryImage(game.playerPhoto!)
                        : null,
                    child: game.playerPhoto == null
                        ? const Icon(
                            Icons.person,
                            size: 70,
                            color: Colors.black54,
                          )
                        : null,
                  ),
                ),

                const SizedBox(height: 10),

                // Tombol untuk mengganti foto.
                TextButton.icon(
                  onPressed: changePhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Ubah Foto Player'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF64D8FF),
                  ),
                ),

                const SizedBox(height: 5),

                // Nama player hanya ditampilkan.
                Text(
                  game.playerName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 20),

                // Level dan coin.
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'LEVEL',
                        value: '${game.level}',
                        icon: Icons.star,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        title: 'COIN',
                        value: '${game.coins}',
                        icon: Icons.monetization_on,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Battle Point dan jumlah Codemon.
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'BATTLE POINT',
                        value: '${game.battlePoint}',
                        icon: Icons.flash_on,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        title: 'CODEMON',
                        value: '${game.ownedCodemons.length}',
                        icon: Icons.pets,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // XP Bar.
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .45),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white24,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.bolt,
                                color: Color(0xFFFFD54F),
                                size: 20,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'PLAYER XP',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Text('$currentXp/$xpTarget XP'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: xpProgress,
                          minHeight: 10,
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFFFD54F),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${(xpProgress * 100).toStringAsFixed(0)}% menuju Level ${game.level + 1}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // HP Bar.
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .45),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white24,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'PLAYER HP',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('${game.hp}/${game.maxHp}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: game.maxHp > 0
                            ? (game.hp / game.maxHp).clamp(0.0, 1.0)
                            : 0.0,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                // Coding Journey.
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .45),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.code,
                        size: 42,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CODING JOURNEY',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              game.javascriptUnlocked
                                  ? 'HTML • CSS • JavaScript'
                                  : game.cssUnlocked
                                      ? 'HTML • CSS'
                                      : 'HTML',
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                          ],
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .48),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white12,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 30,
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }
}
