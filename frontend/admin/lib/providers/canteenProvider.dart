import 'package:flutter/material.dart';
import '../services/canteen-service.dart';

class CanteenProvider with ChangeNotifier {
  List<dynamic> _canteens = [];
  bool isLoading = false;
  bool hasError = false;

  List<dynamic> get canteens => _canteens;

  Future<void> fetchCanteens(CanteenService canteenService) async {
    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      _canteens = await canteenService.getCanteens();
    } catch (e) {
      hasError = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCanteen({
    required CanteenService canteenService,
    required dynamic imageFile,
    required String name,
    required String collegeName,
    required String district,
    required String state,
    required String pinCode,
    required BuildContext context,
  }) async {
    var resData = await canteenService.addCanteen(
      imageFile: imageFile,
      name: name,
      collegeName: collegeName,
      district: district,
      state: state,
      pinCode: pinCode,
    );

    if (resData['isOk']) {
      await fetchCanteens(canteenService);
      return true;
    } else {
      return false;
    }
  }
}
