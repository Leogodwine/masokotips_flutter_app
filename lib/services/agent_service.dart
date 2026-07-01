import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/api_response.dart';
import '../utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AgentService {
  static String get _base => ApiConfig.baseUrl;

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return ApiConfig.getHeaders(token);
  }

  Future<Map<String, dynamic>?> getDashboard() async {
    try {
      final res = await http.get(
        Uri.parse('$_base/agent/dashboard'),
        headers: await _headers(),
      );
      return _safe(res);
    } catch (e) {
      Log.e('AgentService.getDashboard', e);
      return null;
    }
  }

  Future<Map<String, dynamic>?> getReferrals({int page = 1}) async {
    try {
      final res = await http.get(
        Uri.parse('$_base/agent/referrals?page=$page'),
        headers: await _headers(),
      );
      return _safe(res);
    } catch (e) {
      Log.e('AgentService.getReferrals', e);
      return null;
    }
  }

  Future<Map<String, dynamic>?> getEarnings({int page = 1}) async {
    try {
      final res = await http.get(
        Uri.parse('$_base/agent/earnings?page=$page'),
        headers: await _headers(),
      );
      return _safe(res);
    } catch (e) {
      Log.e('AgentService.getEarnings', e);
      return null;
    }
  }

  Map<String, dynamic>? _safe(http.Response res) {
    if (ApiResponse.looksLikeSecurityChallenge(res.body)) return null;
    try {
      return ApiResponse.decodeJson(res.body);
    } catch (_) {
      return null;
    }
  }
}
