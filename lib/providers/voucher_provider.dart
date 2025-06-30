import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cart_provider.dart';

class VoucherNotifier extends StateNotifier<VoucherState> {
  VoucherNotifier() : super(VoucherState());

  void applyVoucher(String code) {
    final discount = _getDiscountForCode(code);
    if (discount > 0) {
      state = state.copyWith(
        appliedCode: code,
        discountAmount: discount,
        isValid: true,
      );
    } else {
      state = state.copyWith(
        appliedCode: '',
        discountAmount: 0.0,
        isValid: false,
      );
    }
  }

  void removeVoucher() {
    state = VoucherState();
  }

  double _getDiscountForCode(String code) {
    // Mock voucher codes with different discounts
    final Map<String, double> voucherCodes = {
      'SAVE10': 10.0,
      'HEALTH20': 20.0,
      'FIRST5': 5.0,
      'WELLNESS15': 15.0,
      'NEWUSER': 25.0,
    };
    
    return voucherCodes[code.toUpperCase()] ?? 0.0;
  }
}

class VoucherState {
  final String appliedCode;
  final double discountAmount;
  final bool isValid;

  VoucherState({
    this.appliedCode = '',
    this.discountAmount = 0.0,
    this.isValid = false,
  });

  VoucherState copyWith({
    String? appliedCode,
    double? discountAmount,
    bool? isValid,
  }) {
    return VoucherState(
      appliedCode: appliedCode ?? this.appliedCode,
      discountAmount: discountAmount ?? this.discountAmount,
      isValid: isValid ?? this.isValid,
    );
  }
}

final voucherProvider = StateNotifierProvider<VoucherNotifier, VoucherState>((ref) {
  return VoucherNotifier();
});

final finalTotalProvider = Provider<double>((ref) {
  final cartTotal = ref.watch(cartTotalProvider);
  final voucher = ref.watch(voucherProvider);
  return (cartTotal - voucher.discountAmount).clamp(0.0, double.infinity);
});