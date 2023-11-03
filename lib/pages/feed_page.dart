
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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


class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {

  final activities = FirebaseFirestore.instance.collection(FirebaseAuth.instance.currentUser!.uid).get();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: activities,
          builder: ((context, snapshot) {
            if(snapshot.hasData) {

              final docs = snapshot.data!.docs;

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) => 
                  ActivityFeedCard(activity: Brosse.fromJson(docs[index].data())),
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