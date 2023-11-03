
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stravadegarschaud/common/drink_data.dart';

class Database {
  static FirebaseAuth auth() => FirebaseAuth.instance;
  static FirebaseFirestore db() => FirebaseFirestore.instance;

  static void addBrosse(Brosse brosse) {
    db().collection("users").doc(auth().currentUser!.uid).collection("brosses").add(brosse.toJson());
  }

  static Future<List<Brosse>> getBrossesForUser(String uid) {
    final brossesCollection = db().collection("users").doc(uid).collection("brosses").get();
    final brosses = brossesCollection.then((collection) => [for (var b in collection.docs) Brosse.fromJson(b.data())]);

    return brosses;
  }
}