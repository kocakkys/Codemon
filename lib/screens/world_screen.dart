import 'dart:math';

import 'package:flutter/material.dart';

import '../data/game_data.dart';
import '../models/enemy.dart';
import '../models/game_state.dart';
import 'battle_screen.dart';

class WorldScreen extends StatefulWidget {
  final GameState game;
  final VoidCallback onChanged;

  const WorldScreen({
    super.key,
    required this.game,
    required this.onChanged,
  });

  @override
  State<WorldScreen> createState() => _WorldScreenState();
}

class _WorldScreenState extends State<WorldScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 2,
      ),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  void _openBattle(Enemy enemy) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BattleScreen(
          game: widget.game,
          enemy: enemy,
          onChanged: widget.onChanged,
        ),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {});
      }

      widget.onChanged();
    });
  }

  void _showWorldQuest({
    required String world,
    required bool unlocked,
    required List<_QuestRequirement> requirements,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF5F7FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Icon(
                unlocked ? Icons.lock_open : Icons.lock,
                color: unlocked ? Colors.green : Colors.redAccent,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$world QUEST',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                unlocked ? 'WORLD TERBUKA!' : 'Selesaikan persyaratan berikut:',
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              ...requirements.map(
                (requirement) {
                  return Container(
                    margin: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: requirement.completed
                          ? Colors.green.withOpacity(.10)
                          : Colors.black.withOpacity(.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: requirement.completed
                            ? Colors.green
                            : Colors.black12,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          requirement.completed
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: requirement.completed
                              ? Colors.green
                              : Colors.black38,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            requirement.text,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'TUTUP',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final htmlQuest = [
      _QuestRequirement(
        text: 'HTML Slime 10x',
        current: widget.game.htmlSlimeWins,
        target: 10,
      ),
      _QuestRequirement(
        text: 'HTML Goblin 5x',
        current: widget.game.htmlGoblinWins,
        target: 5,
      ),
      _QuestRequirement(
        text: 'HTML Dragon 3x',
        current: widget.game.htmlDragonWins,
        target: 3,
      ),
    ];

    final cssQuest = [
      _QuestRequirement(
        text: 'CSS Slime 10x',
        current: widget.game.cssSlimeWins,
        target: 10,
      ),
      _QuestRequirement(
        text: 'CSS Goblin 5x',
        current: widget.game.cssGoblinWins,
        target: 5,
      ),
      _QuestRequirement(
        text: 'CSS Dragon 3x',
        current: widget.game.cssDragonWins,
        target: 3,
      ),
    ];

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/backgrounds/world_bg.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF06152F),
                    Color(0xFF101A45),
                    Color(0xFF050916),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            );
          },
        ),
        Container(
          color: Colors.black.withOpacity(.18),
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              16,
              18,
              16,
              30,
            ),
            child: Column(
              children: [
                const Text(
                  'WORLD',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),

                const Text(
                  'CODING ADVENTURE',
                  style: TextStyle(
                    color: Colors.white60,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                // ==================================================
                // HTML
                // ==================================================

                _WorldSection(
                  worldName: 'WORLD 1',
                  language: 'HTML',
                  unlocked: true,
                  color: const Color(0xFFE44D26),
                  enemies: htmlEnemies,
                  onEnemyTap: _openBattle,
                  floatController: _floatController,
                  questButton: null,
                ),

                const SizedBox(height: 30),

                // ==================================================
                // CSS
                // ==================================================

                _WorldSection(
                  worldName: 'WORLD 2',
                  language: 'CSS',
                  unlocked: widget.game.cssUnlocked,
                  color: const Color(0xFF2965F1),
                  enemies: cssEnemies,
                  onEnemyTap: widget.game.cssUnlocked ? _openBattle : null,
                  floatController: _floatController,
                  questButton: () {
                    _showWorldQuest(
                      world: 'CSS',
                      unlocked: widget.game.cssUnlocked,
                      requirements: htmlQuest,
                    );
                  },
                ),

                const SizedBox(height: 30),

                // ==================================================
                // JAVASCRIPT
                // ==================================================

                _WorldSection(
                  worldName: 'WORLD 3',
                  language: 'JAVASCRIPT',
                  unlocked: widget.game.javascriptUnlocked,
                  color: const Color(0xFFF7DF1E),
                  enemies: javascriptEnemies,
                  onEnemyTap:
                      widget.game.javascriptUnlocked ? _openBattle : null,
                  floatController: _floatController,
                  questButton: () {
                    _showWorldQuest(
                      world: 'JAVASCRIPT',
                      unlocked: widget.game.javascriptUnlocked,
                      requirements: cssQuest,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ================================================================
// WORLD SECTION
// ================================================================

class _WorldSection extends StatelessWidget {
  final String worldName;
  final String language;
  final bool unlocked;
  final Color color;

  final List<Enemy> enemies;

  final void Function(Enemy enemy)? onEnemyTap;

  final AnimationController floatController;

  final VoidCallback? questButton;

  const _WorldSection({
    required this.worldName,
    required this.language,
    required this.unlocked,
    required this.color,
    required this.enemies,
    required this.onEnemyTap,
    required this.floatController,
    required this.questButton,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        14,
        18,
        14,
        18,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.38),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: unlocked ? color.withOpacity(.55) : Colors.white12,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(.18),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color,
                    width: 2,
                  ),
                ),
                child: Icon(
                  unlocked ? Icons.code : Icons.lock,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      worldName,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      language,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ========================================================
          // TOWER
          // ========================================================

          Container(
            height: 70,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.35),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 32,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: color.withOpacity(.30),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(18),
                    ),
                  ),
                ),

                // Tower top
                Container(
                  height: 55,
                  width: 170,
                  decoration: BoxDecoration(
                    color: color.withOpacity(.25),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    border: Border.all(
                      color: color.withOpacity(.50),
                      width: 2,
                    ),
                  ),
                ),

                Positioned(
                  bottom: 5,
                  child: Container(
                    width: 90,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color.withOpacity(.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ========================================================
          // ENEMIES
          // ========================================================

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              enemies.length,
              (index) {
                final enemy = enemies[index];

                return Expanded(
                  child: _FloatingEnemy(
                    enemy: enemy,
                    color: color,
                    unlocked: unlocked,
                    controller: floatController,
                    onTap: onEnemyTap == null ? null : () => onEnemyTap!(enemy),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 18),

          // ========================================================
          // QUEST BUTTON
          // ========================================================

          if (!unlocked && questButton != null)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: questButton,
                icon: const Icon(
                  Icons.assignment,
                ),
                label: const Text(
                  'LIHAT QUEST UNLOCK',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                ),
              ),
            ),

          if (unlocked)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.greenAccent.withOpacity(.5),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_open,
                    color: Colors.greenAccent,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'WORLD TERBUKA',
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ================================================================
// FLOATING ENEMY
// ================================================================

class _FloatingEnemy extends StatelessWidget {
  final Enemy enemy;
  final Color color;
  final bool unlocked;
  final AnimationController controller;
  final VoidCallback? onTap;

  const _FloatingEnemy({
    required this.enemy,
    required this.color,
    required this.unlocked,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final phase = controller.value * pi * 2;

        final offsetY = sin(
              phase + enemy.recommendedMin,
            ) *
            8;

        return Transform.translate(
          offset: Offset(
            0,
            offsetY,
          ),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: Opacity(
          opacity: unlocked ? 1 : .35,
          child: Column(
            children: [
              Container(
                height: 105,
                width: 105,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.35),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: unlocked ? color : Colors.white24,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(.20),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: unlocked
                    ? Image.asset(
                        enemy.image,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) {
                          return const Icon(
                            Icons.pets,
                            size: 50,
                          );
                        },
                      )
                    : const Icon(
                        Icons.lock,
                        size: 40,
                        color: Colors.white54,
                      ),
              ),
              const SizedBox(height: 8),
              Text(
                enemy.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Lv ${enemy.recommendedMin}-${enemy.recommendedMax}',
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// QUEST REQUIREMENT
// ================================================================

class _QuestRequirement {
  final String text;
  final int current;
  final int target;

  const _QuestRequirement({
    required this.text,
    required this.current,
    required this.target,
  });

  bool get completed {
    return current >= target;
  }
}
