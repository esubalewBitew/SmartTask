import 'package:flutter/material.dart';

class ImagePrecacheService {
  static Future<void> precacheAppImages(BuildContext context) async {
    await Future.wait([
       // Home screen images
      precacheImage(
        AssetImage('assets/vectors/band_tranfer_birrAcc_4x_img.png'),
        context,
      ),
      precacheImage(
        AssetImage('assets/vectors/bank_transfer_dollarAcc_4x_img.png'),
        context,
      ),
      precacheImage(
        AssetImage('assets/vectors/change_to_birr_4x_img.png'),
        context,
      ),
      precacheImage(
        AssetImage('assets/vectors/load_by_wallet_4x_img.png'),
        context,
      ),
      precacheImage(
        AssetImage('assets/vectors/wallet_tranfer_birracc_4x_img.png'),
        context,
      ),
      precacheImage(
        AssetImage('assets/vectors/wallet_transfer_dollar_4x_img.png'),
        context,
      ),
    ]);
  }
}