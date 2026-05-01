import 'dart:html' as html;
import 'package:dio/dio.dart';
import 'device_id.dart';

class StoriesService {
  final _dio = Dio();

  Future<String> getStoryText(String storyId) async {
    final id = await DeviceId.get();
    final response = await _dio.get(
      '${html.window.location.origin}/api/get-story',
      queryParameters: {'id': storyId},
      options: Options(headers: {'x-device-id': id}),
    );
    return response.data['text'] as String;
  }
}
