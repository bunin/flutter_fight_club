import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_fight_club/fight_result.dart';
import 'package:flutter_fight_club/resources/fight_club_colors.dart';
import 'package:flutter_fight_club/resources/fight_club_icons.dart';
import 'package:flutter_fight_club/resources/fight_club_images.dart';
import 'package:flutter_fight_club/widgets/action_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FightPage extends StatefulWidget {
  const FightPage({Key? key}) : super(key: key);

  @override
  FightPageState createState() => FightPageState();
}

class FightPageState extends State<FightPage> {
  static const maxLives = 5;

  BodyPart? defendingBodyPart;
  BodyPart? attackingBodyPart;

  BodyPart whatEnemyAttacks = BodyPart.random();
  BodyPart whatEnemyDefends = BodyPart.random();

  int yourLives = maxLives;
  int enemysLives = maxLives;

  String statusText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FightClubColors.background,
      body: SafeArea(
        child: Column(
          children: [
            FightersInfo(
              enemysLivesCount: enemysLives,
              maxLivesCount: maxLives,
              yourLivesCount: yourLives,
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
              child: ColoredBox(
                color: FightClubColors.enemyBG,
                child: SizedBox.expand(
                  child: Center(
                      child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 10,
                      height: 20 / 10,
                      color: FightClubColors.darkGreyText,
                    ),
                    textAlign: TextAlign.center,
                  )),
                ),
              ),
            )),
            ControlsWidget(
              defendingBodyPart: defendingBodyPart,
              attackingBodyPart: attackingBodyPart,
              selectDefendingBodyPart: _selectDefendingBodyPart,
              selectAttackingBodyPart: _selectAttackingBodyPart,
            ),
            SizedBox(height: 14),
            ActionButton(
              text: (yourLives == 0 || enemysLives == 0) ? "Back" : "Go",
              onTap: _onGoButtonClicked,
              color: _getGoButtonColor(),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _getStatusText() {
    if (yourLives == 0 && enemysLives == 0) {
      return "Draw";
    }
    if (yourLives > 0 && enemysLives == 0) {
      return "You won";
    }
    if (yourLives == 0 && enemysLives > 0) {
      return "You lost";
    }
    if (attackingBodyPart == null || defendingBodyPart == null) {
      return "NONE";
    }
    var firstLine = (attackingBodyPart == whatEnemyDefends)
        ? "Your attack was blocked."
        : ("You hit enemy's " + attackingBodyPart!.name.toLowerCase() + ".");
    var secondLine = (defendingBodyPart == whatEnemyAttacks)
        ? "Enemy's attack was blocked."
        : ("Enemy hit your " + whatEnemyAttacks.name.toLowerCase() + ".");
    return firstLine + "\n" + secondLine;
  }

  Color _getGoButtonColor() {
    if (yourLives == 0 || enemysLives == 0) {
      return Colors.black87;
    }
    return (defendingBodyPart != null && attackingBodyPart != null)
        ? Colors.black87
        : FightClubColors.greyButton;
  }

  void _onGoButtonClicked() {
    if (yourLives == 0 || enemysLives == 0) {
      Navigator.of(context).pop();
      return;
    }
    if (defendingBodyPart == null || attackingBodyPart == null) {
      return;
    }
    setState(() {
      if (defendingBodyPart != whatEnemyAttacks) {
        yourLives--;
      }
      if (attackingBodyPart != whatEnemyDefends) {
        enemysLives--;
      }

      final FightResult? fr =
          FightResult.calculateResult(yourLives, enemysLives);
      if (fr != null) {
        SharedPreferences.getInstance().then(
          (sp) {
            switch (fr) {
              case FightResult.draw:
                sp.setInt("stats_draw", (sp.getInt("stats_draw") ?? 0) + 1);
                break;
              case FightResult.lost:
                sp.setInt("stats_lost", (sp.getInt("stats_lost") ?? 0) + 1);
                break;
              case FightResult.won:
                sp.setInt("stats_won", (sp.getInt("stats_won") ?? 0) + 1);
                break;
            }
            return sp.setString("last_fight_result", fr.result);
          },
        );
      }

      statusText = _getStatusText();
      defendingBodyPart = null;
      attackingBodyPart = null;
      whatEnemyAttacks = BodyPart.random();
      whatEnemyDefends = BodyPart.random();
    });
  }

  void _selectDefendingBodyPart(final BodyPart value) {
    if (yourLives == 0 || enemysLives == 0) {
      return;
    }
    setState(() {
      defendingBodyPart = value;
    });
  }

  void _selectAttackingBodyPart(final BodyPart value) {
    if (yourLives == 0 || enemysLives == 0) {
      return;
    }
    setState(() {
      attackingBodyPart = value;
    });
  }
}

class FightersInfo extends StatelessWidget {
  final int maxLivesCount;
  final int yourLivesCount;
  final int enemysLivesCount;

  const FightersInfo({
    Key? key,
    required this.maxLivesCount,
    required this.yourLivesCount,
    required this.enemysLivesCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            // mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(child: ColoredBox(color: FightClubColors.playerBG)),
              Expanded(
                  child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [FightClubColors.playerBG, FightClubColors.enemyBG],
                  ),
                ),
              )),
              Expanded(child: ColoredBox(color: FightClubColors.enemyBG)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              LivesWidget(
                overallLivesCount: maxLivesCount,
                currentLivesCount: yourLivesCount,
              ),
              Column(
                children: [
                  const SizedBox(height: 16),
                  Text("You",
                      style: TextStyle(color: FightClubColors.darkGreyText)),
                  const SizedBox(height: 12),
                  Image.asset(
                    FightClubImages.youAvatar,
                    width: 92,
                    height: 92,
                  ),
                ],
              ),
              SizedBox(
                width: 44,
                height: 44,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: FightClubColors.blueButton,
                  ),
                  child: Center(
                    child: Text(
                      "vs",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  const SizedBox(height: 16),
                  Text("Enemy",
                      style: TextStyle(color: FightClubColors.darkGreyText)),
                  const SizedBox(height: 12),
                  Image.asset(
                    FightClubImages.enemyAvatar,
                    width: 92,
                    height: 92,
                  ),
                ],
              ),
              LivesWidget(
                overallLivesCount: maxLivesCount,
                currentLivesCount: enemysLivesCount,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BodyPart {
  final String name;

  const BodyPart._(this.name);

  static const head = BodyPart._("Head");
  static const torso = BodyPart._("Torso");
  static const legs = BodyPart._("Legs");

  @override
  String toString() {
    return 'BodyPart{name: $name}';
  }

  static const _values = [head, torso, legs];

  static BodyPart random() => _values[Random().nextInt(_values.length)];
}

class BodyPartButton extends StatelessWidget {
  final BodyPart bodyPart;
  final bool selected;
  final ValueSetter<BodyPart> bodyPartSetter;

  const BodyPartButton({
    Key? key,
    required this.bodyPart,
    required this.selected,
    required this.bodyPartSetter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => bodyPartSetter(bodyPart),
      child: SizedBox(
        height: 40,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? FightClubColors.blueButton : Colors.transparent,
            border: selected
                ? null
                : Border.all(
                    color: FightClubColors.darkGreyText,
                    width: 2,
                  ),
          ),
          child: Center(
              child: Text(
            bodyPart.name.toUpperCase(),
            style: TextStyle(
              color: selected
                  ? FightClubColors.whiteText
                  : FightClubColors.darkGreyText,
            ),
          )),
        ),
      ),
    );
  }
}

class LivesWidget extends StatelessWidget {
  final int overallLivesCount;
  final int currentLivesCount;

  const LivesWidget({
    Key? key,
    required this.overallLivesCount,
    required this.currentLivesCount,
  })  : assert(overallLivesCount >= 1),
        assert(currentLivesCount >= 0),
        assert(currentLivesCount <= overallLivesCount),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        overallLivesCount,
        (index) => Padding(
          padding: EdgeInsets.only(top: index > 0 ? 4 : 0),
          child: Image.asset(
            index < currentLivesCount
                ? FightClubIcons.heartFull
                : FightClubIcons.heartEmpty,
            width: 18,
            height: 18,
          ),
        ),
        growable: false,
      ),
    );
  }
}

class ControlsWidget extends StatelessWidget {
  final BodyPart? defendingBodyPart;
  final BodyPart? attackingBodyPart;
  final ValueSetter<BodyPart> selectDefendingBodyPart;
  final ValueSetter<BodyPart> selectAttackingBodyPart;

  const ControlsWidget({
    Key? key,
    this.defendingBodyPart,
    this.attackingBodyPart,
    required this.selectDefendingBodyPart,
    required this.selectAttackingBodyPart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: 16),
        Expanded(
          child: Column(
            children: [
              Text("Defend".toUpperCase(),
                  style: TextStyle(color: FightClubColors.darkGreyText)),
              SizedBox(height: 13),
              BodyPartButton(
                bodyPart: BodyPart.head,
                selected: defendingBodyPart == BodyPart.head,
                bodyPartSetter: selectDefendingBodyPart,
              ),
              SizedBox(height: 14),
              BodyPartButton(
                bodyPart: BodyPart.torso,
                selected: defendingBodyPart == BodyPart.torso,
                bodyPartSetter: selectDefendingBodyPart,
              ),
              SizedBox(height: 14),
              BodyPartButton(
                bodyPart: BodyPart.legs,
                selected: defendingBodyPart == BodyPart.legs,
                bodyPartSetter: selectDefendingBodyPart,
              ),
            ],
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              Text("Attack".toUpperCase(),
                  style: TextStyle(color: FightClubColors.darkGreyText)),
              SizedBox(height: 13),
              BodyPartButton(
                bodyPart: BodyPart.head,
                selected: attackingBodyPart == BodyPart.head,
                bodyPartSetter: selectAttackingBodyPart,
              ),
              SizedBox(height: 14),
              BodyPartButton(
                bodyPart: BodyPart.torso,
                selected: attackingBodyPart == BodyPart.torso,
                bodyPartSetter: selectAttackingBodyPart,
              ),
              SizedBox(height: 14),
              BodyPartButton(
                bodyPart: BodyPart.legs,
                selected: attackingBodyPart == BodyPart.legs,
                bodyPartSetter: selectAttackingBodyPart,
              ),
            ],
          ),
        ),
        SizedBox(width: 16),
      ],
    );
  }
}
