import 'package:flutter/foundation.dart';
import '../models/membership.dart';

class MembershipProvider extends ChangeNotifier {
  Membership _membership = const Membership(tier: MembershipTier.basic);

  Membership get membership => _membership;
  
  bool get isPremium => _membership.isPremium && _membership.isActive && !_membership.isExpired;
  bool get isBasic => _membership.isBasic;
  bool get isExpired => _membership.isExpired;

  void setMembership(Membership membership) {
    _membership = membership;
    notifyListeners();
  }

  void upgradeToPremium({
    required String transactionId,
    DateTime? expiryDate,
  }) {
    _membership = _membership.copyWith(
      tier: MembershipTier.premium,
      transactionId: transactionId,
      expiryDate: expiryDate,
      isActive: true,
    );
    notifyListeners();
  }

  void downgradeToBasic() {
    _membership = const Membership(tier: MembershipTier.basic);
    notifyListeners();
  }

  void renewPremium({
    required String transactionId,
    required DateTime newExpiryDate,
  }) {
    if (_membership.isPremium) {
      _membership = _membership.copyWith(
        transactionId: transactionId,
        expiryDate: newExpiryDate,
        isActive: true,
      );
      notifyListeners();
    }
  }

  void cancelMembership() {
    if (_membership.isPremium) {
      _membership = _membership.copyWith(
        isActive: false,
      );
      notifyListeners();
    }
  }

  // Simulate premium features availability
  bool canAccessPremiumFeatures() {
    return isPremium;
  }

  bool canCreateUnlimitedWorkouts() {
    return isPremium;
  }

  bool canAccessAdvancedAnalytics() {
    return isPremium;
  }

  bool canExportData() {
    return isPremium;
  }

  bool canAccessPremiumWorkouts() {
    return isPremium;
  }

  int getMaxWorkouts() {
    return isPremium ? -1 : 5; // -1 means unlimited
  }

  int getMaxExercisesPerWorkout() {
    return isPremium ? -1 : 10; // -1 means unlimited
  }
}
