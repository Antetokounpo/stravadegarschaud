
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stravadegarschaud/common/drink_data.dart';

class Database {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get db => FirebaseFirestore.instance;

  static void addBrosse(Brosse brosse, String title, String uid) {
    final activityDocument = db.collection("brosses").add(
      Activity(brosse: brosse, userId: uid, title: title, activityId: "").toJson()
    );

    // Ligne pas très propre pour ajouter l'id du document le document lui-même
    activityDocument.then((doc) => doc.set({'activityId' : doc.id}, SetOptions(merge: true)));
  }

  static Future<List<Activity>> getBrossesForUser(String uid) {
    final brossesCollection = db.collection("brosses").where('userId', isEqualTo: uid).get();
    final brosses = brossesCollection.then((collection) => [for (var b in collection.docs) Activity.fromJson(b.data())]);

    return brosses;
  }

  static Future<List<Activity>> getBrossesForSetOfUsers(List<String> uids) {
    var listOfBrosses = [for (var uid in uids) getBrossesForUser(uid)];

    return Future.wait(listOfBrosses).then((listOfLists) => listOfLists.reduce((value, element) => value + element));
  }

  static Future<List<String>> getAllUsersIds() {
    return db.collection("users").get().then((collection) => [for (var u in collection.docs) u.id]);
  }

  static void updateUserInfos() {
    db.collection("users").doc(auth.currentUser!.uid).set({
      'displayName' : auth.currentUser!.displayName
    });
  }

  static Future<String> getDisplayName(String uid) {
    return db.collection("users").doc(uid).get().then((doc) => doc.data()!['displayName']);
  }

  static void likeActivity(String brosseId, String uid) {
    isActivityLiked(brosseId, uid).then(
      (liked) {
        if (!liked) {
          db.collection("pintes").add({
            "brosseId": brosseId,
            "userId": uid
          });
        }
      }
    );
  }

  static Future<bool> isActivityLiked(String brosseId, String uid) {
    return db.collection("pintes").where("userId", isEqualTo: uid).where("brosseId", isEqualTo: brosseId).get().then(
      (collection) => collection.docs.isNotEmpty
    );
  }
}
