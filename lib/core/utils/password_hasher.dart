import 'package:bcrypt/bcrypt.dart';

class PasswordHasher {
  static String hash(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }

  static bool check(String password, String hashed) {
    return BCrypt.checkpw(password, hashed);
  }
}
