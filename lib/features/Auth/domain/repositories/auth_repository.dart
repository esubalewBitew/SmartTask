abstract class AuthRepository {
  Future<void> signIn(String email, String password);
  Future<void> signUp(String email, String password, String name);
  Future<void> forgotPassword(String email);
  Future<void> signOut();
  Future<void> signInWithGoogle();
}
