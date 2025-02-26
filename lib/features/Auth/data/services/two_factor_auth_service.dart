import 'dart:typed_data';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:base32/base32.dart';
import 'package:otp/otp.dart';

class TwoFactorAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String generateSecretKey() {
    final random = Random.secure();
    final bytes =
        Uint8List.fromList(List<int>.generate(20, (i) => random.nextInt(256)));
    return base32.encode(bytes);
  }

  String generateQrData(String secretKey) {
    final userEmail = _auth.currentUser?.email ?? 'user';
    return 'otpauth://totp/SmartTask:$userEmail?secret=$secretKey&issuer=SmartTask';
  }

  bool verifyOTP(String otp, String secretKey) {
    final currentOtp = OTP.generateTOTPCode(
      secretKey,
      DateTime.now().millisecondsSinceEpoch,
      algorithm: Algorithm.SHA1,
      interval: 30,
      length: 6,
    );
    return otp == currentOtp;
  }

  Future<void> enableTwoFactor(String secretKey) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    await _firestore.collection('users').doc(user.uid).update({
      'twoFactorEnabled': true,
      'twoFactorSecret': secretKey,
    });
  }

  Future<String?> getTwoFactorSecret() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data()?['twoFactorSecret'] as String?;
  }
}
