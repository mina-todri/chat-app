import 'package:firebase_auth/firebase_auth.dart';

String getAuthErrorMessage(FirebaseAuthException e) {
  switch (e.code) {
    case "invalid-email":
      return "The email address is not valid";

    case "user-disabled":
      return "The given email has been disabled";

    case "email-already-in-use":
      return "Email already exists";

    case "user-not-found":
      return "User not found";

    case "wrong-password":
      return "The password is invalid";

    case "weak-password":
      return "The password is not strong enough";

    case "invalid-credential":
      return "The email or password is incorrect";

    case "network-request-failed":
      return "Check your internet connection";

    default:
      return "Something went wrong";
  }
}
