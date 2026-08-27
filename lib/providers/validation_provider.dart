import 'package:flutter/foundation.dart';
import 'package:sate_ai/sate_ai.dart';
import '../services/validation_service.dart';

class ValidationProvider extends ChangeNotifier {
  final ValidationService _validationService;

  bool _isValidating = false;
  StressReport? _latestReport;
  String? _errorMessage;

  ValidationProvider(this._validationService);

  bool get isValidating => _isValidating;
  StressReport? get latestReport => _latestReport;
  String? get errorMessage => _errorMessage;

  Future<StressReport?> runValidation(String modelPath, {bool isPreTraining = true}) async {
    _isValidating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (isPreTraining) {
        _latestReport = await _validationService.runPreTrainingValidation(modelPath: modelPath);
      } else {
        _latestReport = await _validationService.runPostTrainingValidation(modelPath: modelPath);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isValidating = false;
      notifyListeners();
    }

    return _latestReport;
  }

  void clearReport() {
    _latestReport = null;
    _errorMessage = null;
    notifyListeners();
  }
}
