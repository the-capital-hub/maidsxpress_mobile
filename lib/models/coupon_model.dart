class Coupon {
  final String code;
  final String discountType;
  final num discountValue;

  Coupon({
    required this.code,
    required this.discountType,
    required this.discountValue,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      code: json['code']?.toString() ?? '',
      discountType: json['discountType']?.toString() ?? '',
      discountValue: json['discountValue'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'discountType': discountType,
        'discountValue': discountValue,
      };
}

class ApplyCouponResult {
  final bool status;
  final num discountAmount;
  final num discountedTotal;
  final Coupon coupon;

  ApplyCouponResult({
    required this.status,
    required this.discountAmount,
    required this.discountedTotal,
    required this.coupon,
  });

  factory ApplyCouponResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return ApplyCouponResult(
      status: json['status'] == true,
      discountAmount: data['discountAmount'] ?? 0,
      discountedTotal: data['discountedTotal'] ?? 0,
      coupon: Coupon.fromJson((data['coupon'] as Map<String, dynamic>? ?? {})),
    );
  }
}


