import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:stravadegarschaud/common/db_commands.dart';
import 'package:stravadegarschaud/pages/home_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key
  });

  // Returns the HomePage if logged in and the sign in screen otherwise
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: ((context, snapshot) {
        if(snapshot.hasData) {
          Database.updateUserInfos(); // Writes users profile to Firestore collection

          return HomePage();
        }
        return const SignInScreen(
          showAuthActionSwitch: false, // Disables registration
        );
      }),
    );
  }
}