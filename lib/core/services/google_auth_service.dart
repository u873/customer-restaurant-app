import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  Future<GoogleSignInAccount?> signIn() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      await googleSignIn.initialize();

      final GoogleSignInAccount account = await googleSignIn.authenticate();

      return account;
    } catch (e) {
      throw Exception("Google sign in failed: $e");
    }
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.disconnect();
    } catch (_) {}
  }
}
