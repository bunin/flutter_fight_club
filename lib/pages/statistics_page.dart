import 'package:flutter/material.dart';
import 'package:flutter_fight_club/resources/fight_club_colors.dart';
import 'package:flutter_fight_club/widgets/secondary_action_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _StatisticsPageContent();
  }
}

class _StatisticsPageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FightClubColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 24),
              child: Text(
                "Statistics",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  height: 40 / 24,
                  letterSpacing: 0.15,
                  color: FightClubColors.darkGreyText,
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<SharedPreferences>(
                builder: (context, snapshot) {
                  final int won = snapshot.data?.getInt("stats_won") ?? 0;
                  final int lost = snapshot.data?.getInt("stats_lost") ?? 0;
                  final int draw = snapshot.data?.getInt("stats_draw") ?? 0;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _getText("Won", won),
                      _getText("Lost", lost),
                      _getText("Draw", draw),
                    ],
                  );
                },
                future: SharedPreferences.getInstance(),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: SecondaryActionButton(
                onTap: () {
                  Navigator.of(context).pop();
                },
                text: "Back",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getText(String text, int num) {
    return Text(
      text + ": " + num.toString(),
      style: TextStyle(
        fontSize: 16,
        height: 40 / 16,
        color: FightClubColors.darkGreyText,
      ),
    );
  }
}
