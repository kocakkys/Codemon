import '../models/codemon.dart';
import '../models/enemy.dart';

final List<CodemonDefinition> codemonsData = [
  // ============================================================
  // HTML
  // ============================================================

  const CodemonDefinition(
    id: 'html_slime',
    name: 'HTML Slime',
    language: 'HTML',
    image: 'assets/codemons/html_slime.png',
    minDamage: 25,
    maxDamage: 50,
  ),

  const CodemonDefinition(
    id: 'html_goblin',
    name: 'HTML Goblin',
    language: 'HTML',
    image: 'assets/codemons/html_goblin.png',
    minDamage: 55,
    maxDamage: 100,
  ),

  const CodemonDefinition(
    id: 'html_dragon',
    name: 'HTML Dragon',
    language: 'HTML',
    image: 'assets/codemons/html_dragon.png',
    minDamage: 150,
    maxDamage: 300,
  ),

  // ============================================================
  // CSS
  // ============================================================

  const CodemonDefinition(
    id: 'css_slime',
    name: 'CSS Slime',
    language: 'CSS',
    image: 'assets/codemons/css_slime.png',
    minDamage: 55,
    maxDamage: 100,
  ),

  const CodemonDefinition(
    id: 'css_goblin',
    name: 'CSS Goblin',
    language: 'CSS',
    image: 'assets/codemons/css_goblin.png',
    minDamage: 150,
    maxDamage: 300,
  ),

  const CodemonDefinition(
    id: 'css_dragon',
    name: 'CSS Dragon',
    language: 'CSS',
    image: 'assets/codemons/css_dragon.png',
    minDamage: 300,
    maxDamage: 600,
  ),

  // ============================================================
  // JAVASCRIPT
  // ============================================================

  const CodemonDefinition(
    id: 'javascript_slime',
    name: 'JavaScript Slime',
    language: 'JavaScript',
    image: 'assets/codemons/javascript_slime.png',
    minDamage: 100,
    maxDamage: 300,
  ),

  const CodemonDefinition(
    id: 'javascript_goblin',
    name: 'JavaScript Goblin',
    language: 'JavaScript',
    image: 'assets/codemons/javascript_goblin.png',
    minDamage: 300,
    maxDamage: 600,
  ),

  const CodemonDefinition(
    id: 'javascript_dragon',
    name: 'JavaScript Dragon',
    language: 'JavaScript',
    image: 'assets/codemons/javascript_dragon.png',
    minDamage: 650,
    maxDamage: 1000,
  ),
];

CodemonDefinition? codemonDefinition(String id) {
  for (final codemon in codemonsData) {
    if (codemon.id == id) {
      return codemon;
    }
  }

  return null;
}

// ============================================================
// HTML ENEMIES
// ============================================================

final List<Enemy> htmlEnemies = [
  const Enemy(
    id: 'html_slime',
    world: 'HTML',
    name: 'HTML Slime',
    image: 'assets/enemies/html_slime.png',
    hp: 250,
    damage: 20,
    recommendedMin: 1,
    recommendedMax: 5,
    rewardCoins: 25,
    rewardExp: 100,
    captureChance: 0.50,
  ),
  const Enemy(
    id: 'html_goblin',
    world: 'HTML',
    name: 'HTML Goblin',
    image: 'assets/enemies/html_goblin.png',
    hp: 500,
    damage: 50,
    recommendedMin: 6,
    recommendedMax: 10,
    rewardCoins: 50,
    rewardExp: 250,
    captureChance: 0.25,
  ),
  const Enemy(
    id: 'html_dragon',
    world: 'HTML',
    name: 'HTML Dragon',
    image: 'assets/enemies/html_dragon.png',
    hp: 1000,
    damage: 100,
    recommendedMin: 11,
    recommendedMax: 15,
    rewardCoins: 100,
    rewardExp: 500,
    captureChance: 0.10,
  ),
];

// ============================================================
// CSS ENEMIES
// ============================================================

final List<Enemy> cssEnemies = [
  const Enemy(
    id: 'css_slime',
    world: 'CSS',
    name: 'CSS Slime',
    image: 'assets/enemies/css_slime.png',
    hp: 500,
    damage: 50,
    recommendedMin: 1,
    recommendedMax: 5,
    rewardCoins: 35,
    rewardExp: 250,
    captureChance: 0.50,
  ),
  const Enemy(
    id: 'css_goblin',
    world: 'CSS',
    name: 'CSS Goblin',
    image: 'assets/enemies/css_goblin.png',
    hp: 1000,
    damage: 100,
    recommendedMin: 6,
    recommendedMax: 10,
    rewardCoins: 65,
    rewardExp: 500,
    captureChance: 0.25,
  ),
  const Enemy(
    id: 'css_dragon',
    world: 'CSS',
    name: 'CSS Dragon',
    image: 'assets/enemies/css_dragon.png',
    hp: 2000,
    damage: 200,
    recommendedMin: 11,
    recommendedMax: 15,
    rewardCoins: 125,
    rewardExp: 1000,
    captureChance: 0.10,
  ),
];

// ============================================================
// JAVASCRIPT ENEMIES
// ============================================================

final List<Enemy> javascriptEnemies = [
  const Enemy(
    id: 'javascript_slime',
    world: 'JavaScript',
    name: 'JavaScript Slime',
    image: 'assets/enemies/javascript_slime.png',
    hp: 1000,
    damage: 100,
    recommendedMin: 1,
    recommendedMax: 5,
    rewardCoins: 45,
    rewardExp: 500,
    captureChance: 0.50,
  ),
  const Enemy(
    id: 'javascript_goblin',
    world: 'JavaScript',
    name: 'JavaScript Goblin',
    image: 'assets/enemies/javascript_goblin.png',
    hp: 2000,
    damage: 200,
    recommendedMin: 6,
    recommendedMax: 10,
    rewardCoins: 80,
    rewardExp: 1000,
    captureChance: 0.25,
  ),
  const Enemy(
    id: 'javascript_dragon',
    world: 'JavaScript',
    name: 'JavaScript Dragon',
    image: 'assets/enemies/javascript_dragon.png',
    hp: 3000,
    damage: 300,
    recommendedMin: 11,
    recommendedMax: 15,
    rewardCoins: 150,
    rewardExp: 2000,
    captureChance: 0.10,
  ),
];

// ============================================================
// QUIZ
// ============================================================

class QuizQuestion {
  final String question;
  final List<String> options;
  final int answer;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.answer,
  });
}

final List<QuizQuestion> htmlQuestions = [
  const QuizQuestion(
    question: 'Tag apa yang digunakan untuk menampilkan gambar?',
    options: ['<h1>', '<p>', '<img>', '<script>'],
    answer: 2,
  ),
  const QuizQuestion(
    question: 'Tag untuk membuat judul utama adalah?',
    options: ['<h1>', '<title2>', '<head1>', '<main>'],
    answer: 0,
  ),
  const QuizQuestion(
    question: 'Tag untuk membuat paragraf adalah?',
    options: ['<text>', '<p>', '<para>', '<article>'],
    answer: 1,
  ),
  const QuizQuestion(
    question: 'Atribut yang umum digunakan untuk sumber gambar adalah?',
    options: ['href', 'src', 'link', 'path'],
    answer: 1,
  ),
];

final List<QuizQuestion> cssQuestions = [
  const QuizQuestion(
    question: 'Properti CSS untuk mengubah warna teks adalah?',
    options: ['font-color', 'text-color', 'color', 'foreground'],
    answer: 2,
  ),
  const QuizQuestion(
    question: 'Properti untuk mengubah ukuran teks adalah?',
    options: ['font-size', 'text-size', 'size', 'font-scale'],
    answer: 0,
  ),
  const QuizQuestion(
    question: 'Display yang cocok untuk membuat layout fleksibel adalah?',
    options: ['block', 'flex', 'static', 'hidden'],
    answer: 1,
  ),
  const QuizQuestion(
    question: 'Properti untuk mengatur jarak dalam elemen adalah?',
    options: ['padding', 'space', 'inside-gap', 'margin-text'],
    answer: 0,
  ),
];

final List<QuizQuestion> javascriptQuestions = [
  const QuizQuestion(
    question:
        'Keyword untuk membuat variabel yang nilainya dapat diubah adalah?',
    options: ['const', 'let', 'fixed', 'static'],
    answer: 1,
  ),
  const QuizQuestion(
    question: 'Fungsi untuk menampilkan pesan di console adalah?',
    options: ['print()', 'console.log()', 'show()', 'write.log()'],
    answer: 1,
  ),
  const QuizQuestion(
    question: 'Operator perbandingan nilai dan tipe yang ketat adalah?',
    options: ['=', '==', '===', '=>'],
    answer: 2,
  ),
  const QuizQuestion(
    question: 'Array JavaScript ditulis menggunakan?',
    options: ['{}', '[]', '()', '<>'],
    answer: 1,
  ),
];
