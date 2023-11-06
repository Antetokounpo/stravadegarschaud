import 'dart:math';
import 'package:collection/collection.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stravadegarschaud/common/bac.dart';

import 'package:stravadegarschaud/common/db_commands.dart';
import 'package:stravadegarschaud/common/drink_data.dart';

class FeedCardHeader extends StatelessWidget {

  final DateTime timeStarted;
  final String username;

  FeedCardHeader({
    required this.timeStarted,
    required this.username
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateString = DateFormat('d MMMM y à H:mm', 'fr_CA').format(timeStarted);

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: CircleAvatar(
            backgroundColor: Colors.orange,
            child: Text(username.split(' ').map((e) => e.toUpperCase()[0],).join()),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(username, style: theme.textTheme.titleMedium),
            Text(dateString)
          ],
        )
      ],
    );
  }
}

class CardStatsBox extends StatelessWidget {

  const CardStatsBox({required this.statName, required this.statResult});

  final String statName;
  final String statResult;

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(statName, style: theme.textTheme.labelMedium,),
        Text(statResult, style: theme.textTheme.headlineSmall,),
      ],
    );
  }
}

class FeedCardStats extends StatelessWidget {

  static const divider = SizedBox(height: 30, child: VerticalDivider());

  final int consosCount;
  final double maxBAC;
  final double avgBAC;
  final Duration duration;

  FeedCardStats({
    required this.consosCount,
    required this.maxBAC,
    required this.avgBAC,
    required this.duration,
  });

  String getDurationString(Duration duration) {
    final hourString = (duration.inHours < 1) ? "" : "${duration.inHours.floor()}h";
    final minuteString = "${(duration.inMinutes % 60).floor()}min";

    return hourString+minuteString;
  }

  @override
  Widget build(BuildContext context) {

    var f = NumberFormat("0.00", "fr_CA");

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        children: [
          CardStatsBox(statName: "Durée", statResult: getDurationString(duration)),
          divider,
          CardStatsBox(statName: "Consos", statResult: consosCount.toString()),
          divider,
          CardStatsBox(statName: "Max", statResult: f.format(maxBAC)),
          divider,
          CardStatsBox(statName: "Moyenne", statResult: f.format(avgBAC))
        ],
      ),
    );
  }
}

class FeedCardSingleButton extends StatelessWidget {

  final Icon icon;
  final String? number;

  const FeedCardSingleButton({
    super.key,
    required this.icon,
    this.number,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextButton(
        onPressed: () {},
        child: Row(
          children: [
            icon,
            number == null ? Container() : Text(number!),
          ],
        ),
      ),
    );
  }
}

class FeedCartButtons extends StatelessWidget {
  static const divider = SizedBox(height: 30, child: VerticalDivider());

  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FeedCardSingleButton(icon: Icon(Icons.thumb_up)),
          divider,
          FeedCardSingleButton(icon: Icon(Icons.comment)),
          divider,
          FeedCardSingleButton(icon: Icon(Icons.share)),
        ],
      ),
    );
  }
}

class AlcoholGraph extends StatelessWidget {

  final List<double> bacOverTime;

  const AlcoholGraph({
    super.key,
    required this.bacOverTime
  });

  @override
  Widget build(BuildContext context) {

    return SizedBox(
             height: 200,
             child: Padding(
               padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
               child: LineChart(
                 LineChartData(
                  minY: 0.0,
                  maxY: 0.5,
                  maxX: bacOverTime.length.toDouble()-1,
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false)
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false)
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false) 
                    )
                  ),
                   lineBarsData: [
                     LineChartBarData(
                      dotData: const FlDotData(show: false),
                      spots: [for (var i = 0; i<bacOverTime.length; ++i) FlSpot(i.toDouble(), double.parse(bacOverTime[i].toStringAsFixed(2)))]
                     )
                   ]
                 )
               ),
             )
            );
  }
}

class ActivityFeedCard extends StatelessWidget {

  final Brosse activity;
  static const brosseSynonymes = ["Brosse", "Débauche", "Dévergondage", "Beuverie", "Bombance", "Ripaille", "Ribouldingue"];

  ActivityFeedCard({required this.activity});

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    final bac = BAC(drinker: activity.drinker, consommations: activity.consommations);
    final bacOverTime = [for (var i = 0; i<activity.duration.inMinutes+1; ++i)  bac.getAlcoholContent(Duration(minutes: i))];
  
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      margin: const EdgeInsets.only(bottom: 20.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
        child: SizedBox(
          height: 400,
          child: Column(
            children: [
              FeedCardHeader(timeStarted: activity.timeStarted, username: Database.auth().currentUser!.displayName!),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                // TODO: Ajouter possibilité de choisir le titre
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(brosseSynonymes[Random().nextInt(brosseSynonymes.length-1)], style: theme.textTheme.titleLarge,),
                ),
              ),
              FeedCardStats(
                consosCount: activity.consommations.length,
                maxBAC: bacOverTime.reduce(max),
                avgBAC: bacOverTime.average,
                duration: activity.duration,
              ),
              AlcoholGraph(bacOverTime: bacOverTime), 
              FeedCartButtons(),
            ]
          ),
        ),
      ),
    );
  }
}


class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {

  final Future<List<Brosse>> activities = Database.getBrossesForUser(Database.auth().currentUser!.uid);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(205, 205, 205, 100),
      body: SafeArea(
        child: FutureBuilder(
          future: activities,
          builder: ((context, snapshot) {
            if(snapshot.hasData) {
              final List<Brosse> brosses = snapshot.data!;
              brosses.sort((a, b) => b.timeStarted.compareTo(a.timeStarted)); // Last one first
              return ListView.builder(
                itemCount: brosses.length,
                itemBuilder: (context, index) => 
                  ActivityFeedCard(activity: brosses[index]),
              );
            } else if(snapshot.hasError) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 100, color: Colors.red,),
                    Text("Erreur lors de la récupération des données de brosses")
                  ],
                ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
        ),
      )
    );
  }
}