class Enemy {
  final String id;
  final String world;
  final String name;
  final String image;

  final int hp;
  final int damage;

  final int recommendedMin;
  final int recommendedMax;

  final int rewardCoins;
  final int rewardExp;

  final double captureChance;

  const Enemy({
    required this.id,
    required this.world,
    required this.name,
    required this.image,
    required this.hp,
    required this.damage,
    required this.recommendedMin,
    required this.recommendedMax,
    required this.rewardCoins,
    required this.rewardExp,
    required this.captureChance,
  });
}
