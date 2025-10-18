enum MembershipTier {
  basic,
  premium,
}

class Membership {
  final MembershipTier tier;
  final DateTime? expiryDate;
  final bool isActive;
  final String? transactionId;

  const Membership({
    required this.tier,
    this.expiryDate,
    this.isActive = true,
    this.transactionId,
  });

  bool get isPremium => tier == MembershipTier.premium;
  bool get isBasic => tier == MembershipTier.basic;
  
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  String get displayName {
    switch (tier) {
      case MembershipTier.basic:
        return 'Basic';
      case MembershipTier.premium:
        return 'Premium';
    }
  }

  String get description {
    switch (tier) {
      case MembershipTier.basic:
        return 'Free tier with basic features';
      case MembershipTier.premium:
        return 'Unlock all features and premium content';
    }
  }

  Map<String, dynamic> toJson() => {
    'tier': tier.name,
    'expiryDate': expiryDate?.toIso8601String(),
    'isActive': isActive,
    'transactionId': transactionId,
  };

  factory Membership.fromJson(Map<String, dynamic> json) => Membership(
    tier: MembershipTier.values.firstWhere(
      (e) => e.name == json['tier'],
      orElse: () => MembershipTier.basic,
    ),
    expiryDate: json['expiryDate'] != null 
        ? DateTime.parse(json['expiryDate']) 
        : null,
    isActive: json['isActive'] ?? true,
    transactionId: json['transactionId'],
  );

  Membership copyWith({
    MembershipTier? tier,
    DateTime? expiryDate,
    bool? isActive,
    String? transactionId,
  }) => Membership(
    tier: tier ?? this.tier,
    expiryDate: expiryDate ?? this.expiryDate,
    isActive: isActive ?? this.isActive,
    transactionId: transactionId ?? this.transactionId,
  );
}
