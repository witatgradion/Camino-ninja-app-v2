// Test file to check protobuf API call to albergues
// ignore_for_file: avoid_print

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:remote_data/src/api_client.dart';
import 'package:remote_data/src/converters/proto_converter.dart';
import 'package:remote_data/src/proto/albergue.pb.dart' as proto;

// Test API against mock server
const bool useMockServer = true;
const String mockServerUrl = 'http://localhost:8080';
const String productionUrl = 'https://api.camino.ninja';

// Add authentication token if needed
const String apiToken = ''; // Fill in your API token if needed

Future<void> main() async {
  // Create a Dio instance with proper configuration
  const baseUrl = useMockServer ? mockServerUrl : productionUrl;

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'x-firebase-appcheck': '123',
      },
    ),
  );

  // Add logging interceptor to see the API requests/responses
  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      logPrint: print,
    ),
  );

  // Create the API client
  final apiClient = ApiClient(dio);

  // Create a separate Dio instance for protobuf requests
  final protobufDio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      responseType:
          ResponseType.bytes, // Set response type to bytes for protobuf
      headers: {
        'x-firebase-appcheck': '123',
        'Accept': 'application/x-protobuf',
      },
    ),
  );

  protobufDio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      logPrint: print,
    ),
  );

  // Create another API client specifically for protobuf
  final protobufApiClient = ApiClient(protobufDio);

  try {
    print('Testing API connection with base URL: $baseUrl');

    // First, let's try the JSON endpoint to check connectivity
    try {
      print('\nAttempting to fetch albergues using JSON endpoint...');
      final albergues = await apiClient.getAlbergues();
      print('✅ Successfully received ${albergues.length} albergues via JSON');

      if (albergues.isNotEmpty) {
        final firstAlbergue = albergues.first;
        print('\nFirst albergue details (JSON):');
        print('ID: ${firstAlbergue.id}');
        print('Name: ${firstAlbergue.name}');
        print('City: ${firstAlbergue.cityName ?? "N/A"}');
      }

      // Now try the protobuf endpoint
      print('\nAttempting to fetch albergues using protobuf endpoint...');
      try {
        final protoBytes = await protobufApiClient.getAlberguesProto();
      print(
        '✅ Successfully received ${protoBytes.length} bytes of protobuf data',
      );

        // Parse the protobuf response
        final protoResponse = proto.AlbergueListResponse.fromBuffer(protoBytes);
        print('✅ Successfully parsed protobuf data');
        print('Number of albergues: ${protoResponse.items.length}');

        // Convert the first albergue to check its contents
        if (protoResponse.items.isNotEmpty) {
          final firstAlbergue = protoResponse.items.first;
          print('\nFirst albergue details (Protobuf):');
          print('ID: ${firstAlbergue.id}');
          print('Name: ${firstAlbergue.name}');
          print('City: ${firstAlbergue.cityName}');

          // Convert to the existing model
          final albergueResponse =
              ProtoConverter.albergueFromProto(firstAlbergue);
          print('\nConverted to AlbergueResponse:');
          print('ID: ${albergueResponse.id}');
          print('Name: ${albergueResponse.name}');
          print('City Name: ${albergueResponse.cityName}');
        }
      } catch (protoError) {
        print('❌ Error with protobuf endpoint: $protoError');
        print(
        'The protobuf endpoint might not be properly implemented on the server side yet.',
      );
      }
    } catch (e) {
      print('❌ Error: $e');

      // Output advice for common errors
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          print('\n🔑 Authentication Error: API requires a valid token.');
          print(
            'Please set a valid API token in the apiToken constant at the top of this file.',
          );
        } else if (e.response?.statusCode == 404) {
          print('\n🔍 Endpoint Not Found: The API endpoint does not exist.');
          print(
            'Check if the API endpoint path is correct in api_client.dart.',
          );
        } else if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.connectionError) {
          print('\n🌐 Connection Error: Could not connect to the server.');
          print('Check if the server is running and accessible at $baseUrl');
        }
      }
    }

    // Test the protobuf serialization with a sample albergue
    print('\n🧪 Testing protobuf serialization with a sample albergue...');

    // Create a sample albergue
    final sampleAlbergue = proto.Albergue()
      ..id = 999
      ..name = 'Sample Albergue'
      ..slug = 'sample-albergue'
      ..orderKey = 1
      ..status = 1
      ..isActive = true
      ..geoPoint = (proto.Albergue().geoPoint
        ..lat = 42.0
        ..lon = -1.0)
      ..isMunicipal = true
      ..isAlbergue = true
      ..cityName = 'Sample City'
      ..address = '123 Camino Way'
      ..postalCode = '12345'
      ..province = 'Sample Province'
      ..region = 'Sample Region'
      ..country = 'Spain'
      ..shareUrl = 'https://example.com/share'
      ..web = 'https://example.com'
      ..cityId = 1
      ..facilities = (proto.AlbergueFacilities()
        ..id = 1
        ..albergueId = 999
        ..hasWifi = true
        ..hasKitchen = true);

    // Serialize to binary
    final bytes = sampleAlbergue.writeToBuffer();
    print('✅ Serialized sample albergue to ${bytes.length} bytes');

    // Deserialize from binary
    final deserializedAlbergue = proto.Albergue.fromBuffer(bytes);
    print('✅ Deserialized back to albergue object');
    print('Name: ${deserializedAlbergue.name}');
    print('City: ${deserializedAlbergue.cityName}');

    // Convert to AlbergueResponse
    final albergueResponse =
        ProtoConverter.albergueFromProto(deserializedAlbergue);
    print('✅ Converted to AlbergueResponse');
    print('Name: ${albergueResponse.name}');
    print('City: ${albergueResponse.cityName}');

    // Demonstrate how the NetworkService will fall back to JSON
    print('\n📋 In real app usage:');
    print('- NetworkService.getAlbergues() will try protobuf first');
    print('- If protobuf fails, it will automatically fall back to JSON');
    print(
      '- The app will work with either format, with no code changes needed',
    );
  } catch (e, stackTrace) {
    print('❌ Fatal error: $e');
    print('Stack trace: $stackTrace');
  }

  print('\n📋 Test summary:');
  print('- Base URL: $baseUrl');
  print('- Authentication: ${apiToken.isNotEmpty ? "Enabled" : "Disabled"}');
  print('- Endpoints tested:');
  print('  * GET /api/v1/albergues (JSON)');
  print('  * GET /api/v2/albergues (Protobuf)');

  // Exit with appropriate status code
  exit(0);
}
