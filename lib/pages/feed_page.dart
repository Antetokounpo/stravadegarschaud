import 'dart:math';
import 'package:collection/collection.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:stravadegarschaud/common/bac.dart';

import 'package:stravadegarschaud/common/db_commands.dart';
import 'package:stravadegarschaud/common/drink_data.dart';

class FeedCardHeader extends StatelessWidget {
  final DateTime timeStarted;
  final String username;

  FeedCardHeader({required this.timeStarted, required this.username});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateString = DateFormat(
      'd MMMM y à H:mm',
      'fr_CA',
    ).format(timeStarted);

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: CircleAvatar(
            backgroundColor: Colors.orange,
            child: Text(
              username.split(' ').map((e) => e.toUpperCase()[0]).join(),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(username, style: theme.textTheme.titleMedium),
            Text(dateString),
          ],
        ),
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
        Text(statName, style: theme.textTheme.labelMedium),
        Text(statResult, style: theme.textTheme.headlineSmall),
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
    final hourString =
        (duration.inHours < 1) ? "" : "${duration.inHours.floor()}h";
    final minuteString = "${(duration.inMinutes % 60).floor()}min";

    return hourString + minuteString;
  }

  @override
  Widget build(BuildContext context) {
    var f = NumberFormat("0.00", "fr_CA");

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        children: [
          CardStatsBox(
            statName: "Durée",
            statResult: getDurationString(duration),
          ),
          divider,
          CardStatsBox(statName: "Consos", statResult: consosCount.toString()),
          divider,
          CardStatsBox(statName: "Max", statResult: f.format(maxBAC)),
          divider,
          CardStatsBox(statName: "Moyenne", statResult: f.format(avgBAC)),
        ],
      ),
    );
  }
}

class FeedCardSingleButton extends StatelessWidget {
  final Icon icon;
  final String? number;
  final void Function()? callback;

  const FeedCardSingleButton({
    super.key,
    required this.icon,
    this.number,
    this.callback,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextButton(
        onPressed: callback,
        child: Row(
          children: [icon, number == null ? Container() : Text(number!)],
        ),
      ),
    );
  }
}

class FeedCardButtons extends StatefulWidget {
  static const divider = SizedBox(height: 30, child: VerticalDivider());

  final String activityId;

  const FeedCardButtons({super.key, required this.activityId});

  // not sure what I did there
  static final currentUserId = Database.auth.currentUser!.uid;

  @override
  State<FeedCardButtons> createState() => _FeedCardButtonsState();
}

class _FeedCardButtonsState extends State<FeedCardButtons> {
  // Cette valeur a besoin d'être intialisé parce qu'elle ne peut être null
  Future<bool> _liked = Future.value(false);
  Future<int> _likeCount = Future.value(0);

  // On regarde dans la DB si l'activité est déjà liké
  @override
  void initState() {
    super.initState();
    _liked = isAlreadyLiked();
    _likeCount = Database.getLikeCount(widget.activityId);
  }

  Future<bool> isAlreadyLiked() {
    return Database.isActivityLiked(
      widget.activityId,
      FeedCardButtons.currentUserId,
    );
  }

  // Quand on like un post, on l'écrit sur la DB et on met l'état _liked à vrai pour update le bouton du UI.
  // On prend pas la valeur de Firestore, pcq elle n'a pas le temps d'être update assez vite. On ne peut pas
  // unlike de toute façon.
  void likeCallback() {
    Database.likeActivity(widget.activityId, FeedCardButtons.currentUserId);

    setState(() {
      _liked = Future.value(true);
      _likeCount = _likeCount.then((count) => count + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FutureBuilder(
            future: Future.wait([_liked, _likeCount]),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final liked = snapshot.data![0] as bool; // _liked
                final likeCount = snapshot.data![1] as int; // _likeCount

                final icon =
                    liked
                        ? const Icon(Icons.thumb_up)
                        : const Icon(Icons.thumb_up_outlined);
                return FeedCardSingleButton(
                  icon: icon,
                  callback: likeCallback,
                  number: likeCount.toString(),
                );
              } else {
                return const FeedCardSingleButton(
                  icon: Icon(Icons.thumb_up_outlined),
                );
              }
            },
          ),
          FeedCardButtons.divider,
          const FeedCardSingleButton(icon: Icon(Icons.comment)),
          FeedCardButtons.divider,
          const FeedCardSingleButton(icon: Icon(Icons.share)),
        ],
      ),
    );
  }
}

class AlcoholGraph extends StatelessWidget {
  final List<double> bacOverTime;
  final DateTime timeStarted;

  const AlcoholGraph({
    super.key,
    required this.bacOverTime,
    required this.timeStarted,
  });

  String convertMinuteToTime(double minutes) {
    return DateFormat.Hm().format(
      timeStarted.add(Duration(minutes: minutes.floor())),
    );
  }

  // Fonction utilisée pour convertir les valeurs de l'axe des x en heures et en minutes.
  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 12);

    Widget text = Text(convertMinuteToTime(value), style: style);

    return SideTitleWidget(meta: meta, child: text);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: LineChart(
          LineChartData(
            minY: 0.0,
            maxY: bacOverTime.reduce(max),
            maxX: bacOverTime.length.toDouble() - 1,
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: bottomTitleWidgets,
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                dotData: const FlDotData(show: false),
                spots: [
                  for (var i = 0; i < bacOverTime.length; ++i)
                    FlSpot(
                      i.toDouble(),
                      double.parse(bacOverTime[i].toStringAsFixed(3)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActivityMap extends StatelessWidget {
  final List<Position> trajectory;

  const ActivityMap({super.key, required this.trajectory});

  @override
  Widget build(BuildContext context) {
    var averageLat = [for (var p in trajectory) p.latitude].average;
    var averageLng = [for (var p in trajectory) p.longitude].average;

    return SizedBox(
      height: 200,
      width: 360,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(
            averageLat,
            averageLng,
          ), // Center the map over the average coordinate
          initialZoom: 15.0,
        ),
        children: [
          TileLayer(
            // Bring your own tiles
            urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // For demonstration only
            userAgentPackageName: 'com.example.app', // Add your app identifier
            // And many more recommended properties!
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: [
                  for (var p in trajectory) LatLng(p.latitude, p.longitude),
                ],
                color: Colors.deepOrange,
                strokeWidth: 3.0,
              ),
            ],
          ),
          RichAttributionWidget(
            // Include a stylish prebuilt attribution widget that meets all requirments
            attributions: [
              TextSourceAttribution(
                'OpenStreetMap contributors',
              ),
              // Also add images...
            ],
          ),
        ],
      ),
    );
  }
}

class ActivityFeedCard extends StatelessWidget {
  final Activity activity;
  //static const brosseSynonymes = ["Brosse", "Débauche", "Dévergondage", "Beuverie", "Bombance", "Ripaille", "Ribouldingue"];

  ActivityFeedCard({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bac = BAC(
      drinker: activity.brosse.drinker,
      consommations: activity.brosse.consommations,
    );
    final bacOverTime = [
      for (var i = 0; i < activity.brosse.duration.inMinutes + 1; ++i)
        bac.getAlcoholContent(Duration(minutes: i)),
    ];

    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      margin: const EdgeInsets.only(bottom: 20.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
        child: SizedBox(
          height: 400,
          child: Column(
            children: [
              FutureBuilder(
                future: Database.getDisplayName(activity.userId),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return FeedCardHeader(
                      timeStarted: activity.brosse.timeStarted,
                      username: snapshot.data!,
                    );
                  } else {
                    return FeedCardHeader(
                      timeStarted: activity.brosse.timeStarted,
                      username: "Anonyme",
                    );
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 10.0,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    activity.title,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              ),
              FeedCardStats(
                consosCount: activity.brosse.consommations.length,
                maxBAC: bacOverTime.reduce(max),
                avgBAC: bacOverTime.average,
                duration: activity.brosse.duration,
              ),
              //AlcoholGraph(bacOverTime: bacOverTime, timeStarted: activity.brosse.timeStarted,),
              ActivityMap(trajectory: activity.brosse.trajectory),
              FeedCardButtons(activityId: activity.activityId),
            ],
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
  final Future<List<Activity>> activities = Database.getAllUsersIds().then(
    (uids) => Database.getBrossesForSetOfUsers(uids),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(205, 205, 205, 100),
      body: SafeArea(
        child: FutureBuilder(
          future: activities,
          builder: ((context, snapshot) {
            if (snapshot.hasData) {
              final List<Activity> brosses = snapshot.data!;
              brosses.sort(
                (a, b) => b.brosse.timeStarted.compareTo(a.brosse.timeStarted),
              ); // Last one first
              return ListView.builder(
                itemCount: brosses.length,
                itemBuilder:
                    (context, index) =>
                        ActivityFeedCard(activity: brosses[index]),
              );
            } else if (snapshot.hasError) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 100, color: Colors.red),
                    Text(
                      "Erreur lors de la récupération des données de brosses",
                    ),
                  ],
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
        ),
      ),
    );
  }
}
