import 'package:flutter/material.dart';

import '../../moduls/profile/model/profile_data.dart';

class SubscriptionAccess {
  SubscriptionAccess._();

  static String normalizeInterval(String interval) {
    final value = interval.trim().toLowerCase();
    if (value.startsWith('year')) return 'year';
    if (value.startsWith('month')) return 'month';
    return value;
  }

  static DateTime _addMonthsUtc(DateTime source, int months) {
    final monthIndex = source.month - 1 + months;
    final year = source.year + (monthIndex ~/ 12);
    final month = (monthIndex % 12) + 1;
    final maxDay = DateTime.utc(year, month + 1, 0).day;
    final day = source.day <= maxDay ? source.day : maxDay;
    return DateTime.utc(
      year,
      month,
      day,
      source.hour,
      source.minute,
      source.second,
      source.millisecond,
      source.microsecond,
    );
  }

  static DateTime? estimateSubscriptionEndsAt({
    required DateTime startsAtUtc,
    required String interval,
  }) {
    final normalized = normalizeInterval(interval);
    if (normalized == 'year') {
      return _addMonthsUtc(startsAtUtc.toUtc(), 12);
    }
    if (normalized == 'month') {
      return _addMonthsUtc(startsAtUtc.toUtc(), 1);
    }
    return null;
  }

  static bool isCurrentSubscriptionActive({DateTime? now}) => false;

  static String? activeSubscriptionBlockMessage({DateTime? now}) => null;

  static Future<bool> syncFromCurrentAuth() async {
    // App review mode: keep all features freely accessible.
    ProfileData.instance.updateSubscription(
      subscribed: true,
      planName: '',
      subscriptionInterval: '',
      subscriptionStartsAt: '',
      subscriptionEndsAt: '',
    );
    return true;
  }

  static Future<bool> isSubscribed() async => true;

  static Future<bool> ensureSubscribedAction({
    required BuildContext context,
    required String featureName,
  }) async => true;
}
