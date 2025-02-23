import 'package:flutter/material.dart';
import '../services/canteenService.dart';
import 'dart:io';

class CanteenProvider with ChangeNotifier {
  List<dynamic> _canteens = [];
  bool isLoading = false;
  bool hasError = false;
  final CanteenService _canteenService = CanteenService();
  List<dynamic> _managers = [];
  List<dynamic> get canteens => _canteens;
  List<dynamic> get managers => _managers;

  Future<void> fetchCanteens() async {
    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      _canteens = await _canteenService.getCanteens();
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
      await fetchCanteens();
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updateCanteen({
    required String canteenId,
    String? name,
    String? collegeName,
    String? district,
    String? state,
    String? pinCode,
    File? imageFile,
  }) async {
    var resData = await _canteenService.updateCanteen(
      canteenId: canteenId,
      name: name,
      collegeName: collegeName,
      district: district,
      state: state,
      pinCode: pinCode,
      imageFile: imageFile,
    );

    if (resData['isOk']) {
      await fetchCanteens();
      return true;
    } else {
      return false;
    }
  }

  Future<String> deleteCanteen({
    required String canteenId,
  }) async {
    var resData = await _canteenService.deleteCanteen(canteenId);

    if (resData['isOk']) {
      _canteens.removeWhere((canteen) => canteen['_id'] == canteenId);
      notifyListeners();
      return "Canteen deleted successfully.";
    } else {
      return resData['error'] ?? "Failed to delete canteen.";
    }
  }

  Future<void> fetchManagers() async {
    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      _managers = await _canteenService.getManagers();
    } catch (e) {
      hasError = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerManager({
    required String name,
    required String email,
    required String password,
    required String role,
    required String canteenId,
  }) async {
    var resData = await _canteenService.registerManager(
      name: name,
      email: email,
      password: password,
      role: role,
      canteenId: canteenId,
    );

    if (resData['isOk']) {
      await fetchManagers();
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updateManager({
    required String managerId,
    required String name,
    required String email,
    required String role,
    required String canteenId,
  }) async {
    var resData = await _canteenService.updateManager(
      managerId: managerId,
      name: name,
      email: email,
      role: role,
      canteenId: canteenId,
    );

    if (resData['isOk']) {
      await fetchManagers();
      return true;
    } else {
      return false;
    }
  }

  Future<String> deleteManager({required String managerId}) async {
    var resData = await _canteenService.deleteManager(managerId);
    print(resData);
    if (resData['isOk']) {
      _managers.removeWhere((manager) => manager['_id'] == managerId);
      notifyListeners();
      return "Manager deleted successfully.";
    } else {
      return resData['error'] ?? "Failed to delete manager.";
    }
  }
}
