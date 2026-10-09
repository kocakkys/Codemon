import 'dart:math';
import 'dart:typed_data';

import '../data/game_data.dart';
import 'codemon.dart';

class GameState {
  String playerName = 'Player';
  Uint8List? playerPhoto;

  int level = 1;
  int exp = 0;

  int maxHp = 100;
  int hp = 100;

  int coins = 100;
  int potions = 3;

  final Random _random = Random();

  final Map<String, int> wins = {
    'html_slime': 0,
    'html_goblin': 0,
    'html_dragon': 0,
    'css_slime': 0,
    'css_goblin': 0,
    'css_dragon': 0,
    'javascript_slime': 0,
    'javascript_goblin': 0,
    'javascript_dragon': 0,
  };

  final List<OwnedCodemon> ownedCodemons = [];

  final List<String?> activeSlots = [
    null,
    null,
    null,
  ];

  GameState() {
    // ==========================================================
    // STARTER CODEMON
    // ==========================================================

    final starter = createStarterCodemon();

    if (starter != null) {
      ownedCodemons.add(starter);
      activeSlots[0] = starter.uid;
    }
  }

  // ============================================================
  // STARTER
  // ============================================================

  OwnedCodemon? createStarterCodemon() {
    final definition = codemonDefinition('html_slime');

    if (definition == null) {
      return null;
    }

    return OwnedCodemon(
      uid: 'starter_html_slime',
      baseId: definition.id,
      name: definition.name,
      language: definition.language,
      image: definition.image,
      damage: 50,
      level: 1,
    );
  }

  // ============================================================
  // RANDOM DAMAGE
  // ============================================================

  int randomDamage(CodemonDefinition definition) {
    return definition.minDamage +
        _random.nextInt(
          definition.maxDamage - definition.minDamage + 1,
        );
  }

  // ============================================================
  // CREATE CODEMON
  // ============================================================

  OwnedCodemon? createCodemon(
    String baseId, {
    int? damage,
    int level = 1,
  }) {
    final definition = codemonDefinition(baseId);

    if (definition == null) {
      return null;
    }

    final uid =
        '${baseId}_${DateTime.now().microsecondsSinceEpoch}_${ownedCodemons.length}';

    return OwnedCodemon(
      uid: uid,
      baseId: definition.id,
      name: definition.name,
      language: definition.language,
      image: definition.image,
      damage: damage ?? randomDamage(definition),
      level: level,
    );
  }

  // ============================================================
  // GET CODEMON
  // ============================================================

  OwnedCodemon? getCodemonByUid(String uid) {
    for (final codemon in ownedCodemons) {
      if (codemon.uid == uid) {
        return codemon;
      }
    }

    return null;
  }

  CodemonDefinition? getDefinition(String id) {
    return codemonDefinition(id);
  }

  List<OwnedCodemon> get activeCodemons {
    return activeSlots
        .whereType<String>()
        .map(getCodemonByUid)
        .whereType<OwnedCodemon>()
        .toList();
  }

  // ============================================================
  // BATTLE POINT
  // ============================================================

  int get battlePoint {
    return ownedCodemons.fold(
      0,
      (sum, codemon) => sum + codemon.damage,
    );
  }

  // ============================================================
  // LEVEL
  // ============================================================

  int get expNeeded {
    return level * 100;
  }

  double get expProgress {
    if (expNeeded == 0) {
      return 0;
    }

    return (exp / expNeeded).clamp(0.0, 1.0);
  }

  // ============================================================
  // WORLD UNLOCK
  // ============================================================

  bool get cssUnlocked {
    return (wins['html_slime'] ?? 0) >= 10 &&
        (wins['html_goblin'] ?? 0) >= 5 &&
        (wins['html_dragon'] ?? 0) >= 3;
  }

  bool get javascriptUnlocked {
    return (wins['css_slime'] ?? 0) >= 10 &&
        (wins['css_goblin'] ?? 0) >= 5 &&
        (wins['css_dragon'] ?? 0) >= 3;
  }

  // ============================================================
  // QUEST PROGRESS
  // ============================================================

  int get htmlSlimeWins {
    return wins['html_slime'] ?? 0;
  }

  int get htmlGoblinWins {
    return wins['html_goblin'] ?? 0;
  }

  int get htmlDragonWins {
    return wins['html_dragon'] ?? 0;
  }

  int get cssSlimeWins {
    return wins['css_slime'] ?? 0;
  }

  int get cssGoblinWins {
    return wins['css_goblin'] ?? 0;
  }

  int get cssDragonWins {
    return wins['css_dragon'] ?? 0;
  }

  // ============================================================
  // EXP
  // ============================================================

  void addExp(int amount) {
    exp += amount;

    while (exp >= expNeeded) {
      exp -= expNeeded;

      level++;

      maxHp += 20;

      hp = maxHp;
    }
  }

  // ============================================================
  // WIN
  // ============================================================

  void winBattle({
    required String enemyId,
    required int rewardCoins,
    required int rewardExp,
  }) {
    wins[enemyId] = (wins[enemyId] ?? 0) + 1;

    coins += rewardCoins;

    addExp(rewardExp);

    hp = maxHp;
  }

  // ============================================================
  // HP
  // ============================================================

  void takeDamage(int amount) {
    hp -= amount;

    if (hp < 0) {
      hp = 0;
    }
  }

  void heal() {
    hp = maxHp;
  }

  // ============================================================
  // POTION
  // ============================================================

  bool usePotion() {
    if (potions <= 0) {
      return false;
    }

    if (hp >= maxHp) {
      return false;
    }

    potions--;

    hp += 40;

    if (hp > maxHp) {
      hp = maxHp;
    }

    return true;
  }

  bool buyPotion() {
    const int price = 25;

    if (coins < price) {
      return false;
    }

    coins -= price;

    potions++;

    return true;
  }

  // ============================================================
  // SURRENDER
  // ============================================================

  void restoreBattleHp(int oldHp) {
    hp = oldHp.clamp(0, maxHp);
  }

  // ============================================================
  // EQUIP
  // ============================================================

  bool equipCodemon(
    String uid,
    int slot,
  ) {
    if (slot < 0 || slot > 2) {
      return false;
    }

    final codemon = getCodemonByUid(uid);

    if (codemon == null) {
      return false;
    }

    for (var i = 0; i < activeSlots.length; i++) {
      if (activeSlots[i] == uid) {
        activeSlots[i] = null;
      }
    }

    activeSlots[slot] = uid;

    return true;
  }

  void unequipSlot(int slot) {
    if (slot >= 0 && slot < activeSlots.length) {
      activeSlots[slot] = null;
    }
  }

  bool isEquipped(String uid) {
    return activeSlots.contains(uid);
  }

  // ============================================================
  // CAPTURE / GACHA
  // ============================================================

  OwnedCodemon? captureCodemon(String baseId) {
    final definition = codemonDefinition(baseId);

    if (definition == null) {
      return null;
    }

    // Damage random sesuai range Codemon.
    final damage = randomDamage(definition);

    final codemon = createCodemon(
      baseId,
      damage: damage,
      level: 1,
    );

    if (codemon == null) {
      return null;
    }

    ownedCodemons.add(codemon);

    // Masukkan otomatis ke slot kalau masih kosong.
    if (activeSlots[0] == null) {
      activeSlots[0] = codemon.uid;
    } else if (activeSlots[1] == null) {
      activeSlots[1] = codemon.uid;
    } else if (activeSlots[2] == null) {
      activeSlots[2] = codemon.uid;
    }

    return codemon;
  }

  // ============================================================
  // MERGE
  // ============================================================

  bool mergeCodemon(
    String baseId,
    int level,
  ) {
    final candidates = ownedCodemons
        .where(
          (codemon) =>
              codemon.baseId == baseId &&
              codemon.level == level &&
              !isEquipped(codemon.uid),
        )
        .take(3)
        .toList();

    if (candidates.length < 3) {
      return false;
    }

    // ==========================================================
    // TOTAL DAMAGE
    // ==========================================================

    final totalDamage = candidates.fold<int>(
      0,
      (sum, codemon) => sum + codemon.damage,
    );

    // Potong 25% dari total.
    final mergedDamage = (totalDamage * 0.75).floor();

    // Hapus 3 Codemon lama.
    for (final candidate in candidates) {
      ownedCodemons.remove(candidate);
    }

    // Buat Codemon baru.
    final evolved = createCodemon(
      baseId,
      damage: mergedDamage,
      level: level + 1,
    );

    if (evolved == null) {
      return false;
    }

    ownedCodemons.add(evolved);

    return true;
  }
}
