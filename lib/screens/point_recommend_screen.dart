import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PointRecommendScreen extends StatefulWidget {
  const PointRecommendScreen({Key? key}) : super(key: key);

  @override
  State<PointRecommendScreen> createState() => _PointRecommendScreenState();
}

class _PointRecommendScreenState extends State<PointRecommendScreen> {
  String location = "위치 불러오는 중...";
  String season = '';
  String timeOfDay = '';
  String pointRecommendation = '';

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    try {
      Position pos = await _determinePosition();
      final weather = await _getWeather(pos.latitude, pos.longitude);
      final address = await _getAddressFromLatLng(pos.latitude, pos.longitude);

      setState(() {
        location =
        '$address\n(${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)})\n$weather';
        season = _getSeason();
        timeOfDay = _getTimeOfDay();
        pointRecommendation = recommendPoint(
          weather: weather,
          season: season,
          timeOfDay: timeOfDay,
        );
      });
    } catch (e) {
      setState(() {
        location = '위치 가져오기 실패: $e';
      });
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('GPS가 꺼져있어요.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('위치 권한이 거부됐어요.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('위치 권한이 영구적으로 거부됐어요.');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("포인트 추천"),
        backgroundColor: const Color(0xFF80CBC4),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("📍 현재 위치", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(location, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text("🌸 계절: ", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(season),
                        const SizedBox(width: 16),
                        const Text("🕒 시간대: ", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(timeOfDay),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              color: const Color(0xFFE0F2F1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("🎯 추천 포인트", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(pointRecommendation, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.explore, color: Colors.white),
              label: const Text("다시 추천 받기", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF80CBC4),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _loadLocation,
            ),
          ],
        ),
      ),
    );
  }
}

// ==============================
// 카카오 주소 변환 API
// ==============================
Future<String> _getAddressFromLatLng(double lat, double lon) async {
  const String kakaoApiKey = '1540a558d6f6c8c6de661572c7ca8b1c';

  final url = Uri.parse(
    'https://dapi.kakao.com/v2/local/geo/coord2address.json?x=$lon&y=$lat',
  );

  final response = await http.get(
    url,
    headers: {'Authorization': 'KakaoAK $kakaoApiKey'},
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final documents = data['documents'];
    if (documents != null && documents.isNotEmpty) {
      return documents[0]['address']['address_name'];
    } else {
      return '주소 정보 없음';
    }
  } else {
    return '카카오 주소 요청 실패 (${response.statusCode})';
  }
}

// ==============================
// 날씨 API 호출
// ==============================
Future<String> _getWeather(double lat, double lon) async {
  const apiKey = '82aa31b38da94614058c97faeb65aaab';
  final url = Uri.parse(
    'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
  );

  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final temp = data['main']['temp'];
    final desc = data['weather'][0]['description'];
    return '현재 $temp°C, $desc';
  } else {
    throw Exception('날씨 정보를 불러오지 못했습니다');
  }
}

// ==============================
// 계절 판별
// ==============================
String _getSeason() {
  final month = DateTime.now().month;

  if (month >= 3 && month <= 5) return '봄';
  if (month >= 6 && month <= 8) return '여름';
  if (month >= 9 && month <= 11) return '가을';
  return '겨울';
}

// ==============================
// 시간대 판별
// ==============================
String _getTimeOfDay() {
  final hour = DateTime.now().hour;

  if (hour >= 5 && hour < 12) return '아침';
  if (hour >= 12 && hour < 17) return '낮';
  if (hour >= 17 && hour < 20) return '저녁';
  return '밤';
}

// ==============================
// 추천 포인트 로직
// ==============================
String recommendPoint({
  required String weather,
  required String season,
  required String timeOfDay,
}) {
  if (season == '봄' && timeOfDay == '아침' && weather.contains('맑')) {
    return '수초 근처 얕은 곳을 공략해보세요 🌿';
  } else if (season == '여름' && timeOfDay == '낮' && weather.contains('흐')) {
    return '그늘진 구조물 근처를 공략해보세요 🏚️';
  } else if (season == '가을' && weather.contains('비')) {
    return '유입수 근처나 수로가 좋습니다 🌊';
  } else if (timeOfDay == '저녁' && weather.contains('맑')) {
    return '쉘로우와 딥 경계 지점을 노려보세요 📉';
  } else if (season == '겨울') {
    return '해질 무렵 깊은 수심을 공략하세요 ❄️';
  } else {
    return '기본 포인트를 공략해보세요 (수초, 구조물 주변 등)';
  }
}
