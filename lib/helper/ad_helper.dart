import 'dart:developer';

import 'package:easy_audience_network/easy_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'my_dialog.dart';

class AdHelper {
  static void init() {
    // No initialization needed for web
  }

  static void showInterstitialAd(VoidCallback onComplete) {
    // Directly call onComplete for web
    onComplete();
  }

  static Widget nativeAd() {
    // Return empty container for web
    return const SizedBox.shrink();
  }

  static Widget nativeBannerAd() {
    // Return empty container for web
    return const SizedBox.shrink();
  }
}
