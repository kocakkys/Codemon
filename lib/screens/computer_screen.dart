import 'package:flutter/material.dart';

import '../models/codemon.dart';
import '../models/game_state.dart';

class ComputerScreen extends StatefulWidget {
  final GameState game;
  final VoidCallback onChanged;

  const ComputerScreen({
    super.key,
    required this.game,
    required this.onChanged,
  });

  @override
  State<ComputerScreen> createState() => _ComputerScreenState();
}

class _ComputerScreenState extends State<ComputerScreen> {
  String filter = 'ALL';

  List<OwnedCodemon> get filtered {
    if (filter == 'ALL') {
      return widget.game.ownedCodemons;
    }

    return widget.game.ownedCodemons
        .where(
          (codemon) => codemon.language.toUpperCase() == filter,
        )
        .toList();
  }

  void equip(OwnedCodemon codemon) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pilih Slot',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 15),
                Row(
                  children: List.generate(
                    3,
                    (index) {
                      final active =
                          widget.game.activeSlots[index] == codemon.uid;

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: FilledButton(
                            onPressed: () {
                              widget.game.equipCodemon(
                                codemon.uid,
                                index,
                              );

                              Navigator.pop(context);

                              widget.onChanged();

                              setState(() {});
                            },
                            child: Text(
                              active
                                  ? 'Slot ${index + 1} ✓'
                                  : 'Slot ${index + 1}',
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void merge(OwnedCodemon codemon) {
    final candidates = widget.game.ownedCodemons
        .where(
          (c) =>
              c.baseId == codemon.baseId &&
              c.level == codemon.level &&
              !widget.game.isEquipped(c.uid),
        )
        .take(3)
        .toList();

    if (candidates.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Butuh 3 ${codemon.name} Lv ${codemon.level} '
            'yang tidak sedang dipakai.',
          ),
        ),
      );

      return;
    }

    final total = candidates.fold<int>(
      0,
      (sum, item) => sum + item.damage,
    );

    final resultDamage = (total * 0.75).floor();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'MERGE CODEMON',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${codemon.name} Lv ${codemon.level}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              ...candidates.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.name),
                      Text(
                        'DMG ${item.damage}',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              Text(
                'Total DMG: $total',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Potongan Merge: 25%',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Lv ${codemon.level + 1} → DMG $resultDamage',
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
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
                Navigator.pop(dialogContext);

                final success = widget.game.mergeCodemon(
                  codemon.baseId,
                  codemon.level,
                );

                if (success) {
                  widget.onChanged();
                  setState(() {});

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${codemon.name} berhasil merge! '
                        'DMG baru: $resultDamage',
                      ),
                    ),
                  );
                }
              },
              child: const Text('MERGE'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/backgrounds/computer_bg.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(
              color: const Color(0xFF071225),
            );
          },
        ),
        SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 15),
              const Text(
                'COMPUTER',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const Text(
                'CODEMON COLLECTION',
                style: TextStyle(
                  color: Colors.white60,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.45),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Battle Point',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${widget.game.battlePoint}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 45,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  children: [
                    _filterButton('ALL'),
                    _filterButton('HTML'),
                    _filterButton('CSS'),
                    _filterButton('JAVASCRIPT'),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(15),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: .70,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final codemon = filtered[index];

                    return _CodemonCard(
                      codemon: codemon,
                      equipped: widget.game.isEquipped(
                        codemon.uid,
                      ),
                      onEquip: () => equip(codemon),
                      onMerge: () => merge(codemon),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _filterButton(String value) {
    final selected = filter == value;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(value),
        selected: selected,
        onSelected: (_) {
          setState(() {
            filter = value;
          });
        },
      ),
    );
  }
}

// ================================================================
// CODEMON CARD
// ================================================================

class _CodemonCard extends StatelessWidget {
  final OwnedCodemon codemon;
  final bool equipped;
  final VoidCallback onEquip;
  final VoidCallback onMerge;

  const _CodemonCard({
    required this.codemon,
    required this.equipped,
    required this.onEquip,
    required this.onMerge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: equipped ? Colors.greenAccent : Colors.white12,
          width: equipped ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: Image.asset(
              codemon.image,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return const Icon(
                  Icons.pets,
                  size: 90,
                );
              },
            ),
          ),
          Text(
            codemon.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            'Lv ${codemon.level}',
            style: const TextStyle(
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'DMG ${codemon.damage}',
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onEquip,
                  child: Text(
                    equipped ? 'EQUIPPED' : 'EQUIP',
                    style: const TextStyle(
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              IconButton(
                onPressed: onMerge,
                icon: const Icon(
                  Icons.merge_type,
                ),
                tooltip: 'Merge 3 Codemon',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
