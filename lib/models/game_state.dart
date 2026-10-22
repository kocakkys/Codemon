import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

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
    final starter = createStarterCodemon();

    if (starter != null) {
      ownedCodemons.add(starter);
      activeSlots[0] = starter.uid;
    }
  }

  // ============================================================
  // FIRESTORE: SIMPAN PROGRES
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'playerName': playerName,
      'playerPhoto': playerPhoto == null ? null : base64Encode(playerPhoto!),
      'level': level,
      'exp': exp,
      'maxHp': maxHp,
      'hp': hp,
      'coins': coins,
      'potions': potions,
      'wins': Map<String, int>.from(wins),
      'ownedCodemons': ownedCodemons.map((codemon) {
        return {
          'uid': codemon.uid,
          'baseId': codemon.baseId,
          'name': codemon.name,
          'language': codemon.language,
          'image': codemon.image,
          'damage': codemon.damage,
          'level': codemon.level,
        };
      }).toList(),
      'activeSlots': List<String?>.from(activeSlots),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // ============================================================
  // FIRESTORE: MUAT PROGRES
  // ============================================================

  void loadFromMap(Map<String, dynamic> data) {
    playerName = data['playerName'] as String? ?? 'Player';

    final savedPhoto = data['playerPhoto'];

    if (savedPhoto is String && savedPhoto.isNotEmpty) {
      try {
        playerPhoto = base64Decode(savedPhoto);
      } catch (_) {
        playerPhoto = null;
      }
    } else {
      playerPhoto = null;
    }

    level = (data['level'] as num?)?.toInt() ?? 1;
    exp = (data['exp'] as num?)?.toInt() ?? 0;

    maxHp = (data['maxHp'] as num?)?.toInt() ?? 100;
    hp = (data['hp'] as num?)?.toInt() ?? maxHp;

    coins = (data['coins'] as num?)?.toInt() ?? 100;
    potions = (data['potions'] as num?)?.toInt() ?? 3;

    // Muat kemenangan.
    final savedWins = data['wins'];

    if (savedWins is Map) {
      for (final key in wins.keys.toList()) {
        wins[key] = (savedWins[key] as num?)?.toInt() ?? 0;
      }
    }

    // Muat Codemon yang dimiliki.
    final savedCodemons = data['ownedCodemons'];

    if (savedCodemons is List) {
      ownedCodemons.clear();

      for (final item in savedCodemons) {
        if (item is! Map) continue;

        final codemonData = Map<String, dynamic>.from(item);

        final uid = codemonData['uid'];
        final baseId = codemonData['baseId'];
        final name = codemonData['name'];
        final language = codemonData['language'];
        final image = codemonData['image'];
        final damage = codemonData['damage'];
        final codemonLevel = codemonData['level'];

        if (uid is! String ||
            baseId is! String ||
            name is! String ||
            language is! String ||
            image is! String ||
            damage is! num) {
          continue;
        }

        ownedCodemons.add(
          OwnedCodemon(
            uid: uid,
            baseId: baseId,
            name: name,
            language: language,
            image: image,
            damage: damage.toInt(),
            level: codemonLevel is num ? codemonLevel.toInt() : 1,
          ),
        );
      }
    }

    // Muat slot Codemon aktif.
    final savedSlots = data['activeSlots'];

    for (var i = 0; i < activeSlots.length; i++) {
      if (savedSlots is List && i < savedSlots.length) {
        final value = savedSlots[i];
        activeSlots[i] = value is String ? value : null;
      } else {
        activeSlots[i] = null;
      }
    }

    // Pastikan slot tidak menunjuk Codemon yang sudah tidak ada.
    for (var i = 0; i < activeSlots.length; i++) {
      final uid = activeSlots[i];

      if (uid != null && getCodemonByUid(uid) == null) {
        activeSlots[i] = null;
      }
    }
  }

  // ============================================================
  // STARTER CODEMON
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

  int get expNeeded => level * 100;

  double get expProgress {
    if (expNeeded == 0) return 0;

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

  int get htmlSlimeWins => wins['html_slime'] ?? 0;
  int get htmlGoblinWins => wins['html_goblin'] ?? 0;
  int get htmlDragonWins => wins['html_dragon'] ?? 0;

  int get cssSlimeWins => wins['css_slime'] ?? 0;
  int get cssGoblinWins => wins['css_goblin'] ?? 0;
  int get cssDragonWins => wins['css_dragon'] ?? 0;

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
    if (potions <= 0 || hp >= maxHp) {
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
    const price = 25;

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

  bool equipCodemon(String uid, int slot) {
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

    final codemon = createCodemon(
      baseId,
      damage: randomDamage(definition),
      level: 1,
    );

    if (codemon == null) {
      return null;
    }

    ownedCodemons.add(codemon);

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

  bool mergeCodemon(String baseId, int level) {
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

    final totalDamage = candidates.fold<int>(
      0,
      (sum, codemon) => sum + codemon.damage,
    );

    final mergedDamage = (totalDamage * 0.75).floor();

    for (final candidate in candidates) {
      ownedCodemons.remove(candidate);
    }

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
