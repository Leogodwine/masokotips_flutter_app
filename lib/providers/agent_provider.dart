import 'package:flutter/foundation.dart';
import '../models/agent.dart';
import '../services/agent_service.dart';
import '../utils/logger.dart';

class AgentProvider with ChangeNotifier {
  final AgentService _service = AgentService();

  AgentStats? _stats;
  Map<String, dynamic>? _agentInfo;
  List<AgentReferral> _referrals = [];
  List<AgentEarning> _earnings = [];
  bool _isLoading = false;
  String? _error;

  AgentStats? get stats => _stats;
  Map<String, dynamic>? get agentInfo => _agentInfo;
  List<AgentReferral> get referrals => _referrals;
  List<AgentEarning> get earnings => _earnings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get referralCode => _agentInfo?['referral_code'] as String?;

  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _service.getDashboard();
      if (res != null && res['success'] == true) {
        final data = res['data'] as Map<String, dynamic>;
        _agentInfo = data['agent'] as Map<String, dynamic>?;
        _stats = AgentStats.fromJson(
            (data['stats'] as Map<String, dynamic>?) ?? {});
      } else {
        _error = res?['message'] ?? 'Failed to load dashboard.';
      }
    } catch (e) {
      Log.e('AgentProvider.loadDashboard', e);
      _error = 'Connection error.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadReferrals() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _service.getReferrals();
      if (res != null && res['success'] == true) {
        _referrals = (res['data'] as List? ?? [])
            .map((j) => AgentReferral.fromJson(j as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      Log.e('AgentProvider.loadReferrals', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadEarnings() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _service.getEarnings();
      if (res != null && res['success'] == true) {
        _earnings = (res['data'] as List? ?? [])
            .map((j) => AgentEarning.fromJson(j as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      Log.e('AgentProvider.loadEarnings', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
