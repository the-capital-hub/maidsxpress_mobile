import 'package:get/get.dart' hide FormData;
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../../models/coupon_model.dart';
import '../../utils/constant/const_data.dart';
import '../../utils/helper/helper_sncksbar.dart';
import '../../utils/logger.dart';

class CouponController extends GetxController {
  final _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    sendTimeout: const Duration(seconds: 10),
  ));
  final _storage = GetStorage();

  final RxBool isApplying = false.obs;
  final Rx<ApplyCouponResult?> applied = Rx<ApplyCouponResult?>(null);

  String? get _authToken => _storage.read('token');

  @override
  void onInit() {
    super.onInit();
    _dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      final token = _authToken;
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      options.headers['Content-Type'] = 'application/json';
      handler.next(options);
    }));
  }

  Future<ApplyCouponResult?> applyCoupon({
    required String code,
    required num totalAmount,
  }) async {
    try {
      isApplying.value = true;
      Logger.info('applyCoupon: code=$code amount=$totalAmount', name: 'Coupon');

      final resp = await _dio.post(
        ApiConstants.applyCoupon,
        data: {
          'code': code,
          'amount': totalAmount,
        },
        options: Options(
          validateStatus: (s) => s != null && s < 500,
          contentType: Headers.formUrlEncodedContentType,
          headers: {'Accept': 'application/json'},
        ),
      );

      if (resp.statusCode == 200) {
        final map = resp.data is Map<String, dynamic>
            ? resp.data as Map<String, dynamic>
            : Map<String, dynamic>.from(resp.data);
        final result = ApplyCouponResult.fromJson(map);
        applied.value = result;
        return result;
      }

      // Show server message if provided
      if (resp.data is Map && (resp.data as Map).containsKey('message')) {
        final msg = (resp.data as Map)['message']?.toString();
        if (msg != null && msg.isNotEmpty) {
          HelperSnackBar.error(msg);
        }
      } else {
        HelperSnackBar.error('Failed to apply coupon. Please check the code.');
      }
      return null;
    } catch (e) {
      Logger.error('applyCoupon error: $e', name: 'Coupon', error: e);
      HelperSnackBar.error(e.toString());
      return null;
    } finally {
      isApplying.value = false;
    }
  }
}


