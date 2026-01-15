import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/alert/dialog.dart';
import 'package:front/screen/myPage_screen/login/provider/auth_provider.dart';
import 'package:front/data/data_source/local/wazzup_token_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref);
});
class ApiClient {
  Ref ref;
  ApiClient(this.ref);

  // dotenv.env의 api url = 10.0.2.2:8080 으로 고정
  final String baseUrl = "${dotenv.env["API_URL"]}";
  final WazzupTokenStorage _storage = WazzupTokenStorage();

  // 토큰을 미리 받아서 메모리에 넣어두자
  String? _cachedAccessToken;
  
  Future<void> loadTokenToMemory() async {
    _cachedAccessToken = await _storage.getAccessToken();
  }

  Map<String, String> get _baseHeaders => {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  // POST 요청*************************************************************************
  Future<http.Response> post(String path, {Object? body}) async {
    String url = '$baseUrl$path';
    String? accessToken = await _getValidToken();
  
    var response = await http.post(
      Uri.parse(url),
      headers: {
        ..._baseHeaders,
        if (accessToken != null)
          'Authorization': 'Bearer $accessToken',
      },
      body: body != null ? jsonEncode(body) : null,
    );

    // 401이나 403 에러를 뱉는다면
    if (response.statusCode == 401 || response.statusCode == 403) {
      if (path.contains('/logout')) {
        print("[ApiClient] 로그아웃 중 토큰 만료 감지. 바로 로컬 로그아웃 처리.");
        _forceLogOut(ref);
        return response;
      }

      print("[ApiClient] 401 감지! 토큰 재발급 시도...");
      bool refreshed = await _refreshAccessToken();

      if (refreshed) {
        String? newAccessToken = _cachedAccessToken;
        print("[ApiClient] 재발급 성공. 원래 요청 재시도: $url");

        return await http.post(
          Uri.parse(url),
          headers: {
            ..._baseHeaders,
            if (newAccessToken != null)
              'Authorization': 'Bearer $newAccessToken',
          },
          body: body != null ? jsonEncode(body) : null,
        );
      }
    }
    return response;
  }

  Future<bool> _refreshAccessToken() async {
    try {
      // 1. 스토리지에서 리프레시 토큰 꺼내기
      String? refreshToken = await _storage.getRefreshToken();

      if (refreshToken == null) {
        print("[ApiClient] 리프레시 토큰이 없습니다.");
        return false;
      }

      // 2. 서버에 재발급 요청
      // 보통 Access Token은 헤더에, Refresh Token은 바디,
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/reissue'),
        headers: _baseHeaders,
        body: jsonEncode({'refreshToken': refreshToken}),
      );
    print('서버 응답: ${response.body}');
      if (response.statusCode == 200) {
        // 3. 재발급 성공 -> 새 토큰 저장
        final jsonResponse = jsonDecode(
          utf8.decode(response.bodyBytes),
        );

        final data = jsonResponse['data']; // 여기서 바로 Map으로 접근

        // AuthResponse 객체를 만들지 않고 토큰 값만 추출
        String newAt = data['wazzupToken'] ?? '';
        String newRt = data['refreshToken'] ?? '';

        _cachedAccessToken = newAt;

        // 토큰 전용 업데이트 메서드 호출
        await ref.read(authControllerProvider.notifier).updateTokensOnly(newAt, newRt);
        
        return true;
      } else {
        print("[ApiClient] 토큰 재발급 실패: ${response.statusCode}");
        // 실패 시 토큰 삭제 (로그아웃 처리)
        _forceLogOut(ref);
        return false;
      }
    } catch (e) {
      print("[ApiClient] 토큰 재발급 중 에러: $e");
      return false;
    }
  }

  void _forceLogOut(ref) async {
    await _storage.deleteAll();
    WazzupToast.showError('로그아웃 되었습니다.\n 다시 로그인 해주세요');
    ref.read(authControllerProvider.notifier).logout();
  }






  // GET 요청*************************************************************************
  Future<http.Response> get(String path) async {
    String url = '$baseUrl$path';

    String? accessToken = await _getValidToken();


    var response = await http.get(
      Uri.parse(url),
      headers: {
        ..._baseHeaders,
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 401 || response.statusCode == 403) {
      print("[ApiClient] 401 감지! 토큰 재발급 시도...");
      bool refreshed = await _refreshAccessToken();

      if (refreshed) {
        String? newToken = _cachedAccessToken;
        print("[ApiClient] 재발급 성공. 원래 요청 재시도: $url");

        return await http.get(
          Uri.parse(url),
          headers: {
            ..._baseHeaders,
            if (newToken != null)
              'Authorization': 'Bearer $newToken',
          },
        );
      } else {
        // 재발급 실패 (리프레시 토큰도 만료됨) -> 로그아웃 처리 필요
        print("[ApiClient] 리프레시 토큰도 만료됨. 재로그인 필요.");
      }
    }
    return response;
  }
  
  // multipart요청**********************************************************************************
  Future<http.Response> postMultipart(
    String path, {
    required Map<String, String> fields,
    required List<XFile> images,
  }) async {
    String url = '$baseUrl$path';
    String? accessToken = await _getValidToken();

    Future<http.MultipartRequest> createRequest(String? token) async {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      
      // 1. 헤더 설정
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // 2. 일반 필드 추가 (content 등)
      request.fields.addAll(fields);

      // 3. 이미지 파일 추가
      for (var image in images) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'images', // 서버에서 받는 파라미터명 (백엔드와 맞추세요)
            image.path,
          ),
        );
      }
      return request;
    }

    // 첫 번째 요청 전송
    var request = await createRequest(accessToken);
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    // 401/403 에러 처리 (기존 post와 동일한 로직)
    if (response.statusCode == 401 || response.statusCode == 403) {
      print("[ApiClient] 멀티파트 401 감지! 토큰 재발급 시도...");
      bool refreshed = await _refreshAccessToken();

      if (refreshed) {
        String? newAccessToken = _cachedAccessToken;
        // 재발급 성공 시 새로운 토큰으로 다시 요청 생성 및 전송
        var retryRequest = await createRequest(newAccessToken);
        var retryStreamedResponse = await retryRequest.send();
        return await http.Response.fromStream(retryStreamedResponse);
      }
    }

    return response;
  }

  // 만료 먼저 검사**********************************************************
  Future<String?> _getValidToken() async {

    // 1. 토큰이 없으면 그냥 null 리턴 (비회원 요청)
    if (_cachedAccessToken == null) {
        // 혹시 모르니 없으면 스토리지 한번 확인
        _cachedAccessToken = await _storage.getAccessToken();
        if (_cachedAccessToken == null) return null;
    }

    // 2. 토큰이 만료되었는지 확인 (JwtDecoder 사용)
    // isExpired()는 토큰의 'exp' 클레임을 확인해서 현재 시간과 비교합니다.
    bool isExpired = JwtDecoder.isExpired(_cachedAccessToken!);

    if (isExpired) {
      print("[ApiClient] 요청 전 토큰 만료 감지! 갱신 시도...");
      
      // 3. 만료됐으면 서버에 찌르기 전에 미리 갱신 시도
      bool refreshed = await _refreshAccessToken();
      
      if (refreshed) {
        // 갱신 성공했으면 새 토큰 리턴
        return _cachedAccessToken;
      } else {
        // 갱신 실패했으면 (리프레시 토큰도 만료 등) -> 로그아웃 처리 될 것임
        return null; 
      }
    }

    // 3. 만료 안 됐으면 기존 토큰 리턴
    return _cachedAccessToken;
  }

  
}
