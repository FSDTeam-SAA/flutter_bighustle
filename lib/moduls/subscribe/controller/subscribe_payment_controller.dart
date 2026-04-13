import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/api_handler/failure.dart';
import '../../../core/api_handler/success.dart';
import '../../../core/helpers/subscription_access.dart';
import '../../../core/notifiers/snackbar_notifier.dart';
import '../../../core/services/app_pigeon/app_pigeon.dart';
import '../../profile/model/profile_data.dart';
import '../implement/plan_interface_impl.dart';
import '../interface/plan_interface.dart';
import '../model/plan_model.dart';

class SubscribePaymentController extends ChangeNotifier {
  SubscribePaymentController();

  final List<PlanModel> _plans = [];
  PlanModel? _currentPlan;
  PlanModel? _selectedPlan;
  bool _isLoadingPlans = false;
  bool _isSubmitting = false;
  bool _initialized = false;

  List<PlanModel> get plans => List.unmodifiable(_plans);
  PlanModel? get currentPlan => _currentPlan;
  PlanModel? get selectedPlan => _selectedPlan;
  bool get isLoadingPlans => _isLoadingPlans;
  bool get isSubmitting => _isSubmitting;


  bool get hasPlans => _plans.isNotEmpty;
  bool get hasSelection => _selectedPlan != null;
  bool get isCurrentSelection =>
      _selectedPlan != null && _selectedPlan?.id == _currentPlan?.id;

  PlanInterface get _planInterface => _ensurePlanInterface();

  void init() {
    if (_initialized) return;
    _initialized = true;
  }

  PlanInterface _ensurePlanInterface() {
    if (!Get.isRegistered<PlanInterface>()) {
      Get.put<PlanInterface>(
        PlanInterfaceImpl(appPigeon: Get.find<AppPigeon>()),
      );
    }
    return Get.find<PlanInterface>();
  }

  Future<void> loadPlans({SnackbarNotifier? snackbarNotifier}) async {
    _setLoadingPlans(true);
    try {
      final result = await _planInterface.getPlans();
      result.fold(
        (failure) => _handlePlanLoadFailure(failure, snackbarNotifier),
        (success) => _handlePlanLoadSuccess(success),
      );
    } catch (_) {
      snackbarNotifier?.notifyError(
        message: 'An error occurred while loading plans',
      );
    } finally {
      _setLoadingPlans(false);
    }
  }

  void selectPlan(PlanModel plan) {
    if (plan.id == _currentPlan?.id) return;
    _selectedPlan = plan;
    notifyListeners();
  }

  /// Stub for in-app purchase — will be implemented with Apple IAP.
  Future<bool> submitSubscription({
    required SnackbarNotifier snackbarNotifier,
  }) async {
    if (!hasSelection) {
      snackbarNotifier.notifyError(message: 'Please select a plan.');
      return false;
    }
    if (isCurrentSelection) {
      snackbarNotifier.notify(message: 'You are already on this plan.');
      return false;
    }
    final activeSubscriptionMessage =
        SubscriptionAccess.activeSubscriptionBlockMessage();
    if (activeSubscriptionMessage != null) {
      snackbarNotifier.notify(message: activeSubscriptionMessage);
      return false;
    }
    _isSubmitting = true;
    notifyListeners();
    try {
      // In-App Purchase integration goes here
      snackbarNotifier.notify(message: 'In-app purchase coming soon.');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Called after a successful IAP purchase to persist subscription state.
  Future<void> persistSubscription({
    required String planName,
    required String subscriptionInterval,
    required String subscriptionStartsAt,
    required String subscriptionEndsAt,
  }) async {
    _currentPlan = _selectedPlan;
    ProfileData.instance.updateSubscription(
      subscribed: true,
      planName: planName,
      subscriptionInterval: subscriptionInterval,
      subscriptionStartsAt: subscriptionStartsAt,
      subscriptionEndsAt: subscriptionEndsAt,
    );
    await _persistSubscriptionToCurrentAuth(
      subscribed: true,
      planName: planName,
      subscriptionInterval: subscriptionInterval,
      subscriptionStartsAt: subscriptionStartsAt,
      subscriptionEndsAt: subscriptionEndsAt,
    );
    notifyListeners();
  }

  void _handlePlanLoadFailure(
    DataCRUDFailure failure,
    SnackbarNotifier? snackbarNotifier,
  ) {
    snackbarNotifier?.notifyError(
      message: failure.uiMessage.isNotEmpty
          ? failure.uiMessage
          : 'Failed to load plans',
    );
    _plans.clear();
    _currentPlan = null;
    _selectedPlan = null;
    notifyListeners();
  }

  void _handlePlanLoadSuccess(Success<List<PlanModel>> success) {
    final fetchedPlans = _normalizePlans(success.data ?? <PlanModel>[]);
    _plans
      ..clear()
      ..addAll(fetchedPlans);

    _currentPlan = _resolveCurrentPlan(fetchedPlans);
    _selectedPlan = _resolveSelectedPlan(fetchedPlans, _currentPlan);
    notifyListeners();
  }

  PlanModel? _resolveCurrentPlan(List<PlanModel> plans) {
    for (final plan in plans) {
      if (plan.isCurrent) return plan;
    }
    for (final plan in plans) {
      if (plan.price == 0) return plan;
    }
    return null;
  }

  PlanModel? _resolveSelectedPlan(List<PlanModel> plans, PlanModel? current) {
    if (plans.isEmpty) return null;
    PlanModel? fallback;
    for (final plan in plans) {
      if (plan.id == current?.id) continue;
      if (plan.price <= 0) continue;
      if (plan.interval == 'month') {
        return plan;
      }
      fallback ??= plan;
    }
    return fallback ?? current ?? plans.first;
  }

  void _setLoadingPlans(bool value) {
    if (_isLoadingPlans == value) return;
    _isLoadingPlans = value;
    notifyListeners();
  }

  Future<void> _persistSubscriptionToCurrentAuth({
    required bool subscribed,
    required String planName,
    required String subscriptionInterval,
    required String subscriptionStartsAt,
    required String subscriptionEndsAt,
  }) async {
    try {
      final appPigeon = Get.find<AppPigeon>();
      final status = await appPigeon.currentAuth();
      if (status is! Authenticated) return;

      final accessToken = status.auth.accessToken ?? '';
      final refreshToken = status.auth.refreshToken ?? '';
      if (accessToken.isEmpty || refreshToken.isEmpty) return;

      final authData = Map<String, dynamic>.from(status.auth.data);
      authData['subscribed'] = subscribed;
      authData['planName'] = planName;
      authData['subscriptionInterval'] = subscriptionInterval;
      authData['subscriptionStartsAt'] = subscriptionStartsAt;
      authData['subscriptionEndsAt'] = subscriptionEndsAt;

      await appPigeon.updateCurrentAuth(
        updateAuthParams: UpdateAuthParams(
          accessToken: accessToken,
          refreshToken: refreshToken,
          data: authData,
        ),
      );
    } catch (_) {}
  }

  List<PlanModel> _normalizePlans(List<PlanModel> plans) {
    if (plans.length < 2) {
      return plans;
    }

    final normalized = List<PlanModel>.from(plans);
    final paidPlans = normalized.where((plan) => plan.price > 0).toList();
    if (paidPlans.length == 2 &&
        paidPlans.every((plan) => plan.interval == paidPlans.first.interval)) {
      paidPlans.sort((a, b) => a.price.compareTo(b.price));
      var monthlySource = paidPlans.last;
      var yearlySource = paidPlans.first;

      final lower = paidPlans.first;
      final higher = paidPlans.last;
      if (higher.price >= lower.price * 3) {
        monthlySource = lower;
        yearlySource = higher;
      }
      if (_looksYearly(lower.name) && !_looksYearly(higher.name)) {
        monthlySource = higher;
        yearlySource = lower;
      } else if (_looksYearly(higher.name) && !_looksYearly(lower.name)) {
        monthlySource = lower;
        yearlySource = higher;
      }
      if (_looksMonthly(lower.name) && !_looksMonthly(higher.name)) {
        monthlySource = lower;
        yearlySource = higher;
      } else if (_looksMonthly(higher.name) && !_looksMonthly(lower.name)) {
        monthlySource = higher;
        yearlySource = lower;
      }

      final monthly = monthlySource.copyWith(interval: 'month');
      final yearly = yearlySource.copyWith(interval: 'year');
      for (var i = 0; i < normalized.length; i += 1) {
        final plan = normalized[i];
        if (plan.id == monthly.id) {
          normalized[i] = monthly;
        } else if (plan.id == yearly.id) {
          normalized[i] = yearly;
        }
      }
    }

    normalized.sort(_planSortComparator);
    return normalized;
  }

  int _planSortComparator(PlanModel a, PlanModel b) {
    final rankA = _intervalRank(a.interval);
    final rankB = _intervalRank(b.interval);
    if (rankA != rankB) {
      return rankA.compareTo(rankB);
    }
    return a.price.compareTo(b.price);
  }

  int _intervalRank(String interval) {
    final normalized = interval.toLowerCase();
    if (normalized.startsWith('month')) return 0;
    if (normalized.startsWith('year')) return 1;
    return 2;
  }

  bool _looksYearly(String value) {
    final normalized = value.toLowerCase();
    return normalized.contains('year') ||
        normalized.contains('annual') ||
        normalized.contains('annually');
  }

  bool _looksMonthly(String value) {
    final normalized = value.toLowerCase();
    return normalized.contains('month') || normalized.contains('monthly');
  }
}
