
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import 'package:stravadegarschaud/common/drink_data.dart';

class FeedCardHeader extends StatelessWidget {

  final DateTime timeStarted;

  FeedCardHeader({required this.timeStarted});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateString = DateFormat('d MMMM y à H:mm', 'fr_CA').format(timeStarted);

    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.orange,
          child: Text("JD"),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("John Doe", style: theme.textTheme.titleMedium),
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
  @override
  Widget build(BuildContext context) {

    return Row(
      children: [
        CardStatsBox(statName: "Allure", statResult: "3 c/h"),
        SizedBox(
          height: 30,
          child: VerticalDivider(),
        ),
        CardStatsBox(statName: "Nombre de consos", statResult: "17")
      ],
    );
  }
}

class FeedCartButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(
          onPressed: () {
            
          },
          child: Row(
            children: [
              Icon(Icons.thumb_up),
              Text("32")
            ],
          ),
        ),
        Spacer(),
        TextButton(
          onPressed: () {},
          child: Row(
            children: [
              Icon(Icons.comment),
              Text("2")
            ],
          ),
        ),
        Spacer(),
        TextButton(
          onPressed: () {},
          child: Icon(Icons.share)
        ),
      ],
    );
  }
}


class ActivityFeedCard extends StatelessWidget {

  final Brosse activity;

  ActivityFeedCard({required this.activity});

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: SizedBox(
        height: 400,
        child: Column(
          children: [
            FeedCardHeader(timeStarted: activity.timeStarted,),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Une grosse bière avec les boys", style: theme.textTheme.titleLarge,),
            ),
            FeedCardStats(),
            SizedBox(
              height: 200,
              child: Image.network("https://www.timescale.com/blog/content/images/2023/04/what-is-a-time-series-graph_img2.png")
            ),
            FeedCartButtons(),
          ]
        ),
      ),
    );
  }
}


class FeedPage extends StatelessWidget {
  const FeedPage({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final brossesBox = Hive.box(name: 'brosses');
    final activity = Brosse.fromJson(brossesBox.getAt(0));


    return Scaffold(
      body: SafeArea(
        child: ListView.builder(
          itemBuilder: (context, index) {
            return ActivityFeedCard(activity: activity,);            
          },
        ),
      ),
    );
  }
}