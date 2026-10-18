import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../data/game_data.dart';
import '../models/codemon.dart';
import '../models/enemy.dart';
import '../models/game_state.dart';
import '../services/audio_service.dart';

class BattleScreen extends StatefulWidget {
  final GameState game;
  final Enemy enemy;
  final VoidCallback onChanged;

  const BattleScreen({
    super.key,
    required this.game,
    required this.enemy,
    required this.onChanged,
  });

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen>
    with TickerProviderStateMixin {
  late int enemyHp;

  final Random _random = Random();

  Timer? _countdownTimer;
  Timer? _questionTimer;

  int countdown = 3;
  int questionSeconds = 15;

  bool showQuestion = false;
  bool locked = true;
  bool battleFinished = false;
  bool playerWon = false;

  bool enemyShake = false;
  bool playerShake = false;

  bool showEnemySlice = false;
  bool showPlayerSlice = false;

  String message = 'BATTLE START!';

  final List<_QuestionEntry> _questionDeck = [];

  _QuestionEntry? _currentEntry;

  List<String> _displayedOptions = [];
  int _correctDisplayIndex = 0;

  late AnimationController _enemyShakeController;
  late AnimationController _playerShakeController;
  late AnimationController _sliceController;

  @override
  void initState() {
    super.initState();

    enemyHp = widget.enemy.hp;

    _enemyShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _playerShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _sliceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _buildQuestionDeck();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startBattleCountdown();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _questionTimer?.cancel();

    _enemyShakeController.dispose();
    _playerShakeController.dispose();
    _sliceController.dispose();

    super.dispose();
  }

  // ============================================================
  // QUESTION SYSTEM
  // ============================================================

  void _buildQuestionDeck() {
    _questionDeck.clear();

    final Set<String> languages = {};

    for (final codemon in widget.game.activeCodemons) {
      languages.add(codemon.language.toLowerCase());
    }

    // Kalau tidak ada Codemon aktif, gunakan bahasa musuh.
    if (languages.isEmpty) {
      languages.add(widget.enemy.world.toLowerCase());
    }

    for (final language in languages) {
      if (language == 'html') {
        for (final question in htmlQuestions) {
          _questionDeck.add(
            _QuestionEntry(
              language: 'HTML',
              question: question,
            ),
          );
        }
      }

      if (language == 'css') {
        for (final question in cssQuestions) {
          _questionDeck.add(
            _QuestionEntry(
              language: 'CSS',
              question: question,
            ),
          );
        }
      }

      if (language == 'javascript') {
        for (final question in javascriptQuestions) {
          _questionDeck.add(
            _QuestionEntry(
              language: 'JavaScript',
              question: question,
            ),
          );
        }
      }
    }

    _questionDeck.shuffle(_random);
  }

  void _prepareNextQuestion() {
    if (_questionDeck.isEmpty) {
      _buildQuestionDeck();
    }

    if (_questionDeck.isEmpty) {
      return;
    }

    final next = _questionDeck.removeAt(0);

    _currentEntry = next;

    final originalOptions = List<String>.from(
      next.question.options,
    );

    final correctAnswer = originalOptions[next.question.answer];

    originalOptions.shuffle(_random);

    _displayedOptions = originalOptions;

    _correctDisplayIndex = _displayedOptions.indexOf(correctAnswer);
  }

  // ============================================================
  // BATTLE COUNTDOWN
  // ============================================================

  void _startBattleCountdown() {
    _countdownTimer?.cancel();

    countdown = 3;
    showQuestion = false;
    locked = true;

    setState(() {});

    GameAudio.countdown();

    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (countdown > 1) {
          setState(() {
            countdown--;
          });

          GameAudio.countdown();
        } else {
          timer.cancel();

          setState(() {
            countdown = 0;
          });

          _openNewQuestion();
        }
      },
    );
  }

  void _openNewQuestion() {
    if (battleFinished) return;

    _prepareNextQuestion();

    if (_currentEntry == null) return;

    setState(() {
      showQuestion = true;
      locked = false;
      questionSeconds = 15;
      message = 'JAWAB SOAL UNTUK MENYERANG!';
    });

    GameAudio.click();

    _startQuestionTimer();
  }

  // ============================================================
  // QUESTION TIMER
  // ============================================================

  void _startQuestionTimer() {
    _questionTimer?.cancel();

    questionSeconds = 15;

    _questionTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted || battleFinished) {
          timer.cancel();
          return;
        }

        if (questionSeconds > 1) {
          setState(() {
            questionSeconds--;
          });
        } else {
          timer.cancel();

          setState(() {
            questionSeconds = 0;
          });

          _timeUp();
        }
      },
    );
  }

  void _stopQuestionTimer() {
    _questionTimer?.cancel();
    _questionTimer = null;
  }

  // ============================================================
  // CLOSE / OPEN QUESTION
  // ============================================================

  void _closeQuestion() {
    if (locked || battleFinished) return;

    setState(() {
      showQuestion = false;
      message = 'SOAL MASIH TERSEDIA - KLIK ? UNTUK MEMBUKA';
    });
  }

  void _reopenQuestion() {
    if (locked || battleFinished) return;

    setState(() {
      showQuestion = true;
      message = 'PILIH JAWABAN!';
    });

    GameAudio.click();
  }

  // ============================================================
  // ANSWER
  // ============================================================

  Future<void> _answer(int index) async {
    if (locked || battleFinished) return;

    if (_currentEntry == null) return;

    _stopQuestionTimer();

    setState(() {
      locked = true;
      showQuestion = false;
    });

    final correct = index == _correctDisplayIndex;

    if (correct) {
      await GameAudio.correct();

      if (!mounted || battleFinished) return;

      setState(() {
        message = 'BENAR! CODEMON MENYERANG!';
      });

      await Future.delayed(
        const Duration(milliseconds: 350),
      );

      await _playerAttack();
    } else {
      await GameAudio.wrong();

      if (!mounted || battleFinished) return;

      setState(() {
        message = 'SALAH! MUSUH MENYERANG!';
      });

      await Future.delayed(
        const Duration(milliseconds: 350),
      );

      await _enemyAttack();
    }

    if (!mounted || battleFinished) return;

    await _nextQuestionDelay();
  }

  // ============================================================
  // TIME OUT
  // ============================================================

  Future<void> _timeUp() async {
    if (locked || battleFinished) return;

    setState(() {
      locked = true;
      showQuestion = false;
      message = 'WAKTU HABIS!';
    });

    await GameAudio.wrong();

    if (!mounted || battleFinished) return;

    await Future.delayed(
      const Duration(milliseconds: 300),
    );

    await _enemyAttack();

    if (!mounted || battleFinished) return;

    await _nextQuestionDelay();
  }

  // ============================================================
  // NEXT QUESTION DELAY
  // ============================================================

  Future<void> _nextQuestionDelay() async {
    if (battleFinished) return;

    for (int i = 3; i > 0; i--) {
      if (!mounted || battleFinished) return;

      setState(() {
        message = 'SOAL BERIKUTNYA DALAM $i...';
      });

      await Future.delayed(
        const Duration(seconds: 1),
      );
    }

    if (!mounted || battleFinished) return;

    _openNewQuestion();
  }

  // ============================================================
  // PLAYER ATTACK
  // ============================================================

  Future<void> _playerAttack() async {
    if (_currentEntry == null) return;

    final questionLanguage = _currentEntry!.language.toLowerCase();

    final matching = widget.game.activeCodemons
        .where(
          (codemon) => codemon.language.toLowerCase() == questionLanguage,
        )
        .toList();

    if (matching.isEmpty) {
      setState(() {
        message = 'BENAR! Tapi tidak ada CODEMON $questionLanguage di slot.';
      });

      return;
    }

    // Hanya satu Codemon yang menyerang.
    final attacker = matching[_random.nextInt(matching.length)];

    enemyHp -= attacker.damage;

    if (enemyHp < 0) {
      enemyHp = 0;
    }

    setState(() {
      enemyShake = true;
      showEnemySlice = true;
      message = '${attacker.name} menyerang! -${attacker.damage} HP';
    });

    GameAudio.attack();

    _enemyShakeController.forward(from: 0);
    _sliceController.forward(from: 0);

    await Future.delayed(
      const Duration(milliseconds: 450),
    );

    if (!mounted) return;

    setState(() {
      enemyShake = false;
      showEnemySlice = false;
    });

    if (enemyHp <= 0) {
      await _finishVictory();
    }
  }

  // ============================================================
  // ENEMY ATTACK
  // ============================================================

  Future<void> _enemyAttack() async {
    widget.game.takeDamage(widget.enemy.damage);

    setState(() {
      playerShake = true;
      showPlayerSlice = true;
      message = '${widget.enemy.name} menyerang! -${widget.enemy.damage} HP';
    });

    GameAudio.attack();

    _playerShakeController.forward(from: 0);
    _sliceController.forward(from: 0);

    widget.onChanged();

    await Future.delayed(
      const Duration(milliseconds: 550),
    );

    if (!mounted) return;

    setState(() {
      playerShake = false;
      showPlayerSlice = false;
    });

    if (widget.game.hp <= 0) {
      await _finishDefeat();
    }
  }

  // ============================================================
  // VICTORY
  // ============================================================

  Future<void> _finishVictory() async {
    battleFinished = true;
    showQuestion = false;

    _stopQuestionTimer();

    widget.game.winBattle(
      enemyId: widget.enemy.id,
      rewardCoins: widget.enemy.rewardCoins,
      rewardExp: widget.enemy.rewardExp,
    );

    OwnedCodemon? captured;

    final roll = _random.nextDouble();

    if (roll < widget.enemy.captureChance) {
      captured = widget.game.captureCodemon(widget.enemy.id);
    }

    widget.onChanged();

    await GameAudio.victory();

    if (!mounted) return;

    setState(() {
      playerWon = true;
      message = 'VICTORY!';
    });

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    if (!mounted) return;

    await _showResult(captured);
  }

  // ============================================================
  // DEFEAT
  // ============================================================

  Future<void> _finishDefeat() async {
    battleFinished = true;
    showQuestion = false;

    _stopQuestionTimer();

    await GameAudio.defeat();

    if (!mounted) return;

    setState(() {
      playerWon = false;
      message = 'DEFEAT';
    });

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    if (!mounted) return;

    await _showResult(null);
  }

  // ============================================================
  // RESULT POPUP
  // ============================================================

  Future<void> _showResult(
    OwnedCodemon? captured,
  ) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(
            playerWon ? 'VICTORY!' : 'DEFEAT',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                playerWon ? Icons.emoji_events : Icons.refresh,
                size: 65,
                color: playerWon ? Colors.amber : Colors.redAccent,
              ),
              const SizedBox(height: 12),
              if (playerWon) ...[
                Text(
                  '+${widget.enemy.rewardCoins} Coin',
                ),
                Text(
                  '+${widget.enemy.rewardExp} EXP',
                ),
                const SizedBox(height: 12),
                if (captured != null)
                  Text(
                    '${captured.name} DIDAPAT!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  )
                else
                  Text(
                    'Codemon belum berhasil didapat.\n'
                    'Chance: ${(widget.enemy.captureChance * 100).round()}%',
                    textAlign: TextAlign.center,
                  ),
              ] else
                const Text(
                  'Coba lagi setelah level dan tim kamu lebih siap.',
                  textAlign: TextAlign.center,
                ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('KEMBALI'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // BATTLE BAG
  // ============================================================

  void _openBattleBag() {
    if (locked || battleFinished) return;

    GameAudio.click();

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .65),
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF5F7FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: const [
              Icon(
                Icons.backpack,
                color: Color(0xFF303545),
                size: 30,
              ),
              SizedBox(width: 10),
              Text(
                'BAG',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFE1E4EC),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.local_pharmacy,
                        color: Colors.blue,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Potion',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Memulihkan 40 HP',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Jumlah: ${widget.game.potions}',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: widget.game.potions <= 0 ||
                              widget.game.hp >= widget.game.maxHp
                          ? null
                          : () {
                              final oldHp = widget.game.hp;

                              final used = widget.game.usePotion();

                              if (!used) return;

                              final healed = widget.game.hp - oldHp;

                              Navigator.pop(context);

                              setState(() {
                                message = 'POTION DIGUNAKAN! +$healed HP';
                              });

                              widget.onChanged();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.black38,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'PAKAI',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.game.potions <= 0) ...[
                const SizedBox(height: 12),
                const Text(
                  'Potion kamu habis.',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              if (widget.game.hp >= widget.game.maxHp &&
                  widget.game.potions > 0) ...[
                const SizedBox(height: 12),
                const Text(
                  'HP kamu sudah penuh.',
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final active = widget.game.activeCodemons;

    final currentQuestion = _currentEntry?.question;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ======================================================
          // BACKGROUND
          // ======================================================

          Image.asset(
            'assets/backgrounds/battle_bg.png',
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
            color: Colors.black.withValues(alpha: .16),
          ),

          SafeArea(
            child: Column(
              children: [
                // ==================================================
                // TOP BAR
                // ==================================================

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    12,
                    8,
                    12,
                    5,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: battleFinished
                            ? null
                            : () {
                                _stopQuestionTimer();
                                Navigator.pop(context);
                              },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.enemy.name,
                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              widget.enemy.world,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Lv ${widget.enemy.recommendedMin}-'
                          '${widget.enemy.recommendedMax}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ==================================================
                // ENEMY HP
                // ==================================================

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: _BattleHpBar(
                    label: widget.enemy.name,
                    value: enemyHp,
                    max: widget.enemy.hp,
                    isPlayer: false,
                  ),
                ),

                const SizedBox(height: 4),

                // ==================================================
                // MAIN BATTLE AREA
                // ==================================================

                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // =================================================
                      // ENEMY
                      // =================================================

                      Positioned(
                        top: 25,
                        child: AnimatedBuilder(
                          animation: _enemyShakeController,
                          builder: (context, child) {
                            final value = _enemyShakeController.value;

                            final offset =
                                sin(value * pi * 10) * (enemyShake ? 14 : 0);

                            return Transform.translate(
                              offset: Offset(offset, 0),
                              child: child,
                            );
                          },
                          child: SizedBox(
                            width: 270,
                            height: 270,
                            child: Image.asset(
                              widget.enemy.image,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) {
                                return const Icon(
                                  Icons.pets,
                                  size: 180,
                                  color: Colors.white54,
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      // =================================================
                      // ENEMY SLICE EFFECT
                      // =================================================

                      if (showEnemySlice)
                        Positioned(
                          top: 25,
                          child: IgnorePointer(
                            child: AnimatedBuilder(
                              animation: _sliceController,
                              builder: (context, child) {
                                return Opacity(
                                  opacity: 1 - _sliceController.value,
                                  child: SizedBox(
                                    width: 280,
                                    height: 280,
                                    child: CustomPaint(
                                      painter: _SlicePainter(
                                        progress: _sliceController.value,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                      // =================================================
                      // PLAYER AREA
                      // =================================================

                      Positioned(
                        bottom: 25,
                        child: AnimatedBuilder(
                          animation: _playerShakeController,
                          builder: (context, child) {
                            final value = _playerShakeController.value;

                            final offset =
                                sin(value * pi * 14) * (playerShake ? 25 : 0);

                            return Transform.translate(
                              offset: Offset(offset, 0),
                              child: child,
                            );
                          },
                          child: Column(
                            children: [
                              _PlayerAvatar(
                                name: widget.game.playerName,
                                photo: widget.game.playerPhoto,
                              ),

                              const SizedBox(height: 7),

                              SizedBox(
                                width: 300,
                                child: _BattleHpBar(
                                  label:
                                      'HP ${widget.game.hp}/${widget.game.maxHp}',
                                  value: widget.game.hp,
                                  max: widget.game.maxHp,
                                  isPlayer: true,
                                ),
                              ),

                              const SizedBox(height: 10),

                              // =========================================
                              // 3 CODEMON SLOTS
                              // =========================================

                              SizedBox(
                                width: 330,
                                child: Row(
                                  children: List.generate(
                                    3,
                                    (index) {
                                      final codemon = index < active.length
                                          ? active[index]
                                          : null;

                                      return Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: _BattleCodemon(
                                            codemon: codemon,
                                            questionLanguage:
                                                _currentEntry?.language,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // =================================================
                      // PLAYER SLICE
                      // =================================================

                      if (showPlayerSlice)
                        Positioned(
                          bottom: 10,
                          child: IgnorePointer(
                            child: AnimatedBuilder(
                              animation: _sliceController,
                              builder: (context, child) {
                                return Opacity(
                                  opacity: 1 - _sliceController.value,
                                  child: SizedBox(
                                    width: 350,
                                    height: 320,
                                    child: CustomPaint(
                                      painter: _SlicePainter(
                                        progress: _sliceController.value,
                                        big: true,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                      // =================================================
                      // BIG COUNTDOWN
                      // =================================================

                      if (countdown > 0)
                        Container(
                          width: 165,
                          height: 165,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: .72),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white24,
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$countdown',
                              style: const TextStyle(
                                fontSize: 82,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),

                      // =================================================
                      // QUESTION + BAG BUTTON
                      // =================================================

                      if (!showQuestion &&
                          !battleFinished &&
                          countdown == 0 &&
                          !locked)
                        Positioned(
                          top: 8,
                          right: 18,
                          child: Column(
                            children: [
                              // =========================================
                              // QUESTION BUTTON
                              // =========================================

                              GestureDetector(
                                onTap: _reopenQuestion,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      width: 72,
                                      height: 72,
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF303545,
                                        ),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 3,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: .35),
                                            blurRadius: 10,
                                            offset: const Offset(
                                              0,
                                              5,
                                            ),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.question_mark,
                                        size: 45,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Positioned(
                                      right: -5,
                                      top: -5,
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        decoration: const BoxDecoration(
                                          color: Colors.redAccent,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '$questionSeconds',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 12),

                              // =========================================
                              // BAG BUTTON
                              // =========================================

                              GestureDetector(
                                onTap: _openBattleBag,
                                child: Container(
                                  width: 58,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF303545,
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white70,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: .35),
                                        blurRadius: 8,
                                        offset: const Offset(
                                          0,
                                          4,
                                        ),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.backpack,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // ==================================================
                // MESSAGE
                // ==================================================

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    0,
                    18,
                    12,
                  ),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // =========================================================
          // QUESTION POPUP
          // =========================================================

          if (showQuestion && !battleFinished && currentQuestion != null)
            _QuestionPopup(
              question: currentQuestion,
              options: _displayedOptions,
              correctIndex: _correctDisplayIndex,
              seconds: questionSeconds,
              locked: locked,
              onAnswer: _answer,
              onClose: _closeQuestion,
              language: _currentEntry?.language ?? '',
            ),
        ],
      ),
    );
  }
}

// ==================================================================
// QUESTION ENTRY
// ==================================================================

class _QuestionEntry {
  final String language;
  final QuizQuestion question;

  const _QuestionEntry({
    required this.language,
    required this.question,
  });
}

// ==================================================================
// QUESTION POPUP
// ==================================================================

class _QuestionPopup extends StatelessWidget {
  final QuizQuestion question;
  final List<String> options;
  final int correctIndex;
  final int seconds;
  final bool locked;
  final void Function(int) onAnswer;
  final VoidCallback onClose;
  final String language;

  const _QuestionPopup({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.seconds,
    required this.locked,
    required this.onAnswer,
    required this.onClose,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final timerProgress = (seconds / 15).clamp(0.0, 1.0);

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: .60),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(18),
        child: Material(
          color: const Color(0xFFF5F7FF),
          borderRadius: BorderRadius.circular(26),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            padding: const EdgeInsets.fromLTRB(
              20,
              18,
              20,
              22,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ====================================================
                // HEADER
                // ====================================================

                Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        color: Color(0xFF303545),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.question_mark,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SOAL $language',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 23,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Jawab untuk menyerang',
                            style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: locked ? null : onClose,
                      icon: const Icon(
                        Icons.close,
                        color: Colors.black87,
                        size: 30,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ====================================================
                // TIMER
                // ====================================================

                Row(
                  children: [
                    const Icon(
                      Icons.timer,
                      color: Colors.black87,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      '$seconds detik',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: timerProgress,
                          minHeight: 10,
                          backgroundColor: Colors.black12,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ====================================================
                // QUESTION
                // ====================================================

                Text(
                  question.question,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 18),

                // ====================================================
                // ANSWERS
                // ====================================================

                ...List.generate(
                  options.length,
                  (index) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: locked ? null : () => onAnswer(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            disabledBackgroundColor: Colors.grey.shade300,
                            disabledForegroundColor: Colors.black45,
                            elevation: 2,
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                16,
                              ),
                              side: const BorderSide(
                                color: Color(0xFFE1E4EC),
                              ),
                            ),
                          ),
                          child: Text(
                            options[index],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// PLAYER AVATAR
// ==================================================================

class _PlayerAvatar extends StatelessWidget {
  final String name;
  final dynamic photo;

  const _PlayerAvatar({
    required this.name,
    required this.photo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: Colors.white,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .35),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipOval(
            child: photo != null
                ? Image.memory(
                    photo,
                    fit: BoxFit.cover,
                  )
                : const Icon(
                    Icons.person,
                    size: 58,
                    color: Colors.black54,
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(
                color: Colors.black,
                blurRadius: 5,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==================================================================
// CODEMON BATTLE CARD
// ==================================================================

class _BattleCodemon extends StatelessWidget {
  final OwnedCodemon? codemon;
  final String? questionLanguage;

  const _BattleCodemon({
    required this.codemon,
    required this.questionLanguage,
  });

  @override
  Widget build(BuildContext context) {
    if (codemon == null) {
      return Container(
        height: 86,
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white12,
          ),
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white38,
        ),
      );
    }

    final canAttack = questionLanguage != null &&
        codemon!.language.toLowerCase() == questionLanguage!.toLowerCase();

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: canAttack ? 1.0 : .35,
      child: Container(
        height: 86,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: canAttack
              ? Colors.green.withValues(alpha: .20)
              : Colors.black.withValues(alpha: .25),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: canAttack ? Colors.greenAccent : Colors.white12,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Image.asset(
                codemon!.image,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) {
                  return const Icon(
                    Icons.pets,
                    color: Colors.white70,
                  );
                },
              ),
            ),
            Text(
              'Lv ${codemon!.level}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// HP BAR
// ==================================================================

class _BattleHpBar extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final bool isPlayer;

  const _BattleHpBar({
    required this.label,
    required this.value,
    required this.max,
    required this.isPlayer,
  });

  @override
  Widget build(BuildContext context) {
    final progress = max <= 0 ? 0.0 : (value / max).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            Text(
              '$value / $max',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 16,
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white54,
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isPlayer
                            ? const [
                                Color(0xFF22C55E),
                                Color(0xFF86EFAC),
                              ]
                            : const [
                                Color(0xFFEF4444),
                                Color(0xFFF97316),
                              ],
                      ),
                    ),
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

// ==================================================================
// SLICE EFFECT
// ==================================================================

class _SlicePainter extends CustomPainter {
  final double progress;
  final bool big;

  const _SlicePainter({
    required this.progress,
    this.big = false,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = big ? 9 : 7;

    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    paint.color = Colors.white.withValues(alpha: opacity);

    final w = size.width;
    final h = size.height;

    final shift = progress * 100;

    // Slash 1
    canvas.drawLine(
      Offset(
        w * .15 + shift,
        h * .20,
      ),
      Offset(
        w * .80 + shift,
        h * .75,
      ),
      paint,
    );

    // Slash 2
    paint.strokeWidth = big ? 7 : 5;

    canvas.drawLine(
      Offset(
        w * .35 - shift,
        h * .05,
      ),
      Offset(
        w * .90 - shift,
        h * .55,
      ),
      paint,
    );

    // Slash 3
    paint.strokeWidth = big ? 5 : 4;

    canvas.drawLine(
      Offset(
        w * .05 + shift,
        h * .55,
      ),
      Offset(
        w * .55 + shift,
        h * .90,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(
    covariant _SlicePainter oldDelegate,
  ) {
    return oldDelegate.progress != progress || oldDelegate.big != big;
  }
}
