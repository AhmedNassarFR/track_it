import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {
  /// 'kg' or 'lbs'
  var weightUnit = 'kg'.obs;

  static const double _kgToLbs = 2.20462;

  @override
  void onInit() {
    super.onInit();
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    weightUnit.value = prefs.getString('weight_unit') ?? 'kg';
  }

  Future<void> setUnit(String unit) async {
    weightUnit.value = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('weight_unit', unit);
  }

  /// Convert a stored kg value to the user's preferred display unit.
  double displayWeight(double kgValue) {
    if (weightUnit.value == 'lbs') {
      return kgValue * _kgToLbs;
    }
    return kgValue;
  }

  /// Formatted display string: e.g. "80 kg" or "176 lbs"
  String displayWeightWithUnit(double kgValue) {
    final converted = displayWeight(kgValue);
    final formatted =
        converted % 1 == 0 ? converted.toInt().toString() : converted.toStringAsFixed(1);
    return '$formatted ${weightUnit.value}';
  }

  /// The "other" unit string for subtitle display
  String secondaryWeightWithUnit(double kgValue) {
    if (weightUnit.value == 'lbs') {
      // Primary is lbs, secondary is kg
      final formatted =
          kgValue % 1 == 0 ? kgValue.toInt().toString() : kgValue.toStringAsFixed(1);
      return '$formatted kg';
    } else {
      // Primary is kg, secondary is lbs
      final lbs = kgValue * _kgToLbs;
      final formatted =
          lbs % 1 == 0 ? lbs.toInt().toString() : lbs.toStringAsFixed(1);
      return '$formatted lbs';
    }
  }

  /// Convert user input (in the current unit) back to kg for storage.
  double toKg(double inputValue) {
    if (weightUnit.value == 'lbs') {
      return inputValue / _kgToLbs;
    }
    return inputValue;
  }

  /// Convert a stored kg value to the current unit for editing.
  double fromKg(double kgValue) {
    return displayWeight(kgValue);
  }

  /// Unit label for input hints
  String get unitLabel => weightUnit.value;
}
