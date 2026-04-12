import 'package:flutter/material.dart';

import '../../moduls/profile/model/profile_data.dart';

class SubscriptionAccess {
  SubscriptionAccess._();

  static String normalizeInterval(String interval) {
    return interval.trim().toLowerCase();
  }

  static DateTime? estimateSubscriptionEndsAt({
    required DateTime startsAtUtc,
    required String interval,
  }) {
    return null;
  }

  static DateTime? currentSubscriptionEndsAt() => null;

  static bool isCurrentSubscriptionActive({DateTime? now}) => false;

  static String activeSubscriptionPlanLabel() => '';

  static String? activeSubscriptionBlockMessage({DateTime? now}) => null;

  static void _unlockFreeAccess() {
    ProfileData.instance.updateSubscription(
      subscribed: true,
      planName: '',
      subscriptionInterval: '',
      subscriptionStartsAt: '',
      subscriptionEndsAt: '',
    );
  }

  static Future<bool> syncFromCurrentAuth() async {
    _unlockFreeAccess();
    return true;
  }

  static Future<bool> isSubscribed() async {
    _unlockFreeAccess();
    return true;
  }

  static Future<bool> ensureSubscribedAction({
    required BuildContext context,
    required String featureName,
  }) async {
    _unlockFreeAccess();
    return true;
  }
}
