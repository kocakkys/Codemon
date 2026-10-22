import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/game_state.dart';

class HomeScreen extends StatefulWidget {
  final GameState game;
  final VoidCallback onChanged;

  const HomeScreen({super.key, required this.game, required this.onChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker picker = ImagePicker();

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

      // Simpan foto dan progres ke Firebase.
      widget.onChanged();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto profil berhasil diperbarui!'),
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

  Future<void> changeName() async {
    final controller = TextEditingController(
      text: widget.game.playerName,
    );

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Nama Player'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Masukkan nama baru',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('BATAL'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  controller.text.trim(),
                );
              },
              child: const Text('SIMPAN'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null || result.isEmpty || !mounted) {
      return;
    }

    try {
      // Simpan username ke profil akun Firebase.
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.updateDisplayName(result);
        await user.reload();
      }

      if (!mounted) return;

      // Perbarui nama yang tampil di Home.
      widget.game.playerName = result;
      widget.onChanged();
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username berhasil diperbarui!'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui username: ${e.message}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/backgrounds/home_bg.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(color: const Color(0xFF09152E));
          },
        ),
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
                const Text(
                  'CODEMON',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'CODING ADVENTURE',
                  style: TextStyle(color: Colors.white70, letterSpacing: 2),
                ),
                const SizedBox(height: 35),
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
                const SizedBox(height: 15),
                Text(
                  game.playerName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                TextButton.icon(
                  onPressed: changeName,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profil'),
                ),
                const SizedBox(height: 20),
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
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .45),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'PLAYER HP',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('${game.hp}/${game.maxHp}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: game.hp / game.maxHp,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .45),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.code, size: 42),
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
                              style: const TextStyle(color: Colors.white70),
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
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 30),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 10, color: Colors.white60),
          ),
        ],
      ),
    );
  }
}
