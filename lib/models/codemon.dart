class CodemonDefinition {
  final String id;
  final String name;
  final String language;
  final String image;

  final int minDamage;
  final int maxDamage;

  const CodemonDefinition({
    required this.id,
    required this.name,
    required this.language,
    required this.image,
    required this.minDamage,
    required this.maxDamage,
  });
}

class OwnedCodemon {
  final String uid;
  final String baseId;
  final String name;
  final String language;
  final String image;

  int damage;
  int level;

  OwnedCodemon({
    required this.uid,
    required this.baseId,
    required this.name,
    required this.language,
    required this.image,
    required this.damage,
    this.level = 1,
  });
}
