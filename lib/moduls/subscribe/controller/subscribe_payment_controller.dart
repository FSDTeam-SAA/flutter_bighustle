import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/api_handler/failure.dart';
import '../../../core/api_handler/success.dart';
import '../../../core/notifiers/snackbar_notifier.dart';
import '../../../core/services/app_pigeon/app_pigeon.dart';
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

  Future<bool> submitSubscription({
    required SnackbarNotifier snackbarNotifier,
  }) async {
    snackbarNotifier.notify(
      message: 'Subscription checkout is disabled in this build.',
    );
    return false;
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
    final fetchedPlans = success.data ?? <PlanModel>[];
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
    for (final plan in plans) {
      if (plan.id != current?.id && plan.price > 0) {
        return plan;
      }
    }
    return current ?? plans.first;
  }

  void _setLoadingPlans(bool value) {
    if (_isLoadingPlans == value) return;
    _isLoadingPlans = value;
    notifyListeners();
  }

  void _setSubmitting(bool value) {
    if (_isSubmitting == value) return;
    _isSubmitting = value;
    notifyListeners();
  }
}
