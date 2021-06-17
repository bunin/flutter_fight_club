class FightResult {
  final String result;

  const FightResult._(this.result);

  static const won = FightResult._("Won");
  static const lost = FightResult._("Lost");
  static const draw = FightResult._("Draw");

  static FightResult? calculateResult(
    final int yourLives,
    final int enemysLives,
  ) {
    if (yourLives > 0 && enemysLives > 0) {
      return null;
    }
    if (yourLives == 0 && enemysLives == 0) {
      return draw;
    }
    if (yourLives > 0) {
      return won;
    }
    return lost;
  }

  @override
  String toString() {
    return 'FightResult{result: $result}';
  }

  static FightResult? fromString(String s) {
    switch (s.toLowerCase()) {
      case "won":
        return won;
      case "lost":
        return lost;
      case "draw":
        return draw;
    }
  }
}
